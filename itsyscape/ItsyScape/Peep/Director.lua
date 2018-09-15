--------------------------------------------------------------------------------
-- ItsyScape/Peep/Director.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Peep = require "ItsyScape.Peep.Peep"

-- Director type.
--
-- A director is a collection of Peeps and Cortexes. Whenever a Peep is added or
-- modified, the Director informs the Cortexes so they can properly filter the
-- Peep.
local Director = Class()

function Director:new(gameDB)
	self.gameDB = gameDB
	self.peeps = {}
	self.cortexes = {}
	self.pendingPeeps = {}
	self.newPeeps = {}
	self.oldPeeps = {}
	self._previewPeep = function(peep, behavior)
		self.pendingPeeps[peep] = true
	end

	self.maps = {}
end

-- Gets the GameDB.
function Director:getGameDB()
	return self.gameDB
end

-- Sets the map for the specified layer.
function Director:setMap(layer, map)
	self.maps[layer] = map
end

-- Gets the map for the specified layer.
function Director:getMap(layer)
	return self.maps[layer]
end

-- Gets the game instance (i.e., ItsyScape.Game.Model.Game).
--
-- If not implemented, returns nil.
function Director:getGameInstance()
	return nil
end

-- Adds a Cortex of the provided type to the Director.
function Director:addCortex(cortexType, ...)
	local cortex = cortexType(...)
	cortex:attach(self)

	table.insert(self.cortexes, cortex)
	return cortex
end

-- Removes a Cortex instance from the Director.
--
-- Returns true if the Cortex was removed, false otherwise. If the Cortex does
-- not belong to the Director, for example, it cannot be removed.
function Director:removeCortex(cortex)
	for index, c in ipairs(self.cortexes) do
		if c == cortex then
			cortex:detach()
			table.remove(self.cortexes, index)

			return true
		end
	end

	return false
end

-- Adds a Peep of the provided type to the Director.
--
-- If no type is provided, just adds a plain 'ol Peep.
function Director:addPeep(peepType, ...)
	peepType = peepType or Peep

	local peep = peepType(...)
	peep.onBehaviorAdded:register(self._previewPeep)
	peep.onBehaviorRemoved:register(self._previewPeep)

	self.newPeeps[peep] = true
	self.pendingPeeps[peep] = true

	peep:assign(self)

	return peep
end

-- Removes a Peep instance from the Director.
--
-- Returns true if the Peep was removed, false otherwise. If the Peep does not
-- belong to the Director, for example, it cannot be removed.
function Director:removePeep(peep)
	if self.peeps[peep] then
		peep.onBehaviorAdded:unregister(self._previewPeep)
		peep.onBehaviorRemoved:unregister(self._previewPeep)

		for _, cortex in ipairs(self.cortexes) do
			cortex:removePeep(peep)
		end

		self.oldPeeps[peep] = true
	end
end

function Director:probe(...)
	local args = { n = select('#', ...), ... }

	local result = {}
	for peep in pairs(self.peeps) do
		local match = true
		for i = 1, args.n do
			local func = args[i]
			if func and not func(peep) then
				match = false
				break
			end
		end

		if match then
			table.insert(result, peep)
		end
	end

	return result
end

-- Updates the Director.
--
-- First updates Peeps.
--
-- Then each Cortex, in the order they were added, is updated.
function Director:update(delta)
	for peep in pairs(self.newPeeps) do
		self.peeps[peep] = true
	end
	self.newPeeps = {}

	for peep in pairs(self.oldPeeps) do
		self.peeps[peep] = nil
	end
	self.oldPeeps = {}

	for peep in pairs(self.peeps) do
		peep:update(self, self:getGameInstance())
	end

	for _, cortex in ipairs(self.cortexes) do
		for peep in pairs(self.pendingPeeps) do
			cortex:previewPeep(peep)
		end
	end
	self.pendingPeeps = {}

	for _, cortex in pairs(self.cortexes) do
		cortex:update(delta)
	end
end

return Director
