---@type Mq
local mq = require("mq")
local BL = require("biggerlib")
local State = require("state")
local settings = require("settings")

local Burn = {}

local ScriptCommands = BL.Enum([[
	Reload,
	PCs,
	Drive
]])

local UseMGB = BL.Enum([[
	NoMGB
	UseMGB
]])

local TargetType = BL.Enum([[
	NoTarget
	Target
]])

local MGBAAManager = {
	TranquilBlessing = {
		aaId = 992,
		IsActive = function()
			local theBuff = mq.TLO.Me.Buff("Tranquil Blessing").ID()
			--BL.log.info("ID of TB buff in IsActive is: " .. tostring(theBuff))
			return mq.TLO.Me.Buff("Tranquil Blessing").ID()
		end,
		Activate = function(self)
			mq.cmd("/alt activate 992")
			mq.delay(500)
		end,
	},
	MassGroupBuff = {
		aaId = 35,
		Activate = function(self)
			mq.cmd("/alt activate 35")
			mq.delay(500)
		end,
	},
}

Burn.args_cmd_handler = function(...)
	local args = { ... }
	if #args < 1 then
		print("Not enough arguments to command")
		return
	end

	local command = args[1]

	if command == ScriptCommands.Reload then
		-- for reload
		local myScriptName = "raidburn"
		mq.cmd("/timed 10 /lua run " .. myScriptName)
		terminate = true
	elseif command == ScriptCommands.PCs then
		State.refreshClassList()
	elseif command == ScriptCommands.Drive then
		local opt = args[2]
		if opt == nil then
			local currentDriver = State.driver
			print("Current driver is " .. currentDriver)
			State.driver = true
		elseif opt == "off" then
			State.driver = false
		elseif opt == "on" then
			State.driver = true
		end
	end
end

------------- Implementation ----------------------------------------------------

Burn.meCastSpell = function(spellname)
	mq.cmdf("/rs I am Casting %s", spellname)

	-- use ONLY MGB AA not Tranquil Blessing bc TB can't be used in combat
	MGBAAManager.MassGroupBuff:Activate()

	-- Pause so automation doesn't interrupt us
	--BL.log.info("Boxr Pausing so automation doesn't interrupt us")
	mq.cmd("/boxr pause")
	mq.delay(100)

	-- Cast spell (should have MGB/TB active already and be targeting the correct)
	--BL.log.dump(spellname)
	--BL.log.info("Casting spell: %s ", spellname)

	-- distinguish between AA and spell
	---- first find the proper AAID from SPELLS_BY_CLASS
	for className, spellList in pairs(SPELLS_BY_CLASS) do
		for spell, spellInfo in pairs(spellList) do
			if spell == spellname then
				--BL.log.info("Found spell %s in class %s", spell, className)
				local aaId = SPELLS_BY_CLASS[className][spell]
				--BL.log.info("AAID is %d", aaId)
				if aaId > 0 then
					BL.info("Activating AA %d", tostring(aaId))
					mq.cmdf("/alt activate %s", tostring(aaId))
					mq.delay(5000)
				elseif aaId == AbilityTypes.Spell then
					BL.info("Casting spell %s", spellname)
					mq.cmdf("/cast %s", spellname)
					mq.delay(5000)
				elseif aaId == AbilityTypes.Disc then
					BL.info("Activating disc %s", spellname)
					mq.cmdf("/disc %s", spellname)
					mq.delay(5000)
				end
				--mq.cmdf("/cast %d", aaId)
				--mq.delay(5000)
			end
		end
	end
	--mq.cmdf("/cast %s", spellname)
	--mq.delay(5000)

	BL.log.info("Completed casting spell: %s ", spellname)
	mq.cmd("/boxr unpause")
end

--- Called when you click the burninate button NOTE THE PERIOD ON THE END IS REQUIRED
--- Example: /rs Burninate - Unified Hand of Righteousness - Jynbur - NoTarget|Target's name - NoMGB|UseMGB.
---@param line string
---@param spellToCast string
---@param toonToCast string
Burn.burninateEventHandler = function(line, spellToCast, toonToCast)
	if toonToCast == mq.TLO.Me.CleanName() then
		Burn.meCastSpell(spellToCast)
	end
end

local function _findNextCharacterToCast(className, spellName)
	State.refreshClassList()
	local chosenCharacter = ""
	local lowestLastUsed = 2 ^ 63 - 1
	--BL.info("In find next char to cast with %s and %s", className, spellName)
	local classInZone = State.ClassInZone[className]

	if classInZone == nil then
		BL.log.warn("No class in zone found for %s", className)
		return
	end

	for charName, char in pairs(State.ClassInZone[className]) do
		if char.SpellState[spellName].LastUsed < lowestLastUsed then
			lowestLastUsed = char.SpellState[spellName].LastUsed
			chosenCharacter = charName
		end
	end
	if chosenCharacter == "" then
		BL.log.warn("No character found for class %s", className)
		return
	end

	return chosenCharacter
end

