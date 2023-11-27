---@type Mq
local mq = require("mq")
---@type ImGui
local imgui = require("ImGui")

local lume = require("zen.biggerlib.lume")
require("zen.biggerlib.logger")

---@type InventoryManager
local Inventory = require("inventory")

--- This UIManager is a singleton providing access to all functionality related to interacting with Everquest's actual UI (not imgui)
---@class UIManager
---@field findItemInBagByName fun(itemName: string): Option<ItemData>
---@field findItemInBagByID fun(itemID: number): Option<ItemData>
---@field getCtrlPickupItemCommand fun(itemData: ItemData): string
---@field pickUpItemOntoCursor fun(itemName: string)
---@field putItemInTopInventorySlot fun(slotNumber: number)
---@field openContainerItemInTopInventorySlot fun(slotNumber: number)
---@field putIngredientsInContainer fun(ingredients: string[])
---@field clickCombineButton fun()
---@field checkWindowExists fun(window: any): boolean
---@field putCursorItemInEmptyInventorySlot fun()
---@field closeAllBags fun(self)
---@field findEmptyTopLevelInventorySlot fun(self): Option<number>
local UIManager = {}

--- Finds an item in the inventory cache by name
---@param itemID number
---@return Option<ItemData>
function UIManager.findItemInBagByID(itemID)
	-- Check if inventoryCache and itemName are valid
	if not Inventory.InventoryCache or not itemID then
		return Option.None
	end

	-- Iterate over each bag in the bagInventory
	for _, bag in ipairs(Inventory.InventoryCache.bagsInventory) do
		-- Iterate over each item in the current bag
		for _, itemData in ipairs(bag) do
			-- Check if the actualItemName matches the itemName we're looking for
			if itemData.itemID == itemID then
				-- Return the matching itemData
				return Option(itemData)
			end
		end
	end

	-- If we reach this point, the item was not found
	return Option.None
end

---Formatting utility function UI.for creating a command to pick up an item based on ItemData
---@param itemData ItemData
---@return string
function UIManager.getCtrlPickupItemCommand(itemData)
	local pickupItemCmd = "/ctrlkey /itemnotify in "
		.. itemData.notifyPackName
		.. " "
		.. itemData.notifyInvSlot2
		.. " leftmouseup"

	return pickupItemCmd
end

--- Finds an item in the inventory cache by name
---@param itemName string
---@return Option<ItemData>
function UIManager.findItemInBagByName(itemName)
	-- Check if inventoryCache and itemName are valid
	if not Inventory.InventoryCache or not itemName then
		return Option.None
	end

	-- Iterate over each bag in the bagInventory
	for _, bag in ipairs(Inventory.InventoryCache.bagsInventory) do
		-- Iterate over each item in the current bag
		for _, itemData in ipairs(bag) do
			-- Check if the actualItemName matches the itemName we're looking for
			if itemData.actualItemName == itemName then
				-- Return the matching itemData
				return Option(itemData)
			end
		end
	end

	-- If we reach this point, the item was not found
	return Option.None
end

function UIManager.pickUpItemOntoCursor(itemName)
	info("Picking up item onto cursor by name: " .. itemName)

	-- THIS METHOD WORKS
	---@type Option
	local foundItem = UIManager.findItemInBagByName(itemName)

	---@type ItemData
	local item = foundItem:Expect("Item not found in inventory")
	dump(item, "Item data")
	local pickupItemCmd = "/ctrlkey /itemnotify in "
		.. item.notifyPackName
		.. " "
		.. tostring(item.notifyInvSlot2 + 1) -- off by ones are great
		.. " leftmouseup"

	dump(pickupItemCmd, "Pickup item command")

	mq.cmd(pickupItemCmd)
	mq.delay(500)
end

function UIManager.putItemInTopInventorySlot(slotNumber)
	mq.cmd("/itemnotify pack" .. slotNumber .. " leftmouseup")
	mq.delay(250)
end

function UIManager.openContainerItemInTopInventorySlot(slotNumber)
	mq.cmd("/itemnotify pack" .. slotNumber .. " rightmouseup")
	mq.delay(250)
end

function UIManager.putIngredientsInContainer(ingredients)
	for index, ingredient in ipairs(ingredients) do
		info("Picking up: " .. ingredient)
		UIManager.pickUpItemOntoCursor(ingredient)

		info("Putting ingredient in container")
		mq.cmd("/itemnotify in pack1 " .. index .. " leftmouseup")
		mq.delay(250)
	end
end

function UIManager.clickCombineButton()
	mq.cmd("/combine pack1")
	mq.delay(1000)
end

function UIManager.checkWindowExists(window)
	if window == nil then
		return false
	end
	if window == false then
		return false
	end

	local windowString = tostring(window)
	if windowString == "FALSE" or windowString == "NULL" then
		return false
	else
		return true
	end
end

--- Puts the item on the cursor into the first empty inventory slot
function UIManager.putCursorItemInEmptyInventorySlot()
	info("Recaching inventory")
	Inventory:recacheInventory()
	UIManager:findEmptyTopLevelInventorySlot()
end

--- MQ has no ability to sort, find, iterate, or otherwise interact with any root window beyond the first of each type
--- This bypasses our inability to find the window we need by closing all of them and then opening the one we want
function UIManager:closeAllBags()
	local window = mq.TLO.Window("ContainerWindow")
	dump(window, "Container Window::")
	while UIManager.checkWindowExists(window) do
		dump(window, "Window")
		--mq.cmd("/notify " .. i .. " 0 leftmouseup")
		mq.TLO.Window("ContainerWindow").DoClose()
		mq.delay(1) -- unnecessary force to wait one frame
		window = mq.TLO.Window("ContainerWindow")
	end
end

--- Finds open top level inventory slot
---@return Option<number>
function UIManager:findEmptyTopLevelInventorySlot()
	return Option(Inventory.InventoryCache.topLevelInventory:match(function(inventoryItem)
		if inventoryItem.Item:IsNone() then
			return inventoryItem.ItemSlotID
		end
	end))
end
UIManager.__index = UIManager

--- Creates a new instance of UIManager
---@return UIManager
function UIManager.new()
	local self = newArray(UIManager)
	return self
end

---@type UIManager
local instance = UIManager.new()
return instance
