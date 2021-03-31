--------------------------------------------------------------------------------
-- Resources/Game/Props/TV/View.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local SimpleStaticView = require "Resources.Game.Props.Common.SimpleStaticView"

local TV = Class(SimpleStaticView)

function TV:getTextureFilename()
	return "Resources/Game/Props/TV/Texture.png"
end

function TV:getModelFilename()
	return "Resources/Game/Props/TV/Model.lstatic", "TV"
end

return TV
