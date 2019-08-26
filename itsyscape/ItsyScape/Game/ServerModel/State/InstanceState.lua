--------------------------------------------------------------------------------
-- ItsyScape/Game/ServerModel/State/InstanceState.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local RPC = require "ItsyScape.Game.ServerModel.RPC"
local Channel = require "ItsyScape.Game.ServerModel.Channel"

local InstanceState = Class()

InstanceState.MapState = Class()
function InstanceState.MapState:new()
	self.maps = {}
	self.transforms = {}
end

function InstanceState.MapState:onLoadMap(layer, tileSetID, filename)
	self.maps[layer] = {
		load = RPC('onLoadMap', layer, tileSetID, filename),
		modify = false,
		layer = layer,
		tileSetID = tileSetID,
		filename = filename
	}
end

function InstanceState.MapState:onMapModified(layer, map)
	local map = self.maps[layer]
	if not map then
		map = { layer = layer }
		self.maps[layer] = map
	end

	map.modify = RPC('onMapModified', layer, map:toString())
end

function InstanceState.MapState:onMapMoved(layer, position, rotation, scale)
	self.transforms[layer] = RPC(
		'onMapMoved',
		layer,
		{ position.x, position.y, position.z },
		{ rotation.x, rotation.y, rotation.z, rotation.w },
		{ scale.x, scale.y, scale.z })
end

function InstanceState.MapState:onUnloadMap(layer)
	self.maps[layer] = nil
	self.transforms[layer] = nil
end

function InstanceState.MapState:send(player)
	local playerState = player:getState()
	local maps = playerState.maps
	if not maps then
		maps = {}
		playerState.maps = maps
	end

	-- First, unload stale maps. A stale map is a map that is no longer
	-- instantiated for the player.
	do
		local unloaded = {}
		for layer, state in pairs(maps) do
			if not self.maps[layer] then
				local event = RPC('onUnloadMap', layer)
				event:send(player, Channel.CHANNEL_STAGE)
				table.insert(unloaded, layer)
			end
		end

		for i = 1, #unloaded do
			maps[layer] = nil
		end
	end

	-- Next, load and modify new or updated maps.
	for layer, selfState in pairs(self.maps) do
		local otherState = maps[layer]
		if not otherState then
			if selfState.load then
				selfState.load:send(player, Channel.CHANNEL_STAGE)
			end

			if selfState.modify then
				selfState.modify:send(player, Channel.CHANNEL_STAGE)
			end

			otherState = {
				load = selfState.load,
				modify = selfState.modify
			}

			maps[layer]= otherState
		else
			if otherState.load ~= selfState.load then
				selfState.load:send(player, Channel.CHANNEL_STAGE)
				otherState.load = selfState.load
			end

			if otherState.modify ~= selfState.modify then
				selfState.modify:send(player, Channel.CHANNEL_STAGE)
				otherState.modify = selfState.modify
			end
		end
	end

	-- Lastly, update the map transforms.
	for layer, transform in pairs(self.transforms) do
		local otherState = maps[layer]
		if not otherState then
			otherState = {}
			maps[layer] = otherState
		end

		if otherState.transform ~= transform then
			transform:send(player, Channel.CHANNEL_STAGE)
		end
	end

	RPC('tick', 0):send(player, Channel.CHANNEL_STAGE)
end

function InstanceState.ActorState:new()
	self.id = false
	self.dead = false
	self.animations = {}
	self.skin = {}
	self.damage = {}
	self.messages = {}
end

function InstanceState.ActorState:getIsAlive()
	return not self.dead
end

function InstanceState.ActorState:onSpawn(actorID)
	self.spawn = RPC(
		'onActorSpawned',
		actorID)
	self.id = actorID
end

function InstanceState.ActorState:onKilled()
	self.spawn = RPC(
		'onActorKilled',
		self.id)
	self.dead = true
end

function InstanceState.ActorState:onDirectionChanged(direction, rotation)
	if rotation then
		self.direction = RPC(
			'onDirectionChanged',
			self.id,
			direction,
			{ rotation.x, rotation.y, rotation.z, rotation.w })
	else
		self.direction = RPC('onDirectionChanged', self.id, direction, nil)
	end
end

function InstanceState.ActorState:onActorMove(position, layer)
	self.position = RPC(
		'onActorMove',
		self.id,
		{ position.x, position.y, position.z },
		layer)
end

function InstanceState.ActorState:onActorTeleport(position, layer)
	self.position = RPC(
		'onActorTeleport',
		self.id,
		{ position.x, position.y, position.z },
		layer)
end

