---@type Mq
local mq = require("mq")
---@type ImGui
local imgui = require("ImGui")
local lume = require("lume")
-- Reminder you can access requires starting from the base /lua folder
local BL = require("biggerlib")
local UI = require("uiManager")

---@class ArmorManager
---@field ArmorSlots table<string, string> A table mapping armor slot names to their descriptions
---@field constructArmorSetDataForExpansion fun(containerPrefix: string, containerPostfix: string, level: number, expansion: string, classEmblemName: string): ArmorSet Constructs an ArmorSet from parts
---@field makeArmorPiece fun(container: string, ingredients: string[]) Makes an individual armor piece
---@field makeArmorSet fun(armorSet: ArmorSet) Iterates the slots in an ArmorSet and crafts each piece
local ArmorManager = {}
ArmorManager.__index = ArmorManager

--- Creates a new instance of ArmorManager
---@return ArmorManager
function ArmorManager.new()
	local self = newTable(ArmorManager)
	return self
end

ArmorManager.ArmorSlots = {
	wristLeft = "Wrist",
	wristRight = "Wrist",
	feet = "Feet",
	arms = "Arms",
	hands = "Hands",
	head = "Head",
	legs = "Legs",
	chest = "Chest",
}

--- Utility function for creating an ArmorSet from parts
---@param containerPrefix string Prefix part of the armor container name, like "Spiritually Faded Luclinite"
---@param containerPostfix string Postfix part of the armor container name, like "Spiritually Faded Luclinite"
---@param level number What level required to make the armor, like '120'
---@param expansion string "Expansion code of the armor, like "NOS"
---@param classEmblemName string Name of the class emblem, like "Arch Lich", so without the "Emblem of the "
---@return ArmorSet
function ArmorManager.constructArmorSetDataForExpansion(
	containerPrefix,
	containerPostfix,
	level,
	expansion,
	classEmblemName
)
	---@type ArmorSet
	local armorSet = {
		Level = level,
		Expansion = expansion,
		Slots = {},
	}

	local function removeTrailingS(str)
		if str:sub(-1) == "s" then
			return str:sub(1, -2)
		else
			return str
		end
	end

	for slot, part in pairs(ArmorManager.ArmorSlots) do
		local containerName = containerPrefix .. " " .. part .. " " .. containerPostfix
		local ingredients = {
			"Luclinite Enduement Medium",
			"Emblem of the " .. classEmblemName,
			"Spiritual Luclinite Powder",
			"Spiritual Luclinite Powder",
			"Spiritual Luclinite Powder",
			"Apparitional " .. removeTrailingS(part) .. " Armor Lining",
		}
		armorSet.Slots[slot] = {
			container = containerName,
			ingredients = ingredients,
		}
	end

	--dump(armorSet, "Armor set")

	return armorSet
end

function ArmorManager.makeArmorPiece(container, ingredients)
	info("Picking up armor container piece: " .. container)
	UI.pickUpItemOntoCursor(container)
	mq.delay(500)
	info("Putting armor container piece in top inventory slot")
	UI.putItemInTopInventorySlot(1)
	mq.delay(500)
	-- Try to auto-inventory, because the later auto-inv will put an item in the open slot that we'll have just picked up
	info("AutoInventory in case there was an item in the top level slot we just picked up")
	mq.cmd("/autoinv")
	mq.delay(500)
	info("Opening armor container piece")
	UI.openContainerItemInTopInventorySlot(1)
	mq.delay(1500)
	------ Iterate over ingredients
	info("Putting ingredients in container")
	UI.putIngredientsInContainer(ingredients)
	mq.delay(1)
	--mq.delay(5500)
	--info("Done filling container: NOT REALLY CLICKING COMBINE BUTTON")
	UI.clickCombineButton()
	mq.delay(2000)
	UI.putCursorItemInEmptyInventorySlot()
	--mq.cmd("/autoinv")
	--mq.delay(500)
	--mq.cmd("/autoinv")
	--mq.delay(500)
end

---Iterate the slots in an ArmorSet and craft each piece
---@param armorSet ArmorSet
function ArmorManager.makeArmorSet(armorSet)
	--local pseudocontinue = true
	for slot, details in pairs(armorSet.Slots) do
		if slot ~= "head" then
			info("Making armor piece for slot: " .. slot)
			info("Details.Container: " .. tostring(details.container))
			info("Details.Ingredients: " .. tostring(details.ingredients))

			ArmorManager.makeArmorPiece(details.container, details.ingredients)

			mq.delay(1000)
		end
	end
end

---@type ArmorManager
local instance = ArmorManager.new()
return instance
