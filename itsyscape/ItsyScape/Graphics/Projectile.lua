--------------------------------------------------------------------------------
-- ItsyScape/Graphics/Projectile.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local Prop = require "ItsyScape.Game.Model.Prop"
local Actor = require "ItsyScape.Game.Model.Actor"
local SceneNode = require "ItsyScape.Graphics.SceneNode"

local Projectile = Class()

function Projectile:new(id, gameView, source, destination, time)
	self.gameView = gameView
	self.id = id
	self.source = source
	self.destination = destination
	self.time = time or 0

	self.sceneNode = SceneNode()
end

function Projectile:attach()
	self.sceneNode:setParent(self.gameView:getScene())
end

function Projectile:poof()
	self.sceneNode:setParent(nil)
end

function Projectile:load()
	-- Nothing.
end

function Projectile:getDelta()
	return math.min(math.max(self.time / self:getDuration(), 0), 1)
end

function Projectile:isDone()
	return self:getDelta() >= 1.0
end

function Projectile:getGameView()
	return self.gameView
end

function Projectile:getResources()
	return self.gameView:getResourceManager()
end

function Projectile:getSource()
	return self.source
end

function Projectile:getDestination()
	return self.destination
end

function Projectile.getTargetPosition(target)
	if target:isType(Prop) or target:isType(Actor) then
		local positionable
		do
			if target:isType(Prop) then
				positionable = self.gameView:getView(target):getRoot()
			elseif target:isType(Actor) then
				positionable = self.gameView:getView(target):getSceneNode()
			end
		end

		if positionable then
			local transform = positionable:getTransform():getGlobalDeltaTransform(1)
			local position = Vector(transform:transformPoint(0, 0, 0))
			local max, min = target:getBounds()

			return position + (max - min) / 2
		end
	elseif target:isType(Vector) then
		return target
	end

	return Vector.ZERO
end

function Projectile:update(delta)
	self.time = self.time + delta
end

function Projectile:getRoot()
	return self.sceneNode
end

function Projectile:tick()
	-- Nothing.
end

return Projectile
