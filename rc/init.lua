---@type Mq
local mq = require("mq")
---@type ImGui
local imgui = require("ImGui")
local lume = require("zen.biggerlib.vendor.lume")
-- Reminder you can access requires starting from the base /lua folder
print("Before BL")
local BL = require("biggerlib")
print("Before RC.UI")
local UI = require("uiManager")
print("After RC.UI")
local Spells = require("spells")
local Armor = require("armor")
local Inventory = require("inventory")

-- TODO LATER: problem - the autoinv command puts the item we need into the open top level inv slot we need to keep open
local function main()
	-- pause cwtn plugins/bard
	mq.cmd("/" .. mq.TLO.Me.Class.ShortName() .. " pause on")

	info("Closing open bags")
	UI.closeAllBags()
	info("Caching inventory")
	Inventory.recacheInventory()
	mq.delay(1)

	--local itemByID = findItemInBagByID(159852):Expect("Item nothing found")
	--dump(itemByID, "Item by ID")
	info("Constructing armor set data for NOS")
	---@type ArmorSet
	local nosArmorSet =
		Armor.constructArmorSetDataForExpansion("Spiritually Faded Luclinite", "Armor", 120, "NOS", "Arch Lich")

	nosArmorSet.Level = 50

	dump(nosArmorSet, "NOS Armor Set")

	info("Making armor set for NOS")
	Armor.makeArmorSet(nosArmorSet)
	info("Finished making armor set")

	Spells.RuneTiers:forEach(function(tier)
		Spells.learnSpellRunes(tier, "Spellbound Lamp")
		Spells.learnSpellRunes(tier, "Etched Bloodstone")
		Spells.learnSpellRunes(tier, "Essence of Life")
	end)

	-----@type ItemData
	--local foundItem = findItemInBagByName(Inventory, "Essence Emerald"):Expect("Item not found in inventory")
	--local pickupItemCmd = "/ctrlkey /itemnotify "
	--	.. foundItem.notifyPackName
	--	.. " "
	--	.. foundItem.notifyInvSlot2
	--	.. " leftmouseup"
	--dump(pickupItemCmd)
	--mq.cmd("/ctrlkey /itemnotify " .. foundItem.notifyPackName .. " " .. foundItem.notifyInvSlot2 .. " leftmouseup")

	-- then i /ctrlkey /itemnotify in packName itemInBagSlot2 leftmouseup
end

main()

--------------------------------- NOTES

-- Heavenly Glorious Void Binding Wrist Muhbis (Container)
----------------right click that and put
-- 1 Emblem of the Deceiver,
-- 1 Heavenly Glorious Void Transmogrificant,
-- 1 Exultant Inhabited Muhbis

--local ArmorSlots = {
--	wristLeft = "Wrist",
--	wristRight = "Wrist",
--	feet = "Feet",
--	arms = "Arms",
--	hands = "Hands",
--	head = "Head",
--	legs = "Legs",
--	chest = "Chest",
--}
--
---- Combine these two with ArmorSlots to end up with something like `Spiritually Faded Luclinite Wrist Armor`
--local containerPrefix = "Spiritually Faded Luclinite"
--local containerPostfix = "Armor"
--}
--local ingredients = {
--	'Emblem of the Coercer',
--	'Heavenly Glorious Void Transmogrificant',
--	'Exultant Inhabited Muhbis',
--}
--
--local armorSet = {
--	containers = containers,
--	ingredients = ingredients,
--	Level = 110,
--	Expansion = 'TBL',
--}
