--------------------------------------------------------------------------------
-- ItsyScape/Game/ServerModel/Player.lua
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
local PlayerBehavior = require "ItsyScape.Peep.Behaviors.PlayerBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local CombatTargetBehavior = require "ItsyScape.Peep.Behaviors.CombatTargetBehavior"
local CombatCortex = require "ItsyScape.Peep.Cortexes.CombatCortex"
local MapPathFinder = require "ItsyScape.World.MapPathFinder"
local ExecutePathCommand = require "ItsyScape.World.ExecutePathCommand"

local ServerPlayer = Class(Player)

-- Constructs a new player.
--
-- The Actor isn't created until ServerPlayer.spawn is called.
function ServerPlayer:new(game, index)
	self.game = game
	self.stage = game:getStage()
	self.index = index
	self.actor = false
	self.peer = false
	self.state = {}
end

function ServerPlayer:getPeer()
	return self.peer
end

function ServerPlayer:setPeer(value)
	self.peer = value or false
end

function ServerPlayer:getState()
	return self.state
end

function ServerPlayer:spawn()
	local storage = self.game:getDirector():getPlayerStorage(self.index):getRoot()

	local path, anchor
	if storage:hasSection("Location") then
		local location = storage:getSection("Location")

		path = storage:get("name")
		anchor = Vector(
			location:get("x"),
			location:get("y"),
			location:get("z"))
	end
	
	if not path then
		path = "@Ship_IsabelleIsland_PortmasterJenkins?" ..
			"map=IsabelleIsland_FarOcean," ..
			"jenkins_state=1," ..
			"i=16," ..
			"j=16," ..
			"shore=IsabelleIsland_Tower," ..
			"shoreAnchor=Anchor_StartGame"
		anchor = "Anchor_Spawn"
	end

	local success, actor = self.stage:spawnActor("Resources.Game.Peeps.Player.One", path, anchor)
	if success then
		self.actor = actor
		actor:getPeep():addBehavior(PlayerBehavior)

		local p = actor:getPeep():getBehavior(PlayerBehavior)
		p.id = self.index
	else
		self.actor = false
	end
end

function ServerPlayer:poof()
	if self.actor then
		local peep = self.actor:getPeep()
		local instance = self.stage:getInstance(peep:getLayerName())

		if instance then
			instance:killActor(self.actor)
		end
	end

	self.actor = false
end

-- Gets the Actor this ServerPlayer is represented by.
function ServerPlayer:getActor()
	return self.actor
end

function ServerPlayer:flee()
	local peep = self.actor:getPeep()
	peep:removeBehavior(CombatTargetBehavior)
	peep:getCommandQueue(CombatCortex.QUEUE):clear()
end

function ServerPlayer:getIsEngaged()
	local peep = self.actor:getPeep()
	return peep:hasBehavior(CombatTargetBehavior)
end

function ServerPlayer:findPath(i, j, k)
	local peep = self.actor:getPeep()
	local position = peep:getBehavior(PositionBehavior).position
	local map = self.game:getDirector():getMap(k)
	local _, playerI, playerJ = map:getTileAt(position.x, position.z)
	local pathFinder = MapPathFinder(map)
	return pathFinder:find(
		{ i = playerI, j = playerJ },
		{ i = i, j = j },
		0)
end

-- Moves the player to the specified position on the map via walking.
function ServerPlayer:walk(i, j, k)
	local peep = self.actor:getPeep()
	return Utility.Peep.walk(peep, i, j, k, math.huge, { asCloseAsPossible = true })
end

return ServerPlayer
