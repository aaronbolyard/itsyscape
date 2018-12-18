--------------------------------------------------------------------------------
-- Resources/Peeps/UndeadSquid/UndeadSquid.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local CacheRef = require "ItsyScape.Game.CacheRef"
local Utility = require "ItsyScape.Game.Utility"
local Equipment = require "ItsyScape.Game.Equipment"
local Creep = require "ItsyScape.Peep.Peeps.Creep"
local ActorReferenceBehavior = require "ItsyScape.Peep.Behaviors.ActorReferenceBehavior"
local SizeBehavior = require "ItsyScape.Peep.Behaviors.SizeBehavior"

local UndeadSquid = Class(Creep)

function UndeadSquid:new(resource, name, ...)
	Creep.new(self, resource, name or 'UndeadSquid', ...)

	local size = self:getBehavior(SizeBehavior)
	size.size = Vector(8, 9, 8)
	size.offset = Vector(0, 1, 0)
end

function UndeadSquid:ready(director, game)
	local actor = self:getBehavior(ActorReferenceBehavior)
	if actor and actor.actor then
		actor = actor.actor
	end

	local body = CacheRef(
		"ItsyScape.Game.Body",
		"Resources/Game/Bodies/UndeadSquid.lskel")
	actor:setBody(body)

	local body = CacheRef(
		"ItsyScape.Game.Skin.ModelSkin",
		"Resources/Game/Skins/UndeadSquid/UndeadSquid.lua")
	actor:setSkin(Equipment.PLAYER_SLOT_BODY, Equipment.SKIN_PRIORITY_BASE, body)

	local idleAnimation = CacheRef(
		"ItsyScape.Graphics.AnimationResource",
		"Resources/Game/Animations/UndeadSquid_Idle/Script.lua")
	self:addResource("animation-idle", idleAnimation)

	Creep.ready(self, director, game)
end

return UndeadSquid
