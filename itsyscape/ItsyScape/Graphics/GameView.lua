--------------------------------------------------------------------------------
-- ItsyScape/Graphics/GameView.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local ActorView = require "ItsyScape.Graphics.ActorView"
local DecorationSceneNode = require "ItsyScape.Graphics.DecorationSceneNode"
local MapMeshSceneNode = require "ItsyScape.Graphics.MapMeshSceneNode"
local ModelResource = require "ItsyScape.Graphics.ModelResource"
local ModelSceneNode = require "ItsyScape.Graphics.ModelSceneNode"
local SceneNode = require "ItsyScape.Graphics.SceneNode"
local StaticMeshResource = require "ItsyScape.Graphics.StaticMeshResource"
local Renderer = require "ItsyScape.Graphics.Renderer"
local ResourceManager = require "ItsyScape.Graphics.ResourceManager"
local SpriteManager = require "ItsyScape.Graphics.SpriteManager"
local ShaderResource = require "ItsyScape.Graphics.ShaderResource"
local TextureResource = require "ItsyScape.Graphics.TextureResource"
local WaterMeshSceneNode = require "ItsyScape.Graphics.WaterMeshSceneNode"
local TileSet = require "ItsyScape.World.TileSet"

local GameView = Class()
GameView.MAP_MESH_DIVISIONS = 16

function GameView:new(game)
	self.game = game
	self.actors = {}
	self.props = {}

	local stage = game:getStage()
	self._onLoadMap = function(_, map, layer, tileSetID)
		self:addMap(map, layer, tileSetID)
	end
	stage.onLoadMap:register(self._onLoadMap)

	self._onUnloadMap = function(_, map, layer)
		self:removeMap(layer)
	end
	stage.onUnloadMap:register(self._onUnloadMap)

	self._onMapModified = function(_, map, layer)
		self:updateMap(map, layer)
	end
	stage.onMapModified:register(self._onMapModified)

	self._onActorSpawned = function(_, actorID, actor)
		self:addActor(actorID, actor)
	end
	stage.onActorSpawned:register(self._onActorSpawned)

	self._onActorKilled = function(_, actor)
		self:removeActor(actor)
	end
	stage.onActorKilled:register(self._onActorKilled)

	self._onPropPlaced = function(_, propID, prop)
		self:addProp(propID, prop)
	end
	stage.onPropPlaced:register(self._onPropPlaced)

	self._onPropRemoved = function(_, prop)
		self:removeProp(prop)
	end
	stage.onPropRemoved:register(self._onPropRemoved)

	self._onDropItem = function(_, item, tile, position)
		self:spawnItem(item, tile, position)
	end
	stage.onDropItem:register(self._onDropItem)

	self._onTakeItem = function(_, item)
		self:poofItem(item)
	end
	stage.onTakeItem:register(self._onTakeItem)

	self._onDecorate = function(_, group, decoration)
		self:decorate(group, decoration)
	end
	stage.onDecorate:register(self._onDecorate)

	self._onWaterFlood = function(_, key, water)
		self:flood(key, water)
	end
	stage.onWaterFlood:register(self._onWaterFlood)

	self._onWaterDrain = function(_, key, water)
		self:drain(key, water)
	end
	stage.onWaterDrain:register(self._onWaterDrain)

	self.scene = SceneNode()
	self.mapMeshes = {}

	self.water = {}

	self.decorations = {}

	self.renderer = Renderer(love.system.getOS() == "Android" or _ARGS["mobile"])
	self.resourceManager = ResourceManager()
	self.spriteManager = SpriteManager(self.resourceManager)

	self.itemBagModel = self.resourceManager:load(
		ModelResource,
		"Resources/Game/Items/ItemBag.lmesh")
	self.itemBagIconModel = self.resourceManager:load(
		ModelResource,
		"Resources/Game/Items/ItemBagIcon.lmesh")
	self.items = {}

	local imageData = love.image.newImageData(1, 1)
	imageData:setPixel(0, 0, 1, 1, 1, 1)
	self.whiteTexture = TextureResource(love.graphics.newImage(imageData))
end

function GameView:getGame()
	return self.game
end

function GameView:getRenderer()
	return self.renderer
end