function InstanceState.ActorState:onAnimationPlayed(slot, priority, animation, force)
	if not priority then
		self.animations[slot] = {
			priority = false,
			rpc = RPC(
				'onAnimationPlayed',
				self.id,
				slot,
				nil,
				force)
		}
	else
		local currentAnimation = self.animations[slot]
		if not currentAnimation then
			self.animations[slot] = {
				priority = priority,
				animation = animation,
				time = love.timer.getTime(),
				rpc = RPC(
					'onAnimationPlayed',
					self.id,
					slot,
					{ type = animation:getResourceTypeID(), filename = animation:getFilename() },
					force)
			}
		else
			if currentAnimation.priority <= priority or force then
				self.animations[slot] = {
					priority = priority,
					animation = animation,
					time = love.timer.getTime(),
					rpc = RPC(
						'onAnimationPlayed',
						self.id,
						slot,
						{ type = animation:getResourceTypeID(), filename = animation:getFilename() },
						force)
				}
			end
		end
	end
end

function InstanceState.ActorState:onTransmogrified(body)
	if body then
		self.body = RPC(
			'onTransmogrified',
			self.id,
			{ type = body:getResourceTypeID(), filename = body:getFilename() })
	else
		self.body = RPC(
			'onTransmogrified',
			self.id,
			nil)
	end
end

function InstanceState.ActorState:onSkinChanged(slot, priority, skin)
	local s = self.skin[slot]
	if priority then
		if skin then
			table.insert(s, {
				priority = priority,
				skin = skin,
				rpc = RPC(
					'onSkinChanged',
					self.id,
					slot,
					priority,
					{ type = skin:getResourceTypeID(), filename = skin:getFilename() })
			})
		end
	else
		for i = 1, #s do
			if s[i].skin == skin then
				table.remove(s, i)
				break
			end
		end
	end
end

function InstanceState.ActorState:onDamage(damageType, damage)
	table.insert(
		self.damage,
		RPC(
			'onDamage',
			self.id,
			damageType,
			damage))
end

function InstanceState.ActorState:onHUDMessage(message, ...)
	table.insert(
		self.messages,
		RPC('onHUDMessage',
			self.id,
			message,
			...))
end

function InstanceState.ActorState:tick(actor)
	if actor:getActionSourceID() ~= self.source then
		self.source = actor:getActionSourceID()
		local actions = actor:getActions()

		local a = {}
		for i = 1, #actions do
			table.insert(a, {
				id = actions[i].id,
				type = actions[i].type,
				verb = actions[i].verb
			})
		end

		self.actions = RPC('_setActions', self.id, a)
	end

	if actor:getName() ~= self.name then
		self.name = RPC('_setName', self.id, actor:getName())
	end

	do
		local min, max = actor:getBounds()
		self.bounds = RPC('_setBounds',
			self.id,
			{ x = min.x, y = min.y, z = min.z },
			{ x = max.x, y = max.y, z = max.z })
	end

	do
		local min, max = actor:getBounds()
		self.tile = RPC('_setTile', self.id, actor:getTile())
	end

	self.hitpoints = RPC('_setHitpoints', actor:getCurrentHitpoints(), actor:getMaximumHitpoints())

	self.messages = {}
	self.damage = {}
end

