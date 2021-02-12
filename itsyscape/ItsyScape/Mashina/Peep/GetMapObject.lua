--------------------------------------------------------------------------------
-- ItsyScape/Mashina/Peep/GetMapObject.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local B = require "B"
local Utility = require "ItsyScape.Game.Utility"
local Probe = require "ItsyScape.Peep.Probe"

local GetMapObject = B.Node("GetMapObject")
GetMapObject.NAME = B.Reference()
GetMapObject.PEEP = B.Reference()

function GetMapObject:update(mashina, state, executor)
	local hits = mashina:getDirector():probe(
		mashina:getLayerName(), Probe.namedMapObject(state[self.NAME]))

	if #hits > 1 then
		Log.warn("More than one hit.")
	end

	local hit = hits[1]
	if hit then
		state[self.PEEP] = hit
		return B.Status.Success
	else
		return B.Status.Failure
	end
end

return GetMapObject