function GameView:getResourceManager()
	return self.resourceManager
end

function GameView:getSpriteManager()
	return self.spriteManager
end

function GameView:getScene()
	return self.scene
end

function GameView:release()
	for _, actor in pairs(self.actors) do
		actor:release()
	end

	local stage = game:getStage()
	stage.onLoadMap:unregister(self._onLoadMap)
	stage.onUnloadMap:unregister(self._onUnloadMap)
	stage.onMapModified:unregister(self._onMapModified)
	stage.onActorSpawned:unregister(self.onActorSpawned)
	stage.onActorKilled:unregister(self._onActorKilled)
	stage.onPropPlaced:unregister(self._onPropPlaced)
	stage.onPropRemoved:unregister(self._onPropRemoved)
	stage.onTakeItem:unregister(self._onTakeItem)
	stage.onDropItem:unregister(self._onDropItem)
	stage.onDecorate:unregister(self._onDecorate)
	stage.onWaterFlood:unregister(self._onWaterFlood)
	stage.onWaterDrain:unregister(self._onWaterDrain)
end

function GameView:addMap(map, layer, tileSetID)
	local tileSetFilename = string.format(
		"Resources/Game/TileSets/%s/Layout.lua",
		tileSetID or "GrassyPlain")
	local tileSet, texture = TileSet.loadFromFile(tileSetFilename, true)

	if self.mapMeshes[layer] then
		self:removeMap(layer)
	end

	local m = {
		tileSet = tileSet,
		texture = texture,
		tileSetID = tileSetID or "GrassyPlain",
		map = map,
		node = SceneNode(),
		parts = {}
	}
	m.node:setParent(self.scene)

	self.mapMeshes[layer] = m
end

function GameView:removeMap(layer)
	local m = self.mapMeshes[layer]
	if m then
		m.node:setParent(nil)

		for i = 1, #m.parts do
			m.parts[i]:setMapMesh(nil)
		end

		self.mapMeshes[layer] = nil
	end
end

function GameView:updateMap(map, layer)
	local m = self.mapMeshes[layer]
	if m then
		if map then
			m.map = map
		end

		for i = 1, #m.parts do
			m.parts[i]:setParent(nil)
			m.parts[i]:setMapMesh(nil)
		end
		m.parts = {}

		local w, h
		do
			local E = 1 / GameView.MAP_MESH_DIVISIONS
			local partialX = map:getWidth() / GameView.MAP_MESH_DIVISIONS
			local partialY = map:getHeight() / GameView.MAP_MESH_DIVISIONS

			w = math.floor(partialX)
			h = math.floor(partialY)

			if partialX - math.floor(partialX) >= E then
				w = w + 1
			end

			if partialY - math.floor(partialY) >= E then
				h = h + 1
			end
		end

		for j = 1, h do
			for i = 1, w do
				local x = (i - 1) * GameView.MAP_MESH_DIVISIONS + 1
				local y = (j - 1) * GameView.MAP_MESH_DIVISIONS + 1

				local node = MapMeshSceneNode()
				node:setParent(m.node)
				table.insert(m.parts, node)
				self.resourceManager:queueEvent(function()
					node:fromMap(
						m.map,
						m.tileSet,
						x, y,
						GameView.MAP_MESH_DIVISIONS,
						GameView.MAP_MESH_DIVISIONS)
					node:getMaterial():setTextures(m.texture)
				end)
			end
		end
	end
end

function GameView:getMapSceneNode(layer)
	local m = self.mapMeshes[layer]
	if m then
		return m.node
	end
end

function GameView:getMapTileSet(layer)
	local m = self.mapMeshes[layer]
	if m then
		return m.tileSet, m.tileSetID
	end
end

function GameView:addActor(actorID, actor)
	local view = ActorView(actor, actorID)
	view:attach(self)

	self.actors[actor] = view
end

function GameView:getActor(actor)
	return self.actors[actor]
end

function GameView:removeActor(actor)
	if self.actors[actor] then
		self.actors[actor]:poof()
		self.actors[actor] = nil
	end
end

function GameView:hasActor(actor)
	return self.actors[actor] ~= nil
end

