--------------------------------------------------------------------------------
-- ItsyScape/Game/Animation/Commands/Particles.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Command = require "ItsyScape.Game.Animation.Commands.Command"
local Color = require "ItsyScape.Graphics.Color"
local ParticlesInstance = require "ItsyScape.Game.Animation.Commands.ParticlesInstance"

-- Command to play an animation (lanim).
--
-- Takes the form:
--
-- Particles { duration, system }
--
-- Where 'system' is a ParticleSystem def.
local Particles, Metatable = Class(Command)

function Particles:new(t)
	self.duration = t.duration or 0
	self.particleSystem = t.system or {}
	self.attach = t.attach or false
	self.rotation = t.rotation or 'IDENTITY'
end

function Particles:getDuration()
	return self.duration
end

function Particles:setDuration(value)
	self.duration = value or self.duration
end

function Particles:getParticleSystem()
	return self.particleSystem
end

function Particles:setParticleSystem(value)
	self.particleSystem = value or self.particleSystem
end

function Particles:getAttach()
	return self.attach
end

function Particles:setAttach(value)
	self.attach = value
end

function Particles:getRotation()
	return self.rotation
end

function Particles:setRotation(value)
	self.rotation = value
end

function Particles:instantiate()
	return ParticlesInstance(self)
end

return Particles
