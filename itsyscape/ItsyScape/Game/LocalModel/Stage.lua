--------------------------------------------------------------------------------
-- ItsyScape/Game/LocalModel/Stage.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local Utility = require "ItsyScape.Game.Utility"
local GroundInventoryProvider = require "ItsyScape.Game.GroundInventoryProvider"
local TransferItemCommand = require "ItsyScape.Game.TransferItemCommand"
local LocalActor = require "ItsyScape.Game.LocalModel.Actor"
local LocalProp = require "ItsyScape.Game.LocalModel.Prop"
local Stage = require "ItsyScape.Game.Model.Stage"
local CompositeCommand = require "ItsyScape.Peep.CompositeCommand"
local ActorReferenceBehavior = require "ItsyScape.Peep.Behaviors.ActorReferenceBehavior"
local InventoryBehavior = require "ItsyScape.Peep.Behaviors.InventoryBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local PropReferenceBehavior = require "ItsyScape.Peep.Behaviors.PropReferenceBehavior"
local Map = require "ItsyScape.World.Map"
local Decoration = require "ItsyScape.Graphics.Decoration"
local ExecutePathCommand = require "ItsyScape.World.ExecutePathCommand"

local LocalStage = Class(Stage)

function LocalStage:new(game)
	Stage.new(self)
	self.game = game
	self.actors = {}
	self.props = {}
	self.peeps = {}
	self.decorations = {}
	self.currentActorID = 1
	self.currentPropID = 1
	self.map = {}
	self.water = {}
	self.gravity = Vector(0, -9.8, 0)
	self.stageName = "::orphan"

	self:spawnGround()
end

function LocalStage:spawnGround()
	if self.ground then
		self.game:getDirector():removePeep(self.ground)
	end

	self.ground = self.game:getDirector():addPeep(self.stageName, require "Resources.Game.Peeps.Ground")
	local inventory = self.ground:getBehavior(InventoryBehavior).inventory
	inventory.onTakeItem:register(self.notifyTakeItem, self)
	inventory.onDropItem:register(self.notifyDropItem, self)
end

function LocalStage:notifyTakeItem(item, key)
	local ref = self.game:getDirector():getItemBroker():getItemRef(item)
	self.onTakeItem(self, { ref = ref, id = item:getID(), noted = item:isNoted() })
end

function LocalStage:notifyDropItem(item, key, source)
	local ref = self.game:getDirector():getItemBroker():getItemRef(item)
	local position = source:getPeep():getBehavior(PositionBehavior)
	if position then
		local p = position.position
		position = Vector(p.x, p.y, p.z)
	else
		position = Vector(0)
	end

	self.onDropItem(
		self,
		{ ref = ref, id = item:getID(), noted = item:isNoted() },
		{ i = key.i, j = key.j, layer = key.layer },
		position)
end

function LocalStage:lookupResource(resourceID, resourceType)
	local Type
	local realResourceID, resource
	do
		local protocol, value = resourceID:match("(.*)%:%/*(.*)")
		if protocol and value then
			realResourceID = value

			if protocol:lower() == "resource" then
				local gameDB = self.game:getGameDB()
				local r = gameDB:getResource(value, resourceType)

				if r then
					local record = gameDB:getRecords("PeepID", { Resource = r }, 1)[1]
					if record then
						t = record:get("Value")

						if not t or t == "" then
							Log.error("resource ID malformed for resource '%s'", value)
							return false, nil
						else
							Type = require(t)
							resource = r
						end
					else
						Log.error("no peep ID for resource '%s'", value)
						return false, nil
					end
				else
					Log.error("resource ('%s') '%s' not found.", resourceType, value)
					return false, nil
				end
			elseif protocol:lower() == "peep" then
				Type = require(value)
			else
				Log.error("bad protocol: '%s'", protocol:lower())
				return false, nil
			end
		else
			Type = require(resourceID)
			realResourceID = resourceID
		end
	end

	return Type, resource, realResourceID
end

