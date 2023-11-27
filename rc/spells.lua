---@type Mq
local mq = require("mq")
---@type ImGui
local imgui = require("ImGui")
local lume = require("zen.biggerlib.lume")
local ZenArray = require("zen.biggerlib.zenarray")
-- Reminder you can access requires starting from the base /lua folder
require("zen.biggerlib.logger")

---@class SpellsManager
---@field RuneTiers ZenArray<string> A list of rune tiers
---@field learnSpellRunes fun(runeTier: string, nameString: string)
local SpellsManager = {}
SpellsManager.__index = SpellsManager

--- Creates a new instance of SpellsManager
---@return SpellsManager
function SpellsManager.new()
	local self = newArray(SpellsManager)
	return self
end

SpellsManager.RuneTiers = newArray({
	minor = "Minor",
	lesser = "Lesser",
	median = "Median",
	greater = "Greater",
	glowing = "Glowing",
})

--- Teaches spell runes based on the tier and name provided
---@param runeTier string
---@param nameString string
function SpellsManager.learnSpellRunes(runeTier, nameString)
	-- Produces "Median Spellbound Lamp" etc
	local runeName = runeTier .. " " .. nameString

	local function useNextRuneItem()
		mq.cmd('/itemnotify "' .. runeName .. '" rightmouseup')
		mq.delay(5000)
	end

	local function getOpenRewardSelectionOptionList()
		---@diagnostic disable-next-line: undefined-field
		return mq.TLO.Window("RewardSelectionWnd/RewardPageTabWindow").Tab(1).Child("RewardSelectionOptionList")
	end

	function filterRewardsRetainingIndices(rewards, substring)
		local filteredRewards = newArray()
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
	local rewards = newArray()
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
	local indicesAlreadyUsed = newArray()
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

---@type SpellsManager
local instance = SpellsManager.new()
return instance
