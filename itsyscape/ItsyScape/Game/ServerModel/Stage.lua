--------------------------------------------------------------------------------
-- ItsyScape/Game/ServerModel/Stage.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Stage = require "ItsyScape.Game.Model.Stage"
local Event = require "ItsyScape.Game.ServerModel.Event"
local Instance = require "ItsyScape.Game.ServerModel.Instance"
local RPC = require "ItsyScape.Game.ServerModel.RPC"
local PlayerBehavior = require "ItsyScape.Peep.Behaviors.PlayerBehavior"
local MapResourceReferenceBehavior = require "ItsyScape.Peep.Behaviors.MapResourceReferenceBehavior"

local ServerStage = Class(Stage)

function ServerStage:new(game)
	Stage.new(self)

	self.currentPropID = 1
	self.currentActorID = 1
	self.currentLayerID = 1

	self.instances = {}
	self.instanceToName = {}
	self.uniqueInstanceID = 1
	self.state = {}

	self.players = {}
end

function ServerStage:preloadInstance(path)
	local isUniqueInstance = path:match("^@")

	local instance
	if isUniqueInstance then
		instance = self:preloadUniqueInstance(path)
	else
		instance = self:preloadStaticInstance(path)
	end

	if instance then
		self:connectInstance(instance)
	end

	return instance
end

function ServerStage:connectInstance(instance)
	self.state[instance] = {
		map = {},
		mapTransform = {},
		actors = {},
		props = {}
	}

	instance.onLoadMap:register(self._onLoadMap, self)
	instance.onUnloadMap:register(self._onUnloadMap, self)
	instance.onMapModified:register(self._onMapModified, self)
	instance.onMapMoved:register(self._onMapMoved, self)
	instance.onActorSpawned:register(self._onActorSpawned, self)
	instance.onActorKilled:register(self._onActorKilled, self)
	instance.onDropItem:register(self._onDropItem, self)
	instance.onTakeItem:register(self._onTakeItem, self)
	instance.onPropPlaced:register(self._onPropPlaced, self)
	instance.onPropRemoved:register(self._onPropRemoved, self)
	instance.onWaterFlood:register(self._onWaterFlood, self)
	instance.onWaterDrain:register(self._onWaterDrain, self)
	instance.onForecast:register(self._onForecast, self)
	instance.onPlayMusic:register(self._onPlayMusic, self)
	instance.onStopMusic:register(self._onStopMusic, self)
	instance.onProjectile:register(self._onProjectile, self)
	instance.onDecorate:register(self._onDecorate, self)
end

function ServerStage:connectActor(instance, actor)
	actor.onDirectionChanged:register(self._onActorDirectionChanged, self, instance)
	actor.onMove:register(self._onActorMove, self, instance)
	actor.onTeleport:register(self._onActorTeleport, self, instance)
	actor.onAnimationPlayed:register(self._onActorAnimationPlayed, self, instance)
	actor.onTransmogrified:register(self._onActorTransmogrified, self, instance)
	actor.onSkinChanged:register(self._onActorSkinChanged, self, instance)
	actor.onDamage:register(self._onActorDamage, self, instance)
	actor.onHUDMessage:register(self._onActorHUDMessage, self, instance)
end

function ServerStage:getInstance(instanceName)
	return self.instances[instanceName]
end

function ServerStage:_onLoadMap(instance, map, layer, tileSetID, filename)
	local state = self.state[instance]
	state:onLoadMap(map, layer, tileSetID, filename)
end

function ServerStage:_onUnloadMap(instance, map, layer)
	local state = self.state[instance]
	state:onUnloadMap(map, layer)
end

function ServerStage:_onMapModified(instance, map, layer)
	local state = self.state[instance]
	state:onMapModified(map, layer)
end

function ServerStage:_onMapMoved(instance, layer, position, rotation, scale)
	local state = self.state[instance]
	state:onMapMoved(layer, position, rotation, scale)
end

function ServerStage:_onActorSpawned(instance, actorID, actor)
	local state = self.state[instance]
	state:onActorSpawned(actorID)
end

function ServerStage:_onActorKilled(instance, actor)
	local state = self.state[instance]
	state:onActorKilled(actor)
end

function ServerStage:_onDropItem(instance, item, tile, position)
	local state = self.state[instance]
	state:onDropItem(item, tile, position)
end

function ServerStage:_onTakeItem(instance, item)
	local state = self.state[instance]
	state:onTakeItem(item)
end

function ServerStage:_onPropPlaced(instance, propID, prop)
	-- TODO
end

function ServerStage:_onPropRemoved(instance, prop)
	-- TODO
end

function ServerStage:_onWaterFlood(instance, key, water, layer)
	local state = self.state[instance]
	state:onWaterFlood(key, water, layer)
end

function ServerStage:_onWaterDrain(instance, key)
	local state = self.state[instance]
	state:onWaterDrain(key)
end

function ServerStage:_onForecast(instance, key, id, props)
	local state = self.state[instance]
	state:onForecast(key, water, id, props)
end

function ServerStage:_onPlayMusic(instance, track, song)
	local state = self.state[instance]
	state:onPlayMusic(track, song)
end

function ServerStage:_onStopMusic(instance, track)
	local state = self.state[instance]
	state:onStopMusic(track)
end

function ServerStage:_onProjectile(instance, projectileID, source, destination, time)
	local state = self.state[instance]
	state:onProjectile(projectileID, source, destination)
end

function ServerStage:_onDecorate(instance, group, decoration, layer, filename)
	local state = self.state[instance]
	state:onDecorate(group, decoration, layer, filename)
end

