--------------------------------------------------------------------------------
-- Resources/Game/DB/Maps/Rumbridge/IsabelleIsland_AbandonedMine.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------

ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_WroughtBronzeKey" {
	-- Nothing.
}

ItsyScape.Meta.Item {
	Value = 1,
	Weight = 0,
	Resource = ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_WroughtBronzeKey"
}

ItsyScape.Meta.ResourceName {
	Language = "en-US",
	Value = "Wrought bronze key",
	Resource = ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_WroughtBronzeKey"
}

ItsyScape.Meta.ResourceDescription {
	Language = "en-US",
	Value = "This key grants you access to the Abandoned Mine.",
	Resource = ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_WroughtBronzeKey"
}

ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_ReinforcedBronzeKey" {
	-- Nothing.
}

ItsyScape.Meta.Item {
	Value = 1,
	Weight = 0,
	Resource = ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_ReinforcedBronzeKey"
}

ItsyScape.Meta.ResourceName {
	Language = "en-US",
	Value = "Reinforced bronze key",
	Resource = ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_ReinforcedBronzeKey"
}

ItsyScape.Meta.ResourceDescription {
	Language = "en-US",
	Value = "This key grants you access to the scary door in the Abandoned Mine.",
	Resource = ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_ReinforcedBronzeKey"
}

ItsyScape.Resource.Item "IsabelleIsland_CrawlingCopperOre" {
	-- Nothing.
}

ItsyScape.Meta.Item {
	Value = 1,
	Weight = 0,
	Unnoteable = 1,
	Untradeable = 1,	
	Resource = ItsyScape.Resource.Item "IsabelleIsland_CrawlingCopperOre"
}

ItsyScape.Meta.ResourceName {
	Language = "en-US",
	Value = "Crawling copper ore",
	Resource = ItsyScape.Resource.Item "IsabelleIsland_CrawlingCopperOre"
}

ItsyScape.Meta.ResourceDescription {
	Language = "en-US",
	Value = "The copper makes your skin crawl when you touch it...",
	Resource = ItsyScape.Resource.Item "IsabelleIsland_CrawlingCopperOre"
}

ItsyScape.Resource.Item "IsabelleIsland_TenseTinOre" {
	-- Nothing.
}

ItsyScape.Meta.Item {
	Value = 1,
	Weight = 0,
	Unnoteable = 1,
	Untradeable = 1,	
	Resource = ItsyScape.Resource.Item "IsabelleIsland_TenseTinOre"
}

ItsyScape.Meta.ResourceName {
	Language = "en-US",
	Value = "Tense tin ore",
	Resource = ItsyScape.Resource.Item "IsabelleIsland_TenseTinOre"
}

ItsyScape.Meta.ResourceDescription {
	Language = "en-US",
	Value = "Just the touch of the ore on your skin makes you tense up...",
	Resource = ItsyScape.Resource.Item "IsabelleIsland_TenseTinOre"
}

ItsyScape.Resource.Peep "GhostlyMinerForeman" {
	ItsyScape.Action.Attack(),

	ItsyScape.Action.Loot() {
		Output {
			Resource = ItsyScape.Resource.DropTable "GhostlyMinerForeman_TenseTin",
			Count = 1
		}
	},

	ItsyScape.Action.Loot() {
		Output {
			Resource = ItsyScape.Resource.DropTable "GhostlyMinerForeman_CrawlingCopper",
			Count = 1
		}
	}
}

ItsyScape.Meta.ResourceName {
	Value = "Ghostly Miner Foreman",
	Language = "en-US",
	Resource = ItsyScape.Resource.Peep "GhostlyMinerForeman"
}

ItsyScape.Meta.ResourceDescription {
	Language = "en-US",
	Value = "Obviously his pension wasn't very good.",
	Resource = ItsyScape.Resource.Item "GhostlyMinerForeman"
}

ItsyScape.Meta.PeepID {
	Value = "Resources.Game.Peeps.GhostlyMinerForeman.GhostlyMinerForeman",
	Resource = ItsyScape.Resource.Peep "GhostlyMinerForeman"
}

ItsyScape.Meta.DropTableEntry {
	Item = ItsyScape.Resource.Item "IsabelleIsland_TenseTinOre",
	Weight = 1,
	Count = 1,
	Resource = ItsyScape.Resource.DropTable "GhostlyMinerForeman_TenseTin"	
}

ItsyScape.Meta.DropTableEntry {
	Item = ItsyScape.Resource.Item "IsabelleIsland_CrawlingCopperOre",
	Weight = 1,
	Count = 1,
	Resource = ItsyScape.Resource.DropTable "GhostlyMinerForeman_CrawlingCopper"	
}

ItsyScape.Meta.PeepStat {
	Skill = ItsyScape.Resource.Skill "Attack",
	Value = ItsyScape.Utility.xpForLevel(10),
	Resource = ItsyScape.Resource.Peep "GhostlyMinerForeman"
}

ItsyScape.Meta.PeepStat {
	Skill = ItsyScape.Resource.Skill "Strength",
	Value = ItsyScape.Utility.xpForLevel(20),
	Resource = ItsyScape.Resource.Peep "GhostlyMinerForeman"
}

ItsyScape.Meta.PeepStat {
	Skill = ItsyScape.Resource.Skill "Defense",
	Value = ItsyScape.Utility.xpForLevel(1),
	Resource = ItsyScape.Resource.Peep "GhostlyMinerForeman"
}

ItsyScape.Meta.PeepStat {
	Skill = ItsyScape.Resource.Skill "Constitution",
	Value = ItsyScape.Utility.xpForLevel(30),
	Resource = ItsyScape.Resource.Peep "GhostlyMinerForeman"
}

ItsyScape.Meta.ResourceTag {
	Value = "Undead",
	Resource = ItsyScape.Resource.Peep "GhostlyMinerForeman"
}

ItsyScape.Meta.PeepMashinaState {
	State = "idle",
	Tree = "Resources/Game/Peeps/GhostlyMinerForeman/GhostlyMinerForeman_IdleLogic.lua",
	IsDefault = 1,
	Resource = ItsyScape.Resource.Peep "GhostlyMinerForeman"
}

do
	local MineAction = ItsyScape.Action.Mine() {
		Output {
			Resource = ItsyScape.Resource.Skill "Mining",
			Count = ItsyScape.Utility.xpForResource(10)
		},

		Output {
			Resource = ItsyScape.Resource.Item "UnfocusedRune",
			Count = 30
		}
	}

	ItsyScape.Resource.Prop "IsabelleIsland_AbandonedMine_Pillar" {
		MineAction
	}

	ItsyScape.Meta.ActionDifficulty {
		Value = math.max(10),
		Action = MineAction
	}

	ItsyScape.Meta.GatherableProp {
		Health = 5,
		SpawnTime = math.huge,
		Resource = ItsyScape.Resource.Prop "IsabelleIsland_AbandonedMine_Pillar"
	}

	ItsyScape.Meta.PeepID {
		Value = "Resources.Game.Peeps.Props.IsabelleIsland.AbandonedMine.Pillar",
		Resource = ItsyScape.Resource.Prop "IsabelleIsland_AbandonedMine_Pillar"
	}

	ItsyScape.Meta.ResourceName {
		Value = string.format("Runic pillar", name),
		Language = "en-US",
		Resource = ItsyScape.Resource.Prop "IsabelleIsland_AbandonedMine_Pillar"
	}

	ItsyScape.Meta.ResourceDescription {
		Language = "en-US",
		Value = "A necromanic energy flows from the pillar.",
		Resource = ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_Pillar"
	}
end
