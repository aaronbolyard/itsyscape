--------------------------------------------------------------------------------
-- Resources/Game/Props/Building_SistineOfTheSimulacrum/View.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local SimpleBuildingView = require "Resources.Game.Props.Common.SimpleBuildingView"

local Sistine = Class(SimpleBuildingView)

Sistine.SCALE = Vector(2)

function Sistine:getTextureFolder()
	return "Resources/Game/Props/Building_SistineOfTheSimulacrum"
end

function Sistine:getModelFilename()
	return "Resources/Game/Props/Building_SistineOfTheSimulacrum/Model.lstatic"
end

function Sistine:load()
	SimpleBuildingView.load(self)

	local rootModelNode = self:getRootModelNode()
	rootModelNode:getTransform():setLocalScale(Sistine.SCALE)
end

return Sistine