function GameView:addProp(propID, prop)
	local PropViewTypeName = string.format("Resources.Game.Props.%s.View", propID, propID)
	local PropView = require(PropViewTypeName)
	local view = PropView(prop, self)
	view:attach()
	view:load()

	self.props[prop] = view
end

function GameView:removeProp(prop)
	if self.props[prop] then
		self.props[prop]:remove()
		self.props[prop] = nil
	end
end

function GameView:spawnItem(item, tile, position)
	local map = self.game:getStage():getMap(tile.layer)
	if map then
		position.y = map:getInterpolatedHeight(position.x, position.z)
	end

	local itemNode = SceneNode()
	do
		local lootBagNode = ModelSceneNode()
		lootBagNode:setModel(self.itemBagModel)
		lootBagNode:getMaterial():setShader(ModelSceneNode.STATIC_SHADER)
		lootBagNode:getMaterial():setTextures(self.whiteTexture)
		lootBagNode:setParent(itemNode)
	end
	do
		local lootIconNode = ModelSceneNode(self.itemBagIconModel)
		lootIconNode:setModel(self.itemBagIconModel)

		local texture = self.resourceManager:queue(
			TextureResource,
			string.format("Resources/Game/Items/%s/Icon.png", item.id),
			function(texture)
				lootIconNode:getMaterial():setTextures(texture)
			end)

		lootIconNode:getMaterial():setShader(ModelSceneNode.STATIC_SHADER)
		lootIconNode:setParent(itemNode)
		lootIconNode:setParent(itemNode)
	end

	itemNode:getTransform():translate(position)
	itemNode:setParent(self.scene)

	self.items[item.ref] = itemNode
end

function GameView:poofItem(item)
	local node = self.items[item.ref]
	if node then
		node:setParent(nil)

		self.items[item.ref] = nil
	end
end

function GameView:decorate(group, decoration)
	if self.decorations[group] then
		self.decorations[group].node:setParent(nil)
		self.decorations[group] = nil
	end

	if decoration then
		local tileSetFilename = string.format(
			"Resources/Game/TileSets/%s/Layout.lstatic",
			decoration:getTileSetID())
		local staticMesh = self.resourceManager:load(
			StaticMeshResource,
			tileSetFilename)

		local textureFilename = string.format(
			"Resources/Game/TileSets/%s/Texture.png",
			decoration:getTileSetID())
		local texture = self.resourceManager:load(
			TextureResource,
			textureFilename)

		local sceneNode = DecorationSceneNode()
		sceneNode:fromDecoration(decoration, staticMesh:getResource())
		sceneNode:getMaterial():setTextures(texture)

		sceneNode:setParent(self.scene)

		self.decorations[group] = { node = sceneNode, decoration = decoration }
	end
end

function GameView:flood(key, water)
	self:drain(key)

	local node = WaterMeshSceneNode()
	local map = self.game:getStage():getMap(water.layer or 1)
	node:generate(
		map,
		water.i or 1,
		water.j or 1,
		water.width or (map:getWidth() - ((water.i or 1) - 1) + 1),
		water.height or (map:getHeight() - ((water.j or 1) - 1) + 1),
		water.y,
		water.finesse)
	if water.isTranslucent then
		node:getMaterial():setIsTranslucent(true)
	end

	self.resourceManager:queue(
		TextureResource,
		string.format("Resources/Game/Water/%s/Texture.png", water.texture or "LightFoamyWater1"),
		function(resource)
			node:getMaterial():setTextures(resource)
			node:setParent(self.scene)
		end)


	self.water[key] = node
end

function GameView:drain(key)
	if self.water[key] then
		self.water[key]:setParent(nil)
		self.water[key]:degenerate()
		self.water[key] = nil
	end
end

function GameView:getDecorations()
	local result = {}
	local count = 0
	for k, v in pairs(self.decorations) do
		result[k] = v.decoration
		count = count + 1
	end

	return result, count
end

function GameView:update(delta)
	self.resourceManager:update()

	for _, actor in pairs(self.actors) do
		actor:update(delta)
	end

	for _, prop in pairs(self.props) do
		prop:update(delta)
	end

	self.spriteManager:update(delta)
end

function GameView:tick()
	self.scene:tick()

	for _, prop in pairs(self.props) do
		prop:tick()
	end
end

return GameView
