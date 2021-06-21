local M = include "Resources/Game/Maps/Rumbridge_Monastery_Floor1/DB/Default.lua"

ItsyScape.Meta.PeepID {
	Value = "Resources.Game.Maps.Rumbridge_Monastery_Floor1.Peep",
	Resource = M._MAP
}

ItsyScape.Meta.ResourceName {
	Value = "Rumbridge Monastery",
	Language = "en-US",
	Resource = M._MAP
}

ItsyScape.Meta.ResourceDescription {
	Value = "A bunch of drunk monks making rum.",
	Language = "en-US",
	Resource = M._MAP
}

M["Anchor_FromRumbridge"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 31,
		PositionY = 4,
		PositionZ = 63,
		Name = "Anchor_FromRumbridge",
		Map = M._MAP,
		Resource = M["Anchor_FromRumbridge"]
	}
end

M["Ladder_Cellar"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 31,
		PositionY = 4,
		PositionZ = 33,
		Name = "Ladder_Cellar",
		Map = M._MAP,
		Resource = M["Ladder_Cellar"]
	}
end
