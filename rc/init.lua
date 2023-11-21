---@type Mq
local mq = require("mq")
---@type ImGui
local imgui = require("ImGui")
local lume = require("lume")
-- Reminder you can access requires starting from the base /lua folder
local BL = require("zen.biggerlib")

-- Possibly unused and useless
local animItems = mq.FindTextureAnimation("A_DragItem")

GLOBAL_AMMO_SLOT = mq.TLO.Me.Inventory(22).ID()

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

local ArmorSlots = {
	wristLeft = "Wrist",
	wristRight = "Wrist",
	feet = "Feet",
	arms = "Arms",
	hands = "Hands",
	head = "Head",
	legs = "Legs",
	chest = "Chest",
}

local function constructArmorSetDataForExpansion(containerPrefix, containerPostfix, level, expansion, classEmblemName)
	local armorSet = {
		Level = level,
		Expansion = expansion,
		Slots = {},
	}

	for slot, part in pairs(ArmorSlots) do
		local containerName = containerPrefix .. " " .. part .. " " .. containerPostfix
		local ingredients = {
			"Luclinite Enduement Medium",
			"Emblem of the " .. classEmblemName,
			"Spiritual Luclinite Powder",
			"Spiritual Luclinite Powder",
			"Spiritual Luclinite Powder",
			"Apparitional " .. part .. " Armor Lining",
		}
		armorSet.Slots[slot] = {
			container = containerName,
			ingredients = ingredients,
		}
	end

	return armorSet
end

-- Example usage for NOS expansion:

local function pickUpItemOntoCursor(itemName)
	mq.cmd('/itemnotify "' .. itemName .. '" leftmouseup')
	mq.delay(250)
end

local function putItemInTopInventorySlot(slotNumber)
	mq.cmd("/itemnotify pack" .. slotNumber .. " leftmouseup")
	mq.delay(250)
end

local function openContainerItemInTopInventorySlot(slotNumber)
	mq.cmd("/itemnotify pack" .. slotNumber .. " rightmouseup")
	mq.delay(250)
end

local function putIngredientsInContainer(ingredients)
	for index, ingredient in ipairs(ingredients) do
		mq.cmd('/ctrlkey /itemnotify "' .. ingredient .. '" leftmouseup')
		mq.delay(250)
		mq.cmd("/itemnotify in pack1 " .. index .. " leftmouseup")
		mq.delay(250)
	end
end

local function clickCombineButton()
	mq.cmd("/notify ContainerWindow Container_Combine leftmouseup")
	mq.delay(250)
end

local function makeArmorPiece(container, ingredients)
	pickUpItemOntoCursor(container)
	putItemInTopInventorySlot(1)
	-- Try to auto-inventory, because the later auto-inv will put an item in the open slot that we'll have just picked up
	mq.cmd("/autoinv")
	mq.delay(500)
	openContainerItemInTopInventorySlot(1)
	---- Iterate over ingredients
	putIngredientsInContainer(ingredients)
	info("NOT REALLY CLICKING COMBINE BUTTON")
	--clickCombineButton()
	mq.cmd("/autoinv")
	mq.delay(500)
	mq.cmd("/autoinv")
	mq.delay(500)
end

local function makeArmorSet(armorSet)
	for slot, details in pairs(armorSet.Slots) do
		makeArmorPiece(details.container, details.ingredients)
	end
end

local function learnSpellRunes(runeTier, nameString)
	-- Produces "Median Spellbound Lamp" etc
	local runeName = runeTier .. " " .. nameString

	local function useNextRuneItem()
		mq.cmd('/itemnotify "' .. runeName .. '" rightmouseup')
		mq.delay(5000)
	end

	local function getOpenRewardSelectionOptionList()
		return mq.TLO.Window("RewardSelectionWnd/RewardPageTabWindow").Tab(1).Child("RewardSelectionOptionList")
	end

	function filterRewardsRetainingIndices(rewards, substring)
		local filteredRewards = newTable()
		for index, item in ipairs(rewards) do
			if not string.find(item, substring) then
				--table.insert(filteredRewards, {index = index, value = item})
				filteredRewards:insert({ listIndex = index, value = item })
			end
		end
		return filteredRewards
	end

	useNextRuneItem()

	local rsol = getOpenRewardSelectionOptionList()
	dump(rsol, "Reward selection option list")
	local rewards = newTable()
	local itemCount = rsol.Items()
	dump(itemCount, "Item count")
	for i = 1, itemCount do
		local item = rsol.List(i)
		rewards[i] = tostring(item) -- Convert each item to a string and store it
		--dump(rewards[i], "List string mapped")
	end
	dump(rewards, "Rewards")

	local filteredRewardsWithIndices = filterRewardsRetainingIndices(rewards, nameString)
	dump(filteredRewardsWithIndices, "Filtered rewards")
	local indicesAlreadyUsed = newTable()
	local totalIndices = #filteredRewardsWithIndices

	--iterate the filtered rewards and select each one
	for _, reward in ipairs(filteredRewardsWithIndices) do
		info("In for loop")
		if not indicesAlreadyUsed:contains(reward.listIndex) then
			info("In new index loop")
			indicesAlreadyUsed:insert(reward.listIndex)
			-- We have to re-get this PER ITERATION because each one is a "new" window
			local rsol = getOpenRewardSelectionOptionList()

			info("Selecting reward index: " .. reward.listIndex)
			rsol.Select(reward.listIndex)
			mq.delay(1000)

			info("Clicking select option button")
			mq.cmd("/notify RewardSelectionWnd RewardSelectionChooseButton leftmouseup ")
			mq.delay(1000)

			-- If we're out of spells to click, don't click the next bloodstone
			totalIndices = totalIndices - 1
			if totalIndices > 0 then
				---- click the next bloodstone
				info("Clicking next bloodstone")
				useNextRuneItem()
			else
				info("No more bloodstones to click! We're NOT clicking the next one!")
			end
		end
	end
	--safety delay
	mq.delay(1000)
