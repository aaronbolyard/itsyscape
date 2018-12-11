--------------------------------------------------------------------------------
-- ItsyScape/UI/SkillGuideController.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Utility = require "ItsyScape.Game.Utility"
local Mapp = require "ItsyScape.GameDB.Mapp"
local Controller = require "ItsyScape.UI.Controller"

local SkillGuideController = Class(Controller)

function SkillGuideController:new(peep, director, skill)
	Controller.new(self, peep, director)

	local game = director:getGameInstance()
	local gameDB = director:getGameDB()
	local brochure = gameDB:getBrochure()

	self.state = { actions = {} }
	self.actionsByID = {}
	self.skill = skill or false

	if self.skill then
		local actionTypes = gameDB:getRecords("SkillAction", {
			Skill = gameDB:getResource(self.skill, "Skill")
		})

		local actionDefinition = Mapp.ActionDefinition()
		for i = 1, #actionTypes do
			if brochure:tryGetActionDefinition(actionTypes[i]:get("ActionType"), actionDefinition) then
				for action in brochure:findActionsByDefinition(actionDefinition) do
					local a, ActionType = Utility.getAction(game, action)
					if a then
						table.insert(self.state.actions, a)
						self.actionsByID[a.id] = action
					end
				end
			end
		end

		self:sort()
	end
end

function SkillGuideController:findActionXPRequirement(action)
	local gameDB = self:getDirector():getGameDB()
	local brochure = gameDB:getBrochure()
	for requirement in brochure:getRequirements(action) do
		local resource = brochure:getConstraintResource(requirement)
		local resourceType = brochure:getResourceTypeFromResource(resource)
		if resourceType.name:lower() == 'skill' and
		   resource.name:lower() == self.skill:lower()
		then
			return requirement.count
		end
	end

	return false
end

function SkillGuideController:findActionOutputXP(action)
	local gameDB = self:getDirector():getGameDB()
	local brochure = gameDB:getBrochure()
	for output in brochure:getOutputs(action) do
		local resource = brochure:getConstraintResource(output)
		local resourceType = brochure:getResourceTypeFromResource(resource)
		if resourceType.name:lower() == 'skill' and
		   resource.name:lower() == self.skill:lower()
		then
			return output.count
		end
	end

	return 0
end

function SkillGuideController:sort()
	local index = 1
	while index <= #self.state.actions do
		local action = self.state.actions[index]
		if not self:findActionXPRequirement(action.instance:getAction()) then
			table.remove(self.state.actions, index)
			self.actionsByID[action.instance:getAction().id] = nil
		else
			index = index + 1
		end
	end

	table.sort(self.state.actions, function(a, b)
		a = a.instance:getAction()
		b = b.instance:getAction()

		local aReqXP, bReqXP = self:findActionXPRequirement(a), self:findActionXPRequirement(b)
		local aOutXP, bOutXP = self:findActionOutputXP(a), self:findActionOutputXP(b)

		if aReqXP < bReqXP then
			return true
		elseif aReqXP > bReqXP then
			return false
		else
			if aOutXP < bOutXP then
				return true
			elseif aOutXP > bOutXP then
				return false
			else
				return a.id < b.id
			end
		end
	end)
end

function SkillGuideController:poke(actionID, actionIndex, e)
	if actionID == "select" then
		self:select(e)
	elseif actionID == "close" then
		self:getGame():getUI():closeInstance(self)
	else
		Controller.poke(self, actionID, actionIndex, e)
	end
end

function SkillGuideController:pull()
	return self.state
end

function SkillGuideController:select(e)
	assert(type(e.id) == "number", "action ID must be number")
	assert(self.actionsByID[e.id] ~= nil, "action with ID not found")

	local director = self:getDirector()
	local gameDB = director:getGameDB()
	local brochure = gameDB:getBrochure()

	local action = self.actionsByID[e.id]
	local result = {}
	do
		result.requirements = {}
		for requirement in brochure:getRequirements(action) do
			local resource = brochure:getConstraintResource(requirement)
			local resourceType = brochure:getResourceTypeFromResource(resource)

			table.insert(
				result.requirements,
				{
					type = resourceType.name,
					resource = resource.name,
					name = Utility.getName(resource, gameDB) or resource.name,
					count = requirement.count
				})
		end
	end
	do
		result.inputs = {}
		for input in brochure:getInputs(action) do
			local resource = brochure:getConstraintResource(input)
			local resourceType = brochure:getResourceTypeFromResource(resource)

			table.insert(
				result.inputs,
				{
					type = resourceType.name,
					resource = resource.name,
					name = Utility.getName(resource, gameDB) or resource.name,
					count = input.count
				})
		end
	end
	do
		result.outputs = {}
		for output in brochure:getOutputs(action) do
			local resource = brochure:getConstraintResource(output)
			local resourceType = brochure:getResourceTypeFromResource(resource)

			table.insert(
				result.outputs,
				{
					type = resourceType.name,
					resource = resource.name,
					name = Utility.getName(resource, gameDB) or resource.name,
					count = output.count
				})
		end
	end

	director:getGameInstance():getUI():sendPoke(
		self,
		"populateRequirements",
		nil,
		{ result })
end

return SkillGuideController