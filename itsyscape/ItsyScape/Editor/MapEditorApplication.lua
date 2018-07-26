--------------------------------------------------------------------------------
-- ItsyScape/Editor/EditorApplication.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local StringBuilder = require "ItsyScape.Common.StringBuilder"
local Vector = require "ItsyScape.Common.Math.Vector"
local Quaternion = require "ItsyScape.Common.Math.Quaternion"
local GameDB = require "ItsyScape.GameDB.GameDB"
local EditorApplication = require "ItsyScape.Editor.EditorApplication"
local AlertWindow = require "ItsyScape.Editor.Common.AlertWindow"
local ConfirmWindow = require "ItsyScape.Editor.Common.ConfirmWindow"
local PromptWindow = require "ItsyScape.Editor.Common.PromptWindow"
local DecorationList = require "ItsyScape.Editor.Map.DecorationList"
local DecorationPalette = require "ItsyScape.Editor.Map.DecorationPalette"
local LandscapeToolPanel = require "ItsyScape.Editor.Map.LandscapeToolPanel"
local PropPalette = require "ItsyScape.Editor.Map.PropPalette"
local NewMapInterface = require "ItsyScape.Editor.Map.NewMapInterface"
local TerrainToolPanel = require "ItsyScape.Editor.Map.TerrainToolPanel"
local TileSetPalette = require "ItsyScape.Editor.Map.TileSetPalette"
local Decoration = require "ItsyScape.Graphics.Decoration"
local MapGridMeshSceneNode = require "ItsyScape.Graphics.MapGridMeshSceneNode"
local PointLightSceneNode = require "ItsyScape.Graphics.PointLightSceneNode"
local Color = require "ItsyScape.Graphics.Color"
local SceneNode = require "ItsyScape.Graphics.SceneNode"
local StaticMeshResource = require "ItsyScape.Graphics.StaticMeshResource"
local FlattenMapMotion = require "ItsyScape.World.FlattenMapMotion"
local HillMapMotion = require "ItsyScape.World.HillMapMotion"
local Map = require "ItsyScape.World.Map"
local MapMotion = require "ItsyScape.World.MapMotion"
local TileSet = require "ItsyScape.World.TileSet"

local MapEditorApplication = Class(EditorApplication)
MapEditorApplication.TOOL_NONE = 0
MapEditorApplication.TOOL_TERRAIN = 1
MapEditorApplication.TOOL_PAINT = 2
MapEditorApplication.TOOL_DECORATE = 3
MapEditorApplication.TOOL_PROP = 4

function MapEditorApplication:new()
	EditorApplication.new(self)

	self.motion = false
	self.decorationList = DecorationList(self)
	self.decorationPalette = DecorationPalette(self)
	self.landscapeToolPanel = LandscapeToolPanel(self)
	self.terrainToolPanel = TerrainToolPanel(self)
	self.tileSetPalette = TileSetPalette(self)
	self.propPalette = PropPalette(self)

	self.windows = {
		self.decorationList,
		self.decorationPalette,
		self.landscapeToolPanel,
		self.terrainToolPanel,
		self.tileSetPalette,
		self.propPalette
	}

	self.currentTool = MapEditorApplication.TOOL_NONE

	self.mapGridSceneNode = MapGridMeshSceneNode()
	self.mapGridSceneNode:getTransform():translate(Vector.UNIT_Y, 1 / 10)
	self.mapGridSceneNode:setParent(self:getGameView():getScene())
	self.mapGridSceneNode:setLineWidth(2)
	self.currentToolNode = false
	self.isDragging = false

	self:getGame():getStage().onMapModified:register(self.updateGrid, self)
	self:getGame():getStage().onLoadMap:register(self.updateTileSet, self)

	self.previousI = 0
	self.currentI = 0
	self.previousJ = 0
	self.currentJ = 0

	self.lastDecorationFeature = false
	self.filename = false

	self.propNames = {}
end

