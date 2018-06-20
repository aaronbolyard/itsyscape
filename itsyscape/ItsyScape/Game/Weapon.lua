--------------------------------------------------------------------------------
-- ItsyScape/Game/Equipment.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Equipment = require "ItsyScape.Game.Equipment"
local Utility = require "ItsyScape.Game.Utility"
local AttackPoke = require "ItsyScape.Peep.AttackPoke"
local EquipmentBehavior = require "ItsyScape.Peep.Behaviors.EquipmentBehavior"
local StatsBehavior = require "ItsyScape.Peep.Behaviors.StatsBehavior"
local AttackCooldownBehavior = require "ItsyScape.Peep.Behaviors.AttackCooldownBehavior"

local Weapon = Class(Equipment)
Weapon.STANCE_AGGRESSIVE = 1 -- Gives strength, wisdom, or dexterity XP
Weapon.STANCE_CONTROLLED = 2 -- Gives attack, magic, or archery XP
Weapon.STANCE_DEFENSIVE  = 3 -- Gives defense XP
Weapon.STYLE_MAGIC   = 1
Weapon.STYLE_ARCHERY = 2
Weapon.STYLE_MELEE   = 3

Weapon.BONUS_STAB    = 'Stab'
Weapon.BONUS_SLASH   = 'Slash'
Weapon.BONUS_CRUSH   = 'Crush'
Weapon.BONUS_ARCHERY = 'Ranged'
Weapon.BONUS_MAGIC   = 'Magic'
Weapon.BONUS_NONE    = 'None'
Weapon.BONUSES       = {
	["Stab"]   = true,
	["Slash"]  = true,
	["Crush"]  = true,
	["Ranged"] = true,
	["Magic"]  = true,
	["None"]   = true
}

-- Rolls an attack.
--
-- Returns true if the attack succeeded, false otherwise. Also returns two integers:
-- the attack roll and the defense roll. Thus, this method returns (success, attacck, defense).
function Weapon:rollAttack(peep, target, bonus)
	-- TODO: Use tiny RNG
	if not Weapon.BONUSES[bonus] then
		return false, 0, 0
	end

	local accuracyBonus
	if bonus == Weapon.BONUS_NONE then
		accuracyBonus = 0
	else
		local bonuses = Utility.Peep.getEquipmentBonuses(peep)
		local k = "Accuracy" .. bonus
		accuracyBonus = bonuses[k] or 0
	end

	local defenseBonus
	if bonus == Weapon.BONUS_NONE then
		defenseBonus = 0
	else
		local bonuses = Utility.Peep.getEquipmentBonuses(target)
		local k = "Defense" .. bonus
		defenseBonus = bonuses[k] or 0
	end

	local attackRoll = math.floor(math.random(0, accuracyBonus))
	local defenseRoll = math.floor(math.random(0, defenseBonus))

	return attackRoll > defenseRoll, attackRoll, defenseRoll
end

function Weapon:rollDamage(peep, multiplier, bonusStrength)
	multiplier = 1
	bonusStrength = bonusStrength or 0

	local stats = peep:getBehavior(StatsBehavior)
	if stats and stats.stats then
		stats = stats.stats
	else
		stats = false
	end

	-- TODO: combat multipliers
	local style = self:getStyle()
	local bonus, level
	if style == Weapon.STYLE_MAGIC then
		bonus = 'StrengthMagic'

		if stats and stats:hasSkill("Wisdom") then
			level = stats:getSkill("Wisdom"):getWorkingLevel()
		end
	elseif style == Weapon.STYLE_ARCHERY then
		bonus = 'StrengthRanged'

		if stats and stats:hasSkill("Dexterity") then
			level = stats:getSkill("Dexterity"):getWorkingLevel()
		end
	elseif style == Weapon.STYLE_MELEE then
		bonus = 'StrengthMelee'

		if stats and stats:hasSkill("Strength") then
			level = stats:getSkill("Strength"):getWorkingLevel()
		end
	end

	local bonuses = Utility.Peep.getEquipmentBonuses(peep)
	local strengthBonus = (bonuses[bonus] or 0) + bonusStrength

	local maxHit = Utility.Combat.calcMaxHit(
		level or 1,
		1.0 * multiplier,
		strengthBonus)
	return math.floor(math.random(1, math.max(maxHit, 1)))
end

function Weapon:getBonusForStance(peep)
	return Weapon.BONUS_NONE
end

function Weapon:getAttackRange(peep)
	return 1
end

function Weapon:onAttackHit(peep, target, attack, defense)
	local damage = self:rollDamage(peep)

	local attack = AttackPoke({
		attackType = self:getBonusForStance(peep):lower(),
		weaponType = self:getWeaponType(),
		damage = damage,
		aggressor = peep
	})

	target:poke('receiveAttack', attack)
	peep:poke('initiateAttack', attack)

	self:applyCooldown(peep)
end

function Weapon:onAttackMiss(peep, target, attack, defense)
	local attack = AttackPoke({
		attackType = self:getBonusForStance(peep):lower(),
		weaponType = self:getWeaponType(),
		damage = 0,
		aggressor = peep
	})

	peep:poke('initiateAttack', attack)

	self:applyCooldown(peep)
end

function Weapon:applyCooldown(peep)
	peep:addBehavior(AttackCooldownBehavior)

	local cooldown = peep:getBehavior(AttackCooldownBehavior)
	cooldown.cooldown = self:getCooldown(peep)
	cooldown.ticks = peep:getDirector():getGameInstance():getCurrentTick()
end

function Weapon:perform(peep, target)
	local s, a, d = self:rollAttack(peep, target, self:getBonusForStance(peep))
	if s then
		self:onAttackHit(peep, target, a, d)
	else
		self:onAttackMiss(peep, target, a, d)
	end
end

function Weapon:getStyle()
	return Weapon.STYLE_MELEE
end

function Weapon:getWeaponType()
	return 'none'
end

function Weapon:getCooldown(peep)
	return 2.4
end

return Weapon