function LocalStage:spawnActor(actorID)
	local Peep, resource, realID = self:lookupResource(actorID, "Peep")

	if Peep then
		local actor = LocalActor(self.game, Peep)
		actor:spawn(self.currentActorID, self.stageName, resource)

		self.onActorSpawned(self, realID, actor)

		self.currentActorID = self.currentActorID + 1
		self.actors[actor] = true

		local peep = actor:getPeep()
		self.peeps[actor] = peep
		self.peeps[peep] = actor

		return true, actor
	end

	return false, nil
end

function LocalStage:killActor(actor)
	if actor and self.actors[actor] then
		local a = self.actors[actor]

		self.onActorKilled(self, actor)
		actor:depart()

		local peep = self.peeps[actor]
		self.peeps[actor] = nil
		self.peeps[peep] = nil

		self.actors[actor] = nil
	end
end

function LocalStage:placeProp(propID)
	local Peep, resource, realID = self:lookupResource(propID, "Prop")

	if Peep then
		local prop = LocalProp(self.game, Peep)
		prop:place(self.currentPropID, self.stageName, resource)

		self.onPropPlaced(self, realID, prop)

		self.currentPropID = self.currentPropID + 1
		self.props[prop] = true

		local peep = prop:getPeep()
		self.peeps[prop] = peep
		self.peeps[peep] = prop

		return true, prop
	end

	return false, nil
end

function LocalStage:removeProp(prop)
	if prop and self.props[prop] then
		local p = self.props[prop]

		self.onPropRemoved(self, prop)
		prop:remove()

		local peep = self.peeps[prop]
		self.peeps[prop] = nil
		self.peeps[peep] = nil

		self.props[prop] = nil
	end
end

function LocalStage:instantiateMapObject(resource)
	local gameDB = self.game:getGameDB()

	local object = gameDB:getRecord("MapObjectLocation", {
		Resource = resource
	})

	local actorInstance, propInstance

	if object then
		local x = object:get("PositionX") or 0
		local y = object:get("PositionY") or 0
		local z = object:get("PositionZ") or 0

		do
			local prop = gameDB:getRecord("PropMapObject", {
				MapObject = object:get("Resource")
			})

			if prop then
				prop = prop:get("Prop")
				if prop then
					local s, p = self:placeProp("resource://" .. prop.name)

					if s then
						local peep = p:getPeep()
						local position = peep:getBehavior(PositionBehavior)
						if position then
							position.position = Vector(x, y, z)
						end

						propInstance = p

						Utility.Peep.setMapObject(peep, resource)
					end
				end
			end
		end

		do
			local actor = gameDB:getRecord("PeepMapObject", {
				MapObject = object:get("Resource")
			})

			if actor then
				actor = actor:get("Peep")
				if actor then
					local s, a = self:spawnActor("resource://" .. actor.name)

					if s then
						local peep = a:getPeep()
						local position = peep:getBehavior(PositionBehavior)
						if position then
							position.position = Vector(x, y, z)
						end

						local direction = object:get("Direction")
						if direction then
							if direction < 0 then
								a:setDirection(Vector(-1, 0, 0))
							elseif direction > 0 then
								a:setDirection(Vector(1, 0, 0))
							end
						end

						actorInstance = a

						Utility.Peep.setMapObject(peep, resource)
					end
				end
			end
		end
	end

	return actorInstance, propInstance
end

function LocalStage:loadMapFromFile(filename, layer, tileSetID)
	self:unloadMap(layer)

	local map = Map.loadFromFile(filename)
	if map then
		self.map[layer] = map
		self.onLoadMap(self, self.map[layer], layer, tileSetID)
		self.game:getDirector():setMap(layer, map)

		self:updateMap(layer)
	end
end

function LocalStage:newMap(width, height, layer, tileSetID)
	self:unloadMap(layer)

	local map = Map(width, height, Stage.CELL_SIZE)
	self.map[layer] = map
	self.onLoadMap(self, self.map[layer], layer, tileSetID)
	self.game:getDirector():setMap(layer, map)

	self:updateMap(layer)
