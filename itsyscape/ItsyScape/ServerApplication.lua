--------------------------------------------------------------------------------
-- ItsyScape/ServerApplication.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local BaseApplication = require "ItsyScape.BaseApplication"
local Class = require "ItsyScape.Common.Class"
local GameDB = require "ItsyScape.GameDB.GameDB"
local ServerGame = require "ItsyScape.Game.ServerModel.Game"
local Dispatch = require "ItsyScape.Game.ServerModel.Dispatch"

local function createGameDB()
	local t = {
		"Resources/Game/DB/Init.lua"
	}

	for _, item in ipairs(love.filesystem.getDirectoryItems("Resources/Game/Maps/")) do
		local f1 = "Resources/Game/Maps/" .. item .. "/DB/Main.lua"
		local f2 = "Resources/Game/Maps/" .. item .. "/DB/Default.lua"
		if love.filesystem.getInfo(f1) then
			table.insert(t, f1)
		elseif love.filesystem.getInfo(f2) then
			table.insert(t, f2)
		end
	end

	return GameDB.create(t, ":memory:")
end

local FONT = love.graphics.getFont()

local ServerApplication = Class(BaseApplication)
ServerApplication.CLICK_NONE = 0
ServerApplication.CLICK_ACTION = 1
ServerApplication.CLICK_WALK = 2
ServerApplication.CLICK_DURATION = 0.25
ServerApplication.CLICK_RADIUS = 32

function ServerApplication:new()
	BaseApplication.new(self)

	self.gameDB = createGameDB()
	self.game = ServerGame(self.gameDB)
	self.dispatch = Dispatch(self.game)
end

function ServerApplication:initialize()
	-- Nothing.
end

function ServerApplication:update(delta)
	self.game:update(delta)
	self.dispatch:tick()
end

function ServerApplication:tick()
	self.game:tick()
end

function ServerApplication:quit()
	return false
end

function ServerApplication:quitGame(game)
	-- Nothing.
end

function ServerApplication:draw()
	love.graphics.printf(
		'Server running.',
		0,
		0,
		300)
end

return ServerApplication
