--------------------------------------------------------------------------------
-- ItsyScape/Game/ServerModel/Instance.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local Quaternion = require "ItsyScape.Common.Math.Quaternion"
local Utility = require "ItsyScape.Game.Utility"
local GroundInventoryProvider = require "ItsyScape.Game.GroundInventoryProvider"
local TransferItemCommand = require "ItsyScape.Game.TransferItemCommand"
local ServerActor = require "ItsyScape.Game.ServerModel.Actor"
local ServerProp = require "ItsyScape.Game.ServerModel.Prop"
local Stage = require "ItsyScape.Game.Model.Stage"
local CompositeCommand = require "ItsyScape.Peep.CompositeCommand"
local Peep = require "ItsyScape.Peep.Peep"
local ActorReferenceBehavior = require "ItsyScape.Peep.Behaviors.ActorReferenceBehavior"
local InventoryBehavior = require "ItsyScape.Peep.Behaviors.InventoryBehavior"
local MapResourceReferenceBehavior = require "ItsyScape.Peep.Behaviors.MapResourceReferenceBehavior"
local PlayerBehavior = require "ItsyScape.Peep.Behaviors.PlayerBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local PropReferenceBehavior = require "ItsyScape.Peep.Behaviors.PropReferenceBehavior"
local RotationBehavior = require "ItsyScape.Peep.Behaviors.RotationBehavior"
local ScaleBehavior = require "ItsyScape.Peep.Behaviors.ScaleBehavior"
local Map = require "ItsyScape.World.Map"
local Decoration = require "ItsyScape.Graphics.Decoration"
local ExecutePathCommand = require "ItsyScape.World.ExecutePathCommand"

local Instance = Class(Stage)

function Instance:new(game, stage, path)
	Stage.new(self)

	self.game = game
	self.stage = stage
	self.actors = {}
	self.actorsByID = {}
	self.props = {}
	self.propsByID = {}
	self.peeps = {}
	self.decorations = {}
	self.map = {}
	self.mapScripts = {}
	self.water = {}
	self.tests = { id = 1 }
	self.weathers = {}
	self.music = {}
	self.filename = ""
	self.playerCount = 0

	self:load(path)

	self.grounds = {}
	self:spawnGround(self.layerName, 1)

	self.mapThread = love.thread.newThread("ItsyScape/Game/LocalModel/Threads/Map.lua")
	self.mapThread:start()
end

function Instance:getFilename()
	return self.filename
end

function Instance:getPlayerCount()
	return self.playerCount
end

function Instance:onPlayerEnter(peep)
	peep:listen('travel', self.onPlayerLeave, self)
	self.playerCount = self.playerCount + 1

	for _, script in pairs(self.mapScripts) do
		script:poke('playerEnter', {
			player = peep
		})
	end

	local actor = peep:getBehavior(ActorReferenceBehavior)
	if actor then
		actor = actor.actor
		self:onActorSpawned(actor:getID(), actor)
	end
end

function Instance:onPlayerLeave(peep)
	self.playerCount = self.playerCount - 1

	for _, script in pairs(self.mapScripts) do
		script:poke('playerLeave', {
			player = peep
		})
	end

	local actor = peep:getBehavior(ActorReferenceBehavior)
	if actor then
		actor = actor.actor
		self:onActorKilled(actor)
	end
end

function Instance:spawnGround(filename, layer)
	local ground = self.game:getDirector():addPeep(self.layerName, require "Resources.Game.Peeps.Ground")
	self.grounds[filename] = ground
	self.grounds[layer] = ground

	local inventory = ground:getBehavior(InventoryBehavior).inventory
	inventory.onTakeItem:register(self.notifyTakeItem, self)
	inventory.onDropItem:register(self.notifyDropItem, self)
end

function Instance:notifyTakeItem(item, key)
	local ref = self.game:getDirector():getItemBroker():getItemRef(item)
	self.onTakeItem(self, { ref = ref, id = item:getID(), noted = item:isNoted() })
end

function Instance:notifyDropItem(item, key, source)
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

function Instance:getMapScript(key)
	local map = self.mapScripts[key]
	if map then
		return map.peep, map.layer
	else
		return nil
	end
end

function Instance:lookupResource(resourceID, resourceType)
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
						local t = record:get("Value")

						if not t or t == "" then
							Log.error("resource ID malformed for resource '%s'", value)
							return false, nil
						else
							Type = require(t)
							resource = r
						end
					else
						Log.warn("no peep ID for resource '%s'", value)
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

