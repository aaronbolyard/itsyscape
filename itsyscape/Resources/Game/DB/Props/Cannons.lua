--------------------------------------------------------------------------------
-- Resources/Game/DB/Props/Cannons.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------

ItsyScape.Resource.Item "IronCannonball" {
	ItsyScape.Action.Smelt() {
		Requirement {
			Resource = ItsyScape.Resource.Skill "Smithing",
			Count = ItsyScape.Utility.xpForLevel(15)
		},

		Input {
			Resource = ItsyScape.Resource.Item "IronBar",
			Count = 1
		},

		Output {
			Resource = ItsyScape.Resource.Item "IronCannonball",
			Count = 1
		},

		Output {
			Resource = ItsyScape.Resource.Skill "Smithing",
			Count = ItsyScape.Utility.xpForResource(15)
		}
	}
}

ItsyScape.Meta.ResourceName {
	Value = "Iron cannonball",
	Language = "en-US",
	Resource = ItsyScape.Resource.Item "IronCannonball"
}

ItsyScape.Meta.ResourceDescription {
	Value = "What's heavier, a ton of iron cannoballs or a ton of feathers?",
	Language = "en-US",
	Resource = ItsyScape.Resource.Item "IronCannonball"
}

ItsyScape.Meta.Item {
	Value = ItsyScape.Utility.valueForItem(11),
	Weight = 0,
	Stackable = 1,
	Resource = ItsyScape.Resource.Item "IronCannonball"
}

ItsyScape.Resource.Prop "Sailing_IronCannon_Default" {
	ItsyScape.Action.Fire() {
		Requirement {
			Resource = ItsyScape.Resource.Skill "Dexterity",
			Count = ItsyScape.Utility.xpForLevel(1)
		},

		Requirement {
			Resource = ItsyScape.Resource.Skill "Strength",
			Count = ItsyScape.Utility.xpForLevel(1)
		},

		Input {
			Resource = ItsyScape.Resource.Item "IronCannonball",
			Count = 1
		},

		Output {
			Resource = ItsyScape.Resource.Skill "Dexterity",
			Count = ItsyScape.Utility.xpForResource(2)
		},

		Output {
			Resource = ItsyScape.Resource.Skill "Strength",
			Count = ItsyScape.Utility.xpForResource(2)
		}
	}
}

ItsyScape.Meta.PeepID {
	Value = "Resources.Game.Peeps.Props.BasicCannon",
	Resource = ItsyScape.Resource.Prop "Sailing_IronCannon_Default"
}

ItsyScape.Meta.MapObjectSize {
	SizeX = 1.5,
	SizeY = 3,
	SizeZ = 1.5,
	MapObject = ItsyScape.Resource.Prop "Sailing_IronCannon_Default"
}

ItsyScape.Meta.ResourceName {
	Value = "Iron cannon",
	Language = "en-US",
	Resource = ItsyScape.Resource.Prop "Sailing_IronCannon_Default"
}

ItsyScape.Meta.ResourceDescription {
	Value = "At least it's not made of bronze...",
	Language = "en-US",
	Resource = ItsyScape.Resource.Prop "Sailing_IronCannon_Default"
}

ItsyScape.Meta.GatherableProp {
	Health = 15,
	SpawnTime = 15,
	Resource = ItsyScape.Resource.Prop "Sailing_IronCannon_Default"
}
