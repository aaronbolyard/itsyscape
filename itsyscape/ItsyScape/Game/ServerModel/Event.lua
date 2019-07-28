--------------------------------------------------------------------------------
-- ItsyScape/Game/ServerModel/Event.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local serpent = require "serpent"
local Class = require "ItsyScape.Common.Class"

local Event, Metatable = Class()

function Event:new(action, t)
	self:serialize(action, t)
end

function Event:serialize(action, t)
	local e = {
		action = tostring(action),
		data = t or {}
	}

	self.data = serpent.dump(e, { sortkeys = true })
end

function Event:send(player)
	Class.ABSTRACT()
end

function Metatable.__eq(a, b)
	return a.data == b.data
end

return Event
