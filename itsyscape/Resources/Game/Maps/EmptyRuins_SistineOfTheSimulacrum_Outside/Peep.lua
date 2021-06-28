--------------------------------------------------------------------------------
-- Resources/Game/Maps/EmptyRuins_SistineOfTheSimulacrum_Outside/Peep.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Utility = require "ItsyScape.Game.Utility"
local Map = require "ItsyScape.Peep.Peeps.Map"

local Sistine = Class(Map)

function Sistine:new(resource, name, ...)
	Map.new(self, resource, name or 'Sistine_Teaser', ...)
end

function Sistine:onLoad(filename, args, layer)
	Map.onLoad(self, filename, args, layer)

	local stage = self:getDirector():getGameInstance():getStage()
	stage:forecast(layer, 'EmptyRuins_SistineOfTheSimulacrum_Outside_Bubbles', 'Fungal', {
		gravity = { 0, 3, 0 },
		wind = { 0, 0, 0 },
		colors = {
			{ 0.0, 0.0, 0.0, 1.0 },
			{ 0.7, 0.8, 0.2, 1.0 },
		},
		minHeight = -10,
		maxHeight = 0,
		ceiling = 20,
		heaviness = 0.5
	})
end

return Sistine
