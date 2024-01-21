---@type Mq
local mq = require("mq")
require("logger")
require("option")
require("zenarray")
require("utils")

--- This InventoryManager is a singleton providing access to all functionality related to interacting with a character's Inventory cache (Not including bank yet)
---@class InventoryManager
---@field InventoryCache InventoryType The cache of the character's inventory
---@field cacheBag fun(inBagToCache: number): BagInventory Caches the inventory of a single bag or container
---@field cacheAllBagsInventories fun(): BagInventory[] | ZenArray Caches inventory of all bags in top level character inventory slots
---@field cacheTopLevelInventory fun(): TopLevelInventoryItem[] | ZenArray cache top level inventory items
---@field recacheInventory fun(self) Recaches the character's inventory
local InventoryManager = {}
InventoryManager.__index = InventoryManager

--- Creates a new instance of InventoryManager
---@return InventoryManager
function InventoryManager.new()
	local self = newArray(InventoryManager)
	return self
end

---@type InventoryType
InventoryManager.InventoryCache = {
	topLevelInventory = {},
	bagsInventory = {},
	openTopLevelInventorySlot = Option.None,
}

--- Caches the inventory of a single bag or container
---@param inBagToCache number
---@return BagInventory
function InventoryManager.cacheBag(inBagToCache)
	---@type BagInventory
	local bagInventory = newArray()

	local notifyPackName = mq.TLO.InvSlot(inBagToCache).Name()

	for itemIndex in range(48) do
		local notifyInvSlot2 = mq.TLO.InvSlot(inBagToCache).Item.Item(itemIndex).ItemSlot2()
		local actualItemName = mq.TLO.InvSlot(inBagToCache).Item.Item(itemIndex).Name()
		local itemID = mq.TLO.InvSlot(inBagToCache).Item.Item(itemIndex).ID()

		---@type ItemData
		local itemData = {
			actualItemName = tostring(actualItemName),
			notifyPackName = tostring(notifyPackName),
			notifyInvSlot2 = tostring(notifyInvSlot2),
			itemID = itemID,
		}

		-- index as array
		table.insert(bagInventory, itemData)
	end
	return bagInventory
end

-- Caches inventory of all bags in top level character inventory slots
---@return ZenArray<BagInventory>
function InventoryManager.cacheAllBagsInventories()
	---@type ZenArray<BagInventory>
	local allBags = newArray(BagInventory)
	-- 23, 32 are top level inventory slots according to EQ, prior to that are equipped items
	for i in range(23, 32) do
		allBags.insert(InventoryManager.cacheBag(i))
	end

	--mq.cmd(notifyCommand)
	--mq.delay(1)
	return allBags
end

--- cache top level inventory items
---@return TopLevelInventoryItem[] | ZenArray
function InventoryManager.cacheTopLevelInventory()
	---@type TopLevelInventoryItem[] | ZenArray
	local topLevelInventory = newArray()

	for i = 23, 32 do
		local inventorySlot = mq.TLO.InvSlot(i)
		local itemSlotID = inventorySlot.ID()
		local invItem = inventorySlot.Item()
		local inventorySlotName = inventorySlot.Name()

		topLevelInventory:insert({
			ItemSlotID = itemSlotID,
			Item = Option.Wrap(invItem),
			Name = inventorySlotName,
		})
	end

	return topLevelInventory
end

--- cache entire inventory (Top level items and all items in top level containers, not bank)
function InventoryManager:recacheInventory()
	---@type UIManager
	local UI = require("uiManager")
	---@type ZenArray<TopLevelInventoryItem>
	local topLevelInventory = InventoryManager.cacheTopLevelInventory()
	local openSlot = UI:findEmptyTopLevelInventorySlot()

	---@type ZenArray<BagInventory>
	local bagsInventory = InventoryManager.cacheAllBagsInventories()
	---@type InventoryType
	self.InventoryCache = {
		topLevelInventory = topLevelInventory,
		bagsInventory = bagsInventory,
		openTopLevelInventorySlot = openSlot,
	}
end

---@type InventoryManager
local instance = InventoryManager.new()
return instance
