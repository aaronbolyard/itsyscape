--------------------------------------------------------------------------------
-- ItsyScape/Peep/Peeps/Prop.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local Utility = require "ItsyScape.Game.Utility"
local Peep = require "ItsyScape.Peep.Peep"
local PropReferenceBehavior = require "ItsyScape.Peep.Behaviors.PropReferenceBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local SizeBehavior = require "ItsyScape.Peep.Behaviors.SizeBehavior"

local Prop = Class(Peep)

function Prop:new(resource, ...)
	Peep.new(self, ...)

	self:addBehavior(PropReferenceBehavior)
	self:addBehavior(PositionBehavior)
	self:addBehavior(SizeBehavior)
	
	local size = self:getBehavior(SizeBehavior)
	size.size = Vector(1, 1, 1)

	self.resource = resource or false
	self.mapObject = false
end

function Prop:getGameDBResource()
	return self.resource
end

function Prop:setMapObject(value)
	self.mapObject = value or false
end

function Prop:getMapObject()
	return self.mapObject
end

function Prop:spawnOrPoof(mode)
	print(self:getName())
	local game = self:getDirector():getGameInstance()
	local position = self:getBehavior(PositionBehavior)
	local size = self:getBehavior(SizeBehavior)
	if position then
		local map = game:getStage():getMap(position.layer or 1)
		if map then
			local p = position.position
			local halfSize = size.size / 2

			for x = p.x - halfSize.x, p.x + halfSize.x do
				for z = p.z - halfSize.z, p.z + halfSize.z do
					local tile, i, j = map:getTileAt(x, z)

					if mode == 'spawn' then
						tile:pushImpassable()
					elseif mode == 'poof' then
						tile:popImpassable()
					end
				end
			end
		end
	end
end

function Prop:ready(director, game)
	Peep.ready(self, director, game)

	if self.resource then
		local gameDB = game:getGameDB()

		local name = Utility.getName(self.resource, gameDB)
		if name then
			self:setName(name)
		else
			self:setName("*" .. self.resource.name)
		end

		self:spawnOrPoof('spawn')
	end
end

function Prop:getPropState()
	return {}
end

return Prop
