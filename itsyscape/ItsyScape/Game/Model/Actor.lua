--------------------------------------------------------------------------------
-- ItsyScape/Game/Model/Actor.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Callback = require "ItsyScape.Common.Callback"

-- Actor, representing anything like an NPC, player, or monster.
local Actor = Class()

-- Represents an invalid ID.
Actor.NIL_ID = 0

function Actor:new()
	self.onDirectionChanged = Callback()
	self.onMove = Callback()
	self.onTeleport = Callback()
	self.onAnimationPlayed = Callback()
	self.onTransmogrified = Callback()
	self.onSkinChanged = Callback()
end

-- Spawns the Actor, assigning it the given unique ID.
function Actor:spawn(id)
	Class.ABSTRACT()
end

-- Called when the Actor leaves the Stage.
--
-- Should set ID to Actor.NIL_ID.
function Actor:depart()
	Class.ABSTRACT()
end

-- Gets the Actor's unique ID, or Actor.NIL_ID if the actor is not spawned.
function Actor:getID()
	return Class.ABSTRACT()
end

-- Gets the name of the Actor.
function Actor:getName()
	return Class.ABSTRACT()
end

-- Gets the resource type of the Actor.
function Actor:getResourceType()
	return Class.ABSTRACT()
end

-- Gets the resource name of the Actor.
function Actor:getResourceName()
	return Class.ABSTRACT()
end

-- Sets the name of the Actor.
function Actor:setName(value)
	Class.ABSTRACT()
end

-- Sets the direction of the Actor.
--
-- See Actor.getDirection
function Actor:setDirection(direction)
	Class.ABSTRACT()
end

-- Gets the direction of the Actor, as a Vector.
--
-- direction need not be normalized. Instead, the magnitude of direction can be
-- used for animation purposes.
--
-- When direction changes, onDirectionChanged should be invoked.
function Actor:getDirection()
	return Class.ABSTRACT()
end

-- Teleports the actor to the new position.
--
-- See Actor.getPosition
function Actor:teleport(position)
	Class.ABSTRACT()
end

-- Move the actor to the new position.
--
-- See Actor.getPosition
function Actor:move(position)
	Class.ABSTRACT()
end

-- Gets the absolution position of the Actor in the world as a Vector.
--
-- When position changes, onTeleport should be called if the movement is instant,
-- otherwise onMove should be called.
function Actor:getPosition()
	return Class.ABSTRACT()
end

-- Gets the tile as a tuple in the form (i, j, layer).
function Actor:getTile()
	return Class.ABSTRACT()
end

-- Returns the bounds, as (min, max).
function Actor:getBounds()
	return Class.ABSTRACT()
end

-- Pokes 'action' with the specified ID.
--
-- Actions are stored in the GameDB.
function Actor:poke(action)
	Class.ABSTRACT()
end

-- Gets the current health of the Actor.
function Actor:getCurrentHealth()
	return Class.ABSTRACT()
end

-- Gets the maximum health of the Actor.
function Actor:getMaximumHealth()
	return Class.ABSTRACT()
end

-- Makes the Actor play the animation on the provided slot.
--
-- animation should be a CacheRef to an ItsyScape.Game.Animation.Animation.
--
-- If 'priority' is lower than the current animation's priority in the provided
-- slot, the animation is not played. If 'priority' is a falsey value, the
-- animation is stopped.
--
-- If 'force' is set, then the animation always plays.
--
-- Should invoke Actor.onAnimationPlayed with the slot and animation if
-- successful.
--
-- Returns true if the animation was played, false otherwise.
function Actor:playAnimation(slot, priority, animation, force)
	return Class.ABSTRACT()
end

-- Sets the model of the Actor.
--
-- body should be a CacheRef to a ItsyScape.Game.Body.
--
-- Should invoke Actor.onTransmogrified with the model.
function Actor:setBody(body)
	Class.ABSTRACT()
end

-- Sets a skin at the provided slot.
--
-- skin should be CacheRef to an ItsyScape.Game.Skin-derived object.
--
-- Should invoke Actor.onSkinChanged with the slot, priority, and skin.
function Actor:setSkin(slot, priority, skin)
	Class.ABSTRACT()
end

-- Unsets a skin at the provided slot.
--
-- skin should be CacheRef to an ItsyScape.Game.Skin-derived object.
--
-- Should invoke Actor.onSkinChanged with the slot, priority (false), and skin.
-- A priority of false means the skin is to be removed.
function Actor:unsetSkin(slot, skin)
	Class.ABSTRACT()
end

-- Returns the skins at the slot, or nil if no skin is set.
--
-- Return values are in the order skin1, priority1, ..., skinN, priorityN.
function Actor:getSkin(slot)
	return Class.ABSTRACT()
end

return Actor
