--------------------------------------------------------------------------------
-- ItsyScape/Game/ServerModel/Game.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Game = require "ItsyScape.Game.Model.Game"
local ServerPlayer = require "ItsyScape.Game.ServerModel.Player"
local ServerStage = require "ItsyScape.Game.ServerModel.Stage"
local ServerUI = require "ItsyScape.Game.ServerModel.UI"
local ItsyScapeDirector = require "ItsyScape.Game.ItsyScapeDirector"

local ServerGame = Class(Game)
ServerGame.TICKS_PER_SECOND = 10

function ServerGame:new(gameDB)
	Game.new(self)

	self.gameDB = gameDB
	self.stage = ServerStage(self)
	self.players = {}
	self.currentPlayerIndex = 1
	self.ui = ServerUI(self)
	self.director = ItsyScapeDirector(self, gameDB)
	self.ticks = 0

	self.pendingPlayers = {}
end

function ServerGame:getGameDB()
	return self.gameDB
end

function ServerGame:getDirector()
	return self.director
end

function ServerGame:getStage()
	return self.stage
end

function ServerGame:spawnPlayer(playerStorage)
	local index = self.currentPlayerIndex
	self.currentPlayerIndex = self.currentPlayerIndex + 1

	self.director:setPlayerStorage(index, playerStorage)

	local player = ServerPlayer(self, index)
	self.players[index] = player
	table.insert(self.pendingPlayers, player)

	return player
end

function ServerGame:getGameDB()
	return self.gameDB
end

function ServerGame:getPlayer(id)
	return self.players[id] or false
end

function ServerGame:getStage()
	return self.stage
end

function ServerGame:getUI()
	return self.ui
end

function ServerGame:getDirector()
	return self.director
end

function ServerGame:getTicks()
	return ServerGame.TICKS_PER_SECOND
end

function ServerGame:getCurrentTick()
	return self.ticks
end

function ServerGame:tick()
	for i = 1, #self.pendingPlayers do
		local player = self.pendingPlayers[i]
		player:spawn()
	end
	self.pendingPlayers = {}

	self.ticks = self.ticks + 1
	self.stage:tick()
	self.director:update(self:getDelta())
	self.ui:update(self:getDelta())
end

function ServerGame:update(delta)
	self.stage:update(delta)
end

return ServerGame
