--------------------------------------------------------------------------------
-- ItsyScape/Application.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local BaseApplication = require "ItsyScape.BaseApplication"
local Class = require "ItsyScape.Common.Class"
local Tween = require "ItsyScape.Common.Math.Tween"
local Vector = require "ItsyScape.Common.Math.Vector"
local Ray = require "ItsyScape.Common.Math.Ray"
local Probe = require "ItsyScape.Game.Probe"
local GameDB = require "ItsyScape.GameDB.GameDB"
local LocalGame = require "ItsyScape.Game.LocalModel.Game"
local Color = require "ItsyScape.Graphics.Color"
local GameView = require "ItsyScape.Graphics.GameView"
local Renderer = require "ItsyScape.Graphics.Renderer"
local ThirdPersonCamera = require "ItsyScape.Graphics.ThirdPersonCamera"
local ToolTip = require "ItsyScape.UI.ToolTip"
local UIView = require "ItsyScape.UI.UIView"

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

local function inspectGameDB(gameDB)
	local VISIBLE_RESOURCES = {
		"Item",
		"Peep",
		"Prop",
		"Map"
	}

	for i = 1, #VISIBLE_RESOURCES do
		local resourceType = VISIBLE_RESOURCES[i]
		for resource in gameDB:getResources(resourceType) do
			local name = gameDB:getRecord("ResourceName", {
				Resource = resource
			})

			if not name then
				Log.warn("Resource '%s' (%s) doesn't have name.", resource.name, resourceType)
			end

			local description = gameDB:getRecord("ResourceDescription", {
				Resource = resource
			})

			if not description then
				Log.warn("Resource '%s' (%s) doesn't have description.", resource.name, resourceType)
			end
		end
	end
end

local FONT = love.graphics.getFont()

local Application = Class(BaseApplication)
Application.CLICK_NONE = 0
Application.CLICK_ACTION = 1
Application.CLICK_WALK = 2
Application.CLICK_DURATION = 0.25
Application.CLICK_RADIUS = 32

function Application:new()
	BaseApplication.new(self)

	self.camera = ThirdPersonCamera()
	do
		self.camera:setDistance(30)
		self.camera:setUp(Vector(0, -1, 0))
		self.camera:setHorizontalRotation(-math.pi / 8)
		self.camera:setVerticalRotation(-math.pi / 2)
	end

	self.previousTickTime = love.timer.getTime()
	self.startDrawTime = false
	self.time = 0

	self.frames = 0
	self.frameTime = 0

	self.gameDB = createGameDB()
	self.game = LocalGame(self.gameDB)
	self.gameView = GameView(self.game)
	self.uiView = UIView(self.gameView)

	self.game.onQuit:register(self.quitGame, self)

	self.gameView:getRenderer():setCamera(self.camera)

	self.showDebug = true
	self.show2D = true
	self.show3D = true

	self.clickActionTime = 0
	self.clickActionType = Application.CLICK_NONE

	if _DEBUG then
		inspectGameDB(self.gameDB)
	end

	self.paused = false
end

function Application:initialize()
	self:getGame():getStage():newMap(1, 1, 1)

	self:tick()
end

function Application:getCamera()
	return self.camera
end

function Application:getGameDB()
	return self.gameDB
end

function Application:getGame()
	return self.game
end

function Application:getGameView()
	return self.gameView
end

function Application:getUIView()
	return self.uiView
end

function Application:getIsPaused()
	return self.paused
end

function Application:setIsPaused(value)
	self.paused = value or false
end

function Application:probe(x, y, performDefault, callback, tests)
	if self.paused then
		return
	end

	local ray = self:shoot(x, y)
	local probe = Probe(self.game, self.gameView, self.gameDB, ray, tests)
	probe.onExamine:register(function(name, description)
		self.uiView:examine(name, description)
	end)
	probe:all(function()
		if performDefault then
			for action in probe:iterate() do
				if action.id ~= "Examine" then
					if action.id == "Walk" then
						self.clickActionType = Application.CLICK_WALK
					else
						self.clickActionType = Application.CLICK_ACTION
					end

					self.clickActionTime = Application.CLICK_DURATION
					self.clickX, self.clickY = love.mouse.getPosition()

					local s, r = pcall(action.callback)
					if not s then
						Log.warn("couldn't perform action: %s", r)
					end
					break
				end
			end
		end

		if callback then
			callback(probe)
		end
	end)
end

function Application:shoot(x, y)
	local width, height = love.window.getMode()
	y = height - y

	love.graphics.origin()
	self.camera:apply()

	local a = Vector(love.graphics.unproject(x, y, 0.0))
	local b = Vector(love.graphics.unproject(x, y, 0.1))
	local r = Ray(a, b - a)

	return r
end