function Instance:spawnActor(actorID, layer)
	layer = layer or 1

	local Peep, resource, realID = self:lookupResource(actorID, "Peep")

	if Peep then
		local actor = ServerActor(self.game, Peep)
		actor:spawn(self.stage:getNextActorID(), self.layerName, resource)

		self.onActorSpawned(self, realID, actor)

		self.actors[actor] = true
		self.actorsByID[actorID] = actor

		local peep = actor:getPeep()
		self.peeps[actor] = peep
		self.peeps[peep] = actor

		peep:listen('ready', function()
			local p = peep:getBehavior(PositionBehavior)
			if p then
				p.layer = layer
			end
		end)

		return true, actor
	end

	return false, nil
end

function LocalStage:moveActorTo(actor)
	if actor and (self.actors[actor] or self.peeps[actor]) then
		if actor:isCompatibleType(Peep) then
			actor = self.peeps[actor]
		end

		local peep = actor:getPeep()
		self.peeps[actor] = peep
		self.peeps[peep] = actor
		self.actors[actor] = true
		self.actorsByID[actor:getID()] = actor

		local position = peep:getBehavior(PositionBehavior)
		if position then
			position.layer = self.layer
		end
	end
end

function LocalStage:moveActorFrom(actor)
	if actor and (self.actors[actor] or self.peeps[actor]) then
		if actor:isCompatibleType(Peep) then
			actor = self.peeps[actor]
		end

		local peep = self.peeps[actor]
		self.peeps[actor] = nil
		self.peeps[peep] = nil

		self.actors[actor] = nil
		self.actorsByID[actor:getID()] = nil
	end
end

function Instance:killActor(actor)
	if actor and (self.actors[actor] or self.peeps[actor]) then
		if actor:isCompatibleType(Peep) then
			actor = self.peeps[actor]
		end

		local id = actor:getID()

		self.onActorKilled(self, actor)
		actor:depart()

		local peep = self.peeps[actor]
		self.peeps[actor] = nil
		self.peeps[peep] = nil

		self.actors[actor] = nil
		self.actorsByID[id] = nil
	end
end

function Instance:placeProp(propID, layer)
	layer = layer or 1

	local Peep, resource, realID = self:lookupResource(propID, "Prop")

	if Peep then
		local prop = ServerProp(self.game, Peep)
		prop:place(self.stage:getNextPropID(), self.layerName, resource)

		self.onPropPlaced(self, realID, prop)

		self.props[prop] = true
		self.propsByID[prop] = prop

		local peep = prop:getPeep()
		self.peeps[prop] = peep
		self.peeps[peep] = prop

		peep:listen('ready', function()
			local p = peep:getBehavior(PositionBehavior)
			if p then
				p.layer = layer
			end
		end)

		return true, prop
	end

	return false, nil
end

function Instance:removeProp(prop)
	if prop and (self.props[prop] or self.peeps[prop]) then
		if prop:isCompatibleType(Peep) then
			prop = self.peeps[prop]
		end

		local id = prop:getID()

		self.onPropRemoved(self, prop)
		prop:remove()

		local peep = self.peeps[prop]
		self.peeps[prop] = nil
		self.peeps[peep] = nil

		self.props[prop] = nil
		self.propsByID[prop] = nil
	end
end

