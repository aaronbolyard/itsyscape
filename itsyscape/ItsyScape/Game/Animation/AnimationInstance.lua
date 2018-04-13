--------------------------------------------------------------------------------
-- ItsyScape/Game/Animation/AnimationInstance.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"

local AnimationInstance = Class()
function AnimationInstance:new(animation, animatable)
	self.animation = animation
	self.animatable = animatable

	self.channels = {}
	self:addChannel(animation:getTargetChannel())
	for i = 1, animation:getNumChannels() do
		self:addChannel(animation:getChannel(i))
	end

	self.time = 0
end

function AnimationInstance:addChannel(channel)
	local c = { current = 1, previous = 0 }
	for i = 1, channel:getNumCommands() do
		local commandInstance = channel:getCommand(i):instantiate()
		commandInstance:bind(self.animatable)
		table.insert(c, commandInstance)
	end

	table.insert(self.channels, c)
end

function AnimationInstance:play(time)
	if time < self.time then
		return
	end

	self.time = time
	for i = 1, #self.channels do
		local channel = self.channels[i]
		for j = channel.current, #channel do
			local command = channel[j]
			if command:pending(time) then
				if command.previous ~= j then
					command:start(animatable)
					command.previous = j
				end

				command:play(self.animatable, time)

				channel.current = j
				break
			else
				-- We only want to stop the previous animation if it actually
				-- played.
				if channel.previous == j then
					command:stop(self.animatable)
				end
			end
		end
	end
end

return AnimationInstance
