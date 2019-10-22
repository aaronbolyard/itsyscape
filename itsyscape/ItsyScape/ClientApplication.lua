--------------------------------------------------------------------------------
-- ItsyScape/ClientApplication.lua
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
local PlayerStorage = require "ItsyScape.Game.PlayerStorage"
local GameDB = require "ItsyScape.GameDB.GameDB"
local ClientGame = require "ItsyScape.Game.ClientModel.Game"
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

local ClientApplication = Class(BaseApplication)
ClientApplication.CLICK_NONE = 0
ClientApplication.CLICK_ACTION = 1
ClientApplication.CLICK_WALK = 2
ClientApplication.CLICK_DURATION = 0.25
ClientApplication.CLICK_RADIUS = 32 
ClientApplication.CAMERA_HORIZONTAL_ROTATION = -math.pi / 6
ClientApplication.CAMERA_VERTICAL_ROTATION = -math.pi / 2
ClientApplication.MAX_CAMERA_VERTICAL_ROTATION_OFFSET = math.pi / 4
ClientApplication.MAX_CAMERA_HORIZONTAL_ROTATION_OFFSET = math.pi / 6 - math.pi / 12
ClientApplication.PROBE_TICK = 1 / 10

function ClientApplication:new()
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

	self.frames = 0
	self.frameTime = 0

	local storage
	do
		storage = PlayerStorage()
		storage:deserialize(love.filesystem.read('Player/Default.dat'))
	end

	self.gameDB = createGameDB()
	self.game = ClientGame("127.0.0.1:2017", storage)
	self.gameView = GameView(self.game)
	--self.uiView = UIView(self.gameView)

	--self.game.onQuit:register(self.quitGame, self)

	self.gameView:getRenderer():setCamera(self.camera)

	self.showDebug = true
	self.show2D = true
	self.show3D = true

	self.clickActionTime = 0
	self.clickActionType = ClientApplication.CLICK_NONE

	if _DEBUG then
		inspectGameDB(self.gameDB)
	end

	self.isCameraDragging = false
	self.cameraVerticalRotationOffset = 0
	self.cameraHorizontalRotationOffset = 0

	self:getCamera():setHorizontalRotation(ClientApplication.CAMERA_HORIZONTAL_ROTATION)
	self:getCamera():setVerticalRotation(ClientApplication.CAMERA_VERTICAL_ROTATION)

	self.showingToolTip = false
	self.toolTipTick = math.huge
	self.mouseMoved = false
	self.mouseX, self.mouseY = math.huge, math.huge

	self.previousPlayerPosition = false
	self.currentPlayerPosition = false

	self.cameraOffset = Vector(0)
end

function ClientApplication:getPlayerPosition(delta)
	local position
	do
		local gameView = self:getGameView()
		local actor = gameView:getActor(self:getGame():getPlayer():getActor())
		if actor then
			local node = actor:getSceneNode()
			local transform = node:getTransform():getGlobalDeltaTransform(delta or 0)
			position = Vector(transform:transformPoint(0, 1, 0))
		end
	end

	return position or Vector.ZERO
end

function ClientApplication:initialize()
	--self:getGame():getStage():newMap(1, 1, 1)

	love.audio.setDistanceModel('linear')

	self:tick()
end

function ClientApplication:getCamera()
	return self.camera
end

function ClientApplication:getGameDB()
	return self.gameDB
end

function ClientApplication:getGame()
	return self.game
end

function ClientApplication:getGameView()
	return self.gameView
end

function ClientApplication:getUIView()
	return self.uiView
end

function ClientApplication:probe(x, y, performDefault, callback, tests)
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
						self.clickActionType = ClientApplication.CLICK_WALK
					else
						self.clickActionType = ClientApplication.CLICK_ACTION
					end

					self.clickActionTime = ClientApplication.CLICK_DURATION
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

function ClientApplication:shoot(x, y)
	local width, height = love.window.getMode()
	y = height - y

	love.graphics.origin()
	self.camera:apply()

	local a = Vector(love.graphics.unproject(x, y, 0.0))
	local b = Vector(love.graphics.unproject(x, y, 0.1))
	local r = Ray(a, b - a)

	return r
end

