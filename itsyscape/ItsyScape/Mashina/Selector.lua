--------------------------------------------------------------------------------
-- ItsyScape/Mashina/Selector.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local B = require "B"

local Selector = B.Node("Selector")

function Selector:update(mashina, state, executor)
	local children = { self.tree:children(self.node) }
	for i = 1, #children do
		local r = executor:update(children[i])
		if r == B.Status.Working then
			return B.Status.Working
		elseif r == B.Status.Success then
			executor:drop()
			return B.Status.Success
		end
	end

	executor:drop()
	return B.Status.Failure
end

return Selector