function Instance:instantiateMapObject(resource, layer)
	layer = layer or 1

	local gameDB = self.game:getGameDB()

	local object = gameDB:getRecord("MapObjectLocation", {
		Resource = resource
	}) or gameDB:getRecord("MapObjectReference", {
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
					local s, p = self:placeProp("resource://" .. prop.name, layer)

					if s then
						local peep = p:getPeep()
						local position = peep:getBehavior(PositionBehavior)
						if position then
							position.position = Vector(x, y, z)
						end

						local scale = peep:getBehavior(ScaleBehavior)
						if scale then
							local sx = object:get("ScaleX") 
							local sy = object:get("ScaleY") 
							local sz = object:get("ScaleZ")

							if sx == 0 then
								sx = 1
							end

							if sy == 0 then
								sy = 1
							end

							if sz == 0 then
								sz = 1
							end

							scale.scale = Vector(sx, sy, sz)
						end

						local rotation = peep:getBehavior(RotationBehavior)
						if rotation then
							local rx = object:get("RotationX") or 0
							local ry = object:get("RotationY") or 0
							local rz = object:get("RotationZ") or 0
							local rw = object:get("RotationW") or 1

							if rw ~= 0 then
								rotation.rotation = Quaternion(rx, ry, rz, rw)
							end
						end

						propInstance = p

						Utility.Peep.setMapObject(peep, resource)

						local s, b = peep:addBehavior(MapResourceReferenceBehavior)
						if s then
							b.map = object:get("Map")
						end
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
					local s, a = self:spawnActor("resource://" .. actor.name, layer)

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

						local s, b = peep:addBehavior(MapResourceReferenceBehavior)
						if s then
							b.map = object:get("Map")
						end
					end
				end
			end
		end
	end

	return actorInstance, propInstance
end

function Instance:loadMapFromFile(filename, layer, tileSetID)
	self:unloadMap(layer)

	local map = Map.loadFromFile(filename)
	if map then
		self.map[layer] = map
		self.onLoadMap(self, self.map[layer], layer, tileSetID, filename)
		self.game:getDirector():setMap(layer, map)

		self:updateMap(layer)
	end
end

function Instance:newMap(width, height, layer, tileSetID)
	self:unloadMap(layer)

	local map = Map(width, height, Stage.CELL_SIZE)
	self.map[layer] = map
	self.onLoadMap(self, self.map[layer], layer, tileSetID)
	self.game:getDirector():setMap(layer, map)

	self:updateMap(layer)
end

function Instance:updateMap(layer, map)
	if self.map[layer] then
		if map then
			self.map[layer] = map
			self.game:getDirector():setMap(layer, map)
		end

		love.thread.getChannel('ItsyScape.Map::input'):push({
			type = 'load',
			key = layer,
			data = self.map[layer]:toString()
		})

		self.onMapModified(self, self.map[layer], layer)
	end
end

function Instance:unloadMap(layer)
	if self.map[layer] then
		self.onUnloadMap(self, self.map[layer], layer)
		self.map[layer] = nil
		self.game:getDirector():setMap(layer, nil)

		love.thread.getChannel('ItsyScape.Map::input'):push({
			type = 'unload',
			key = layer
		})

		self.stage:freeLayer(layer)
	end
end

function Instance:flood(key, water, layer)
	self.onWaterFlood(self, key, water, layer)
end

function Instance:drain(key, layer)
	self.onWaterDrain(self, key)
end

function Instance:unloadAll()
	do
		self.game:getDirector():getItemBroker():toStorage()
	end

	local layers = self:getInstances()
	for i = 1, #layers do
		self:unloadMap(layers[i])
	end

	for key in pairs(self.water) do
		self.onWaterDrain(self, key)
	end

	for group, decoration in pairs(self.decorations) do
		self:decorate(group, nil)
	end

	for weather in pairs(self.weathers) do
		self:forecast(nil, weather, nil)
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
			self:collectItems()

			self.grounds = {}
		end

		for _, actor in ipairs(p) do
			self:killActor(actor)
		end
	end

	self.game:getDirector():removeLayer(self.layerName)
	self.mapScripts = {}
end

function Instance:loadMapResource(filename, args)
	local directoryPath = "Resources/Game/Maps/" .. filename

	local meta
	do
		local metaFilename = directoryPath .. "/meta"
		local data = "return " .. (love.filesystem.read(metaFilename) or "")
		local chunk = assert(loadstring(data))
		meta = setfenv(chunk, {})() or {}
	end

	local musicMeta
	do
		local metaFilename = directoryPath .. "/meta.music"
		local data = "return " .. (love.filesystem.read(metaFilename) or "")
		local chunk = assert(loadstring(data))
		musicMeta = setfenv(chunk, {})() or {}
	end

	for key, song in pairs(musicMeta) do
		self:playMusic(self.layerName, key, song)
	end

	local layer = self.stage:getNewLayer()
	self.layer = layer

	self:loadMapFromFile(directoryPath .. "/1.lmap", , meta[1])

	do
		local waterDirectoryPath = directoryPath .. "/Water"
		for _, item in ipairs(love.filesystem.getDirectoryItems(waterDirectoryPath)) do
			local data = "return " .. (love.filesystem.read(waterDirectoryPath .. "/" .. item) or "")
			local chunk = assert(loadstring(data))
			water = setfenv(chunk, {})() or {}

			self.onWaterFlood(self, item, water, layer)
			self.water[item] = water
		end
	end

	for _, item in ipairs(love.filesystem.getDirectoryItems(directoryPath .. "/Decorations")) do
		local group = item:match("(.*)%.ldeco$")
		if group then
			local key = directoryPath .. "/Decorations/" .. item
			local filename = key
			local decoration = Decoration(filename)
			self:decorate(key, decoration, layer, filename)
		end
	end

	self:spawnGround(filename, layer)

	local mapScript

	local gameDB = self.game:getGameDB()
	local resource = gameDB:getResource(filename, "Map")
	if resource then
		do
			local Peep = self:lookupResource("resource://" .. resource.name, "Map")
			if not Peep then
				Peep = require "ItsyScape.Peep.Peeps.Map"
			end

			self.mapScripts[filename] = {
				peep = self.game:getDirector():addPeep(self.layerName, Peep, resource),
				layer = layer
			}

			self.mapScripts[filename].peep:listen('ready',
				function(self)
					self:poke('load', filename, args or {}, layer)
				end
			)

			do
				local _, m = self.mapScripts[filename].peep:addBehavior(MapResourceReferenceBehavior)
				m.map = resource
			end 

			mapScript = self.mapScripts[filename].peep
		end

		local objects = gameDB:getRecords("MapObjectLocation", {
			Map = resource
		})

		for i = 1, #objects do
			self:instantiateMapObject(objects[i]:get("Resource"), layer)
		end
	end

	return layer, mapScript
end

function Instance:playMusic(layerName, channel, song)
	self.onPlayMusic(self, channel, song)
	table.insert(self.music, {
		channel = channel,
		song = song
	})
end

function Instance:stopMusic(layerName, channel, song)
	self.onStopMusic(self, channel, song)

	local index = 1
	while index <= #self.music do
		local m = self.music[index]
		if m.channel == channel and m.song == song then
			table.remove(self.music, index)
		else
			index = index + 1
		end
	end
end

function Instance:load(path)
	local filename
	local instance
	local args = {}
	do
		local s, e = path:find("%?")
		s = s or 1
		e = e or #path + 1
		
		instance = path:sub(1, e - 1)

		do
			local x, y = path:find("^(%d+)@")
			if x and y then
				filename = path:sub(y + 1, e - 1)
			else
				filename = instance
			end
		end

		Log.info("Loading map %s (%s).", filename, instance or "no instance")

		local pathArguments = path:sub(e, -1)
		for key, value in pathArguments:gmatch("([%w_]+)=([%w_]+)") do
			Log.info("Map argument '%s' -> '%s'.", key, value)
			args[key] = value
		end
	end

	local oldMusic = self.music
	self.music = {}

	self:unloadAll()
	local oldLayerName = self.layerName
	self.layerName = path
	self.filename = filename

	do
		for i = 1, #oldMusic do
			local m = oldMusic[i]
			local hasSong = false
			for j = 1, #self.music do
				if self.music[j].channel == m.channel then
					hasSong = true
					break
				end
			end

			if not hasSong then
				self:stopMusic(self.layerName, m.channel, m.song)
			end
		end
	end

	self:loadMapResource(filename, args)
end

function Instance:getMap(layer)
	return self.map[layer]
end

function Instance:testMap(layer, ray, callback)
	local id = self.tests.id
	self.tests.id = id + 1

	self.tests[id] = {
		layer = layer,
		callback = callback
	}

	love.thread.getChannel('ItsyScape.Map::input'):push({
		type = 'probe',
		id = id,
		key = layer,
		origin = { ray.origin.x, ray.origin.y, ray.origin.z },
		direction = { ray.direction.x, ray.direction.y, ray.direction.z }
	})
end

function Instance:getInstances()
	local layers = {}
	for index in pairs(self.map) do
		if type(index) == 'number' then
			table.insert(layers, index)
		end
	end

	table.sort(layers)
	return layers
end

function Instance:getGravity()
	return self.gravity
end

function Instance:setGravity(value)
	self.gravity = value or self.gravity
end

function Instance:getItemsAtTile(i, j, layer)
	local ground = self.grounds[layer]
	if not ground then
		return {}
	end

	local inventory = ground:getBehavior(InventoryBehavior).inventory

	if not inventory or not inventory:getBroker() then
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

function Instance:dropItem(item, count, owner)
	local broker = self.game:getDirector():getItemBroker()
	local provider = broker:getItemProvider(item)
	local map = provider:getPeep():getInstanceName()
	local destination = self.grounds[map]:getBehavior(InventoryBehavior).inventory
	local transaction = broker:createTransaction()
	provider:getPeep():poke('dropItem', {
		item = item,
		count = count
	})

	transaction:addParty(provider)
	transaction:addParty(destination)
	transaction:transfer(destination, item, count, owner or 'drop', false)
	transaction:commit()
end

function Instance:takeItem(player, i, j, layer, ref)
	local ground = self.grounds[layer]
	if not ground then
		return
	end

	local inventory = ground:getBehavior(InventoryBehavior).inventory
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

function Instance:collectItems()
	local transactions = {}

	local broker = self.game:getDirector():getItemBroker()
	local manager = self.game:getDirector():getItemManager()

	for key, ground in pairs(self.grounds) do
		inventory = ground:getBehavior(InventoryBehavior).inventory
		if broker:hasProvider(inventory) then
			for item in broker:iterateItems(inventory) do
				-- In the ground table, grounds are stored by layer (number) and layer (string).
				if type(key) == 'string' then
					local owner = broker:getItemTag(item, "owner")
					if owner and owner:hasBehavior(PlayerBehavior) then
						local bank = owner:getBehavior(InventoryBehavior).bank

						if bank then
							local transaction = transactions[owner]
							if not transaction then
								transaction = broker:createTransaction()
								transaction:addParty(bank)

								transactions[owner] = transaction
							end

							transaction:addParty(inventory)
							transaction:transfer(bank, item, item:getCount(), 'take')

							if not item:isNoted() and manager:isNoteable(item:getID()) then
								transaction:note(bank, item:getID(), item:getCount())
							end
						end
					end


					local ref = broker:getItemRef(item)
					self.onTakeItem(self, { ref = ref, id = item:getID(), noted = item:isNoted() })
				end
			end
		end
	end

	for _, transaction in pairs(transactions) do
		local s, r = transaction:commit()
		if not s then
			Log.warn("Couldn't commit pickicide: %s", r)
		end
	end
end

function Instance:fireProjectile(projectileID, source, destination)
	function peepToModel(peep)
		if peep:isCompatibleType(require "ItsyScape.Peep.Peep") then
			local prop = peep:getBehavior(PropReferenceBehavior)
			if prop and prop.prop then
				return prop.prop
			end

			local actor = peep:getBehavior(ActorReferenceBehavior)
			if actor and actor.actor then
				return actor.actor
			end

			return Utility.Peep.getAbsolutePosition(peep)
		end

		return peep
	end

	self.onProjectile(self, projectileID, peepToModel(source), peepToModel(destination), 0)
end

function Instance:forecast(layer, name, id, props)
	self.onForecast(self, name, id, props)
	self.weathers[name] = true
end

function Instance:decorate(group, decoration, layer)
	self.onDecorate(self, group, decoration, layer or 1)
	self.decorations[group] = decoration
end

function Instance:getActor(key)
	return self.actors[key]
end

function Instance:iterateActors()
	return pairs(self.actors)
end

function Instance:getProp(key)
	return self.actors[key]
end

function Instance:iterateProps()
	return pairs(self.props)
end

function Instance:tick()
	for _, map in pairs(self.mapScripts) do
		local peep = map.peep

		local position = peep:getBehavior(PositionBehavior)
		if position then
			position = position.position
		else
			position = Vector.ZERO
		end

		local rotation = peep:getBehavior(RotationBehavior)
		if rotation then
			rotation = rotation.rotation
		else
			rotation = Quaternion.IDENTITY
		end

		local scale = peep:getBehavior(ScaleBehavior)
		if scale then
			scale = scale.scale
		else
			scale = Vector.ONE
		end

		self.onMapMoved(self, map.layer, position, rotation, scale)
	end
end

function Instance:update(delta)
	local m = love.thread.getChannel('ItsyScape.Map::output'):pop()
	while m do
		if m.type == 'probe' then
			local test = self.tests[m.id]
			if test then
				local map = self:getMap(test.layer)
				if map then
					self.tests[m.id] = nil
					local results = {}

					for i = 1, #m.tiles do
						local tile = m.tiles[i]
						local result = {
							[Map.RAY_TEST_RESULT_TILE] = map:getTile(tile.i, tile.j),
							[Map.RAY_TEST_RESULT_I] = tile.i,
							[Map.RAY_TEST_RESULT_J] = tile.j,
							[Map.RAY_TEST_RESULT_POSITION] = Vector(unpack(tile.position))
						}

						table.insert(results, result)
					end

					test.callback(results)
				end
			end
		end
		m = love.thread.getChannel('ItsyScape.Map::output'):pop()
	end
end

return Instance
