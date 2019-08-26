--------------------------------------------------------------------------------
-- ItsyScape/Game/ClientModel/Player.lua
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
local Player = require "ItsyScape.Game.Model.Player"
local Channel = require "ItsyScape.Game.ServerModel.Channel"
local RPC = require "ItsyScape.Game.ServerModel.RPC"
local PlayerBehavior = require "ItsyScape.Peep.Behaviors.PlayerBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local CombatTargetBehavior = require "ItsyScape.Peep.Behaviors.CombatTargetBehavior"
local CombatCortex = require "ItsyScape.Peep.Cortexes.CombatCortex"
local MapPathFinder = require "ItsyScape.World.MapPathFinder"
local ExecutePathCommand = require "ItsyScape.World.ExecutePathCommand"

local ClientPlayer = Class(Player)

ClientPlayer.RPC = {}
function ClientPlayer.RPC:_setIsEngaged(value)
	self.isEngaged = value
end

-- Constructs a new player.
--
-- The Actor isn't created until ClientPlayer.spawn is called.
function ClientPlayer:new(game)
	self.game = game
	self.isEngaged = false
end

function ClientPlayer:spawn(id)
	local stage = self.game:getStage()
	self.actor = self.game:getActor(id)
end

function ClientPlayer:poof()
	self.actor = false
end

-- Gets the Actor this ClientPlayer is represented by.
function ClientPlayer:getActor()
	return self.actor
end

function ClientPlayer:flee()
	local event = RPC("flee", 0)
	event:send(self.game:getServer(), Channel.CHANNEL_PLAYER)
end

function ClientPlayer:getIsEngaged()
	return self.isEngaged
end

-- Moves the player to the specified position on the map via walking.
function ClientPlayer:walk(i, j, k)
	local event = RPC("walk", 0, i, j, k)
	event:send(self.game:getServer(), Channel.CHANNEL_PLAYER)
end

function ClientPlayer:dispatch(event)
	local func = ClientActor.RPC[event.call]
	if func then
		func(self, unpack(event.n, event))
	end
end

return ClientPlayer
