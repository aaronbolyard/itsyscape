--------------------------------------------------------------------------------
-- ItsyScape/Game/ServerModel/RPC.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Event = require "ItsyScape.Game.ServerModel.Event"

local RPC = Class(Event)

function RPC:new(call, id, ...)
	return self:serialize('RPC', {
		call = call,
		id = id,
		n = select('#', ...),
		...
	})
end

return RPC
