---@type mq
local mq = require('mq')
local BL = require('biggerlib')
lume = require "lume"
-- Possibly unused and useless
local animItems = mq.FindTextureAnimation('A_DragItem')

GLOBAL_AMMO_SLOT = mq.TLO.Me.Inventory(22).ID()

-- Heavenly Glorious Void Binding Wrist Muhbis (Container)
----------------right click that and put
-- 1 Emblem of the Deceiver,
-- 1 Heavenly Glorious Void Transmogrificant,
-- 1 Exultant Inhabited Muhbis
-- example item to find
--local wrist_muhbis = mq.TLO.FindItem("Heavenly Glorious Void Binding Wrist Muhbis")
---- itemslot is which top level inv slot its in
---- these range from to 23 to 32, as priors are for equipment inv slots
--local itemslot = wrist_muhbis.ItemSlot()
---- This is sub slot, which is the slot inside of the top level container.
--local itemslot2 = wrist_muhbis.ItemSlot2()
--BL.log.dump(itemslot .. " : " .. itemslot2)
--
---- Use the FIRST slot, make it empty in top level inv, this is 23
--local TopInventorySlot = mq.TLO.Me.Inventory(23)
--local TopInventorySlotID = TopInventorySlot.ID()
--BL.log.info("Dumping top inv")
--BL.log.dump(TopInventorySlot)
--BL.log.dump(TopInventorySlotID)
-- move item to first slot

local containers = {
	--"Heavenly Glorious Void Binding Wrist Muhbis",
	--"Heavenly Glorious Void Binding Wrist Muhbis",
	--"Heavenly Glorious Void Binding Feet Muhbis",
	--"Heavenly Glorious Void Binding Arms Muhbis",
	--"Heavenly Glorious Void Binding Hands Muhbis",
	--"Heavenly Glorious Void Binding Head Muhbis",
	"Heavenly Glorious Void Binding Legs Muhbis",
	"Heavenly Glorious Void Binding Chest Muhbis",
}
local ingredients = {
	"Emblem of the Coercer",
	"Heavenly Glorious Void Transmogrificant",
	"Exultant Inhabited Muhbis"
}

local armorSet = {
	containers = containers,
	ingredients = ingredients,
	Level = 110,
	Expansion = "TBL"
}

local function pickUpContainer(containerName)
	mq.cmd('/itemnotify \"' .. containerName .. '\" leftmouseup')
	mq.delay(250)
end

local function putItemInTopInventorySlot(slotNumber)
	mq.cmd('/itemnotify pack' .. slotNumber .. ' leftmouseup')
	mq.delay(250)
end

local function openContainerItemInTopInventorySlot(slotNumber)
	mq.cmd('/itemnotify pack' .. slotNumber .. ' rightmouseup')
	mq.delay(250)
end

local function putIngredientsInContainer(ingredients)
	for index, ingredient in ipairs(ingredients) do
		mq.cmd('/ctrlkey /itemnotify \"' .. ingredient .. '\" leftmouseup')
		mq.delay(250)
		mq.cmd('/itemnotify in pack1 ' .. index .. ' leftmouseup')
		mq.delay(250)
	end
end

local function clickCombineButton()
	mq.cmd('/notify ContainerWindow Container_Combine leftmouseup')
	mq.delay(250)
end



local function makeArmorPiece(container, ingredients)

	pickUpContainer(container)
	putItemInTopInventorySlot(1)
	openContainerItemInTopInventorySlot(1)
	---- Iterate over ingredients
	putIngredientsInContainer(ingredients)
	--BL.log.info("NOT REALLY CLICKING COMBINE BUTTON")
	clickCombineButton()
	mq.cmd('/autoinv')
	mq.delay(500)
	mq.cmd('/autoinv')
	mq.delay(500)
end

local function makeArmorSet(armorSet)
	for index, container in ipairs(armorSet.containers) do
		makeArmorPiece(container, armorSet.ingredients)
	end
end

local InventorySlotStates = {
	EMPTY = 0,
	OCCUPIED = 1,
}

-- table|
local InventorySlot = {
	inventorySlotState = InventorySlotStates.EMPTY,
	item = ""
}

local CharacterInventoryState = {
	slot1 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children = nil,
	},
	slot2 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children = nil,
	},
	slot3 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children = nil,
	},
	slot4 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children = nil,
	},
	slot5 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children = nil,
	},
	slot6 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children = nil,
	},
	slot7 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children = nil,
	},
	slot8 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children = nil,
	},
	slot9 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children = nil,
	},
	slot10 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children = nil,
	},
}

local function cacheInventory()

end


-- Current problem - the autoinv command puts the item we need into the open top level inv slot we need to keep open
-- need to actually cache our current inventory state
local function main()
	--makeArmorSet(armorSet)
	cacheInventory()
end

main()
