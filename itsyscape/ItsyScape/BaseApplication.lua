--------------------------------------------------------------------------------
-- ItsyScape/BaseApplication.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"

local BaseApplication = Class()

function BaseApplication:new()
	self.times = {}
end

function BaseApplication:measure(name, func, ...)
	local before = love.timer.getTime()
	func(...)
	local after = love.timer.getTime()

	local index
	if not self.times[name] then
		index = #self.times + 1
		self.times[name] = index
	else
		index = self.times[name]
	end

	self.times[index] = { value = after - before, name = name }
end

function BaseApplication:initialize()
	-- Nothing.
end

function BaseApplication:update(delta)
	-- Nothing.
end

function BaseApplication:tick()
	-- Nothing.
end

function BaseApplication:quit()
	-- Nothing.
end

function BaseApplication:quitGame(game)
	-- Nothing.
end

function BaseApplication:mousePress(x, y, button)
	-- Nothing.
end

function BaseApplication:mouseRelease(x, y, button)
	-- Nothing.
end

function BaseApplication:mouseScroll(x, y)
	-- Nothing.
end

function BaseApplication:mouseMove(x, y, button)
	-- Nothing.
end

function BaseApplication:keyDown(...)
	-- Nothing.
end

function BaseApplication:keyUp(...)
	-- Nothing.
end

function BaseApplication:type(...)
	-- Nothing.
end

function BaseApplication:draw()
	-- Nothing.
end

return BaseApplication
