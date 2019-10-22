--------------------------------------------------------------------------------
-- ItsyScape/Game/ClientModel/Game.lua
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
local Stage = require "ItsyScape.Game.Model.Stage"
local ClientActor = require "ItsyScape.Game.ClientModel.Actor"
local Channel = require "ItsyScape.Game.ServerModel.Channel"
local Decoration = require "ItsyScape.Graphics.Decoration"

local ClientStage = Class(Stage)

ClientStage.RPC = {}

function ClientStage.RPC:onLoadMap(layer, tileSetID, filename)
	local map = Map.loadFromFile(filename)

	self.maps[layer] = map
	self:onLoadMap(map, layer, tileSetID)
end

function ClientStage.RPC:onUnloadMap(layer)
	self:onUnloadMap(layer, self.maps[layer])
	self.maps[layer] = nil
end

function ClientStage.RPC:onMapModified(layer, map)
	map = Map.loadFromString(map)
	self:onMapModified(map)
end

function ClientStage.RPC:onMapMoved(layer, position, rotation, scale)
	position = Vector(unpack(position))
	rotation = Quaternion(unpack(rotation))
	scale = Vector(unpack(scale))

	self:onMapMoved(layer, position, rotation, scale)
end

function ClientStage.RPC:onDropItem(item, tile, position)
	position = Vector(unpack(position))

	self:onDropItem(item, tile, position)
end

function ClientStage.RPC:onTakeItem(item)
	self:onTakeItem(item)
end

function ClientStage.RPC:onWaterFlood(key, water, layer)
	self:onWaterFlood(key, water, layer)
end

function ClientStage.RPC:onWaterDrain(key)
	self:onWaterDrain(key)
end

function ClientStage.RPC:onForecast(key, id, props)
	self:onForecast(key, id, props)
end

function ClientStage.RPC:onPlayMusic(track, song)
	self:onPlayMusic(track, song)
end

function ClientStage.RPC:onStopMusic(track)
	self:onStopMusic(track)
end

function ClientStage:onProjectile(projectileID, source, destination)
	-- TODO
end

function ClientStage:onDecorate(key, decoration, layer, filename)
	if filename then
		self:onDecorate(key, Decoration(filename), layer)
	else
		local chunk = assert(loadstring(data))
		local result = setfenv(chunk, {})() or {}
		self:onDecorate(key, result, layer)
	end
end

function ClientStage.RPC:tick()
	self.game:onChannelTick(Channel.CHANNEL_STAGE)
end

function ClientStage.RPC:onActorX(event)
	if event.call == 'onSpawned' then
		local actor = ClientActor()
		actor:dispatch(event)

		self.actors[actor:getID()] = actor
	elseif event.call == 'tick' then
		self.game:onChannelTick(Channel.CHANNEL_ACTOR)
	else
		local actor = self.actors[event.id]
		if not actor then
			Log.warn("Received RPC %s for actor %d, but actor not found.", event.call, event.id)
		end

		actor:dispatch(event)
	end
end

function ClientStage:new(game)
	Stage.new(self)

	self.game = game
	self.maps = {}
	self.actors = {}
end

function ClientStage:dispatch(channel, event)
	if channel == Channel.CHANNEL_STAGE then
		local func = ClientStage.RPC[event.call]
		if func then
			func(self, unpack(event.n, event))
		end
	elseif channel == Channel.CHANNEL_ACTOR then
		self:onActorX(event)
	end
end

return ClientStage