function InstanceState.ActorState:send(player)
	local state = player:getState()
	local actor = state.actors[self.id]

	if not actor and self.id then
		if self.spawn and self:getIsAlive() then
			self.spawn:send(player, Channel.CHANNEL_ACTOR)
		end

		actor = {
			animations = {},
			skin = {},
			spawn = self.spawn
		}

		state.actors[self.id] = actor
	end

	if not self:getIsAlive() then
		RPC('onKilled', self.id):send(player, Channel.CHANNEL_ACTOR)
	end

	if self.position ~= actor.position and self.position then
		self.position:send(player, Channel.CHANNEL_ACTOR)
	end

	if actor.actions ~= self.actions and self.actions then
		self.actions:send(player, Channel.CHANNEL_ACTOR)
	end

	if actor.name ~= self.name and self.name then
		self.name:send(player, Channel.CHANNEL_ACTOR)
	end

	if actor.direction ~= self.direction and self.direction then
		self.direction:send(player, Channel.CHANNEL_ACTOR)
	end

	if actor.bounds ~= self.bounds and self.bounds then
		self.bounds:send(player, Channel.CHANNEL_ACTOR)
	end

	if actor.hitpoints ~= self.hitpoints and self.hitpoints then
		self.hitpoints:send(player, Channel.CHANNEL_ACTOR)
	end

	if actor.tile ~= self.tile and self.tile then
		self.tile:send(player, Channel.CHANNEL_ACTOR)
	end

	for i = 1, #self.damage do
		self.damage[i]:send(player, Channel.CHANNEL_ACTOR)
	end

	for i = 1, #self.messages do
		self.messages[i]:send(player, Channel.CHANNEL_ACTOR)
	end

	for slot, animation in pairs(actor.animations) do
		local otherAnimation = actor.animations[slot]
		if otherAnimation then
			if animation.animation ~= otherAnimation.animation then
				if animation.priority then
					local time = love.timer.getTime() - animation.time
					local rpc = RPC(
						'onAnimationPlayed',
						self.id,
						animation.priority,
						{ type = animation.animation:getResourceTypeID(), filename = animation.animation:getFilename() },
						time)
					rpc:send(player, Channel.CHANNEL_ACTOR)
				else
					animation.rpc:send(player, Channel.CHANNEL_ACTOR)
				end
			end
		end
	end

	for slot, playerSlot in pairs(actor.skins) do
		local removed = {}

		for _, playerSkin in ipairs(playerSlot) do
			local hasSkin = false
			for index, selfSkin in self.skins[slot] do
				if selfSkin.skin == playerSkin.skin and selfSkin.priority == playerSkin.priority then
					hasSkin = true
					break
				end
			end

			if not hasSkin then
				local rpc = RPC(
					'onSkinChanged',
					self.id,
					slot,
					false,
					{ type = selfSkin.skin:getResourceTypeID(), filename = selfSkin.skin:getFilename() })
				rpc:send(player, Channel.CHANNEL_ACTOR)
				table.insert(removed, index)
			end
		end

		for i = 1, #removed do
			table.remove(playerSlot, removed[i])
		end
	end

	for slot, selfSlot in pairs(self.skins) do
		for _, selfSkin in ipairs(selfSlot) do
			local hasSkin = false
			for _, playerSkin in actor.skins[slot] do
				if selfSkin.skin == playerSkin.skin and selfSkin.priority == playerSkin.priority then
					hasSkin = true
					break
				end
			end

			if not hasSkin then
				selfSkin.rpc:send(player, Channel.CHANNEL_ACTOR)
			end
		end
	end
end

function InstanceState:new(instance)
	self.instance = instance
	self.map = InstanceState.MapState()
	self.actors = {}
end

function InstanceState:onLoadMap(map, layer, tileSetID, filename)
	self.map:onLoadMap(layer, tileSetID, filename)
end

function InstanceState:onUnloadMap(map, layer)
	self.map:onUnloadMap(layer)
end

function InstanceState:onMapModified(map, layer)
	self.map:onMapModified(layer, map)
end

function InstanceState:onMapMoved(layer, position, rotation, scale)
	self.map:onMapMoved(layer, position, rotation, scale)
end

function InstanceState:onActorSpawned(actorID, actor)
	local actor = InstanceState.ActorState()
	actor:onSpawn(actorID)

	self.actors[actorID] = actor
end

function InstanceState:onActorKilled(actor)
	local actor = self.actors[actor:getID()]
	if actor then
		actor:onKilled()
	end
end

function InstanceState:onActorDirectionChanged(direction, rotation)
	local actor = self.actors[actor:getID()]
	if actor then
		actor:onDirectionChanged(direction, rotation)
	end
end

function InstanceState:onActorMove(position)
	local actor = self.actors[actor:getID()]
	if actor then
		actor:onMove(position)
	end
end

function InstanceState:onActorTeleport(position)
	local actor = self.actors[actor:getID()]
	if actor then
		actor:onTeleport(position)
	end
end

function InstanceState:onActorAnimationPlayed(slot, priority, animation, force)
	local actor = self.actors[actor:getID()]
	if actor then
		actor:onAnimationPlayed(slot, priority, animation, force)
	end
end

function InstanceState:onActorTransmogrified(body)
	local actor = self.actors[actor:getID()]
	if actor then
		actor:onTransmogrified(body)
	end
end

function InstanceState:onActorSkinChanged(slot, priority, skin)
	local actor = self.actors[actor:getID()]
	if actor then
		actor:onSkinChanged(slot, priority, skin)
	end
end

function InstanceState:onActorDamage(damageType, damage)
	local actor = self.actors[actor:getID()]
	if actor then
		actor:onDamage(damageType, damage)
	end
end

function InstanceState:onActorHUDMessage(message, ...)
	local actor = self.actors[actor:getID()]
	if actor then
		actor:onHUDMessage(message, ...)
	end
end

function InstanceState:send(player)
	self.map:send(player)

	for id, actor in pairs(self.actors) do
		actor:send(player)
	end

	RPC('tick', 0):send(player, Channel.CHANNEL_ACTOR)
end

function InstanceState:tick()
	local deadActors = {}
	for id, actor in pairs(self.actors) do
		if not actor:getIsAlive() then
			table.insert(deadActors, id)
		else
			self.actors:tick(actor)
		end
	end

	for i = 1, #deadActors do
		self.actors[deadActors[i]] = nil
	end
end

return InstanceState
