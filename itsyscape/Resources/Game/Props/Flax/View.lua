--------------------------------------------------------------------------------
-- Resources/Game/Props/Flax/View.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local SimpleStaticView = require "Resources.Game.Props.Common.SimpleStaticView"

local Flax = Class(SimpleStaticView)

function Flax:getTextureFilename()
	return "Resources/Game/Props/Flax/Texture.png"
end

function Flax:getModelFilename()
	return "Resources/Game/Props/Flax/Model.lstatic", "Flax"
end

return Flax
