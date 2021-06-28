local M = {}

M._MAP = ItsyScape.Resource.Map "EmptyRuins_SistineOfTheSimulacrum_Outside"

M["Building_SistineOfTheSimulacrum1"] = ItsyScape.Resource.MapObject.Unique()
do
	ItsyScape.Meta.MapObjectLocation {
		PositionX = 51.000000,
		PositionY = 1.000000,
		PositionZ = 31.000000,
		RotationX = 0.000000,
		RotationY = 0.000000,
		RotationZ = 0.000000,
		RotationW = 1.000000,
		ScaleX = 1.000000,
		ScaleY = 1.000000,
		ScaleZ = 1.000000,
		Name = "Building_SistineOfTheSimulacrum1",
		Map = M._MAP,
		Resource = M["Building_SistineOfTheSimulacrum1"]
	}

	ItsyScape.Meta.PropMapObject {
		Prop = ItsyScape.Resource.Prop "Building_SistineOfTheSimulacrum",
		MapObject = M["Building_SistineOfTheSimulacrum1"]
	}
end

return M