end

function LocalStage:updateMap(layer, map)
	if self.map[layer] then
		if map then
			self.map[layer] = map
			self.game:getDirector():setMap(layer, map)
		end

		self.onMapModified(self, self.map[layer], layer)
	end
end

function LocalStage:unloadMap(layer)
	if self.map[layer] then
		self.onUnloadMap(self, self.map[layer], layer)
		self.map[layer] = nil
		self.game:getDirector():setMap(layer, nil)
	end
end

function LocalStage:unloadAll()
	self.game:getDirector():removeLayer(self.stageName)

	local layers = self:getLayers()
	for i = 1, #layers do
		self:unloadMap(layers[i])
	end

	for key in pairs(self.water) do
		self.onWaterDrain(self, key)
	end

	for group, decoration in pairs(self.decorations) do
		self:decorate(group, nil)
	end

	do
		local p = {}

		for prop in self:iterateProps() do
			table.insert(p, prop)
		end

		for _, prop in ipairs(p) do
			self:removeProp(prop)
		end
	end

	do
		local p = {}

		for actor in self:iterateActors() do
			if actor ~= self.game:getPlayer():getActor() then
				table.insert(p, actor)
			end
		end

		do
			local broker = self.game:getDirector():getItemBroker()
			local inventory = self.ground:getBehavior(InventoryBehavior).inventory
			for item in broker:iterateItems(inventory) do
				local ref = broker:getItemRef(item)
				self.onTakeItem(self, { ref = ref, id = item:getID(), noted = item:isNoted() })
			end
		end

		for _, actor in ipairs(p) do
			self:killActor(actor)
		end
	end
end

function LocalStage:movePeep(peep, filename, anchor)
	local playerPeep = self.game:getPlayer():getActor():getPeep()
	if playerPeep == peep then
		if filename ~= self.stageName then
			self:loadStage(filename)
		end

		playerPeep = self.game:getPlayer():getActor():getPeep()
		local position = playerPeep:getBehavior(PositionBehavior)

		local gameDB = self.game:getGameDB()
		local map = gameDB:getResource(filename, "Map")
		if map then
			local mapObject = gameDB:getRecord("MapObjectLocation", {
				Name = anchor,
				Map = map
			})

			local x, y, z = mapObject:get("PositionX"), mapObject:get("PositionY"), mapObject:get("PositionZ")
			position.position = Vector(x, y, z)
		end
	else
		local actor = peep:getBehavior(ActorReferenceBehavior)
		local prop = peep:getBehavior(PropReferenceBehavior)
		if actor and actor.actor then
			self:killActor(actor.actor)
		elseif prop and prop.prop then
			self:removeProp(prop.prop)
		else
			Log.error("Cannot move peep '%s'; not player, actor, or prop.", peep:getName())
			Log.warn("Removing peep '%s' anyway; may cause bad references.", peep:getName())
			self.game:getDirector():removePeep(peep)
		end
	end
end

function LocalStage:loadStage(filename)
	do
		local director = self.game:getDirector()
		director:movePeep(self.game:getPlayer():getActor():getPeep(), filename)
	end

	self:unloadAll()

	self.stageName = filename

	local directoryPath = "Resources/Game/Maps/" .. filename

	local meta
	do
		local metaFilename = directoryPath .. "/meta"
		local data = "return " .. (love.filesystem.read(metaFilename) or "")
		local chunk = assert(loadstring(data))
		meta = setfenv(chunk, {})() or {}
	end

	for _, item in ipairs(love.filesystem.getDirectoryItems(directoryPath)) do
		local layer = item:match(".*(-?%d)%.lmap$")
		if layer then
			layer = tonumber(layer)

			local tileSetID
			if meta[layer] then
				tileSetID = meta[layer].tileSetID
			end

			local layerMeta = meta[layer] or {}

			self:loadMapFromFile(directoryPath .. "/" .. item, layer, layerMeta.tileSetID)
		end
	end

	do
		local waterDirectoryPath = directoryPath .. "/Water"
		for _, item in ipairs(love.filesystem.getDirectoryItems(waterDirectoryPath)) do
			local data = "return " .. (love.filesystem.read(waterDirectoryPath .. "/" .. item) or "")
			local chunk = assert(loadstring(data))
			water = setfenv(chunk, {})() or {}

			self.onWaterFlood(self, item, water)
			self.water[item] = water
		end
	end

	for _, item in ipairs(love.filesystem.getDirectoryItems(directoryPath .. "/Decorations")) do
		local group = item:match("(.*)%.ldeco$")
		if group then
			local decoration = Decoration(directoryPath .. "/Decorations/" .. item)
			self:decorate(group, decoration)
		end
	end

	self:spawnGround()

	local gameDB = self.game:getGameDB()
	local resource = gameDB:getResource(filename, "Map")
	if resource then
		local objects = gameDB:getRecords("MapObjectLocation", {
			Map = resource
		})

		for i = 1, #objects do
			self:instantiateMapObject(objects[i]:get("Resource"))
		end
	end
