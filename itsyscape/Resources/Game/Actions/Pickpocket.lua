--------------------------------------------------------------------------------
-- Resources/Game/Actions/Pickpocket.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Utility = require "ItsyScape.Game.Utility"
local CompositeCommand = require "ItsyScape.Peep.CompositeCommand"
local CallbackCommand = require "ItsyScape.Peep.CallbackCommand"
local WaitCommand = require "ItsyScape.Peep.WaitCommand"
local Action = require "ItsyScape.Peep.Action"

local Pickpocket = Class(Action)
Pickpocket.SCOPES = { ['world'] = true, ['world-pvm'] = true, ['world-pvp'] = true }
Pickpocket.FLAGS = { ['item-inventory'] = true, ['item-equipment'] = true }
Pickpocket.QUEUE = {}
Pickpocket.DURATION = 0.5

function Pickpocket:perform(state, player, target)
	local FLAGS = {
		['item-inventory'] = true,
		['item-equipment'] = true
	}

	if target and self:canPerform(state, FLAGS) then
		local i, j, k = Utility.Peep.getTile(target)
		local walk = Utility.Peep.getWalk(player, i, j, k, 1, { asCloseAsPossible = false })

		if walk then
			local perform = CallbackCommand(self.transfer, self, state, player)
			local wait = WaitCommand(Pickpocket.DURATION, false)
			local command = CompositeCommand(true, walk, perform, wait)

			local queue = player:getCommandQueue()
			return queue:interrupt(command)
		end
	end

	return false
end

return Pickpocket
