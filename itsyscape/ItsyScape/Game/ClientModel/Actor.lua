--------------------------------------------------------------------------------
-- ItsyScape/Game/Null/Actor.lua
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
local CacheRef = require "ItsyScape.Game.CacheRef"
local Actor = require "ItsyScape.Game.Model.Actor"

local ClientActor = Class(Actor)
ClientActor.RPC = {}

function ClientActor.RPC:onSpawned(id)
	self:spawn(id)
end

function ClientActor.RPC:onKilled()
	self:depart()
end

function ClientActor.RPC:onAnimationPlayed(priority, animation, time, force)
	animation = CacheRef(animation.type, animation.filename)
	self:onAnimationPlayed(priority, a, time, force)
end

function ClientActor.RPC:onTransmogrified(body)
	if body then
		body = CacheRef(body.type, body.filename)
	end

	self:onTransmogrified(body)
end

function ClientActor.RPC:onSkinChanged(slot, priority, skin)
	skin = CacheRef(skin.type, skin.filename)
	self:onSkinChanged(slot, priority, skin)
end

function ClientActor.RPC:onMove(position)
	self.position = Vector(unpack(position))
	self:onMove(position)
end

function ClientActor.RPC:onTeleport(position)
	self.position = Vector(unpack(position))
	self:onTeleport(self.position)
end

function ClientActor.RPC:onDirectionChanged(direction, rotation)
	if rotation then
		rotation = Quaternion(unpack(rotation))
	end

	self.direction = direction
	self.rotation = rotation
	self:onDirectionChanged(direction, rotation)
end

function ClientActor.RPC:onHUDMessage(...)
	self:onHUDMessage(...)
end

function ClientActor.RPC:onDamage(...)
	self:onDamage(...)
end

function ClientActor.RPC:_setActions(actions)
	self.actions = actions
end

function ClientActor.RPC:_setName(name)
	self.name = name
end

function ClientActor.RPC:_setBounds(min, max)
	self.min = Vector(unpack(min))
	self.max = Vector(unpack(max))
end

function ClientActor.RPC:_setTile(...)
	self.tile = { ... }
end

function ClientActor:new()
	self.name = ""
	self.tile = { 0, 0, 1 }
	self.min = Vector.ZERO
	self.max = Vector.ZERO
end

function ClientActor:spawn(id)
	self.id = id
end

function ClientActor:depart()
	self.id = Actor.NIL_ID
end

function ClientActor:teleport(position)
	self.onTeleport(self, position)
end

function ClientActor:move(position)
	self.onMove(self, position)
end

function ClientActor:orientate(direction, rotation)
	self.onDirectionChanged(direction, rotation)
end

function ClientActor:getID()
	return self.id
end

function ClientActor:getName()
	return self.name
end

function ClientActor:getPosition()
	return self.position
end

function ClientActor:getDirection()
	return self.direction, self.rotation
end

function ClientActor:getTile()
	return unpack(self.tile)
end

function ClientActor:getBounds()
	return self.min, self.max
end

function ClientActor:getActions(scope)
	return self.actions
end

function ClientActor:poke(action, scope)
	-- TODO
end

function ClientActor:getCurrentHitpoints()
	return self.currentHitpoints
end

function ClientActor:getMaximumHitpoints()
	return self.maximumHitpoints
end

function ClientActor:playAnimation(slot, priority, animation, force)
	self.onAnimationPlayed(self, slot, priority, animation)
end

function ClientActor:setBody(body)
	self.onTransmogrified(self, body)
end

function ClientActor:setSkin(slot, priority, skin)
	self.onSkinChanged(self, slot, priority, skin)
end

function ClientActor:unsetSkin(slot, skin)
	self.onSkinChanged(self, slot, false, skin)
end

function ClientActor:getSkin(slot)
	return
end

function ClientActor:dispatch(event)
	local func = ClientActor.RPC[event.call]
	if func then
		func(self, unpack(event.n, event))
	end
end

return ClientActor