function ServerStage:_onActorDirectionChanged(self, instance, actor, direction, rotation)
	local state = self.state[instance]
	state:onActorDirectionChanged(actor, direction, rotation)
end

function ServerStage:_onActorMove(self, instance, actor, position, layer)
	local state = self.state[instance]
	state:onActorMove(actor, position, layer)
end

function ServerStage:_onActorTeleport(self, instance, actor, position)
	local state = self.state[instance]
	state:onActorTeleport(actor, position)
end

function ServerStage:_onActorAnimationPlayed(self, instance, actor, slot, priority, animation, force)
	local state = self.state[instance]
	state:onActorAnimationPlayed(actor, slot, priority, animation, force)
end

function ServerStage:_onActorTransmogrified(self, instance, actor, body)
	local state = self.state[instance]
	state:onActorTransmogrified(actor, body)
end

function ServerStage:_onActorSkinChanged(self, instance, actor, slot, priority, skin)
	local state = self.state[instance]
	state:onActorSkinChanged(actor, slot, priority, skin)
end

function ServerStage:_onActorDamage(self, instance, actor, damageType, damage)
	local state = self.state[instance]
	state:onActorDamage(actor, damageType, damage)
end

function ServerStage:_onActorHUDMessage(self, instance, actor, ...)
	local state = self.state[instance]
	state:onActorHUDMessage(actor, ...)
end

function ServerStage:preloadUniqueInstance(path)
	local index = self.uniqueInstanceID
	self.uniqueInstanceID = self.uniqueInstanceID + 1

	path = string.format("%d%s", index, path)

	local instance = Instance(self.game, self, path)
	self.instances[path] = instance
	self.instanceToName[instance] = path
	self.state[instance] = self:makeState(instance)

	return instance
end

function ServerStage:preloadStaticInstance(path)
	local instance = self.instances[path]
	if not instance then
		instance = Instance(self.game, self, path)
		self.instanceToName[instance] = path
		self.state[instance] = self:makeState(instance)
	end

	return instance
end

function ServerStage:spawnActor(actor, path, anchor)
	local instanceName self:preloadInstance(path)
	local instance = self.instances[instanceName]

	if instance then
		local success, actor = instance:spawnActor(actor, path)
		if success then
			actor:getPeep():listen('finalize', function(peep)
				self:movePeep(peep, path, anchor)
			end)
		end

		return success, actor
	end
end

function ServerStage:movePeep(peep, path, anchor)
	local from, to

	local currentInstanceName
	do
		currentInstanceName = peep:getLayerName()

		local currentInstance =  self.instances[currentInstanceName]
		if currentInstance and path ~= currentInstanceName then
			currentInstance:moveActorFrom(peep)
			from = currentInstance:getFilename()

			if peep:hasBehavior(PlayerBehavior) then
				local playerID = peep:getBehavior(PlayerBehavior).id
				local player = self.game:getPlayer(playerID)
				if player then
					local players = self.players[currentInstanceName]
					if players then
						players[player] = nil
					end
				end
			end
		end
	end

	do
		local newInstanceName = self:preloadInstance(path)

		local newInstance = self.instances[newInstanceName]
		if newInstance and newInstanceName ~= currentInstanceName then
			newInstance:moveActorTo(peep)
			to = newInstance:getFilename()
		end

		peep:poke('travel', {
			from = from,
			to = to
		})

		if to and to ~= "" then
			local resource = self.game:getGameDB():getResource(to, "Map")

			local s, m = peep:addBehavior(MapResourceReferenceBehavior)
			if s then
				m.map = resource or false
			end
		else
			peep:removeBehavior(MapResourceReferenceBehavior)
		end

		do
			if Class.isType(anchor, Vector) then
				position.position = Vector(anchor.x, anchor.y, anchor.z)
			else
				local gameDB = self.game:getGameDB()
				local map = gameDB:getResource(newInstance:getFilename(), "Map")
				if map then
					local mapObject = gameDB:getRecord("MapObjectLocation", {
						Name = anchor,
						Map = map
					})

					local x, y, z = mapObject:get("PositionX"), mapObject:get("PositionY"), mapObject:get("PositionZ")
					position.position = Vector(x, y, z)
				end
			end
		end

		if peep:hasBehavior(PlayerBehavior) and path ~= newInstanceName then
			local playerID = peep:getBehavior(PlayerBehavior).id
			local player = self.game:getPlayer(playerID)
			if player then
				local players = self.players[newInstanceName] or {}
				players[player] = true

				self.players[newInstanceName] = players
			end
		end
	end
end

function ServerStage:getNextPropID()
	local result = self.currentPropID
	self.currentPropID = self.currentPropID + 1

	return result
end

function ServerStage:getNextActorID()
	local result = self.currentActorID
	self.currentActorID = self.currentActorID + 1

	return result
end

function ServerStage:getNewLayer()
	local result = self.currentLayerID
	self.currentLayerID = self.currentLayerID + 1

	return result
end

function ServerStage:takeItem(player, i, j, layer, ref)
	local instanceName = player:getActor():getPeep():getLayerName()
	local instance = self.instances[instanceName]
	instance:takeItem(player, i, j, layer, ref)
end

function ServerStage:tick()
	local pendingRemoval = {}

	for name, instance in pairs(self.instances) do
		instance:tick()

		if instance:getPlayerCount() == 0 then
			pendingRemoval[name] = instance
		end
	end

	for name, instance in pairs(pendingRemoval) do
		instance:unloadAll()
		self.instances[name] = nil
		self.instanceToName[instance] = nil
		self.state[instance] = nil
		self.players[name] = nil
	end
end

function ServerStage:update(delta)
	for _, instance in pairs(self.instances) do
		instance:update(delta)
	end
end

return ServerStage
