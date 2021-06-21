local M = {}

M._MAP = ItsyScape.Resource.Map "Rumbridge_Monastery_Floor1"

M["WoodenLadder_Default1"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 31.000000,
		PositionY = 3.000000,
		PositionZ = 43.000000,
		RotationX = 0.000000,
		RotationY = 0.000000,
		RotationZ = 0.000000,
		RotationW = 1.000000,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "WoodenLadder_Default1",
		Map = M._MAP,
		Resource = M["WoodenLadder_Default1"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "WoodenLadder_Default",
		MapObject = M["WoodenLadder_Default1"]
	}
end

return M
