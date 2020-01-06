--------------------------------------------------------------------------------
-- Resources/Game/Items/ToyBoomerang/Logic.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Boomerang = require "Resources.Game.Items.Common.Boomerang"

local ToyBoomerang = Class(Boomerang)

function ToyBoomerang:getProjectile()
	return 'ToyBoomerang'
end

return ToyBoomerang
