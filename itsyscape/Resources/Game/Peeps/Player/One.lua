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
local Curve = require "ItsyScape.Game.Curve"
local Equipment = require "ItsyScape.Game.Equipment"
local EquipmentInventoryProvider = require "ItsyScape.Game.EquipmentInventoryProvider"
local PlayerInventoryProvider = require "ItsyScape.Game.PlayerInventoryProvider"
local Stats = require "ItsyScape.Game.Stats"
local Peep = require "ItsyScape.Peep.Peep"
local ActorReferenceBehavior = require "ItsyScape.Peep.Behaviors.ActorReferenceBehavior"
local EquipmentBehavior = require "ItsyScape.Peep.Behaviors.EquipmentBehavior"
local HumanoidBehavior = require "ItsyScape.Peep.Behaviors.HumanoidBehavior"
local MovementBehavior = require "ItsyScape.Peep.Behaviors.MovementBehavior"
local InventoryBehavior = require "ItsyScape.Peep.Behaviors.InventoryBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local SizeBehavior = require "ItsyScape.Peep.Behaviors.SizeBehavior"
local StanceBehavior = require "ItsyScape.Peep.Behaviors.StanceBehavior"
local StatsBehavior = require "ItsyScape.Peep.Behaviors.StatsBehavior"

local One = Class(Peep)

function One:new(...)
	Peep.new(self, 'Player', ...)

	self:addBehavior(ActorReferenceBehavior)
	self:addBehavior(EquipmentBehavior)
	self:addBehavior(HumanoidBehavior)
	self:addBehavior(MovementBehavior)
	self:addBehavior(InventoryBehavior)
	self:addBehavior(PositionBehavior)
	self:addBehavior(SizeBehavior)
	self:addBehavior(StanceBehavior)
	self:addBehavior(StatsBehavior)

	local movement = self:getBehavior(MovementBehavior)
	movement.maxSpeed = 16
	movement.maxAcceleration = 16
	movement.decay = 0.6
	movement.velocityMultiplier = 1
	movement.accelerationMultiplier = 1
	movement.stoppingForce = 3

	local inventory = self:getBehavior(InventoryBehavior)
	inventory.inventory = PlayerInventoryProvider(self)

	local equipment = self:getBehavior(EquipmentBehavior)
	equipment.equipment = EquipmentInventoryProvider(self)

	local walkAnimation = CacheRef(
		"ItsyScape.Graphics.AnimationResource",
		"Resources/Game/Animations/Human_Walk_1/Script.lua")
	self:addResource("animation-walk", walkAnimation)
	local idleAnimation = CacheRef(
		"ItsyScape.Graphics.AnimationResource",
		"Resources/Game/Animations/Human_Idle_1/Script.lua")
	self:addResource("animation-idle", idleAnimation)
	local attackAnimation = CacheRef(
		"ItsyScape.Graphics.AnimationResource",
		"Resources/Game/Animations/Human_AttackStaffCrush_1/Script.lua")
	self:addResource("animation-attack", attackAnimation)
end

function One:assign(director)
	Peep.assign(self, director)

	local inventory = self:getBehavior(InventoryBehavior)
	director:getItemBroker():addProvider(inventory.inventory)

	local equipment = self:getBehavior(EquipmentBehavior)
	director:getItemBroker():addProvider(equipment.equipment)

	local stats = self:getBehavior(StatsBehavior)
	stats.stats = Stats("Player.One", director:getGameDB())
	stats.stats:getSkill("Constitution"):setXP(Curve.XP_CURVE:compute(10))
	stats.stats:getSkill("Attack"):setLevelBoost(1)
	stats.stats:getSkill("Defense"):setLevelBoost(-1)

	-- DEBUG
	local t = director:getItemBroker():createTransaction()
	t:addParty(inventory.inventory)
	t:spawn(inventory.inventory, "AmuletOfYendor")
	t:spawn(inventory.inventory, "AmuletOfYendor", 10, true)
	t:spawn(inventory.inventory, "ErrinTheHeathensHat")
	t:spawn(inventory.inventory, "ErrinTheHeathensCoat")
	t:spawn(inventory.inventory, "ErrinTheHeathensGloves")
	t:spawn(inventory.inventory, "ErrinTheHeathensBoots")
	t:spawn(inventory.inventory, "ErrinTheHeathensStaff")
	t:spawn(inventory.inventory, "AirRune", 100)
	t:spawn(inventory.inventory, "EarthRune", 100)
	t:spawn(inventory.inventory, "WaterRune", 100)
	t:spawn(inventory.inventory, "FireRune", 100)
	t:commit()

	self:addPoke('initiateAttack')
	self:addPoke('receiveAttack')
end

function One:ready(director, game)
	local actor = self:getBehavior(ActorReferenceBehavior)
	if actor and actor.actor then
		actor = actor.actor
	end

	actor:setBody(CacheRef("ItsyScape.Game.Body", "Resources/Game/Bodies/Human.lskel"))
	actor:setSkin('eyes', 1, CacheRef("ItsyScape.Game.Skin.ModelSkin", "Resources/Game/Skins/Player_One/Eyes.lua"))

	local head = CacheRef(
		"ItsyScape.Game.Skin.ModelSkin",
		"Resources/Game/Skins/Itsy/Helmet.lua")
	actor:setSkin(Equipment.PLAYER_SLOT_HEAD, 0, head)
	local body = CacheRef(
		"ItsyScape.Game.Skin.ModelSkin",
		"Resources/Game/Skins/Itsy/Body.lua")
	actor:setSkin(Equipment.PLAYER_SLOT_BODY, 0, body)
	local hands = CacheRef(
		"ItsyScape.Game.Skin.ModelSkin",
		"Resources/Game/Skins/Itsy/Gloves.lua")
	actor:setSkin(Equipment.PLAYER_SLOT_HANDS, 0, hands)
	local feet = CacheRef(
		"ItsyScape.Game.Skin.ModelSkin",
		"Resources/Game/Skins/Itsy/Boots.lua")
	actor:setSkin(Equipment.PLAYER_SLOT_FEET, 0, feet)
end

function One:update(director, game)
	Peep.update(self, director, game)

	if love.keyboard.isDown('space') then
		if self.space then
			local AttackPoke = require "ItsyScape.Peep.AttackPoke"
			self:poke('initiateAttack', AttackPoke({ attackType = 'stab' }))
			self.space = false
		end
	else
		self.space = true
	end
end

return One