function MapEditorApplication:setTool(tool)
	if tool == self.currentTool then
		return
	end

	for i = 1, #self.windows do
		self.windows[i]:close()
	end

	if tool == MapEditorApplication.TOOL_TERRAIN then
		self.currentTool = MapEditorApplication.TOOL_TERRAIN
		self.terrainToolPanel:open()
		self.terrainToolPanel:setToolSize(0)
	elseif tool == MapEditorApplication.TOOL_PAINT then
		self.currentTool = MapEditorApplication.TOOL_PAINT
		self.tileSetPalette:open()
		self.landscapeToolPanel:open()
		self.landscapeToolPanel:setToolSize(0)
	elseif tool == MapEditorApplication.TOOL_DECORATE then
		self.lastDecorationFeature = false
		self.currentTool = MapEditorApplication.TOOL_DECORATE
		self.decorationList:open()
		self.decorationPalette:open()
	elseif tool == MapEditorApplication.TOOL_PROP then
		self.currentTool = MapEditorApplication.TOOL_PROP
		self.propPalette:open()
	end
end

function MapEditorApplication:initialize()
	EditorApplication.initialize(self)

	local newMapInterface = NewMapInterface(self)
	self:getUIView():getRoot():addChild(newMapInterface)
	newMapInterface.onSubmit:register(function()
		self:setTool(MapEditorApplication.TOOL_PAINT)
	end)
end

function MapEditorApplication:updateGrid(stage, map, layer)
	if layer == 1 then
		self.mapGridSceneNode:fromMap(map, false)
	end
end

function MapEditorApplication:updateTileSet(stage, map, layer, tileSetID)
	local tileSetFilename = string.format(
		"Resources/Game/TileSets/%s/Layout.lua",
		tileSetID or "GrassyPlain")
	self.tileSet, self.tileSetTexture = TileSet.loadFromFile(tileSetFilename, true)

	self.tileSetPalette:refresh(self.tileSet, self.tileSetTexture)
end

function MapEditorApplication:paint()
	local i, j, width, height
	do
		local motion
		do
			local x, y = love.mouse.getPosition()
			motion = MapMotion(self:getGame():getStage():getMap(1))
			motion:onMousePressed(self:makeMotionEvent(x, y, 1))
		end

		local tile
		tile, i, j = motion:getTile()

		i = i - self.landscapeToolPanel:getToolSize()
		j = j - self.landscapeToolPanel:getToolSize()
		local s = self.landscapeToolPanel:getToolSize() * 2 + 1
		width, height = s, s
	end

	local map = self:getGame():getStage():getMap(1)
	local mode = self.landscapeToolPanel:getMode()

	if map then
		for t = 1, height do
			for s = 1, width do
				local u = i + s - 1
				local v = j + t - 1

				if u >= 1 and u <= map:getWidth() and
				   v >= 1 and v <= map:getHeight()
				then
					local tile = map:getTile(u, v)
					if mode == LandscapeToolPanel.MODE_FLAT then
						tile.flat = self.tileSetPalette:getCurrentTile() or tile.flat
					elseif mode == LandscapeToolPanel.MODE_EDGE then
						tile.edge = self.tileSetPalette:getCurrentTile() or tile.edge
					elseif mode == LandscapeToolPanel.MODE_DECAL then
						tile.decals[1] = self.tileSetPalette:getCurrentTile()
					end
				end
			end
		end
	end

	self:getGame():getStage():updateMap(1)
end

function MapEditorApplication:makeMotionEvent(x, y, button)
	return {
		x = x or 0,
		y = y or 0,
		button = button or 1,
		ray = self:shoot(x, y),
		forward = self:getCamera():getForward(),
		left = self:getCamera():getLeft(),
		zoom = self:getCamera():getDistance(),
		eye = self:getCamera():getEye()
	}
end

function MapEditorApplication:makeMotion(x, y, button)
	local map = self:getGame():getStage():getMap(1)
	local size = self.terrainToolPanel:getToolSize()
	if size == TerrainToolPanel.SIZE_HILL then
		self.motion = HillMapMotion(map)
	elseif size == TerrainToolPanel.SIZE_SINGLE then
		self.motion = MapMotion(map)
	else
		self.motion = FlattenMapMotion(size, map)
	end
end

function MapEditorApplication:makeCurrentToolNode()
	if not self.currentToolNode then
		self.currentToolNode = MapGridMeshSceneNode()
		self.currentToolNode:getTransform():translate(Vector.UNIT_Y, 1 / 10)
		self.currentToolNode:setParent(self:getGameView():getScene())
		self.currentToolNode:setLineWidth(4)
	end
end

