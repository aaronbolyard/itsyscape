--------------------------------------------------------------------------------
-- Resources/Game/DB/Items/Ores.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------

local ORES = {
	["Copper"] = {
		tier = 0,
		weight = 10.5
	},

	["Tin"] = {
		tier = 0,
		weight = 9.1
	}
}

for name, ore in pairs(ORES) do
	local ItemName = string.format("%sOre", name)
	local Ore = ItsyScape.Resource.Item(ItemName)

	local MineAction = ItsyScape.Action.Mine()

	MineAction {
		Requirement {
			Resource = ItsyScape.Resource.Skill "Mining",
			Count = ItsyScape.Utility.xpForLevel(math.max(ore.tier, 1))
		},

		Output {
			Resource = ItsyScape.Resource.Skill "Mining",
			Count = ItsyScape.Utility.xpForResource(math.max(ore.tier, 1))
		},

		Output {
			Resource = Ore,
			Count = 1
		}
	}

	ItsyScape.Meta.Item {
		Value = ItsyScape.Utility.valueForItem(ore.tier),
		Weight = ore.weight,
		Resource = Ore
	}

	ItsyScape.Meta.ResourceCategory {
		Key = "Metal",
		Value = name,
		Resource = Ore
	}

	ItsyScape.Meta.ResourceName {
		Value = string.format("%s ore", name),
		Language = "en-US",
		Resource = Ore
	}
end
