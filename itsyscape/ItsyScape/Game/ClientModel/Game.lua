--------------------------------------------------------------------------------
-- ItsyScape/Game/ClientModel/Game.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local enet = require "enet"
local Class = require "ItsyScape.Common.Class"
local Game = require "ItsyScape.Game.Model.Game"
local ClientStage = require "ItsyScape.Game.ClientModel.Stage"
local ClientPlayer = require "ItsyScape.Game.ClientModel.Player"
local Channel = require "ItsyScape.Game.ServerModel.Channel"
local RPC = require "ItsyScape.Game.ServerModel.RPC"

local ClientGame = Class(Game)

ClientGame.RPC = {}
function ClientGame.RPC:saveGame(playerStorage)
	Log.warn("Saving game via network not yet implemented.")
end

function ClientGame:new(address, playerStorage)
	self.isConnected = false
	self.playerStorage = playerStorage

	self.server = enet.host_create()
	self.peer = self.server:connect(address)

	self.stage = ClientStage(self)
	self.player = ClientPlayer(self)

	self.ticks = {}
end

function ClientGame:getStage()
	return self.stage
end

function ClientGame:getPlayer()
	return self.player
end

function ClientGame:getIsConnected()
	return self.isConnected
end

function ClientGame:connect()
	local event = RPC('connect', 0, self.playerStorage:serialize())
	event:send(self.peer, Channel.CHANNEL_GAME)
end

function ClientGame:disconnect()
	self.isConnected = false
end

function ClientGame:onChannelTick(channel)
	self.ticks[channel] = self.ticks[channel] + 1
end

function ClientGame:getShouldTick()
	local hasTick = true
	for _, index in pairs(Channel) do
		local tick = self.ticks[index] or 0
		if tick <= 0 then
			hasTick = false
			break
		end
	end

	return hasTick
end

function ClientGame:getTicks()
	return 10
end

function ClientGame:tick()
	for _, index in pairs(Channel) do
		self.ticks[index] = math.max((self.ticks[index] or 0) - 1, 0)
	end
end

function ClientGame:update()
	local event = self.server:service(0)
	while event do
		if event.type == 'connect' then
			self:connect()
		elseif event.type == 'disconnect' then
			self:disconnect()
		else
			local s, e

			s, e = pcall(loadstring, event.data)
			if not s then
				Log.warn("Bad packet: %s", e)
			else
				local func = setfenv(e, {})
				s, e = pcall(func)
				if not s then
					Log.warn("Failed to execute packet: %s", e)
				else
					event.data = s
					self:dispatch(event)
				end
			end
		end

		event = self.server:service()
	end
end

function ClientGame:dispatch(event)
	if event.channel == Channel.CHANNEL_GAME then
		local func = ClientGame.RPC[event.call]
		if func then
			func(self, unpack(event.n, event))
		end
	elseif event.channel == Channel.CHANNEL_PLAYER then
		self.player:dispatch(event.data)
	else
		self.stage:dispatch(event.channel, event.data)
	end
end

return ClientGame
