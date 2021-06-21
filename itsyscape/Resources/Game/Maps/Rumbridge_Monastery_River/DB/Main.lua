local M = include "Resources/Game/Maps/Rumbridge_Monastery_River/DB/Default.lua"

ItsyScape.Meta.ResourceName {
	Value = "Rumbridge Monastery, River",
	Language = "en-US",
	Resource = M._MAP
}

ItsyScape.Meta.ResourceDescription {
	Value = "River under the Rumbridge monastery.",
	Language = "en-US",
	Resource = M._MAP
}

M["Light_Ambient"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 0,
		PositionY = 0,
		PositionZ = 0,
		Name = "Light_Ambient",
		Map = M._MAP,
		Resource = M["Light_Ambient"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "AmbientLight_Default",
		MapObject = M["Light_Ambient"]
	}

	ItsyScape.Meta.Light {
		ColorRed = 215,
		ColorGreen = 244,
		ColorBlue = 238,
		Resource = M["Light_Ambient"]
	}

	ItsyScape.Meta.AmbientLight {
		Ambience = 1.0,
		Resource = M["Light_Ambient"]
	}
end

M["Light_Fog1"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 0,
		PositionY = 0,
		PositionZ = 0,
		Name = "Light_Fog1",
		Map = M._MAP,
		Resource = M["Light_Fog1"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "Fog_Default",
		MapObject = M["Light_Fog1"]
	}

	ItsyScape.Meta.Fog {
		ColorRed = 55,
		ColorGreen = 113,
		ColorBlue = 200,
		NearDistance = 80,
		FarDistance = 100,
		Resource = M["Light_Fog1"]
	}
end