end

function LocalStage:getMap(layer)
	return self.map[layer]
end

function LocalStage:getLayers()
	local layers = {}
	for index in pairs(self.map) do
		table.insert(layers, index)
	end

	table.sort(layers)
	return layers
end

function LocalStage:getGravity()
	return self.gravity
end

function LocalStage:setGravity(value)
	self.gravity = value or self.gravity
end

function LocalStage:getItemsAtTile(i, j, layer)
	local inventory = self.ground:getBehavior(InventoryBehavior).inventory
	if not inventory then
		return {}
	else
		local key = GroundInventoryProvider.Key(i, j, layer)
		local broker = self.game:getDirector():getItemBroker()
		local result = {}
		for item in broker:iterateItemsByKey(inventory, key) do
			table.insert(result, {
				ref = broker:getItemRef(item),
				id = item:getID(),
				count = item:getCount(),
				noted = item:isNoted()
			})
		end

		return result
	end
end

function LocalStage:dropItem(item, count)
	local destination = self.ground:getBehavior(InventoryBehavior).inventory
	local broker = self.game:getDirector():getItemBroker()
	local transaction = broker:createTransaction()
	local provider = broker:getItemProvider(item)
	provider:getPeep():poke('dropItem', {
		item = item,
		count = count
	})

	transaction:addParty(provider)
	transaction:addParty(destination)
	transaction:transfer(destination, item, count, 'drop', false)
	transaction:commit()
end

function LocalStage:takeItem(i, j, layer, ref)
	local inventory = self.ground:getBehavior(InventoryBehavior).inventory
	if inventory then
		local key = GroundInventoryProvider.Key(i, j, layer)
		local broker = self.game:getDirector():getItemBroker()

		local targetItem
		for item in broker:iterateItemsByKey(inventory, key) do
			if broker:getItemRef(item) == ref then
				targetItem = item
				break
			end
		end

		if targetItem then
			local player = self.game:getPlayer()
			local path = player:findPath(i, j, layer)
			if path then
				local queue = player:getActor():getPeep():getCommandQueue()
				local function condition()
					if not broker:hasItem(targetItem) then
						return false
					end

					if broker:getItemProvider(targetItem) ~= inventory then
						return false
					end

					return true
				end

				local playerInventory = player:getActor():getPeep():getBehavior(
					InventoryBehavior).inventory
				if playerInventory then
					local walkStep = ExecutePathCommand(path)
					local takeStep = TransferItemCommand(
						broker,
						targetItem,
						playerInventory,
						targetItem:getCount(),
						'take',
						true)

					queue:interrupt(CompositeCommand(condition, walkStep, takeStep))
				end
			end
		end
	end
end

function LocalStage:decorate(group, decoration)
	self.onDecorate(self, group, decoration)
	self.decorations[group] = decoration
end

function LocalStage:iterateActors()
	return pairs(self.actors)
end

function LocalStage:iterateProps()
	return pairs(self.props)
end

return LocalStage
