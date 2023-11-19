---@type Mq
local mq          = require('mq')
---@type ImGui
local imgui       = require('ImGui')
local lume        = require "lume"
local BL          = require('biggerlib')

-- Possibly unused and useless
local animItems   = mq.FindTextureAnimation('A_DragItem')

GLOBAL_AMMO_SLOT  = mq.TLO.Me.Inventory(22).ID()



-- Heavenly Glorious Void Binding Wrist Muhbis (Container)
----------------right click that and put
-- 1 Emblem of the Deceiver,
-- 1 Heavenly Glorious Void Transmogrificant,
-- 1 Exultant Inhabited Muhbis


local containers  = {
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

local armorSet    = {
	containers  = containers,
	ingredients = ingredients,
	Level       = 110,
	Expansion   = "TBL"
}

local function pickUpItemOntoCursor(itemName)
	mq.cmd('/itemnotify \"' .. itemName .. '\" leftmouseup')
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
	
	pickUpItemOntoCursor(container)
	putItemInTopInventorySlot(1)
	-- Try to auto-inventory, because the later auto-inv will put an item in the open slot that we'll have just picked up
	mq.cmd('/autoinv')
	mq.delay(500)
	openContainerItemInTopInventorySlot(1)
	---- Iterate over ingredients
	putIngredientsInContainer(ingredients)
	--info("NOT REALLY CLICKING COMBINE BUTTON")
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

local InventorySlotStates     = {
	EMPTY    = 0,
	OCCUPIED = 1,
}

-- table|
local InventorySlot           = {
	inventorySlotState = InventorySlotStates.EMPTY,
	item               = ""
}

local CharacterInventoryState = {
	slot1  = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children           = nil,
	},
	slot2  = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children           = nil,
	},
	slot3  = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children           = nil,
	},
	slot4  = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children           = nil,
	},
	slot5  = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children           = nil,
	},
	slot6  = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children           = nil,
	},
	slot7  = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children           = nil,
	},
	slot8  = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children           = nil,
	},
	slot9  = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children           = nil,
	},
	slot10 = {
		inventorySlotState = InventorySlotStates.EMPTY,
		children           = nil,
	},
}

local function cacheInventory()
	local inventory = mq.TLO.Inventory(23)
	dump(inventory)
	-- returns first slot in the bank
	local bank = mq.TLO.Me.Bank(1)
	
	dump(bank)
	local bankid = bank.ID()
	dump(bankid)
	
	mq.cmd()
	
	
	
	-- HERE TRYING TO FIGURE OUT HOW TO CAPTURE THE OUTPUT OF THIS
	--local banklist = mq.cmd('/banklist')
	--dump(banklist)
end

--- @param runeName string
local function learnSpellRunes(runeName)
	-- temp commented to test, this part works tho
	mq.cmd('/itemnotify \"' .. runeName .. '\" rightmouseup')
	mq.delay(5000)
	
	local rsol            = mq.TLO.Window("RewardSelectionWnd/RewardPageTabWindow").Tab(1).Child("RewardSelectionOptionList")
	local rewards         = {}
	local rewardItemCount = rsol.Items()
	for i = 1, rewardItemCount do
		local bigbrain = rsol.List(i)
		--dump(bigbrain, "List index " .. i)
		table.insert(rewards, tostring(bigbrain))
		--dump(rewards, "Table after insert")
	end
	
	--dump(rewards)
	
	function filterRewardsWithIndices(rewardsArray, substring)
		local filteredRewards = {}
		for index, item in ipairs(rewardsArray) do
			if not string.find(item, substring) then
				table.insert(filteredRewards, { listIndex = index, optionText = item })
			end
		end
		return filteredRewards
	end
	
	
	--]]
	local filteredRewardsWithIndices = filterRewardsWithIndices(rewards, "Spellbound Lamp")
	dump(filteredRewardsWithIndices)
	
	--[[
DUMP : {
[1] = {
[listIndex] = 6
[optionText] = Perforate Rk. II

--]]
	local indicesAlreadyUsed = {}
	--table.insert(indicesAlreadyUsed, 9)
	--table.insert(indicesAlreadyUsed, 6)
	
	function contains(table, value)
		for _, v in ipairs(table) do
			if v == value then
				return true
			end
		end
		return false
	end
	
	local totalIndices = #filteredRewardsWithIndices
	
	--iterate the filtered rewards and select each one
	for _, reward in ipairs(filteredRewardsWithIndices) do
		
		if not contains(indicesAlreadyUsed, reward.listIndex) then
			table.insert(indicesAlreadyUsed, reward.listIndex)
			local rsol = mq.TLO.Window("RewardSelectionWnd/RewardPageTabWindow").Tab(1).Child("RewardSelectionOptionList")
			
			info("Selecting reward index: " .. reward.listIndex)
			rsol.Select(reward.listIndex)
			mq.delay(1000)
			
			info("Clicking select option button")
			-- click select option button
			mq.cmd('/notify RewardSelectionWnd RewardSelectionChooseButton leftmouseup ')
			mq.delay(1000)
			
			-- If we're out of spells to click, don't click the next bloodstone
			totalIndices = totalIndices - 1
			if totalIndices > 0 then
				---- click the next bloodstone
				info("Clicking next bloodstone")
				mq.cmd('/itemnotify \"' .. runeName .. '\" rightmouseup')
				mq.delay(4000)
			
			else
				info("No more bloodstones to click! We're NOT clicking the next one!")
			end
			
		end
		
	end
	--safety delay
	mq.delay(1000)
	
	
end


-- Current problem - the autoinv command puts the item we need into the open top level inv slot we need to keep open
-- need to actually cache our current inventory state
local function main()
	--makeArmorSet(armorSet)
	--cacheInventory()
	mq.cmd("/cwtna pause on")
	mq.delay(1000)
	--learnSpellRunes("Minor Etched Bloodstone")
	--mq.delay(1000)
	--learnSpellRunes("Lesser Etched Bloodstone")
	--mq.delay(1000)
	--learnSpellRunes("Median Etched Bloodstone")
	--mq.delay(1000)
	--learnSpellRunes("Greater Etched Bloodstone")
	--mq.delay(1000)
	--learnSpellRunes("Glowing Etched Bloodstone")
	
	--learnSpellRunes("Minor Essence of Life")
	--mq.delay(1000)
	--learnSpellRunes("Lesser Essence of Life")
	--mq.delay(1000)
	--learnSpellRunes("Median Essence of Life")
	--mq.delay(1000)
	--learnSpellRunes("Greater Essence of Life")
	--mq.delay(1000)
	--learnSpellRunes("Glowing Essence of Life")
	
	learnSpellRunes("Minor Spellbound Lamp")
	learnSpellRunes("Lesser Spellbound Lamp")
	learnSpellRunes("Median Spellbound Lamp")
	learnSpellRunes("Greater Spellbound Lamp")
	learnSpellRunes("Glowing Spellbound Lamp")
end

main()
