--------------------------------------------------------------------------------
-- ItsyScape/Peep/Peeps/Creep.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local Stats = require "ItsyScape.Game.Stats"
local Utility = require "ItsyScape.Game.Utility"
local Peep = require "ItsyScape.Peep.Peep"
local AttackPoke = require "ItsyScape.Peep.AttackPoke"
local ActorReferenceBehavior = require "ItsyScape.Peep.Behaviors.ActorReferenceBehavior"
local CombatStatusBehavior = require "ItsyScape.Peep.Behaviors.CombatStatusBehavior"
local MovementBehavior = require "ItsyScape.Peep.Behaviors.MovementBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local SizeBehavior = require "ItsyScape.Peep.Behaviors.SizeBehavior"
local StatsBehavior = require "ItsyScape.Peep.Behaviors.StatsBehavior"
local MapPathFinder = require "ItsyScape.World.MapPathFinder"
local ExecutePathCommand = require "ItsyScape.World.ExecutePathCommand"

local Creep = Class(Peep)

function Creep:new(resource, ...)
	Peep.new(self, ...)

	self:addBehavior(ActorReferenceBehavior)
	self:addBehavior(CombatStatusBehavior)
	self:addBehavior(MovementBehavior)
	self:addBehavior(PositionBehavior)
	self:addBehavior(SizeBehavior)
	self:addBehavior(StatsBehavior)

	local movement = self:getBehavior(MovementBehavior)
	movement.maxSpeed = 12
	movement.maxAcceleration = 12
	movement.decay = 0.6
	movement.velocityMultiplier = 1
	movement.accelerationMultiplier = 1
	movement.stoppingForce = 3

	self:addPoke('initiateAttack')
	self:addPoke('receiveAttack')
	self:addPoke('hit')
	self:addPoke('miss')
	self:addPoke('die')
	
	local size = self:getBehavior(SizeBehavior)
	size.size = Vector(1, 2, 1)

	self.resource = resource or false
end

function Creep:ready(director, game)
	Peep.ready(self, director, game)

	if self.resource then
		local gameDB = game:getGameDB()

		local name = Utility.getName(self.resource, gameDB)
		if name then
			self:setName(name)
		else
			self:setName("*" .. self.resource.name)
		end
	end
end

function Creep:walk(i, j, k)
	local position = self:getBehavior(PositionBehavior).position
	local map = self:getDirector():getGameInstance():getStage():getMap(k)
	local _, playerI, playerJ = map:getTileAt(position.x, position.z)
	local pathFinder = MapPathFinder(map)
	local path = pathFinder:find(
		{ i = playerI, j = playerJ },
		{ i = i, j = j })
	if path then
		local queue = self:getCommandQueue()
		queue:interrupt(ExecutePathCommand(path))
	end
end

function Creep:onReceiveAttack(p)
	local combat = self:getBehavior(CombatStatusBehavior)
	local damage = math.max(math.min(combat.currentHitpoints, p:getDamage()), 0)

	local attack = AttackPoke({
		attackType = p:getAttackType(),
		weaponType = p:getWeaponType(),
		damageType = p:getDamageType(),
		damage = damage,
		aggressor = p:getAggressor()
	})

	if damage > 0 then
		self:poke('hit', attack)
	else
		self:poke('miss', attack)
	end
end

function Creep:onHit(p)
	local combat = self:getBehavior(CombatStatusBehavior)
	combat.currentHitpoints = math.max(combat.currentHitpoints - p:getDamage(), 0)

	if math.floor(combat.currentHitpoints) == 0 then
		self:poke('die', p)
	end
end

function Creep:onMiss(p)
	-- Nothing.
end

function Creep:onDie(p)
	self:getCommandQueue():clear()

	local movement = self:getBehavior(MovementBehavior)
	movement.velocity = Vector.ZERO
	movement.acceleration = Vector.ZERO
end

return Creep