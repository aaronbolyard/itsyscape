local M = {}

M._MAP = ItsyScape.Resource.Map "EmptyRuins_Downtown"

M["Door_IronGate2"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 29.000000,
		PositionY = 4.000000,
		PositionZ = 69.000000,
		RotationX = 0.000000,
		RotationY = -0.000000,
		RotationZ = 0.000000,
		RotationW = 1.000000,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "Door_IronGate2",
		Map = M._MAP,
		Resource = M["Door_IronGate2"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "Door_IronGate",
		MapObject = M["Door_IronGate2"]
	}
end

return M
