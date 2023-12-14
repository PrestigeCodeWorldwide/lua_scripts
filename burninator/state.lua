---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

-------------------------------- Typedefs --------------------------------
--- @type table<string, string[]>
SPELLS_BY_CLASS = {
	["Cleric"] = {
		"Unified Hand of Righteousness",
	},
	["Shaman"] = {},
	["Druid"] = {},
	["Wizard"] = {},
	["Magician"] = {},
	["Enchanter"] = {},
	["Necromancer"] = {},
	["Warrior"] = {},
	["Paladin"] = {},
	["Ranger"] = {
		"Auspice of the Hunter",
	},
	["Shadow Knight"] = {},
	["Monk"] = {},
	["Rogue"] = {},
	["Bard"] = {
		"Funeral Dirge",
	},
	["Beastlord"] = {
		"Paragon of Spirit",
	},
	["Berserker"] = {
		"Ancient: Cry of Chaos",
	},
}

--- @class SpellState
--- @field LastUsed number

--- @class CharacterInfo
--- @field Character string
--- @field CharacterName string
--- @field SpellState table<string, SpellState>

--- @class ClassInfo
--- @field [number] CharacterInfo

---------------------------------- State ----------------------------------

--- @class State
--- @field terminate boolean
--- @field pause boolean
--- @field driver boolean
--- @field ClassInZone table<string, ClassInfo>
--- @field Classes table<string, string>

local State = { terminate = false, pause = false, driver = false }

---@type table<string, CharacterInfo>
State.ClassInZone = {}

--- @type table<string, string>
State.Classes = {
	cleric = "Cleric",
	warrior = "Warrior",
	paladin = "Paladin",
	ranger = "Ranger",
	shadowknight = "Shadow Knight",
	druid = "Druid",
	monk = "Monk",
	rogue = "Rogue",
	shaman = "Shaman",
	necromancer = "Necromancer",
	wizard = "Wizard",
	magician = "Magician",
	enchanter = "Enchanter",
	beastlord = "Beastlord",
	bard = "Bard",
}

---Flip pause state
---@param val boolean|string|nil
function State.togglePause(val)
	if val == "on" then
		State.paused = true
	elseif val == "off" then
		State.paused = false
		print("\at[Burninate] \agUNPAUSED")
	else
		if State.paused == true then
			State.paused = false
			print("\at[Burninate] \agUNPAUSED")
		else
			print("\at[Burninate] \agPAUSED")
			State.paused = true
		end
	end
end

function State.refreshClassList()
	State.ClassInZone = State.ClassInZone or {}

	for key, class in pairs(State.Classes) do
		local charactersOfClass = State.getClassInZone(class)
		for _, character in ipairs(charactersOfClass) do
			-- Check if the character object is valid and has a name
			if character and character.Name then
				local SpellState = {}
				for _, spell in ipairs(SPELLS_BY_CLASS[class]) do
					SpellState[spell] = { LastUsed = 0 }
				end

				if State.ClassInZone[class] == nil then
					State.ClassInZone[class] = {}
				end

				State.ClassInZone[class][character.Name()] = {
					Character = character,
					SpellState = SpellState,
				}
			end
		end
	end
	print("Dumping Final array")
	BL.log.dump(State.ClassInZone)
end

function State:UpdateSpellStateOnUse(class, characterName, spellName)
	BL.log.warn("Updating spell state on use for class %s, character %s, spell %s", class, characterName, spellName)
	local character = self.ClassInZone[class][characterName]

	BL.log.warn("Character found in state array:")
	BL.log.dump(character)

	if character then
		local spellState = character.SpellState[spellName]
		if spellState then
			spellState.LastUsed = mq.gettime()
		end
	end
end

function State.getClassInZone(class)
	return mq.getFilteredSpawns(function(spawn)
		local isPC = spawn.Type() == "PC"
		local spawnClass = spawn.Class()
		local inputClass = class
		local matchesClass = spawnClass == inputClass
		local matches = isPC and matchesClass

		return matches
	end)
end

--function State.refreshClassList()
--	for key, value in pairs(State.Classes) do
--		print("Getting class in zone for " .. value)
--		State.ClassInZone[value] = State.getClassInZone(value)
--	end
--	print("Dumping Final array")
--	BL.log.dump(State.ClassInZone)

--	--print("Printing all shaman")
--	--utils.dump(State.ClassInZone.shaman)
--end

--function State.getClassInZone(class)
--	return mq.getFilteredSpawns(function(spawn)
--		local isPC = spawn.Type() == "PC"
--		local spawnClass = spawn.Class()
--		local inputClass = class
--		local matchesClass = spawnClass == inputClass
--		local matches = isPC and matchesClass

--		return matches
--	end)
--end

return State
