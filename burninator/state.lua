---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

-------------------------------- Typedefs --------------------------------
--- Note here that the number is the AA ID,
--- to signify that this is instead a spell, pass 0
--- to signify that this is instead a clicky, pass -1

MGBAbilityTypes = BL.Enum([[		
	Disc = -20
	Spell = -1
	Item = -100
]])

--- @type table<string, table<string, number> >
SPELLS_BY_CLASS = {
    ["Cleric"] = {
		["Celestial Regeneration"] = 38,
	},
	["Shaman"] = {
        ["Ancestral Aid"] = 447,
	},
	--["Druid"] = {},
	--["Wizard"] = {},
	--["Magician"] = {},
    ["Enchanter"] = {
		["Illusions of Grandeur"] = 2202,
	},
	--["Necromancer"] = {},
	--["Warrior"] = {},
	--["Paladin"] = {},
	["Ranger"] = {
		["Auspice of the Hunter"] = 462,
	},
	["Shadow Knight"] = {
		["T'vyl's Resolve"] = 742,
	},
	--["Monk"] = {},
	--["Rogue"] = {},
	["Bard"] = {
		["Funeral Dirge"] = 777,
	},
	["Beastlord"] = {
		["Paragon of Spirit"] = 128,
	},
	["Berserker"] = {
		["War Cry of Dravel"] = MGBAbilityTypes.Disc,
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
--- @field optIntoGroupBurnTriggers boolean
--- @field runCircleRotation boolean
--- @field ClassInZone table<string, ClassInfo>
--- @field Classes table<string, string>
--- @field CircleOfPowerUsers table<string, number>
--- @field AddCircleOfPowerUser function(name)
--- @field CircleOfPowerUsedBy function(name)
local State = {}
State.CircleOfPowerUsers = {}

function State.AddCircleOfPowerUser(name)
	if name == "" then
		return
	end

	--BL.info("Adding %s to Circle Of Power users", name)
	State.CircleOfPowerUsers[name] = 0
end

function State.CircleOfPowerUsedBy(name)
	State.CircleOfPowerUsers[name] = mq.gettime()
end

function State.FindNextCircleOfPowerUser()
	local lowestLastUsed = 2 ^ 31
	local chosenCharacter = ""
	--BL.dump(State.CircleOfPowerUsers, "CircleOfPowerUsers")
	for charName, lastUsed in pairs(State.CircleOfPowerUsers) do
		if lastUsed < lowestLastUsed then
			lowestLastUsed = lastUsed
			chosenCharacter = charName
		end
	end
	if chosenCharacter == "" then
		return nil
	end

	return chosenCharacter
end

function State.Init()
	State.useZActors = true
	State.terminate = false
	State.pause = false
	State.driver = false
	State.runCircleRotation = false
	--State.optIntoGroupBurnTriggers = false
end

---@type table<string, CharacterInfo>
State.ClassInZone = {}

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
	State.ClassInZone = {}

	for class, _ in pairs(SPELLS_BY_CLASS) do
		local charactersOfClass = State.getClassInZone(class)
		for _, character in pairs(charactersOfClass) do
			-- Check if the character object is valid and has a name
			--BL.dump(char)
			if character then
				local SpellState = {}
				for spell, spellInfo in pairs(SPELLS_BY_CLASS[class]) do
					--BL.log.dump(spell, "Spell")
					--BL.log.dump(spellInfo, "SpellInfo")
					SpellState[spell] = { LastUsed = 0 }
				end

				if State.ClassInZone[class] == nil then
					State.ClassInZone[class] = {}
				end

				State.ClassInZone[class][character] = {
					Character = character,
					SpellState = SpellState,
				}
			end
		end
	end
	--BL.info("Completed Refreshing Class List")
	--BL.log.dump(State.ClassInZone)
end

function State.UpdateSpellStateOnUse(class, characterName, spellName)
	BL.info("In State:UpdateSpellStateOnUse")

	if State.ClassInZone[class] == nil then
		BL.warn("No characters found for class: %s", class)
		return
	end


	local spellState = State.ClassInZone[class][characterName].SpellState[spellName]
	if spellState then
		State.ClassInZone[class][characterName].SpellState[spellName].LastUsed = mq.gettime()
		BL.info("Setting last used for %s to %d", spellName,
			State.ClassInZone[class][characterName].SpellState[spellName].LastUsed)
	else
		BL.warn("Couldn't find spell state")
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

local myState = State
myState.Init()

return myState