function MapEditorApplication:mousePress(x, y, button)
	if not EditorApplication.mousePress(self, x, y, button) then
		if button == 1 then
			if self.currentTool == MapEditorApplication.TOOL_TERRAIN then
				self:makeMotion(x, y, button)
				self.motion:onMousePressed(self:makeMotionEvent(x, y, button))

				if not self.currentToolNode then
					self:makeCurrentToolNode()
				end

				local _, i, j = self.motion:getTile()
				self.currentToolNode:fromMap(
					self:getGame():getStage():getMap(1),
					motion,
					i, i, j, j)
			elseif self.currentTool == MapEditorApplication.TOOL_PAINT then
				self:paint()
				self.isDragging = true
			elseif self.currentTool == MapEditorApplication.TOOL_DECORATE then
				local group, decoration = self.decorationList:getCurrentDecoration()
				if group and decoration then
					local tile = self.decorationPalette:getCurrentGroup()
					if tile then
						local motion = MapMotion(self:getGame():getStage():getMap(1))
						motion:onMousePressed(self:makeMotionEvent(x, y, button))

						local t, i, j = motion:getTile()
						local y = t:getInterpolatedHeight(0.5, 0.5)
						local x = (i - 1 + 0.5) * motion:getMap():getCellSize()
						local z = (j - 1 + 0.5) * motion:getMap():getCellSize()

						local rotation, scale
						if self.lastDecorationFeature then
							rotation = self.lastDecorationFeature:getRotation()
							scale = self.lastDecorationFeature:getScale()
						end

						self.lastDecorationFeature = decoration:add(
							tile,
							Vector(x, y, z),
							rotation,
							scale)
						self:getGame():getStage():decorate(group, decoration)
					end
				end
			elseif self.currentTool == MapEditorApplication.TOOL_PROP then
				local prop = self.propPalette:getCurrentProp()
				if prop then
					local s, p = self:getGame():getStage():placeProp("resource://" .. prop.name)
					if s then
						local motion = MapMotion(self:getGame():getStage():getMap(1))
						motion:onMousePressed(self:makeMotionEvent(x, y, button))

						local t, i, j = motion:getTile()
						local y = t:getInterpolatedHeight(0.5, 0.5)
						local x = (i - 1 + 0.5) * motion:getMap():getCellSize()
						local z = (j - 1 + 0.5) * motion:getMap():getCellSize()

						local peep = p:getPeep()
						local position = peep:getBehavior(require "ItsyScape.Peep.Behaviors.PositionBehavior")
						position.position = Vector(x, y, z)

						local index = 1
						local name
						repeat
							name = string.format("%s%d", prop.name, index)
							index = index + 1
						until self.propNames[name] == nil

						self.propNames[name] = p
						self.propNames[p] = name
					end
				end
			end
		elseif button == 2 then
			if self.currentTool == MapEditorApplication.TOOL_DECORATE then
				local group, decoration = self.decorationList:getCurrentDecoration()
				if group and decoration then
					local tileSetFilename = string.format(
						"Resources/Game/TileSets/%s/Layout.lstatic",
						decoration:getTileSetID())
					local staticMesh = self:getGameView():getResourceManager():load(
						StaticMeshResource,
						tileSetFilename)

					local hit
					do
						local hits = decoration:testRay(self:shoot(x, y), staticMesh:getResource())
						table.sort(hits, function(a, b)
							local i = self:getCamera():getEye() - a[Decoration.RAY_TEST_RESULT_POSITION]
							local j = self:getCamera():getEye() - b[Decoration.RAY_TEST_RESULT_POSITION]

							return i:getLength() < j:getLength()
						end)

						hit = hits[1]
					end

					if hit then
						decoration:remove(hit[Decoration.RAY_TEST_RESULT_FEATURE])
						self:getGame():getStage():decorate(group, decoration)
					end
				end
			elseif self.currentTool == MapEditorApplication.TOOL_PROP then
				local hit
				do
					local hits = {}
					for prop in self:getGame():getStage():iterateProps() do
						local ray = self:shoot(x, y)
						local s, p = ray:hitBounds(prop:getBounds())
						if s then
							table.insert(hits, { position = p, prop = prop })
						end
					end

					local eye = self:getCamera():getEye()
					table.sort(hits, function(a, b)
						return (a.position - eye):getLength() < (b.position - eye):getLength()
					end)

					hit = hits[1]
				end

				if hit then
					self:getGame():getStage():removeProp(hit.prop)
				end
			end
		end
	end
