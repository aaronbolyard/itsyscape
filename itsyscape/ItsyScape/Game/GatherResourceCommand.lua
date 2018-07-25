--------------------------------------------------------------------------------
-- ItsyScape/World/GatherResourceCommand.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Command = require "ItsyScape.Peep.Command"
local PropResourceHealthBehavior = require "ItsyScape.Peep.Behaviors.PropResourceHealthBehavior"

local GatherResourceCommand = Class(Command)

function GatherResourceCommand:new(prop, tool, t)
	Command.new(self)

	t = t or {}
	self.prop = prop
	self.tool = tool
	self.skill = t.skill or false
	self.multiplier = t.multiplier or 1
	self.bonusStrength = t.bonusStrength or 0
	self.time = 0
	self.isFinished = false
end

function GatherResourceCommand:getIsFinished()
	return self.isFinished
end

function GatherResourceCommand:onResourceObtained(peep, e)
	self.isFinished = true
end

function GatherResourceCommand:onBegin(peep)
	local itemManager = peep:getDirector():getItemManager()
	local logic = itemManager:getLogic(self.tool:getID())
	if logic:isCompatibleType(require "ItsyScape.Game.Weapon") then
		self.cooldown = logic:getCooldown(peep)
	else
		Log.warn("Unsupported logic for Item '%s'.", tool)
		self.cooldown = math.huge
	end

	self.prop:listen('resourceObtained', self.onResourceObtained, self, peep)

	peep:poke('resourceHit', {
		tool = self.tool,
		damage = 0,
		skill = self.skill
	})
end

function GatherResourceCommand:onEnd(peep)
	self.prop:silence('resourceObtained', self.onResourceObtained)
end

function GatherResourceCommand:onInterrupt(peep)
	self.prop:silence('resourceObtained', self.onResourceObtained)
end

function GatherResourceCommand:update(delta, peep)
	if self.time > self.cooldown then
		self:attack(peep)
		self.time = 0
	else
		self.time = self.time + delta
	end
end

function GatherResourceCommand:attack(peep)
	local itemManager = peep:getDirector():getItemManager()
	local logic = itemManager:getLogic(self.tool:getID())
	if logic:isCompatibleType(require "ItsyScape.Game.Weapon") then
		self.cooldown = logic:getCooldown(peep)

		local damage = logic:rollDamage(peep, self.multiplier, self.bonusStrength)
		self.prop:poke('resourceHit', {
			tool = self.tool,
			damage = damage
		})

		peep:poke('resourceHit', {
			tool = self.tool,
			damage = damage,
			skill = self.skill
		})
	end
end

return GatherResourceCommand