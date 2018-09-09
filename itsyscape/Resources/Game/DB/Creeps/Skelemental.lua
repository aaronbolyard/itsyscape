--------------------------------------------------------------------------------
-- Resources/Game/DB/Creeps/Skelemental.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------

include "Resources/Game/DB/Creeps/Skelementals/Copper.lua"

local BARS = {
	["Copper"] = {
		tier = 1,
		{ name = "CopperFlake", count = 5 }
	},

	["Bronze"] = {
		tier = 1,
		{ name = "CopperFlake", count = 5 },
		{ name = "TinFlake", count = 5 }
	}
}

for name, bar in pairs(BARS) do
	local ItemName = string.format("%sBar", name)
	local Bar = ItsyScape.Resource.Item(ItemName)

	local SmeltAction = ItsyScape.Action.Smelt()
	for i = 1, #bar do
		SmeltAction {
			Input {
				Resource = ItsyScape.Resource.Item(bar[i].name),
				Count = bar[i].count
			}
		}
	end

	SmeltAction {
		Requirement {
			Resource = ItsyScape.Resource.Skill "Smithing",
			Count = ItsyScape.Utility.xpForLevel(math.max(bar.tier, 1))
		},

		Output {
			Resource = ItsyScape.Resource.Skill "Smithing",
			Count = ItsyScape.Utility.xpForResource(math.max(bar.tier, 1))
		},

		Output {
			Resource = Bar,
			Count = 1
		}
	}

	Bar {
		SmeltAction
	}
end