function ClientApplication:update(delta)
	self.game:update()
	while self.game:getShouldTick() do
		self:tick()

		self.previousTickTime = love.timer.getTime()
	end

	--self:measure('game:update()', function() self.game:update(delta) end)
	self:measure('gameView:update()', function() self.gameView:update(delta) end)
	--self:measure('uiView:update()', function() self.uiView:update(delta) end)

	self.clickActionTime = self.clickActionTime - delta

	self.toolTipTick = self.toolTipTick - delta
	if self.mouseMoved and self.toolTipTick < 0 then
		self:probe(self.mouseX, self.mouseY, false, function(probe)
			local action = probe:toArray()[1]
			local renderer = self:getUIView():getRenderManager()
			if action and action.type ~= 'examine' then
				local text = string.format("%s %s", action.verb, action.object)
				self.showingToolTip = true
				self.toolTip = {
					ToolTip.Header(text),
					ToolTip.Text(action.description)
				}
			else
				renderer:unsetToolTip()
				self.toolTip = nil
				self.showingToolTip = false
			end
		end, { ['actors'] = true, ['props'] = true })

		self.mouseMoved = false
		self.toolTipTick = ClientApplication.PROBE_TICK
	end

	if self.showingToolTip then
		local renderer = self:getUIView():getRenderManager()
		renderer:setToolTip(
			math.huge,
			unpack(self.toolTip))
	end

	if _DEBUG then
		local isShiftDown = love.keyboard.isDown('lshift') or
		                    love.keyboard.isDown('rshift')
		local isCtrlDown = love.keyboard.isDown('lctrl') or
		                   love.keyboard.isDown('rctrl')
		local speed
		if isShiftDown then
			speed = 8
		else
			speed = 2
		end

		do
			if love.keyboard.isDown('up') then
				self.cameraOffset = self.cameraOffset + -Vector.UNIT_Z * speed * delta
			end

			if love.keyboard.isDown('down') then
				self.cameraOffset = self.cameraOffset + Vector.UNIT_Z * speed * delta
			end
		end

		do
			if love.keyboard.isDown('left') then
				self.cameraOffset = self.cameraOffset + -Vector.UNIT_X * speed * delta
			end
			if love.keyboard.isDown('right') then
				self.cameraOffset = self.cameraOffset + Vector.UNIT_X * speed * delta
			end
		end

		do
			if love.keyboard.isDown('pageup') then
				self.cameraOffset = self.cameraOffset + -Vector.UNIT_Y * speed * delta
			end
			if love.keyboard.isDown('pagedown') then
				self.cameraOffset = self.cameraOffset + Vector.UNIT_Y * speed * delta
			end
		end

		if love.keyboard.isDown('space') then
			self.cameraOffset = Vector(0)
		end
	end
end

function ClientApplication:tick()
	self:measure('gameView:tick()', function() self.gameView:tick() end)
	self:measure('game:tick()', function() self.game:tick() end)
end

function ClientApplication:quit()
	return false
end

function ClientApplication:quitGame(game)
	-- Nothing.
end

function ClientApplication:mousePress(x, y, button)
	if self.uiView:getInputProvider():isBlocking(x, y) then
		self.uiView:getInputProvider():mousePress(x, y, button)
		return true
	else
		if button == 1 then
			self:probe(x, y, true)
		elseif button == 2 then
			self:probe(x, y, false, function(probe) self.uiView:probe(probe:toArray()) end)
		elseif button == 3 then
			self.isCameraDragging = true
		end
	end

	return false
end

function ClientApplication:mouseRelease(x, y, button)
	self.uiView:getInputProvider():mouseRelease(x, y, button)

	if button == 3 then
		self.isCameraDragging = false
	end

	return false
end

function ClientApplication:mouseScroll(x, y)
	if self.uiView:getInputProvider():isBlocking(love.mouse.getPosition()) then
		self.uiView:getInputProvider():mouseScroll(x, y)
		return true
	else
		local distance = self.camera:getDistance() - y * 0.5

		if not _DEBUG then
			self:getCamera():setDistance(math.min(math.max(distance, 1), 40))
		else
			self:getCamera():setDistance(distance)
		end
	end

	return false
end

function ClientApplication:mouseMove(x, y, button)
	self.uiView:getInputProvider():mouseMove(x, y, dx, dy)

	self.mouseX = x
	self.mouseY = y

	if not self:getUIView():getInputProvider():isBlocking(love.mouse.getPosition()) then
		self.mouseMoved = true
		self.toolTipTick = math.min(self.toolTipTick, ClientApplication.PROBE_TICK)
	else
		if self.showingToolTip then
			self.showingToolTip = false
			local renderer = self:getUIView():getRenderManager()
			renderer:unsetToolTip()
		end
	end

	if self.isCameraDragging then
		local angle1 = self.cameraVerticalRotationOffset + dx / 128
		local angle2 = self.cameraHorizontalRotationOffset + -dy / 128

		if not _DEBUG then
			angle1 = math.max(
				angle1,
				-ClientApplication.MAX_CAMERA_VERTICAL_ROTATION_OFFSET)
			angle1 = math.min(
				angle1,
				ClientApplication.MAX_CAMERA_VERTICAL_ROTATION_OFFSET)
			angle2 = math.max(
				angle2,
				-ClientApplication.MAX_CAMERA_HORIZONTAL_ROTATION_OFFSET)
			angle2 = math.min(
				angle2,
				ClientApplication.MAX_CAMERA_HORIZONTAL_ROTATION_OFFSET)
		end

		self:getCamera():setVerticalRotation(
			ClientApplication.CAMERA_VERTICAL_ROTATION + angle1)
		self:getCamera():setHorizontalRotation(
			ClientApplication.CAMERA_HORIZONTAL_ROTATION + angle2)

		self.cameraVerticalRotationOffset = angle1
		self.cameraHorizontalRotationOffset = angle2
	end

	return false
