local M = {}

M._MAP = ItsyScape.Resource.Map "Dream_Teaser"

M["TheEmptyKingsExecutionerAxe1"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 27.000000,
		PositionY = 0.000000,
		PositionZ = 43.000000,
		RotationX = 0.000000,
		RotationY = 0.000000,
		RotationZ = 0.000000,
		RotationW = 1.000000,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "TheEmptyKingsExecutionerAxe1",
		Map = M._MAP,
		Resource = M["TheEmptyKingsExecutionerAxe1"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "TheEmptyKingsExecutionerAxe",
		MapObject = M["TheEmptyKingsExecutionerAxe1"]
	}
end

return M
