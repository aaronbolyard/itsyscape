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
local Vector = require "ItsyScape.Common.Math.Vector"
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
local WeatherMap = require "ItsyScape.World.WeatherMap"

local GameView = Class()
GameView.MAP_MESH_DIVISIONS = 16

function GameView:new(game)
	self.game = game
	self.actors = {}
	self.props = {}
	self.views = {}

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

	self._onMapMoved = function(_, layer, position, rotation, scale, offset, disabled)
		self:moveMap(layer, position, rotation, scale, offset, disabled)
	end
	stage.onMapMoved:register(self._onMapMoved)

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

	self._onDecorate = function(_, group, decoration, layer)
		self:decorate(group, decoration, layer)
	end
	stage.onDecorate:register(self._onDecorate)

	self._onWaterFlood = function(_, key, water, layer)
		self:flood(key, water, layer)
	end
	stage.onWaterFlood:register(self._onWaterFlood)

	self._onWaterDrain = function(_, key, water)
		self:drain(key, water)
	end
	stage.onWaterDrain:register(self._onWaterDrain)

	self._onForecast = function(_, layer, key, id, props)
		self:forecast(layer, key, nil)
		self:forecast(layer, key, id, props)
	end
	stage.onForecast:register(self._onForecast)

	self._onProjectile = function(_, projectileID, source, destination, time)
		self:fireProjectile(projectileID, source, destination, time)
	end
	stage.onProjectile:register(self._onProjectile)

	self._onPlayMusic = function(_, track, song)
		self:playMusic(track, song)
	end
	stage.onPlayMusic:register(self._onPlayMusic)

	self._onStopMusic = function(_, track, song)
		self:playMusic(track, false)
	end
	stage.onStopMusic:register(self._onStopMusic)

	self.scene = SceneNode()
	self.mapMeshes = {}

	self.music = {}

	self.water = {}

	self.decorations = {}

	self.renderer = Renderer(_MOBILE)
	self.resourceManager = ResourceManager()
	self.spriteManager = SpriteManager(self.resourceManager)

	self.itemBagModel = self.resourceManager:load(
		ModelResource,
		"Resources/Game/Items/ItemBag.lmesh")
	self.itemBagIconModel = self.resourceManager:load(
		ModelResource,
		"Resources/Game/Items/ItemBagIcon.lmesh")
	self.items = {}

	local whiteTextureImageData = love.image.newImageData(1, 1)
	whiteTextureImageData:setPixel(0, 0, 1, 1, 1, 0)
	self.whiteTexture = TextureResource(love.graphics.newImage(whiteTextureImageData))

	local itemTextureImageData = love.image.newImageData(1, 1)
	itemTextureImageData:setPixel(0, 0, 1, 1, 1, 1)
	self.itemTexture = TextureResource(love.graphics.newImage(itemTextureImageData))

	self.projectiles = {}

	self.weather = {}
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
	stage.onMapMoved:unregister(self._onMapMoved)
	stage.onActorSpawned:unregister(self.onActorSpawned)
	stage.onActorKilled:unregister(self._onActorKilled)
	stage.onPropPlaced:unregister(self._onPropPlaced)
	stage.onPropRemoved:unregister(self._onPropRemoved)
	stage.onTakeItem:unregister(self._onTakeItem)
	stage.onDropItem:unregister(self._onDropItem)
	stage.onDecorate:unregister(self._onDecorate)
	stage.onWaterFlood:unregister(self._onWaterFlood)
	stage.onWaterDrain:unregister(self._onWaterDrain)
	stage.onForecast:unregister(self._onForecast)
	stage.onProjectile:unregister(self._onProjectile)
	stage.onPlayMusic:unregister(self._onPlayMusic)
	stage.onStopMusic:unregister(self._onStopMusic)
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
		parts = {},
		weatherMap = WeatherMap(layer, -8, -8, map:getCellSize(), map:getWidth() + 16, map:getHeight() + 16)
	}

	m.weatherMap:addMap(m.map)

	self.mapMeshes[layer] = m
