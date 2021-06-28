--------------------------------------------------------------------------------
-- Resources/Game/DB/Creeps/TheEmptyKing.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------

ItsyScape.Resource.Peep "TheEmptyKing_Cutscene" {
	-- Nothing
}

ItsyScape.Meta.PeepID {
	Value = "Resources.Game.Peeps.TheEmptyKing.CutsceneEmptyKing",
	Resource = ItsyScape.Resource.Peep "TheEmptyKing_Cutscene"
}

ItsyScape.Meta.ResourceName {
	Value = "The Empty King",
	Language = "en-US",
	Resource = ItsyScape.Resource.Peep "TheEmptyKing_Cutscene"
}

ItsyScape.Meta.ResourceDescription {
	Value = "They whisper your fate in riddles, for They know the end of all things.",
	Language = "en-US",
	Resource = ItsyScape.Resource.Peep "TheEmptyKing_Cutscene"
}

ItsyScape.Resource.Peep "TheEmptyKing_FullyRealized_Cutscene" {
	ItsyScape.Action.Attack()
}

ItsyScape.Meta.PeepID {
	Value = "Resources.Game.Peeps.TheEmptyKing.CutsceneEmptyKingFullyRealized",
	Resource = ItsyScape.Resource.Peep "TheEmptyKing_FullyRealized_Cutscene"
}

ItsyScape.Meta.ResourceName {
	Value = "The Empty King",
	Language = "en-US",
	Resource = ItsyScape.Resource.Peep "TheEmptyKing_FullyRealized_Cutscene"
}

ItsyScape.Meta.ResourceDescription {
	Value = "The Empty King in their fully realized glory. Praise Them!",
	Language = "en-US",
	Resource = ItsyScape.Resource.Peep "TheEmptyKing_FullyRealized_Cutscene"
}

ItsyScape.Resource.Prop "TheEmptyKingsExecutionerAxe" {
	-- Nothing
}

ItsyScape.Meta.PeepID {
	Value = "Resources.Game.Peeps.Props.PassableProp",
	Resource = ItsyScape.Resource.Prop "TheEmptyKingsExecutionerAxe"
}

ItsyScape.Meta.ResourceName {
	Value = "The Empty King's executioner axe",
	Language = "en-US",
	Resource = ItsyScape.Resource.Prop "TheEmptyKingsExecutionerAxe"
}

ItsyScape.Meta.ResourceDescription {
	Value = "How many lives were lost during the ritual that banished the Old Ones from the Realm?",
	Language = "en-US",
	Resource = ItsyScape.Resource.Prop "TheEmptyKingsExecutionerAxe"
}

ItsyScape.Resource.Peep "EmptyZealot_Cutscene" {
	-- Nothing
}

ItsyScape.Meta.PeepID {
	Value = "Resources.Game.Peeps.EmptyZealot.BaseEmptyZealot",
	Resource = ItsyScape.Resource.Peep "EmptyZealot_Cutscene"
}

ItsyScape.Meta.ResourceName {
	Value = "Zealot",
	Language = "en-US",
	Resource = ItsyScape.Resource.Peep "EmptyZealot_Cutscene"
}

ItsyScape.Meta.ResourceDescription {
	Value = "A fanatic devoting their life in service to the Empty King.",
	Language = "en-US",
	Resource = ItsyScape.Resource.Peep "EmptyZealot_Cutscene"
}

ItsyScape.Resource.Peep "Nyarlathotep_Cutscene" {
	-- Nothing
}

ItsyScape.Meta.PeepID {
	Value = "Resources.Game.Peeps.Nyarlathotep.BaseNyarlathotep",
	Resource = ItsyScape.Resource.Peep "Nyarlathotep_Cutscene"
}

ItsyScape.Meta.ResourceName {
	Value = "Nyarlathotep, First Consul",
	Language = "en-US",
	Resource = ItsyScape.Resource.Peep "Nyarlathotep_Cutscene"
}

ItsyScape.Meta.ResourceDescription {
	Value = "Serves as First Consul of The Empty King's divine bureaucracy, the Fate Mashina. But rumors speak of their inclination for shadows and trickery...",
	Language = "en-US",
	Resource = ItsyScape.Resource.Peep "Nyarlathotep_Cutscene"
}

ItsyScape.Resource.Prop "Building_SistineOfTheSimulacrum" {
	-- Nothing
}

ItsyScape.Meta.PeepID {
	Value = "Resources.Game.Peeps.Props.PassableProp",
	Resource = ItsyScape.Resource.Prop "Building_SistineOfTheSimulacrum"
}

ItsyScape.Meta.MapObjectSize {
	SizeX = 0,
	SizeY = 0,
	SizeZ = 0,
	MapObject = ItsyScape.Resource.Prop "Building_SistineOfTheSimulacrum"
}