end

function MapEditorApplication:mouseMove(x, y, dx, dy)
	if not EditorApplication.mouseMove(self, x, y, dx, dy) then
		if self.motion then
			local r = self.motion:onMouseMoved(self:makeMotionEvent(x, y))

			if r then
				self:getGame():getStage():updateMap(1)
			end
		end

		do
			local motion
			if self.motion then
				motion = self.motion
			else
				motion = MapMotion(self:getGame():getStage():getMap(1))
				motion:onMousePressed(self:makeMotionEvent(x, y, 1))
			end

			local _, i, j = motion:getTile()
			self.previousI = self.currentI
			self.previousJ = self.currentJ
			self.currentI = i
			self.currentJ = j
		end

		if self.currentTool == MapEditorApplication.TOOL_TERRAIN then
			local motion
			if self.motion then
				motion = self.motion
			else
				motion = MapMotion(self:getGame():getStage():getMap(1))
				motion:onMousePressed(self:makeMotionEvent(x, y, 1))
			end

			local _, i, j = motion:getTile()
			if not self.currentToolNode then
				self:makeCurrentToolNode()
			end

			self.currentToolNode:fromMap(
				self:getGame():getStage():getMap(1),
				motion,
				i, i, j, j)
		elseif self.currentTool == MapEditorApplication.TOOL_PAINT then
			if not self.currentToolNode then
				self:makeCurrentToolNode()
			end

			local motion
			if not self.motion then
				motion = MapMotion(self:getGame():getStage():getMap(1))
				motion:onMousePressed(self:makeMotionEvent(x, y, 1))
			else
				motion = self.motion
			end

			local _, i, j = motion:getTile()

			self.currentToolNode:fromMap(
				self:getGame():getStage():getMap(1),
				false,
				i - self.landscapeToolPanel:getToolSize(),
				i + self.landscapeToolPanel:getToolSize(),
				j - self.landscapeToolPanel:getToolSize(),
				j + self.landscapeToolPanel:getToolSize())

			if self.isDragging and
			   (self.previousI ~= self.currentI or self.currentJ ~= self.previousJ)
			then
				self:paint()
			end
		elseif self.currentToolNode then
			self.currentToolNode:setParent(nil)
			self.currentToolNode = false
		end
	end
end

function MapEditorApplication:mouseRelease(x, y, button)
	if not EditorApplication.mouseRelease(self, x, y, button) then
		if button == 1 and self.motion then
			self.motion:onMouseReleased(self:makeMotionEvent(x, y, button))
			self.motion = false
		end

		self.isDragging = false
	end
end

