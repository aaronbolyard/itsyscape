--------------------------------------------------------------------------------
-- Resources/Game/Maps/Rumbridge_Port/Peep.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Vector = require "ItsyScape.Common.Math.Vector"
local Quaternion = require "ItsyScape.Common.Math.Quaternion"
local Utility = require "ItsyScape.Game.Utility"
local Probe = require "ItsyScape.Peep.Probe"
local Map = require "ItsyScape.Peep.Peeps.Map"
local FollowerBehavior = require "ItsyScape.Peep.Behaviors.FollowerBehavior"
local PositionBehavior = require "ItsyScape.Peep.Behaviors.PositionBehavior"
local RotationBehavior = require "ItsyScape.Peep.Behaviors.RotationBehavior"

local Port = Class(Map)
Port.CREW_PASSAGE = {
	i1 = 21,
	j1 = 18,
	i2 = 24,
	j2 = 28
}

function Port:new(resource, name, ...)
	Map.new(self, resource, name or 'Rumbridge_Port', ...)

	self:addPoke('spawnShip')
	self:addPoke('recruit')
end

function Port:onLoad(filename, args, layer)
	Map.onLoad(self, filename, args, layer)

	self:poke('spawnShip')

	local playerStorage = self:getDirector():getPlayerStorage():getRoot()
	local followersStorage = playerStorage:getSection("Follower"):getSection("SailingCrew")
	for i = 1, followersStorage:length() do
		self:poke('recruit', followersStorage:getSection(i):get("id"))
	end
end

function Port:onSpawnShip(filename, args, layer)
	local player = self:getDirector():getGameInstance():getPlayer():getActor():getPeep()
	if player:getState():has("SailingItem", "Ship") then
		local _, ship = Utility.Map.spawnMap(self, "Ship_Player1", Vector(12, 0, 48))
		local rotation = ship:getBehavior(RotationBehavior)
		rotation.rotation = Quaternion.Y_90
		local position = ship:getBehavior(PositionBehavior)
		position.offset = Vector(0, 2, 0)
	end
end

function Port:onRecruit(id)
	local stage = self:getDirector():getGameInstance():getStage()
	local success, actor = stage:spawnActor(
		"Resources.Game.Peeps.Sailors.BaseSailor",
		self:getLayer())

	if success then
		local peep = actor:getPeep()
		peep:listen('finalize', function()
			local map = self:getDirector():getMap(self:getLayer())

			local position
			repeat
				local i = math.random(Port.CREW_PASSAGE.i1, Port.CREW_PASSAGE.i2)
				local j = math.random(Port.CREW_PASSAGE.j1, Port.CREW_PASSAGE.j2)
				local tile = map:getTile(i, j)

				if not tile:hasFlag('impassable') then
					position = map:getTileCenter(i, j)
				end
			until position

			peep:getBehavior(PositionBehavior).position = position

			peep:pushPoke('place', id)
		end)

		local follower = peep:getBehavior(FollowerBehavior)
		follower.id = id
	end
end

return Port
