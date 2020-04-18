--------------------------------------------------------------------------------
-- ItsyScape/Game/LocalModel/Player.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local Ray = require "ItsyScape.Common.Math.Ray"
local Utility = require "ItsyScape.Game.Utility"
local Player = require "ItsyScape.Game.Model.Player"
local PlayerBehavior = require "ItsyScape.Peep.Behaviors.PlayerBehavior"
local ActorReferenceBehavior = require "ItsyScape.Peep.Behaviors.ActorReferenceBehavior"
local DisabledBehavior = require "ItsyScape.Peep.Behaviors.DisabledBehavior"
local MovementBehavior = require "ItsyScape.Peep.Behaviors.MovementBehavior"
local PropReferenceBehavior = require "ItsyScape.Peep.Behaviors.PropReferenceBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local SizeBehavior = require "ItsyScape.Peep.Behaviors.SizeBehavior"
local TargetTileBehavior = require "ItsyScape.Peep.Behaviors.TargetTileBehavior"
local CombatTargetBehavior = require "ItsyScape.Peep.Behaviors.CombatTargetBehavior"
local CombatCortex = require "ItsyScape.Peep.Cortexes.CombatCortex"
local MapPathFinder = require "ItsyScape.World.MapPathFinder"
local PathNode = require "ItsyScape.World.PathNode"
local ExecutePathCommand = require "ItsyScape.World.ExecutePathCommand"

local LocalPlayer = Class(Player)
LocalPlayer.MOVEMENT_STOP_THRESHOLD = 10

-- Constructs a new player.
--
-- The Actor isn't created until Player.spawn is called.
function LocalPlayer:new(game, stage)
	Player.new(self)

	self.game = game
	self.stage = stage
	self.actor = false
	self.direction = Vector.UNIT_X
end

function LocalPlayer:spawn()
	local success, actor = self.stage:spawnActor("Resources.Game.Peeps.Player.One")
	if success then
		self.actor = actor
		actor:getPeep():addBehavior(PlayerBehavior)

		local p = actor:getPeep():getBehavior(PlayerBehavior)
		p.id = 1

		actor:getPeep():listen('finalize', function()
			local storage = self.game:getDirector():getPlayerStorage(1):getRoot()
			if storage:hasSection("Location") then
				local location = storage:getSection("Location")
				if location:get("name") then
					self.stage:movePeep(
						actor:getPeep(),
						location:get("name"),
						Vector(
							location:get("x"),
							location:get("y"),
							location:get("z")),
						true)
					return
				end
			end
		end)
	else
		self.actor = false
	end
end

function LocalPlayer:poof()
	if self.actor then
		self.stage:killActor(self.actor)
	end

	self.actor = false
end

-- Gets the Actor this Player is represented by.
function LocalPlayer:getActor()
	return self.actor
end

function LocalPlayer:flee()
	local peep = self.actor:getPeep()
	peep:removeBehavior(CombatTargetBehavior)
	peep:getCommandQueue(CombatCortex.QUEUE):clear()
end

function LocalPlayer:getIsEngaged()
	local peep = self.actor:getPeep()
	return peep:hasBehavior(CombatTargetBehavior)
end

function LocalPlayer:findPath(i, j, k)
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

function LocalPlayer:move(x, z)
	if not self.actor then
		return
	end

	local direction = Vector(x, 0, z):getNormal()
	local length = direction:getLength()
	local peep = self.actor:getPeep()
	local movement = peep:getBehavior(MovementBehavior)
	if length == 0 or peep:hasBehavior(DisabledBehavior) then
		local currentAccceleration = movement.acceleration:getLength()
		if currentAccceleration < LocalPlayer.MOVEMENT_STOP_THRESHOLD then
			movement.acceleration = Vector.ZERO
			movement.velocity = Vector.ZERO
			movement.isStopping = true
		end
	else
		if peep:getCommandQueue():clear() then
			movement.acceleration = movement.maxAcceleration * direction
			movement.isStopping = false

			local i, j, k = Utility.Peep.getTile(peep)

			self.direction = direction
			peep:poke('walk', { i = i, j = j, k = k })
		end
	end
end

-- Moves the player to the specified position on the map via walking.
function LocalPlayer:walk(i, j, k)
	local peep = self.actor:getPeep()
	return Utility.Peep.walk(peep, i, j, k, math.huge, { asCloseAsPossible = true })
end

function LocalPlayer:changeCamera(cameraType)
	self.onChangeCamera(self, cameraType)
end

return LocalPlayer
