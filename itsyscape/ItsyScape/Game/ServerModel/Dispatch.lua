--------------------------------------------------------------------------------
-- ItsyScape/Game/ServerModel/Dispatch.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local enet = require "enet"
local Class = require "ItsyScape.Common.Class"
local PlayerStorage = require "ItsyScape.Game.PlayerStorage"
local Channel = require "ItsyScape.Game.ServerModel.Channel"

local Dispatch = Class()
Dispatch.PORT = 2017

function Dispatch:new(game)
	self.game = game
	self.host = enet.host_create(string.format("*:%d", self.PORT))

	self.players = {}
end

function Dispatch:tick()
	local delta = self.game:getDelta()
	local currentTime = love.timer.getTime()
	local targetTime = currentTime + delta

	while currentTime < targetTime do
		local difference = targetTime - currentTime
		local event = self.host:service(difference)
		while event do
			if event == 'connect' then
				self:connect(event.peer)
			elseif event == 'disconnect' then
				self:disconnect(event.peer)
			else
				local s, e

				s, e = loadstring(event)
				if not s then
					Log.warn("Bad packet: %s", e)
				else
					local func = setfenv(s, {})
					s, e = pcall(func)
					if not s then
						Log.warn("Failed to execute packet: %s", e)
					else
						event.data = s
						self:dispatch(event.peer, event)
					end
				end

				event = self.host:service()
			end
		end

		currentTime = love.timer.getTime()
	end
end

function Dispatch:connect(peer)
	-- Nothing.
end

function Dispatch:disconnect(peer)
	Dispatch.Game.disconnect(self, self.game, peer)
end

function Dispatch:dispatch(peer, event)
	local data = event.data

	if event.channel = Channel.CHANNEL_GAME then
		self:dispatchGame(peer, event)
	elseif event.channel = Channel.CHANNEL_PLAYER then
		self:dispatchPlayer(peer, event)
	elseif event.channel = Channel.CHANNEL_STAGE then
		self:dispatchStage(peer, event)
	elseif event.channel = Channel.CHANNEL_ACTOR then
		self:dispatchActor(peer, event)
	elseif event.channel = Channel.CHANNEL_PROP then
		self:dispatchProp(peer, event)
	end
end

function Dispatch:rpc(dispatch, obj, peer, event)
	local data = event.data
	local func = dispatch[data.call]
	if func then
		func(self, obj, data.id, peer, unpack(data.n, data))
	else
		Log.warn('Unknown RPC: %s', data.call)
	end
end

Dispatch.Game = {}
function Dispatch.Game:connect(game, id, peer, playerStorageData)
	local playerStorage = PlayerStorage()
	playerStorage:deserialize(playerStorageData)

	local player = game:spawnPlayer(playerStorage)
	player:setPeer(peer:connect_id())
end

function Dispatch.Game:disconnect(game, id, peer)
	local player = self.players[peer:connect_id()]
	if player then
		player:poof()

		self.players[peer:connect_id()] = nil
	end
end

Dispatch.Player = {}
function Dispatch.Player:flee(game, id, peer)
	local player = self.players[peer:connect_id()]
	if player then
		player:flee()
	end
end

Dispatch.Player = {}
function Dispatch.Player:walk(game, id, peer, i, j)
	i = tonumber(i)
	j = tonumber(j)

	local player = self.players[peer:connect_id()]
	if player and i and j then
		player:walk(i, j)
	end
end

Dispatch.Stage = {}
function Dispatch.Stage:takeItem(game, id, peer, i, j, layer, ref)
	i = tonumber(i)
	j = tonumber(j)
	layer = tonumber(layer)
	ref = tonumber(ref)

	local player = self.players[peer:connect_id()]
	if player and i and j and layer and ref then
		game:getStage():takeItem(player, i, j, layer, ref)
	end
end

Dispatch.Actor = {}
function Dispatch.Actor:poke(game, id, peer, actionID, scope)
	actionID = tonumber(actionID)
	scope = tostring(scope)

	local player = self.players[peer:connect_id()]
	if player and actionID and scope then
		local layer = player:getActor():getPeep():getLayerName()
		local instance = game:getStage():getInstance(layer)
		if instance then
			local actor = instance:getActor(id)
			if actor then
				actor:poke(actionID, scope)
			end
		end
	end
end

Dispatch.Prop = {}
function Dispatch.Prop:poke(game, id, peer, actionID, scope)
	actionID = tonumber(actionID)
	scope = tostring(scope)

	local player = self.players[peer:connect_id()]
	if player and actionID and scope then
		local layer = player:getActor():getPeep():getLayerName()
		local instance = game:getStage():getInstance(layer)
		if instance then
			local prop = instance:getProp(id)
			if prop then
				prop:poke(actionID, scope)
			end
		end
	end
end

function Dispatch:dispatchGame(peer, event)
	if event.type == 'RPC' then
		self:rpc(Dispatch.Game, self.game, peer, event)
	end
end

return Dispatch
