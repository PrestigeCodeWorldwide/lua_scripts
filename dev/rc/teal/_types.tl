require 'zen.biggerlib.option'

-- ItemData class definition
local record ItemData
  actualItemName: string
  notifyPackName: string
  notifyInvSlot2: string
  itemID: number
end

-- TopLevelInventoryItem class definition
local record TopLevelInventoryItem
  ItemSlotID: number
  Item: Option<ItemData>
  Name: string
end

-- BagInventory type definition
global type BagInventory = {ItemData}

-- InventoryType class definition
local record InventoryType
  topLevelInventory: {TopLevelInventoryItem}
  bagsInventory: {BagInventory}
  openTopLevelInventorySlot: Option<number>
end

-- ArmorSetSlot class definition
local record ArmorSetSlot
  ingredients: {string}
  container: string
end

-- ArmorSet class definition
local record ArmorSet
  Level: number
  Expansion: string
  Slots: {string: ArmorSetSlot}
end
