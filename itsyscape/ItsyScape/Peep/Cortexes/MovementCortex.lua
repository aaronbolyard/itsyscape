--------------------------------------------------------------------------------
-- ItsyScape/Peep/Cortexes/MovementCortex.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------

local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local Cortex = require "ItsyScape.Peep.Cortex"
local MovementBehavior = require "ItsyScape.Peep.Behaviors.MovementBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local SizeBehavior = require "ItsyScape.Peep.Behaviors.SizeBehavior"

local MovementCortex = Class(Cortex)

-- The epsilon to determine whether an object is on the ground.
MovementCortex.GROUND_EPSILON = 0.1

-- If any of the components of the acceleration or velocity vectors fall within
-- +/- CLAMP_EPSILON, then the component is clamped to zero.
MovementCortex.CLAMP_EPSILON = 0.05

-- Baseline for tick.
--
-- The MovementCortex was built under the assumption of 10 ticks/second. If this
-- number changes in the future, the acceleration and velocity need to be smudged
-- to feel the same. The 'multiplier' calculation in update keeps the movement
-- roughly consistent no matter the ticks/second.
MovementCortex.BASE_LINE_TICKS = 10

function MovementCortex:new()
	Cortex.new(self)

	self:require(MovementBehavior)
	self:require(PositionBehavior)
	self:require(SizeBehavior)
end

-- Clamps vector following rules of MovementCortex.CLAMP_EPSILON.
local function clampVector(v)
	if math.abs(v.x) < MovementCortex.CLAMP_EPSILON then
		v.x = 0
	end

	if math.abs(v.y) < MovementCortex.CLAMP_EPSILON then
		v.y = 0
	end

	if math.abs(v.z) < MovementCortex.CLAMP_EPSILON then
		v.z = 0
	end
end

function MovementCortex:update(delta)
	local game = self:getDirector():getGameInstance()
	local gravity = game:getStage():getGravity()

	local multiplier = 1 + (game:getTicks() - 10) / 200

	for peep in self:iterate() do
		local movement = peep:getBehavior(MovementBehavior)
		local position = peep:getBehavior(PositionBehavior)
		local map = self:getDirector():getMap(position.layer or 1)
		if map then
			movement:clampMovement()

			movement.acceleration = movement.acceleration + movement.acceleration * delta + gravity * delta
			clampVector(movement.acceleration)

			local wasMoving
			do
				local xzVelocity = movement.velocity * Vector(1, 0, 1)
				if xzVelocity:getLengthSquared() > 0 then
					wasMoving = true
				end
			end

			local acceleration = movement.acceleration * delta * movement.accelerationMultiplier
			movement.velocity = movement.velocity + acceleration * multiplier
			clampVector(movement.velocity)

			do
				local xzVelocity = movement.velocity * Vector(1, 0, 1)
				if xzVelocity:getLengthSquared() == 0 and movement.isOnGround then
					movement.isStopping = false
					if wasMoving and movement.targetFacing then
						movement.facing = movement.targetFacing
						movement.targetFacing = false
					end
				end
			end

			local oldPosition = position.position

			local velocity = movement.velocity * delta * movement.velocityMultiplier
			position.position = position.position + velocity * multiplier

			movement.acceleration = movement.acceleration * 1 / (1 + movement.decay * 8 * delta)
			movement.velocity = movement.velocity * 1 / (1 + movement.decay * 8 * delta)

			local y = map:getInterpolatedHeight(
				position.position.x,
				position.position.z)
			if math.abs(position.position.y - y) < MovementCortex.GROUND_EPSILON and
			   math.abs(movement.velocity.y * delta) < MovementCortex.GROUND_EPSILON
			then
				movement.isOnGround = true
			elseif position.position.y < y and not movement.isOnGround then
				movement.acceleration.y = -movement.acceleration.y * movement.bounce
				movement.velocity.y = -movement.velocity.y * movement.bounce
				position.position.y = y
				movement.isOnGround = false
			elseif position.position.y > y + MovementCortex.GROUND_EPSILON
			       and movement.isOnGround
			then
				movement.isOnGround = false
			end

			if movement.isOnGround then
				position.position.y = y
				movement.acceleration.y = 0
				movement.velocity.y = 0

				if movement.isStopping then
					movement.acceleration = movement.acceleration * movement.decay ^ movement.stoppingForce
					movement.velocity = movement.velocity * movement.decay ^ movement.stoppingForce
				end
			else
				position.position.y = math.max(position.position.y + gravity.y * delta, y)
			end

			local stepY = position.position.y - oldPosition.y 
			if stepY > movement.maxStepHeight then
				position.position = oldPosition
			end

			if movement.velocity.x < -0.5 then
				movement.facing = MovementBehavior.FACING_LEFT
			elseif movement.velocity.x > 0.5 then
				movement.facing = MovementBehavior.FACING_RIGHT
			end
		end
	end
end

return MovementCortex