end

local RuneTiers = newTable({
	minor = "Minor",
	lesser = "Lesser",
	median = "Median",
	greater = "Greater",
	glowing = "Glowing",
})

--- Finds open top level inventory slot
---@param inTopLevelInventory TopLevelInventoryItem[] | ZenTable
local function findEmptyTopLevelInventorySlot(inTopLevelInventory)
	return Option(inTopLevelInventory:match(function(inventoryItem)
		if inventoryItem.Item:IsNone() then
			return inventoryItem.ItemSlotID
		end
	end))
end

local function cacheBag(inBagToCache)
	local bagInventory = {}

	local notifyPackName = mq.TLO.InvSlot(inBagToCache).Name()

	for itemIndex in range(48) do
		local notifyInvSlot2 = mq.TLO.InvSlot(inBagToCache).Item.Item(itemIndex).ItemSlot2()
		local actualItemName = mq.TLO.InvSlot(inBagToCache).Item.Item(itemIndex).Name()

		---@type ItemData
		local itemData = {
			actualItemName = tostring(actualItemName),
			notifyPackName = tostring(notifyPackName),
			notifyInvSlot2 = tostring(notifyInvSlot2),
		}
		-- index as array
		table.insert(bagInventory, itemData)
	end
	dump("Returning bagInventory with actualItemName: " .. tostring(bagInventory["Essence Emerald"]))
	return bagInventory
end

-- Caches inventory of all bags in top level character inventory slots
local function cacheAllBagsInventories()
	local allBags = newTable()
	-- 23, 32 are top level inventory slots according to EQ, prior to that are equipped items
	for i in range(23, 32) do
		allBags:insert(cacheBag(i))
	end

	--mq.cmd(notifyCommand)
	--mq.delay(1)
	return allBags
end

--- cache top level inventory items
---@return TopLevelInventoryItem[] | ZenTable
local function cacheTopLevelInventory()
	---@type TopLevelInventoryItem[] | ZenTable
	local topLevelInventory = newTable()

	for i = 23, 32 do
		local inventorySlot = mq.TLO.InvSlot(i)
		local itemSlotID = inventorySlot.ID()
		local invItem = inventorySlot.Item()
		local inventorySlotName = inventorySlot.Name()
		--local itemSlotPack = inventorySlot.Pack()
		--local itemSlotNumberInPack = inventorySlot.Slot()

		topLevelInventory:insert({
			ItemSlotID = itemSlotID,
			Item = Option(invItem),
			Name = inventorySlotName,
			--Pack = Option(itemSlotPack),
			--SlotNumberInPack = Option(itemSlotNumberInPack),
		})
	end

	return topLevelInventory
end

local function cacheInventory()
	---@type TopLevelInventoryItem[] | ZenTable
	local topLevelInventory = cacheTopLevelInventory()
	local openSlot = findEmptyTopLevelInventorySlot(topLevelInventory)

	local bagInventory = cacheAllBagsInventories()
	local inventoryCache = {
		topLevelInventory = topLevelInventory,
		bagInventory = bagInventory,
		openTopLevelInventorySlot = openSlot,
	}
	--dump(inventoryCache, "Inventory Cache: ")
	return inventoryCache
end

local function findItemInBagByName(inventoryCache, itemName)
	-- Check if inventoryCache and itemName are valid
	if not inventoryCache or not itemName then
		return nil, "Invalid inventoryCache or itemName"
	end

	-- Iterate over each bag in the bagInventory
	for _, bag in ipairs(inventoryCache.bagInventory) do
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

-- TODO LATER: problem - the autoinv command puts the item we need into the open top level inv slot we need to keep open
local function main()
	-- pause cwtn plugins/bard
	mq.cmd("/" .. mq.TLO.Me.Class.ShortName() .. " pause on")
	mq.delay(1000)

	--local nosArmorSet = constructArmorSetDataForExpansion("Spiritually Faded Luclinite", "Armor", 120, "NOS", "Arch Lich")
	--makeArmorSet(nosArmorSet)

	--RuneTiers:forEach(function(tier)
	--	learnSpellRunes(tier, 'Spellbound Lamp')
	--	learnSpellRunes(tier, 'Etched Bloodstone')
	--	learnSpellRunes(tier, 'Essence of Life')
	--end)

	print(Option(nil)) --> None
	print(Option(nil):IsNone()) --> true
	print(Option(nil):IsSome()) --> false
	print(Option(1)) --> Some(1)
	print(Option(1):IsNone()) --> false
	print(Option(1):IsSome()) --> true

	local inventory = cacheInventory()

	---@type ItemData
	local foundItem = findItemInBagByName(inventory, "Essence Emerald"):Expect("Item not found in inventory")
	local pickupItemCmd = "/ctrlkey /itemnotify "
		.. foundItem.notifyPackName
		.. " "
		.. foundItem.notifyInvSlot2
		.. " leftmouseup"
	dump(pickupItemCmd)
	mq.cmd("/ctrlkey /itemnotify " .. foundItem.notifyPackName .. " " .. foundItem.notifyInvSlot2 .. " leftmouseup")
	dump(foundItem)
	-- then i /ctrlkey /itemnotify in packName itemInBagSlot2 leftmouseup
end

main()
