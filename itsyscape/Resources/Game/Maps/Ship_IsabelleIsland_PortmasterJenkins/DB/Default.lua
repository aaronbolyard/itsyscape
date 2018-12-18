local M = {}

M._MAP = ItsyScape.Resource.Map "Ship_IsabelleIsland_PortmasterJenkins"

M["Sailing_CommonHelm_Default1"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 27.000000,
		PositionY = 5.000000,
		PositionZ = 11.000000,
		RotiationX = 0.000000,
		RotiationY = 0.000000,
		RotiationZ = 0.000000,
		RotiationW = 1.000000,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "Sailing_CommonHelm_Default1",
		Map = M._MAP,
		Resource = M["Sailing_CommonHelm_Default1"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "Sailing_CommonHelm_Default",
		MapObject = M["Sailing_CommonHelm_Default1"]
	}
end

M["Sailing_BasicSail_Default2"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 23.000000,
		PositionY = 4.000000,
		PositionZ = 11.000000,
		RotiationX = 0.000000,
		RotiationY = 0.000000,
		RotiationZ = 0.000000,
		RotiationW = 1.000000,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "Sailing_BasicSail_Default2",
		Map = M._MAP,
		Resource = M["Sailing_BasicSail_Default2"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "Sailing_BasicSail_Default",
		MapObject = M["Sailing_BasicSail_Default2"]
	}
end

M["Sailing_BasicSail_Default1"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 13.000000,
		PositionY = 4.000000,
		PositionZ = 11.000000,
		RotiationX = 0.000000,
		RotiationY = 0.000000,
		RotiationZ = 0.000000,
		RotiationW = 1.000000,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "Sailing_BasicSail_Default1",
		Map = M._MAP,
		Resource = M["Sailing_BasicSail_Default1"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "Sailing_BasicSail_Default",
		MapObject = M["Sailing_BasicSail_Default1"]
	}
end

return M
