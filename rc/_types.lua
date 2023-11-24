---@meta RaidCopyTypes
local Option, None = require "biggerlib.option"

---@class ItemData Inventory item data to be cached - gives ability to notify item via packname and slot2
---@field actualItemName string Name of the item in-game
---@field notifyPackName string Which backpack/container in TL Inventory the object is in
---@field notifyInvSlot2 string Which slot of the container the item is in
---@field itemID number The item ID

---@class TopLevelInventoryItem
---@field ItemSlotID number
---@field Item Option<Item>
---@field Name string

---@class BagInventory : ItemData[]

---@class InventoryType : ZenTable
---@field topLevelInventory TopLevelInventoryItem[] | ZenTable
---@field bagsInventory BagInventory[] | ZenTable
---@field openTopLevelInventorySlot Option(number)

--- Data bag for an armor set, such as "Spiritually faded luclinite" NoS armor
---@class ArmorSet : ZenTable
---@field Level number Level required for making the armor set 
---@field Expansion string
---@field Slots table<string, ArmorSetSlot> | ZenTable

---@class ArmorSetSlot : ZenTable
---@field ingredients string[] List of ingredient names
---@field container string Name of the container