function Application:update(delta)
	-- Accumulator. Stores time until next tick.
	self.time = self.time + delta

	-- Only update at the specified intervals.
	while self.time > self.game:getDelta() do
		self:tick()

		-- Handle cases where 'delta' exceeds TICK_RATE
		self.time = self.time - self.game:getDelta()

		-- Store the previous frame time.
		self.previousTickTime = love.timer.getTime()
	end

	self:measure('game:update()', function() self.game:update(delta) end)
	self:measure('gameView:update()', function() self.gameView:update(delta) end)
	self:measure('uiView:update()', function() self.uiView:update(delta) end)

	self.clickActionTime = self.clickActionTime - delta
end

function Application:tick()
	if not self.paused then
		self:measure('gameView:tick()', function() self.gameView:tick() end)
		self:measure('game:tick()', function() self.game:tick() end)
	end
end

function Application:quit()
	return false
end

function Application:quitGame(game)
	-- Nothing.
end

function Application:mousePress(x, y, button)
	if self.uiView:getInputProvider():isBlocking(x, y) then
		self.uiView:getInputProvider():mousePress(x, y, button)
		return true
	end

	return false
end

function Application:mouseRelease(x, y, button)
	self.uiView:getInputProvider():mouseRelease(x, y, button)

	return false
end

function Application:mouseScroll(x, y)
	if self.uiView:getInputProvider():isBlocking(love.mouse.getPosition()) then
		self.uiView:getInputProvider():mouseScroll(x, y)
		return true
	end

	return false
end

function Application:mouseMove(x, y, button)
	self.uiView:getInputProvider():mouseMove(x, y, dx, dy)

	return false
end

function Application:keyDown(...)
	self.uiView:getInputProvider():keyDown(...)
	return false
end

function Application:keyUp(...)
	self.uiView:getInputProvider():keyUp(...)
	return false
end

function Application:type(...)
	self.uiView:getInputProvider():type(...)
	return false
end

function Application:getFrameDelta()
	local currentTime = love.timer.getTime()
	local previousTime = self.previousTickTime

	-- Generate a delta (0 .. 1 inclusive) between the current and previous
	-- frames
	return (currentTime - previousTime) / self.game:getDelta()
end

function Application:draw()
	local width, height = love.window.getMode()
	local function draw()
		local delta = self:getFrameDelta()

		self.camera:setWidth(width)
		self.camera:setHeight(height)

		do
			if self.show3D then
				self.gameView:getRenderer():draw(self.gameView:getScene(), delta)
			end

			self.gameView:getRenderer():present()

			if self.show2D then
				self.gameView:getSpriteManager():draw(self.camera, delta)
			end
		end

		love.graphics.setBlendMode('alpha')
		love.graphics.origin()
		love.graphics.ortho(width, height)

		if self.show2D then
			self.uiView:draw()
		end

		if self.clickActionTime > 0 then
			local color
			if self.clickActionType == Application.CLICK_WALK then
				color = Color(1, 1, 0, 0.25)
			else
				color = Color(1, 0, 0, 0.25)
			end

			local mu = Tween.powerEaseInOut(
				self.clickActionTime / Application.CLICK_DURATION,
				3)
			local oldColor = { love.graphics.getColor() }
			love.graphics.setColor(color:get())
			love.graphics.circle(
				'fill',
				self.clickX, self.clickY,
				mu * Application.CLICK_RADIUS)
			love.graphics.setColor(unpack(oldColor))
		end
	end

	local s, r = xpcall(function() self:measure('draw', draw) end, debug.traceback)
	if not s then
		love.graphics.setBlendMode('alpha')
		love.graphics.origin()
		love.graphics.ortho(width, height)

		error(r, 0)
	end

	if _DEBUG and self.showDebug then
		love.graphics.setFont(FONT)

		local width = love.window.getMode()
		local r = string.format("FPS: %d\n", love.timer.getFPS())
		local sum = 0
		for i = 1, #self.times do
			r = r .. string.format(
				"%s: %.04f (%010d)\n",
				self.times[i].name,
				self.times[i].value,
				1 / self.times[i].value)
			sum = sum + self.times[i].value
		end
		if 1 / sum < 60 then
			r = r .. string.format(
					"!!! sum: %.04f (%010d)\n",
					sum,
					1 / sum)
		else
			r = r .. string.format(
					"sum: %.04f (%010d)\n",
					sum,
					1 / sum)
		end

		love.graphics.printf(
			r,
			width - 300,
			0,
			300,
			'right')
	end

	self.frames = self.frames + 1
	local currentTime = love.timer.getTime()
	if currentTime > self.frameTime + 1 then
		self.fps = math.floor(self.frames / (currentTime - self.frameTime))
		self.frames = 0
		self.frameTime = currentTime
	end
end

return Application
