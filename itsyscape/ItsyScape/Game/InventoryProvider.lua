--------------------------------------------------------------------------------
-- ItsyScape/Game/InventoryProvider.lua
--
-- This file is a part of ItsyScape.
--
-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.
--------------------------------------------------------------------------------
local Class = require "ItsyScape.Common.Class"

-- Abstract interface to an InventoryProvider.
--
-- An InventoryProvider is something that can hold items. Derived classes will
-- implement high-level things like querying.
--
-- For example, a player inventory would have 28 (or whatever) slots, where
-- items stack when possible; can be assigned to any slot from 1-28 (e.g., slots
-- 2, 4, and 5 could be filled but the rest empty); and so on.
--
-- On the other hand, a ground inventory would have an unlimited number of
-- slots; items would be stored on tiles; and items would not merge. (So a single
-- tile could have 5 stacks of coins, or whatever).
local InventoryProvider = Class()

function InventoryProvider:new()
	self.broker = false
end

-- Gets the broekr this provider belongs to.
function InventoryProvider:getBroker()
	return self.broker
end

-- Returns the Peep that this InventoryProvider bleongs to.
--
-- All InventoryProviders must have a valid Peep. This means items that
-- spawn in the game world normally must have a transient spawner Peep.
--
-- It is an error for the Peep to not have a PositionBehavior.
function InventoryProvider:getPeep()
	return Class.ABSTRACT()
end

-- Returns the maximum number of inventory slots this InventoryPRovider can
-- have. A value of inf (i.e., math.huge) means there is no limited.
function InventoryProvider:getMaxInventorySpace()
	return Class.ABSTRACT()
end


-- Called when an item is destroyed during a transaction.
--
-- 'item' is the ItemInstance of the transferred item.
--
-- 'item' will not be valid; it is no longer a part of the ItemBroker when this
-- method is called.
--
-- If this method fails, the transaction still proceeds.
function InventoryProvider:onSpawn(item)
	-- Nothing.
end


-- Called when an item is spawned during a transaction.
--
-- 'item' is the ItemInstance of the transferred item. 'count' is the number of
-- items that were transferred. (This will be different from item.getCount() if
-- the former).
--
-- If this method fails, the transaction still proceeds.
function InventoryProvider:onSpawn(item, count)
	-- Nothing.
end

-- Called when an item is transferred during a transaction.
--
-- 'item' is the ItemInstance of the transferred item. 'count' is the number of
-- items that were transferred. (This will be different from item.getCount() if
-- the former)
--
-- 'source' is the Inventory the item is being transferred from.
--
-- 'purpose' is a special string that can be, for example, 'trade' or 'drop'.
--
-- If this method fails, the transaction still proceeds.
function InventoryProvider:onTransfer(item, source, count, purpose)
	-- Nothing.
end

-- Called when the Inventory is loaded.
--
-- Normally the invetory should be deserialized.
function InventoryProvider:load(broker)
	assert(not self.broker, "already assigned to broker")
	self.broker = broker
end

-- Called when the InventoryProvider is unloaded.
--
-- Normally ths Inventory should be serialized.
function InventoryProvider:unload(broker)
	assert(self.broker, "not assigned to broker")
	self.broker = false
end

return InventoryProvider