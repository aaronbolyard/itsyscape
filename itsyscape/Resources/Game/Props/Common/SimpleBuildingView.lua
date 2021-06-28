--------------------------------------------------------------------------------
-- Resources/Game/Props/Common/SimpleBuildingView.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local Color = require "ItsyScape.Graphics.Color"
local DecorationSceneNode = require "ItsyScape.Graphics.DecorationSceneNode"
local PropView = require "ItsyScape.Graphics.PropView"
local SceneNode = require "ItsyScape.Graphics.SceneNode"
local StaticMeshResource = require "ItsyScape.Graphics.StaticMeshResource"
local TextureResource = require "ItsyScape.Graphics.TextureResource"

local SimpleBuildingView = Class(PropView)

function SimpleBuildingView:getTextureFolder()
	return Class.ABSTRACT()
end

function SimpleBuildingView:getModelFilename()
	return Class.ABSTRACT()
end

function SimpleBuildingView:getRootModelNode()
	return self.decoration
end

function SimpleBuildingView:load()
	PropView.load(self)

	local resources = self:getResources()
	local root = self:getRoot()

	self.decoration = SceneNode()

	resources:queue(
		StaticMeshResource,
		self:getModelFilename(),
		function(mesh)
			local decoration = mesh:getResource()
			for feature in decoration:iterate() do
				local textureFilename = string.format("%s/Texture_%s.png", self:getTextureFolder(), feature)

				local model = DecorationSceneNode()
				model:fromGroup(decoration, feature)

				resources:queue(
					TextureResource,
					textureFilename,
					function(texture)
						model:getMaterial():setTextures(texture)
						model:setParent(self.decoration)
					end)
			end
		end)

	self.decoration:setParent(root)
end

return SimpleBuildingView