Burn.emitSpellEvent = function(className, spellName)
	-- Reject non-driver requests
	if not State.driver then
		BL.log.warn("Not driver, rejecting request!")
		return
	end

	local chosenCharacter = _findNextCharacterToCast(className, spellName)

	State:UpdateSpellStateOnUse(className, chosenCharacter, spellName)

	if chosenCharacter == nil then
		BL.log.warn("No character found for class %s!  We can't use %s", className, spellName)
		mq.cmdf("/rs WARNING WARNING No character found for class %s!  We can't use %s", className, spellName)
		return
	end

	-- Matcher Text follows pattern: "Burninate" (trigger phrase) - "Funeral Dirge" (spell name to cast) - "Robothaus" (toon to cast) "." (Period required at end)
	-- Meant for "/rs Burninate - Funeral Dirge - Robothaus." or "/rs Burninate - Perseverance - Caelinaex."
	mq.cmdf("/rs Burninate - %s - %s.", spellName, chosenCharacter)
end

function Burn.TurnOffPluginUses()
	BL.log.info("Turning off plugin uses")
	local myClass = mq.TLO.Me.Class.ShortName()

	if myClass == "SHD" then
		mq.cmd("/shd UseTVyls off")
	elseif myClass == "BRD" then
		mq.cmd("/bard UseFuneralDirge off")
	elseif myClass == "RNG" then
		mq.cmd("/rng UseAuspice off")
		mq.delay(50)
		mq.cmd("/rng MGBAuspice off")
	elseif myClass == "SHM" then
		mq.cmd("/shm UseAncestralAid off")
	elseif myClass == "BER" then
		mq.cmd("/ber UseWarCry off")
		mq.delay(50)
		mq.cmd("/ber MGBWarCry off")
	elseif myClass == "BST" then
		--BL.info("In BST")
		mq.cmd("/bst UseParagon off")
		mq.delay(50)
		mq.cmd("/bst MGBParagon off")
	end
	mq.delay(50)
end

Burn.triggerFullBurn = function()
	BL.log.info("Starting full burn!")
	mq.cmd("/rs Starting full burn!")
	-- go thru each spell and cast it
	for className, spellList in pairs(SPELLS_BY_CLASS) do
		-- Skip SK and Paragon in FULL BURN
		if className == "Shadow Knight" or className == "Beastlord" then
			mq.cmd("/rs Skipping " .. className .. " in full burn")
		else
			for spell, _ in pairs(spellList) do
				BL.log.info("Casting spell %s for class %s", spell, className)
				Burn.emitSpellEvent(className, spell)
			end
		end
	end
end

Burn.uiEventHandlers = {
	-- Callback triggered on refresh button click
	refresh = State.refreshClassList,
	burninate = Burn.burninateEventHandler,
	handleCircleOfPowerList = Burn.handleCircleOfPowerListRequest,
}

-- This is the event that will be triggered by /rs WHOCANPOWER
-- Each box with the item will respond to be added to the driver's user list
function Burn.handleCircleOfPowerListRequest(line)
	local ihavethepower = mq.TLO.FindItem("Rage of Rolfron").ID()
	local iAmAHealer = mq.TLO.Me.Class.ShortName() == "CLR"
		or mq.TLO.Me.Class.ShortName() == "SHM"
		or mq.TLO.Me.Class.ShortName() == "DRU"

	if ihavethepower ~= nil and ihavethepower ~= "NULL" and ihavethepower > 0 and not iAmAHealer then
		mq.cmdf("/rs %s has the power!", mq.TLO.Me.CleanName(), ihavethepower)
	end
end

function Burn.handleCircleOfPowerListResponse(line, personName, personNameTwo)
	--add personName to SET of CoP users
	State.AddCircleOfPowerUser(personName)
end

Burn.HandleCircleOfPower = function()
	-- see if i have the buff already or am not driver
	if not State.driver or not State.runCircleRotation then
		return
	end

	if mq.TLO.Me.Song("Circle of Power IV Effect").ID() then
		--BL.info("Already have Circle Of Power, not casting another")
		return
	end

	local personToUseCoP = State.FindNextCircleOfPowerUser()
	if personToUseCoP == nil then
		return
	end
	mq.cmdf("/rs DOCIRCLEOFPOWER %s.", personToUseCoP)
	State.CircleOfPowerUsedBy(personToUseCoP)
	mq.delay(2000)
end

function Burn.DoCircleOfPowerEventHandler(line, personName)
	if personName == mq.TLO.Me.CleanName() then
		--mq.cmd("/boxr pause")
		--mq.delay(50)
		mq.cmd("/rs I AM USING CIRCLE OF POWER")
		mq.delay(50)
		mq.cmd("/useitem Rage of Rolfron")
		mq.delay(750)
		--mq.cmd("/boxr unpause")
		--mq.delay(50)
	end
end

function Burn.Init()
	-- Matcher Text follows pattern: "Burninate" (trigger phrase) - "Funeral Dirge" (spell name to cast) - "Robothaus" (toon to cast) "." (Period required at end)
	-- Meant for "/rs Burninate - Funeral Dirge - Robothaus." or "/rs Burninate - Perseverance - Caelinaex."
	mq.event("burninate", "#*#Burninate - #1# - #2#.#*#", Burn.burninateEventHandler)
	mq.event("handleCircleOfPowerListRequest", "#*#WHOCANPOWER#*#", Burn.handleCircleOfPowerListRequest)
	mq.event(
		"handleCircleOfPowerListResponse",
		"#*#raid, '#1# has the power!'#*#",
		Burn.handleCircleOfPowerListResponse
	)
	mq.event("doCircleOfPower", "#*#DOCIRCLEOFPOWER #1#.#*#", Burn.DoCircleOfPowerEventHandler)
end

return Burn