end

function GameView:removeMap(layer)
	local m = self.mapMeshes[layer]
	if m then
		m.node:setParent(nil)

		for i = 1, #m.parts do
			m.parts[i]:setMapMesh(nil)
		end

		m.weatherMap:removeMap(m.map)

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

		m.weatherMap:addMap(m.map)
	end
end

function GameView:moveMap(layer, position, rotation, scale, offset, disabled)
	local node = self:getMapSceneNode(layer)
	if node then
		local transform = node:getTransform()
		transform:setLocalTranslation(position)
		transform:setLocalRotation(rotation)
		transform:setLocalScale(scale)
		transform:setLocalOffset(offset)

		if disabled and node:getParent() then
			node:setParent(nil)
		elseif not disabled and not node:getParent() then
			node:setParent(self.scene)
		end
	end

	local m = self.mapMeshes[layer]
	if m then
		m.weatherMap:updateMap(m.map, position, rotation, scale)

		local x = ((m.map:getWidth() + 0.5) * m.map:getCellSize()) / 2
		local z = ((m.map:getHeight() + 0.5) * m.map:getCellSize()) / 2
		local globalTransform = m.node:getTransform():getGlobalTransform()
		local position = Vector(globalTransform:transformPoint(x, 0, z))
		m.weatherMap:setAbsolutePosition(position)
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
	self.views[actor] = view
end

function GameView:getActor(actor)
	return self.actors[actor]
end

function GameView:removeActor(actor)
	if self.actors[actor] then
		local view = self.actors[actor]
		self.actors[actor]:poof()
		self.actors[actor] = nil
		self.views[view] = nil
	end
end

function GameView:hasActor(actor)
	return self.actors[actor] ~= nil
end

function GameView:addProp(propID, prop)
	local PropViewTypeName = string.format("Resources.Game.Props.%s.View", propID, propID)
	local s, r = xpcall(function() return require(PropViewTypeName) end, debug.traceback)
	if not s then
		Log.warnOnce("Failed to load prop view '%s': %s", PropViewTypeName, r)
		r = require "Resources.Game.Props.Null.View"
	end

	local PropView = r
	local view = PropView(prop, self)
	view:attach()
	view:load()

	self.props[prop] = view
	self.views[prop] = view
end

function GameView:getProp(prop)
	return self.props[prop]
end

function GameView:removeProp(prop)
	if self.props[prop] then
		local view = self.props[prop]
		self.props[prop]:remove()
		self.props[prop] = nil
		self.views[prop] = nil
	end
end

function GameView:getView(instance)
	return self.views[instance]
end

function GameView:spawnItem(item, tile)
	local map = self.game:getStage():getMap(tile.layer)
	if map then
		position = map:getTileCenter(tile.i, tile.j)
	end

	local itemNode = SceneNode()
	do
		local lootBagNode = ModelSceneNode()
		lootBagNode:setModel(self.itemBagModel)
		lootBagNode:getMaterial():setShader(ModelSceneNode.STATIC_SHADER)
		lootBagNode:getMaterial():setTextures(self.itemTexture)
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

	local map = self:getMapSceneNode(tile.layer)
	if not map then
		map = self.scene
	end

	itemNode:getTransform():translate(position)
	itemNode:setParent(map)

	self.items[item.ref] = itemNode
end

function GameView:poofItem(item)
	local node = self.items[item.ref]
	if node then
		node:setParent(nil)

		self.items[item.ref] = nil
	end
end

function GameView:decorate(group, decoration, layer)
	local groupName = group .. '#' .. tostring(layer)
	if self.decorations[groupName] and
	   self.decorations[groupName].sceneNode
	then
		self.decorations[groupName].sceneNode:setParent(nil)
		self.decorations[groupName] = nil
	end

	local map = self:getMapSceneNode(layer)
	if not map then
		map = self.scene
	end

	if decoration then
		local d = {}

		self.resourceManager:queueEvent(function()
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

			sceneNode:setParent(map)

			d.sceneNode = sceneNode
			d.decoration = decoration
			d.name = group
		end)

		self.decorations[groupName] = d
	end
