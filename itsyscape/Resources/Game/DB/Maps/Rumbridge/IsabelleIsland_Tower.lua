--------------------------------------------------------------------------------
-- Resources/Game/DB/Maps/Rumbridge/IsabelleIsland_Tower.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------

do
	local TalkAction = ItsyScape.Action.Talk()

	ItsyScape.Resource.Peep "IsabelleIsland_IsabelleNice" {
		TalkAction
	}

	ItsyScape.Meta.TalkSpeaker {
		Resource = ItsyScape.Resource.Peep "IsabelleIsland_IsabelleNice",
		Name = "Isabelle",
		Action = TalkAction
	}

	ItsyScape.Meta.TalkSpeaker {
		Resource = ItsyScape.Resource.Peep "IsabelleIsland_Drakkenson",
		Name = "Drakkenson",
		Action = TalkAction
	}

	ItsyScape.Meta.TalkDialog {
		Script = "Resources/Game/Maps/IsabelleIsland_Tower/Dialog/Isabelle_en-US.lua",
		Language = "en-US",
		Action = TalkAction
	}

	ItsyScape.Meta.PeepID {
		Value = "Resources.Game.Peeps.Isabelle.IsabelleNice",
		Resource = ItsyScape.Resource.Peep "IsabelleIsland_IsabelleNice"
	}

	ItsyScape.Meta.ResourceName {
		Language = "en-US",
		Value = "Isabelle",
		Resource = ItsyScape.Resource.Peep "IsabelleIsland_IsabelleNice"
	}

	ItsyScape.Meta.ResourceDescription {
		Language = "en-US",
		Value = "Her old neighbors were noisy, or was it nosey?",
		Resource = ItsyScape.Resource.Peep "IsabelleIsland_IsabelleNice"
	}
end

do
	local TalkAction = ItsyScape.Action.Talk()

	ItsyScape.Resource.Peep "IsabelleIsland_AdvisorGrimm" {
		TalkAction
	}

	ItsyScape.Meta.TalkSpeaker {
		Resource = ItsyScape.Resource.Peep "IsabelleIsland_AdvisorGrimm",
		Name = "AdvisorGrimm",
		Action = TalkAction
	}

	ItsyScape.Meta.TalkDialog {
		Script = "Resources/Game/Maps/IsabelleIsland_Tower/Dialog/AdvisorGrimm_en-US.lua",
		Language = "en-US",
		Action = TalkAction
	}

	ItsyScape.Meta.PeepID {
		Value = "Resources.Game.Peeps.AdvisorGrimm.AdvisorGrimm",
		Resource = ItsyScape.Resource.Peep "IsabelleIsland_AdvisorGrimm"
	}

	ItsyScape.Meta.ResourceName {
		Language = "en-US",
		Value = "Advisor Grimm",
		Resource = ItsyScape.Resource.Peep "IsabelleIsland_AdvisorGrimm"
	}

	ItsyScape.Meta.ResourceDescription {
		Language = "en-US",
		Value = "Gesundheit!",
		Resource = ItsyScape.Resource.Peep "IsabelleIsland_AdvisorGrimm"
	}
end

ItsyScape.Resource.Peep "IsabelleIsland_Drakkenson" {
	-- Nothing.
}

ItsyScape.Meta.ResourceName {
	Language = "en-US",
	Value = "Mysterious voice",
	Resource = ItsyScape.Resource.Peep "IsabelleIsland_Drakkenson"
}

ItsyScape.Meta.ResourceName {
	Language = "en-US",
	Value = "You want a spoiler? Page 606.",
	Resource = ItsyScape.Resource.Peep "IsabelleIsland_Drakkenson"
}