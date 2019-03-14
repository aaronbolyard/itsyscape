local M = include "Resources/Game/Maps/Ship_IsabelleIsland_Pirate/DB/Default.lua"

ItsyScape.Meta.PeepID {
	Value = "Resources.Game.Maps.Ship_IsabelleIsland_Pirate.Peep",
	Resource = M._MAP
}

ItsyScape.Meta.ResourceName {
	Value = "Black Tentacle Pirates' Ship",
	Language = "en-US",
	Resource = M._MAP
}

ItsyScape.Meta.ResourceDescription {
	Value = "A ship crewed by men that taunt the Old Ones; what folly.",
	Language = "en-US",
	Resource = M._MAP
}

M["Sailing_IronCannon_Default1"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 15.000000,
		PositionY = 4.000000,
		PositionZ = 7.000000,
		RotationX = 0.000000,
		RotationY = 0.000000,
		RotationZ = 0.000000,
		RotationW = 1.000000,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "Sailing_IronCannon_Default1",
		Map = M._MAP,
		Resource = M["Sailing_IronCannon_Default1"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "Sailing_IronCannon_Default",
		MapObject = M["Sailing_IronCannon_Default1"]
	}
end

M["Sailing_IronCannon_Default2"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 25.000000,
		PositionY = 4.000000,
		PositionZ = 7.000000,
		RotationX = 0.000000,
		RotationY = 0.000000,
		RotationZ = 0.000000,
		RotationW = 1.000000,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "Sailing_IronCannon_Default2",
		Map = M._MAP,
		Resource = M["Sailing_IronCannon_Default2"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "Sailing_IronCannon_Default",
		MapObject = M["Sailing_IronCannon_Default2"]
	}
end

M["Sailing_IronCannon_Default3"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 15.000000,
		PositionY = 4.000000,
		PositionZ = 15.000000,
		RotationX = ItsyScape.Utility.Quaternion.Y_180.x,
		RotationY = ItsyScape.Utility.Quaternion.Y_180.y,
		RotationZ = ItsyScape.Utility.Quaternion.Y_180.z,
		RotationW = ItsyScape.Utility.Quaternion.Y_180.w,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "Sailing_IronCannon_Default3",
		Map = M._MAP,
		Resource = M["Sailing_IronCannon_Default3"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "Sailing_IronCannon_Default",
		MapObject = M["Sailing_IronCannon_Default3"]
	}
end

M["Sailing_IronCannon_Default4"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 25.000000,
		PositionY = 4.000000,
		PositionZ = 15.000000,
		RotationX = ItsyScape.Utility.Quaternion.Y_180.x,
		RotationY = ItsyScape.Utility.Quaternion.Y_180.y,
		RotationZ = ItsyScape.Utility.Quaternion.Y_180.z,
		RotationW = ItsyScape.Utility.Quaternion.Y_180.w,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "Sailing_IronCannon_Default4",
		Map = M._MAP,
		Resource = M["Sailing_IronCannon_Default4"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "Sailing_IronCannon_Default",
		MapObject = M["Sailing_IronCannon_Default4"]
	}
end
