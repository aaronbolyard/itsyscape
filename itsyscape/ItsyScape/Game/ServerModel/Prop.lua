--------------------------------------------------------------------------------
-- ItsyScape/Game/ServerModel/Prop.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local Quaternion = require "ItsyScape.Common.Math.Quaternion"
local Prop = require "ItsyScape.Game.Model.Prop"
local Utility = require "ItsyScape.Game.Utility"
local AttackPoke = require "ItsyScape.Peep.AttackPoke"
local PropReferenceBehavior = require "ItsyScape.Peep.Behaviors.PropReferenceBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local RotationBehavior = require "ItsyScape.Peep.Behaviors.RotationBehavior"
local ScaleBehavior = require "ItsyScape.Peep.Behaviors.ScaleBehavior"
local SizeBehavior = require "ItsyScape.Peep.Behaviors.SizeBehavior"

local ServerProp = Class(Prop)

function ServerProp:new(game, peepType)
	Prop.new(self)

	self.game = game
	self.id = Prop.NIL_ID
	self.peepType = peepType
end

function ServerProp:getPeep()
	return self.peep
end

function ServerProp:place(id, group, resource, ...)
	assert(self.id == Prop.NIL_ID, "Prop already spawned")

	self.peep = self.game:getDirector():addPeep(group, self.peepType, resource, ...)
	local _, propReference = self.peep:addBehavior(PropReferenceBehavior)
	propReference.prop = self

	self.id = id
	self.resource = resource or false	
end

function ServerProp:remove()
	assert(self.id ~= Prop.NIL_ID, "Prop not spawned")

	self.game:getDirector():removePeep(self.peep)
	self.peep = nil

	self.id = Prop.NIL_ID
end

function ServerProp:getID()
	return self.id
end

function ServerProp:getName()
	return self.peep:getName()
end

function ServerProp:getDescription()
	return Utility.Peep.getDescription(self.peep)
end

function ServerProp:getResourceType()
	error("nyi")
end

function ServerProp:getResourceName()
	if self.peep then
		return Utility.Peep.getResource(self.peep).name
	end

	return nil
end

function ServerProp:setName(value)
	self.peep:setName(value)
end

function ServerProp:getPosition()
	if not self.peep then
		return Vector.ZERO
	end

	local position = self.peep:getBehavior(PositionBehavior)
	if position then
		return position.position, position.layer
	else
		return Vector.ZERO
	end
end

function ServerProp:getRotation()
	if not self.peep then
		return Quaternion.IDENTITY
	end

	local rotation = self.peep:getBehavior(RotationBehavior)
	if rotation then
		return rotation.rotation
	else
		return Quaternion.IDENTITY
	end
end

function ServerProp:getScale()
	if not self.peep then
		return Vector.ONE
	end

	local scale = self.peep:getBehavior(ScaleBehavior)
	if scale then
		return scale.scale
	else
		return Vector.ONE
	end
end

function ServerProp:getTile()
	if not self.peep then
		return 0, 0, 0
	end

	local position = self.peep:getBehavior(PositionBehavior)
	if position then
		local map = self.game:getDirector():getMap(position.layer or 1)
		local i, j = map:getTileAt(position.position.x, position.position.z)

		return i, j, position.layer or 1
	else
		return 0, 0, 0
	end
end

-- Returns the bounds, as (min, max).
function ServerProp:getBounds()
	if not self.peep then
		return Vector.ZERO, Vector.ZERO
	end

	local position = self:getPosition()

	local size = self.peep:getBehavior(SizeBehavior)
	if size then
		local xzSize = Vector(size.size.x / 2, 0, size.size.z / 2)
		local ySize = Vector(0, size.size.y, 0)
		local min = position - xzSize
		local max = position + xzSize + ySize

		return min + size.offset, max + size.offset
	else
		return position, position
	end
end

function ServerProp:getActions(scope)
	local mapObject = Utility.Peep.getMapObject(self.peep)
	if mapObject then
		-- First we see if there's any actions whatsoever for the map object.
		-- If so, we don't use the default actions.
		--
		-- However, we only want to return 'scope' actions, so we have to look-up
		-- the actions *again*.
		local actions = Utility.getActions(self.game, mapObject)
		if #actions > 0 then
			return Utility.getActions(self.game, mapObject, scope or 'world')
		end
	end

	if self.resource then
		return Utility.getActions(self.game, self.resource, scope)
	end

	return {}
end

function ServerProp:poke(action, scope, player)
	if self.resource then
		local playerPeep = player:getActor():getPeep()
		local peep = self:getPeep()
		local s = Utility.performAction(
			self.game,
			self.resource,
			action,
			scope,
			playerPeep:getState(), playerPeep, peep)
		local m = Utility.Peep.getMapObject(peep)
		if not s and m then
			Utility.performAction(
				self.game,
				m,
				action,
				scope,
				playerPeep:getState(), playerPeep, peep)
		end
	end
end

function ServerProp:getState()
	local peep = self:getPeep()
	if peep and peep.getPropState then
		return peep:getPropState()
	else
		return {}
	end
end

return ServerProp
