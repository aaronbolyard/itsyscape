local M = include "Resources/Game/Maps/IsabelleIsland_AbandonedMine/DB/Default.lua"

M["SkeletonMinerJoe"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 16.5 * 2,
		PositionY = 3,
		PositionZ = 21.5 * 2,
		Name = "Skeleton",
		Map = M._MAP,
		Resource = M["SkeletonMinerJoe"]
	}

	local TalkAction = ItsyScape.Action.Talk()

	ItsyScape.Meta.TalkSpeaker {
		Resource = M["SkeletonMinerJoe"],
		Name = "Joe",
		Action = TalkAction
	}

	ItsyScape.Meta.TalkDialog {
		Script = "Resources/Game/Maps/IsabelleIsland_AbandonedMine/Dialog/SkeletonMinerJoe_en-US.lua",
		Language = "en-US",
		Action = TalkAction
	}

	M["SkeletonMinerJoe"] {
		TalkAction,
		ItsyScape.Action.Attack()
	}

	ItsyScape.Meta.PeepMapObject {
		Peep = ItsyScape.Resource.Peep "Skeleton_Base",
		MapObject = M["SkeletonMinerJoe"]
	}

	ItsyScape.Meta.PeepMashinaState {
		State = "mine",
		Tree = "Resources/Game/Maps/IsabelleIsland_AbandonedMine/Scripts/Miner_MineLogic.lua",
		IsDefault = 1,
		Resource = M["SkeletonMinerJoe"]
	}

	ItsyScape.Meta.PeepMashinaState {
		State = "smelt",
		Tree = "Resources/Game/Maps/IsabelleIsland_AbandonedMine/Scripts/Miner_SmeltLogic.lua",
		Resource = M["SkeletonMinerJoe"]
	}

	ItsyScape.Meta.PeepEquipmentItem {
		Item = ItsyScape.Resource.Item "IronPickaxe",
		Count = 1,
		Resource = M["SkeletonMinerJoe"]
	}

	ItsyScape.Meta.ResourceName {
		Value = "Skeleton Miner Joe",
		Language = "en-US",
		Resource = M["SkeletonMinerJoe"]
	}

	ItsyScape.Meta.PeepStat {
		Skill = ItsyScape.Resource.Skill "Mining",
		Value = ItsyScape.Utility.xpForLevel(20),
		Resource = M["SkeletonMinerJoe"]
	}
end

M["CopperSkelemental1"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 41.5 * 2,
		PositionY = 3,
		PositionZ = 19.5 * 2,
		Name = "CopperSkelemental",
		Map = M._MAP,
		Resource = M["CopperSkelemental1"]
	}

	ItsyScape.Meta.PeepMapObject {
		Peep = ItsyScape.Resource.Peep "CopperSkelemental",
		MapObject = M["CopperSkelemental1"]
	}
end

M["CopperSkelemental2"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 27.5 * 2,
		PositionY = 3,
		PositionZ = 24.5 * 2,
		Name = "CopperSkelemental",
		Map = M._MAP,
		Resource = M["CopperSkelemental2"]
	}

	ItsyScape.Meta.PeepMapObject {
		Peep = ItsyScape.Resource.Peep "CopperSkelemental",
		MapObject = M["CopperSkelemental2"]
	}
end

M["CopperSkelemental3"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 14.5 * 2,
		PositionY = 3,
		PositionZ = 33.5 * 2,
		Name = "CopperSkelemental",
		Map = M._MAP,
		Resource = M["CopperSkelemental3"]
	}

	ItsyScape.Meta.PeepMapObject {
		Peep = ItsyScape.Resource.Peep "CopperSkelemental",
		MapObject = M["CopperSkelemental3"]
	}
end

M["TinSkelemental1"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 39.5 * 2,
		PositionY = 3,
		PositionZ = 18.5 * 2,
		Name = "TinSkelemental",
		Map = M._MAP,
		Resource = M["TinSkelemental1"]
	}

	ItsyScape.Meta.PeepMapObject {
		Peep = ItsyScape.Resource.Peep "TinSkelemental",
		MapObject = M["TinSkelemental1"]
	}
end

M["TinSkelemental2"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 33.5 * 2,
		PositionY = 3,
		PositionZ = 22.5 * 2,
		Name = "TinSkelemental",
		Map = M._MAP,
		Resource = M["TinSkelemental2"]
	}

	ItsyScape.Meta.PeepMapObject {
		Peep = ItsyScape.Resource.Peep "TinSkelemental",
		MapObject = M["TinSkelemental2"]
	}
end

M["TinSkelemental3"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 14.5 * 2,
		PositionY = 3,
		PositionZ = 33.5 * 2,
		Name = "TinSkelemental",
		Map = M._MAP,
		Resource = M["TinSkelemental3"]
	}

	ItsyScape.Meta.PeepMapObject {
		Peep = ItsyScape.Resource.Peep "TinSkelemental",
		MapObject = M["TinSkelemental3"]
	}
end

M["EntranceDoor"] {
	ItsyScape.Action.Open() {
		Requirement {
			Resource = ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_WroughtBronzeKey",
			Count = 1
		}
	},

	ItsyScape.Action.Close() {
		-- Nothing.
	}
}

M["CraftingRoomDoor"] {
	ItsyScape.Action.Open() {
		-- Nothing.
	},

	ItsyScape.Action.Close() {
		-- Nothing.
	}
}

M["BossDoor"] {
	ItsyScape.Action.Open() {
		Requirement {
			Resource = ItsyScape.Resource.Item "IsabelleIsland_AbandonedMine_ReinforcedBronzeKey",
			Count = 1
		}
	},

	ItsyScape.Action.Close() {
		-- Nothing.
	}
}