function MapEditorApplication:keyDown(key, scan, isRepeat, ...)
	if not EditorApplication.keyDown(self, key, scan, isRepeat, ...) then
		if not isRepeat then
			if key == 'f1' then
				self:setTool(MapEditorApplication.TOOL_TERRAIN)
			elseif key == 'f2' then
				self:setTool(MapEditorApplication.TOOL_PAINT)
			elseif key == 'f3' then
				self:setTool(MapEditorApplication.TOOL_DECORATE)
			elseif key == 'f4' then
				self:setTool(MapEditorApplication.TOOL_PROP)
			end

			if self.currentTool == MapEditorApplication.TOOL_DECORATE
			   and self.lastDecorationFeature
			then
				if key == 'r' then
					local yRotation = Quaternion.fromAxisAngle(Vector.UNIT_Y, math.pi / 2)
					local newRotation = self.lastDecorationFeature:getRotation() * yRotation
					--newRotation = newRotation:getNormal()

					local group, decoration = self.decorationList:getCurrentDecoration()
					if decoration:remove(self.lastDecorationFeature) then
						self.lastDecorationFeature = decoration:add(
							self.lastDecorationFeature:getID(),
							self.lastDecorationFeature:getPosition(),
							newRotation,
							self.lastDecorationFeature:getScale())
						self:getGame():getStage():decorate(group, decoration)
					end
				end
			end

			if key == 's' and
			   (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl'))
			then
				local newSave
				if self.filename ~= false and
				   not (love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift'))
				then
					newSave = false
				else
					newSave = true
				end

				if newSave then
					local prompt = PromptWindow(self)
					prompt.onSubmit:register(function(_, filename)
						if not self:isResourceNameValid(filename) then
							local alert = AlertWindow(self)
							alert:open(string.format("Map name '%s' invalid.", filename))
						else
							local path = self:getOutputDirectoryName("Maps", filename)
							if love.filesystem.getInfo(path) then
								local confirm = ConfirmWindow(self)
								confirm.onSubmit:register(function()
									self:save(filename)
								end)
								confirm:open(string.format("Map '%s' already exists. Overwrite?", filename))
							else
								self:save(filename)
							end
						end
					end)
					prompt:open("What is the map name?", "Save", self.filename)
				else
					self:save(self.filename)
				end
			end

			if key == 'o' and
			   (love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl'))
			then
				local preferExisting = love.keyboard.isDown('lshift') or love.keyboard.isDown('rshift')

				local prompt = PromptWindow(self)
				prompt.onSubmit:register(function(_, filename)
					if not self:isResourceNameValid(filename) then
						local alert = AlertWindow(self)
						alert:open(string.format("Map name '%s' invalid.", filename))
					else
						if self:load(filename, preferExisting) then
							self.filename = filename
						end
					end
				end)
				prompt:open("What is the map name?", "Load")
			end
		end
	end
end

function MapEditorApplication:save(filename)
	if self:makeOutputDirectory("Maps", filename) then
		if not self:makeOutputSubdirectory("Maps", filename, "Decorations") then
			Log.warn("Couldn't save map %s.", filename)
			return false
		end

		local decorations = self:getGameView():getDecorations()
		for group, decoration in pairs(decorations) do
			local filename = self:getOutputFilename("Maps", filename, "Decorations", group .. ".ldeco")
			local s, r = love.filesystem.write(filename, decoration:toString())
			if not s then
				Log.warn(
					"Couldn't save decoration '%s' to %s: %s",
					group, filename, r)
			end
		end

		local layers = self:getGame():getStage():getLayers()
		for i = 1, #layers do
			local map = self:getGame():getStage():getMap(layers[i])
			local index = tonumber(layers[i])
			if index then
				local filename = self:getOutputFilename(
					"Maps",
					filename,
					StringBuilder.stringify(index, "%d") .. ".lmap")
				local s, r = love.filesystem.write(filename, map:toString())
				if not s then
					Log.warn(
						"Couldn't save map layer %d to %s: %s",
						index, filename, r)
				end
			end
		end

		do
			local meta = {}
			for i = 1, #layers do
				local _, tileSetID = self:getGameView():getMapTileSet(layers[i])
				meta[layers[i]] = {
					tileSetID = tileSetID,
				}
			end

			local filename = self:getOutputFilename("Maps", filename, "meta")
			love.filesystem.write(filename, StringBuilder.stringifyTable(meta))
		end

		do
			local s = StringBuilder()
			s:pushLine("local M = {}")
			s:pushLine()

			s:pushFormatLine("M._MAP = ItsyScape.Resource.Map %q", filename)
			s:pushLine()

			for prop in self:getGame():getStage():iterateProps() do
				local position = prop:getPosition()
				local rotation = prop:getRotation()
				local scale = prop:getScale()
				local name = self.propNames[prop]
				if name then
					s:pushFormatLine("M[%q] = ItsyScape.Resource.MapObject.Unique()", name)
					s:pushLine("do")
					s:pushLine("\tItsyScape.Meta.MapObjectLocation {")
					s:pushFormatLine("\t\tPositionX = %f,", position.x)
					s:pushFormatLine("\t\tPositionY = %f,", position.y)
					s:pushFormatLine("\t\tPositionZ = %f,", position.z)
					s:pushFormatLine("\t\tRotiationX = %f,", rotation.x)
					s:pushFormatLine("\t\tRotiationY = %f,", rotation.y)
					s:pushFormatLine("\t\tRotiationZ = %f,", rotation.z)
					s:pushFormatLine("\t\tRotiationW = %f,", rotation.w)
					s:pushFormatLine("\t\tScaleX = %f,", scale.x)
					s:pushFormatLine("\t\tScaleY = %f,", scale.y)
					s:pushFormatLine("\t\tScaleZ = %f,", scale.z)
					s:pushFormatLine("\t\tName = %q,", name)
					s:pushFormatLine("\t\tMap = M._MAP,")
					s:pushFormatLine("\t\tResource = M[%q]", name)
					s:pushFormatLine("\t}")
					s:pushLine()
					s:pushLine("\tItsyScape.Meta.PropMapObject {")
					s:pushFormatLine("\t\tProp = ItsyScape.Resource.Prop %q,", prop:getResourceName())
					s:pushFormatLine("\t\tMapObject = M[%q]", name)
					s:pushFormatLine("\t}")
					s:pushLine("end")
				end
			end

			s:pushLine()
			s:pushLine("return M")

			local dbFilename = self:getOutputFilename("Maps", filename, "DB", "Default.lua")
			love.filesystem.write(dbFilename, s:toString())
		end

		self.filename = filename
		return true
	end

	return false
end

function MapEditorApplication:load(filename, preferExisting)
	self:unload()

	local path
	if preferExisting then
		path = self:getDirectoryName("Maps", filename)
	end

	if not path or not love.filesystem.getInfo(path) then
		path = self:getOutputDirectoryName("Maps", filename)
	end

	if not love.filesystem.getInfo(path) then
		Log.warn("Map '%s' doesn't exist.", filename)

		return false
	end

	local meta
	do
		local metaFilename
		if preferExisting then
			metaFilename = self:getDirectoryName("Maps", filename) .. "meta"
			print(metaFilename)
		else
			metaFilename = self:getOutputFilename("Maps", filename, "meta")
		end
		local data = "return " .. (love.filesystem.read(metaFilename) or "")
		local chunk = assert(loadstring(data))
		meta = setfenv(chunk, {})() or {}
	end

	for _, item in ipairs(love.filesystem.getDirectoryItems(path)) do
		local layer = item:match(".*(-?%d)%.lmap$")
		if layer then
			layer = tonumber(layer)
			local map = Map.loadFromFile(path .. item)

			local tileSetID
			if meta[layer] then
				tileSetID = meta[layer].tileSetID
			end

			local layerMeta = meta[layer] or {}

			self:getGame():getStage():newMap(
				map:getWidth(), map:getHeight(), layer, layerMeta.tileSetID)
			self:getGame():getStage():updateMap(layer, map)
		end
	end

	for _, item in ipairs(love.filesystem.getDirectoryItems(path .. "/Decorations")) do
		local group = item:match("(.*)%.ldeco$")
		if group then
			local decoration = Decoration(path .. "Decorations/" .. item)
			self:getGame():getStage():decorate(group, decoration)
		end
	end

	if love.filesystem.getInfo(path .. "/DB/Default.lua") then
		local gameDB = GameDB.create({
			"Resources/Game/DB/Init.lua",
			path .. "/DB/Default.lua"
		}, ":memory:")

		local resource = gameDB:getResource(filename, "Map")
		if resource then
			local objects = gameDB:getRecords("MapObjectLocation", {
				Map = resource
			})

			for i = 1, #objects do
				local x = objects[i]:get("PositionX") or 0
				local y = objects[i]:get("PositionY") or 0
				local z = objects[i]:get("PositionZ") or 0

				do
					local prop = gameDB:getRecord("PropMapObject", {
						MapObject = objects[i]:get("Resource")
					})

					if prop then
						prop = prop:get("Prop")
						if prop then
							local s, p = self:getGame():getStage():placeProp("resource://" .. prop.name)

							if s then
								local peep = p:getPeep()
								local position = peep:getBehavior(require "ItsyScape.Peep.Behaviors.PositionBehavior")
								position.position = Vector(x, y, z)
							end

							local name = objects[i]:get("Name")
							self.propNames[name] = p
							self.propNames[p] = name
						end
					end
				end
			end
		end
	end

	return true
end

function MapEditorApplication:unload()
	local layers = self:getGame():getStage():getLayers()
	for i = 1, #layers do
		self:getGame():getStage():unloadMap(layers[i])
	end

	local decorations = self:getGameView():getDecorations()
	for group, decoration in pairs(decorations) do
		self:getGame():getStage():decorate(group, nil)
	end

	for prop in self:getGame():getStage():iterateProps() do
		self:getGame():getStage():removeProp(prop)
	end

	self.propNames = {}
end

return MapEditorApplication
