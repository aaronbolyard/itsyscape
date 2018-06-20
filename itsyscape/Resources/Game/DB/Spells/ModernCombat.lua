--------------------------------------------------------------------------------
-- Resources/Game/DB/Spells/ModernCombat.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------

ItsyScape.Resource.Spell "FireBlast" {
	ItsyScape.Action.Cast() {
		Requirement {
			Resource = ItsyScape.Resource.Skill "Magic",
			Count = ItsyScape.Utility.xpForLevel(52)
		},

		Input {
			Resource = ItsyScape.Resource.Item "AirRune",
			Count = 10
		},

		Input {
			Resource = ItsyScape.Resource.Item "FireRune",
			Count = 10
		},

		Output {
			Resource = ItsyScape.Resource.Skill "Magic",
			Count = 100
		}
	}
}

ItsyScape.Meta.CombatSpell {
	Strength = 64,
	Resource = ItsyScape.Resource.Spell "FireBlast"
}

ItsyScape.Utility.tag(ItsyScape.Resource.Spell "FireBlast", "magic")
ItsyScape.Utility.tag(ItsyScape.Resource.Spell "FireBlast", "magic_modern_spell")
ItsyScape.Utility.tag(ItsyScape.Resource.Spell "FireBlast", "magic_combat_spell")

ItsyScape.Resource.Spell "WaterBlast" {
	ItsyScape.Action.Cast() {
		Requirement {
			Resource = ItsyScape.Resource.Skill "Magic",
			Count = ItsyScape.Utility.xpForLevel(48)
		},

		Input {
			Resource = ItsyScape.Resource.Item "AirRune",
			Count = 10
		},

		Input {
			Resource = ItsyScape.Resource.Item "WaterRune",
			Count = 10
		},

		Output {
			Resource = ItsyScape.Resource.Skill "Magic",
			Count = 90
		}
	}
}

ItsyScape.Meta.CombatSpell {
	Strength = 56,
	Resource = ItsyScape.Resource.Spell "WaterBlast"
}

ItsyScape.Utility.tag(ItsyScape.Resource.Spell "WaterBlast", "magic")
ItsyScape.Utility.tag(ItsyScape.Resource.Spell "WaterBlast", "magic_modern_spell")
ItsyScape.Utility.tag(ItsyScape.Resource.Spell "WaterBlast", "magic_combat_spell")

ItsyScape.Resource.Spell "EarthBlast" {
	ItsyScape.Action.Cast() {
		Requirement {
			Resource = ItsyScape.Resource.Skill "Magic",
			Count = ItsyScape.Utility.xpForLevel(44)
		},

		Input {
			Resource = ItsyScape.Resource.Item "AirRune",
			Count = 10
		},

		Input {
			Resource = ItsyScape.Resource.Item "EarthRune",
			Count = 10
		},

		Output {
			Resource = ItsyScape.Resource.Skill "Magic",
			Count = 70
		}
	}
}

ItsyScape.Utility.tag(ItsyScape.Resource.Spell "EarthBlast", "magic")
ItsyScape.Utility.tag(ItsyScape.Resource.Spell "EarthBlast", "magic_modern_spell")
ItsyScape.Utility.tag(ItsyScape.Resource.Spell "EarthBlast", "magic_combat_spell")

ItsyScape.Meta.CombatSpell {
	Strength = 48,
	Resource = ItsyScape.Resource.Spell "EarthBlast"
}

ItsyScape.Resource.Spell "AirBlast" {
	ItsyScape.Action.Cast() {
		Requirement {
			Resource = ItsyScape.Resource.Skill "Magic",
			Count = ItsyScape.Utility.xpForLevel(40)
		},

		Input {
			Resource = ItsyScape.Resource.Item "AirRune",
			Count = 10
		},

		Output {
			Resource = ItsyScape.Resource.Skill "Magic",
			Count = 60
		}
	}
}

ItsyScape.Meta.CombatSpell {
	Strength = 40,
	Resource = ItsyScape.Resource.Spell "AirBlast"
}

ItsyScape.Utility.tag(ItsyScape.Resource.Spell "AirBlast", "magic")
ItsyScape.Utility.tag(ItsyScape.Resource.Spell "AirBlast", "magic_modern_spell")
ItsyScape.Utility.tag(ItsyScape.Resource.Spell "AirBlast", "magic_combat_spell")