end

function ClientApplication:keyDown(...)
	self.uiView:getInputProvider():keyDown(...)

	local isShiftDown = love.keyboard.isDown('lshift') or
	                    love.keyboard.isDown('rshift')

	local isCtrlDown = love.keyboard.isDown('lctrl') or
	                    love.keyboard.isDown('rctrl')

	if key == 'printscreen' and isCtrlDown then
		self:snapshotPlayerPeep()
	elseif key == 'printscreen' and isShiftDown then
		self:snapshotGame()
	end

	return false
end

function ClientApplication:getScreenshotName(prefix, index)
	local suffix = os.date("%Y-%m-%d %H%M%S")

	local filename
	if index then
		filename = string.format("%s %s %03d.png", prefix, suffix, index)
	else
		filename = string.format("%s %s.png", prefix, suffix)
	end

	return filename
end

function ClientApplication:snapshotPlayerPeep()
	local actors
	if _DEBUG then
		actors = {}
		for actor in self:getGame():getStage():iterateActors() do
			table.insert(actors, actor)
		end
	else
		actors = { self:getGame():getPlayer():getActor() }
	end

	local renderer = Renderer()
	love.graphics.push('all')
	do
		local camera = ThirdPersonCamera()
		local gameCamera = self:getCamera()
		camera:setHorizontalRotation(gameCamera:getHorizontalRotation())
		camera:setVerticalRotation(gameCamera:getVerticalRotation())
		camera:setWidth(1024)
		camera:setHeight(1024)

		local renderer = Renderer()
		love.graphics.setScissor()
		renderer:setClearColor(Color(0, 0, 0, 0))
		renderer:setCullEnabled(false)
		renderer:setCamera(camera)

		for index, actor in ipairs(actors) do
			local view = self:getGameView():getActor(actor)
			local zoom, position
			do
				local min, max = actor:getBounds()
				local offset = (max.y - min.y) / 2
				zoom = (max.z - min.z) + math.max((max.y - min.y), (max.x - min.x)) + 4

				local transform = view:getSceneNode():getTransform():getGlobalTransform()
				position = Vector(transform:transformPoint(0, offset, 0))
			end

			camera:setPosition(position)
			camera:setDistance(zoom)

			renderer:draw(view:getSceneNode(), self:getFrameDelta(), 1024, 1024)
			love.graphics.setCanvas()

			local imageData = renderer:getOutputBuffer():getColor():newImageData()
			imageData:encode('png', self:getScreenshotName("Peep", index))
		end
	end
	love.graphics.pop()
end

function ClientApplication:snapshotGame()
	love.graphics.push('all')
	do
		local camera = self:getCamera()
		local w, h = camera:getWidth(), camera:getHeight()

		camera:setWidth(1920)
		camera:setHeight(1080)

		local renderer = Renderer()

		love.graphics.setScissor()
		renderer:setClearColor(Color(0, 0, 0, 0))
		renderer:setCullEnabled(false)
		renderer:setCamera(camera)
		renderer:draw(self:getGameView():getScene(), self:getFrameDelta(), 1920, 1080)
		love.graphics.setCanvas()

		local imageData = renderer:getOutputBuffer():getColor():newImageData()
		imageData:encode('png', self:getScreenshotName("Screenshot"))

		camera:setWidth(w)
		camera:setHeight(h)
	end
	love.graphics.pop()
end

function ClientApplication:keyUp(...)
	self.uiView:getInputProvider():keyUp(...)
	return false
end

function ClientApplication:type(...)
	self.uiView:getInputProvider():type(...)
	return false
end

function ClientApplication:getFrameDelta()
	local currentTime = love.timer.getTime()
	local previousTime = self.previousTickTime

	-- Generate a delta (0 .. 1 inclusive) between the current and previous
	-- frames
	return (currentTime - previousTime) / self.game:getDelta()
end

function ClientApplication:draw()
	self:getCamera():setPosition(
		self:getPlayerPosition(self:getFrameDelta()) + self.cameraOffset)

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
			--self.uiView:draw()
		end

		if self.clickActionTime > 0 then
			local color
			if self.clickActionType == ClientApplication.CLICK_WALK then
				color = Color(1, 1, 0, 0.25)
			else
				color = Color(1, 0, 0, 0.25)
			end

			local mu = Tween.powerEaseInOut(
				self.clickActionTime / ClientApplication.CLICK_DURATION,
				3)
			local oldColor = { love.graphics.getColor() }
			love.graphics.setColor(color:get())
			love.graphics.circle(
				'fill',
				self.clickX, self.clickY,
				mu * ClientApplication.CLICK_RADIUS)
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

return ClientApplication
