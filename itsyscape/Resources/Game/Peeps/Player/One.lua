--------------------------------------------------------------------------------
-- Resources/Peeps/Player/One.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local CacheRef = require "ItsyScape.Game.CacheRef"
local PlayerInventoryProvider = require "ItsyScape.Game.PlayerInventoryProvider"
local Peep = require "ItsyScape.Peep.Peep"
local ActorReferenceBehavior = require "ItsyScape.Peep.Behaviors.ActorReferenceBehavior"
local HumanoidBehavior = require "ItsyScape.Peep.Behaviors.HumanoidBehavior"
local MovementBehavior = require "ItsyScape.Peep.Behaviors.MovementBehavior"
local InventoryBehavior = require "ItsyScape.Peep.Behaviors.InventoryBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local SizeBehavior = require "ItsyScape.Peep.Behaviors.SizeBehavior"

local One = Class(Peep)

function One:new(...)
	Peep.new(self, 'Player', ...)

	self:addBehavior(HumanoidBehavior)
	self:addBehavior(MovementBehavior)
	self:addBehavior(InventoryBehavior)
	self:addBehavior(PositionBehavior)
	self:addBehavior(SizeBehavior)

	local movement = self:getBehavior(MovementBehavior)
	movement.maxSpeed = 16
	movement.maxAcceleration = 16
	movement.decay = 0.6
	movement.velocityMultiplier = 1
	movement.accelerationMultiplier = 1
	movement.stoppingForce = 3

	local inventory = self:getBehavior(InventoryBehavior)
	inventory.inventory = PlayerInventoryProvider(self)
end

function One:assign(director)
	Peep.assign(self, director)

	local inventory = self:getBehavior(InventoryBehavior)
	director:getItemBroker():addProvider(inventory.inventory)

	-- DEBUG
	local t = director:getItemBroker():createTransaction()
	t:addParty(inventory.inventory)
	t:spawn(inventory.inventory, "AmuletOfYendor")
	t:spawn(inventory.inventory, "AmuletOfYendor", 10, true)
	t:commit()
end

function One:ready(director, game)
	local actor = self:getBehavior(ActorReferenceBehavior)
	if actor and actor.actor then
		actor = actor.actor
	end

	actor:setBody(CacheRef("ItsyScape.Game.Body", "Resources/Game/Bodies/Human.lskel"))
	actor:setSkin('body', 1, CacheRef("ItsyScape.Game.Skin.ModelSkin", "Resources/Game/Skins/Player_One/Body.lua"))
	actor:setSkin('eyes', 1, CacheRef("ItsyScape.Game.Skin.ModelSkin", "Resources/Game/Skins/Player_One/Eyes.lua"))
end

return One
