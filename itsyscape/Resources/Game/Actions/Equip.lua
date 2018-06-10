--------------------------------------------------------------------------------
-- Resources/Game/Actions/Equip.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"
local Mapp = require "ItsyScape.GameDB.Mapp"
local Action = require "ItsyScape.Peep.Action"
local InventoryBehavior = require "ItsyScape.Peep.Behaviors.InventoryBehavior"
local EquipmentBehavior = require "ItsyScape.Peep.Behaviors.EquipmentBehavior"

local Equip = Class(Action)
Equip.SCOPES = { ['inventory'] = true }

function Equip:perform(state, item, peep)
	--if not self:canPerform(state) then
	--	return false
	--end

	local director = peep:getDirector()
	local inventory = peep:getBehavior(InventoryBehavior)
	local equipment = peep:getBehavior(EquipmentBehavior)
	if inventory and inventory.inventory and
	   equipment and equipment.equipment
	then
		inventory = inventory.inventory
		equipment = equipment.equipment
	else
		return false, "no inventory"
	end

	local broker = director:getItemBroker()
	local transaction = broker:createTransaction()
	transaction:addParty(inventory)
	transaction:addParty(equipment)
	transaction:transfer(equipment, item)
	local s, r = transaction:commit()
	if not s then
		io.stderr:write("error: ", r, "\n")
		return false, "transaction failed"
	end
end

return Equip