end

function GameView:flood(key, water, layer)
	self:drain(key)

	local parent = self:getMapSceneNode((water.layer or 1) - 1 + (layer or 1))
	if not parent then
		parent = self.scene
	end

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
			node:setParent(parent)
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

function GameView:forecast(layer, key, id, props)
	if not id then
		local current = self.weather[key]
		if current then
			current:remove()
		end

		self.weather[key] = nil
		return
	end

	local WeatherType
	do
		local WeatherTypeName = string.format("ItsyScape.Graphics.%sWeather", id)
		local s, r = pcall(require, WeatherTypeName)
		if not s then
			Log.error("Failed to load weather '%s': %s.", id, r)
			return
		end

		WeatherType = r
	end

	if WeatherType then
		local node = self.mapMeshes[layer]
		if node then
			map = node.weatherMap

			local weather = WeatherType(self, layer, map, props or {})
			self.weather[key] = weather
		end
	end
end

function GameView:fireProjectile(projectileID, source, destination, time)
	local ProjectileType
	do
		local ProjectileTypeName = string.format("Resources.Game.Projectiles.%s.Projectile", projectileID)
		local s, r = pcall(require, ProjectileTypeName)
		if not s then
			Log.error("Failed to load projectile '%s': %s.", projectileID, r)
			return
		end

		ProjectileType = r
	end

	if ProjectileType then
		local projectile = ProjectileType(projectileID, self, source, destination, time)
		projectile:attach()
		projectile:load()
		self.projectiles[projectile] = true
	end
end

function GameView:playMusic(track, song)
	if not song or _CONF.musicVolume == 0 then
		local t = self.music[track]
		if t then
			table.insert(t, false)
		end
	else
		local filename = string.format("Resources/Game/Music/%s/Music.ogg", song)
		local song = love.audio.newSource(filename, 'stream')
		song:setVolume(0)
		song:setLooping(true)
		song:play()

		local t = self.music[track]
		if t then
			table.insert(t, song)
		else
			t = { song }
		end

		self.music[track] = t
	end
end

function GameView:getDecorations()
	local result = {}
	local count = 0
	for k, v in pairs(self.decorations) do
		result[v.name] = v.decoration
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

	local finishedProjectiles = {}
	for projectile in pairs(self.projectiles) do
		projectile:update(delta)

		if projectile:isDone() then
			table.insert(finishedProjectiles, projectile)
		end
	end

	for i = 1, #finishedProjectiles do
		finishedProjectiles[i]:poof()
		self.projectiles[finishedProjectiles[i]] = nil
	end

	for _, weather in pairs(self.weather) do
		weather:update(delta)
	end

	self.spriteManager:update(delta)

	do
		local actor = self:getActor(self.game:getPlayer():getActor())
		if actor then
			player = actor:getSceneNode()
			local transform = player:getTransform():getGlobalDeltaTransform(0, 0, 0)
			love.audio.setPosition(transform:transformPoint(0, 0, 0))
		end
	end

	for track, songs in pairs(self.music) do
		local index = 1
		while index < #songs do
			local song = songs[index]
			if song then
				song:setVolume(math.max(song:getVolume() - 0.5 * delta, 0))
			end

			if not song or song:getVolume() <= 0.01 then
				if song then
					song:stop()
					song:release()
				end
				table.remove(songs, index)
			else
				index = index + 1
			end
		end

		local lastSong = songs[#songs]
		if not lastSong then
			if #songs == 1 then
				table.remove(songs, 1)
			end
		else
			lastSong:setVolume(math.min(lastSong:getVolume() + 0.5 * delta, 1))
		end
	end
end

function GameView:tick()
	self.scene:tick()

	for _, actor in pairs(self.actors) do
		actor:tick()
	end

	for _, prop in pairs(self.props) do
		prop:tick()
	end

	for projectile in pairs(self.projectiles) do
		projectile:tick()
	end
end

return GameView
