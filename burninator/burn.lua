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
			if self:IsActive() then
				BL.log.info("Tranquil Blessing is already active, not reactivating")
			else
				BL.log.info("Tranquil Blessing is not active, activating")
				mq.cmd("/dgra /alt activate 992")
				mq.delay(500)
			end
		end,
	},
	MassGroupBuff = {
		aaId = 35,
		Activate = function(self)
			if mq.TLO.Me.Buff("Mass Group Buff") then
				BL.log.info("Mass Group Buff is active, not reactivating")
			else
				mq.cmd("/dgra /alt activate 35")
			end
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
		local myScriptName = "zen/burninator"
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
	-- check to see if has Tranquil Blessing buff before using MGB
	BL.log.warn("USING TRANQUIL BLESSING - Change me after Dev to MGB")
	MGBAAManager.TranquilBlessing:Activate()

	-- Pause so automation doesn't interrupt us
	BL.log.info("Boxr Pausing so automation doesn't interrupt us")
	mq.cmd("/boxr pause")
	mq.delay(100)
	-- check targeting
	target = TargetType:FromStr(target) -- Get TargetType from the string MQ caught
	if target ~= nil and target ~= TargetType.NoTarget then
		BL.log.info("Targeting: %s ", tostring(target))
		mq.cmdf("/target %s", target)
		mq.delay(100)
	end
	-- Cast spell (should have MGB/TB active already and be targeting the correct)
	BL.log.dump(spellname)
	BL.log.info("Casting spell: %s ", spellname)

	mq.cmdf("/cast %s", spellname)
	mq.delay(5000)

	BL.log.info("Completed casting spell: %s ", spellname)
	mq.cmd("/boxr unpause")
end

--- Called when you click the burninate button NOTE THE PERIOD ON THE END IS REQUIRED
--- Example: /rs Burninate - Unified Hand of Righteousness - Jynbur - NoTarget|Target's name - NoMGB|UseMGB.
---@param line string
---@param spellToCast string
---@param toonToCast string
Burn.burninateEventHandler = function(line, spellToCast, toonToCast)
	print("Burninate Event Handler")

	print("Spell to cast: " .. spellToCast)
	print("Toon to cast: " .. toonToCast)

	if toonToCast == mq.TLO.Me.CleanName() then
		mq.cmd("/rs Event handler named ME as spell caster, casting!")
		Burn.meCastSpell(spellToCast)
	end
end

Burn.emitSpellEvent = function(className, spellName)
	-- Reject non-driver requests
	if not State.driver then
		BL.log.warn("Not driver, rejecting request!")
		return
	end

	--characterName comes from checking our State and finding the character of the equivalent ClassInZone with the lowest LastUsed value
	local chosenCharacter = ""
	local lowestLastUsed = 2 ^ 63 - 1
	for charName, char in pairs(State.ClassInZone[className]) do
		if char.SpellState[spellName].LastUsed < lowestLastUsed then
			BL.log.warn(
				"Found newest last use character %s at time %d  vs prior %d",
				charName,
				char.SpellState[spellName].LastUsed,
				lowestLastUsed
			)
			lowestLastUsed = char.SpellState[spellName].LastUsed
			chosenCharacter = charName
		end
	end
	if chosenCharacter == "" then
		BL.log.warn("No character found for class %s", className)
		return
	end
	State:UpdateSpellStateOnUse(className, chosenCharacter, spellName)

	-- Matcher Text follows pattern: "Burninate" (trigger phrase) - "Funeral Dirge" (spell name to cast) - "Robothaus" (toon to cast) "." (Period required at end)
	-- Meant for "/rs Burninate - Funeral Dirge - Robothaus." or "/rs Burninate - Perseverance - Caelinaex."
	mq.cmdf("/rs Burninate - %s - %s.", spellName, chosenCharacter)
end

Burn.uiEventHandlers = {
	-- Callback triggered on refresh button click
	refresh = State.refreshClassList,
	burninate = Burn.burninateEventHandler,
}

Burn.triggerFullBurn = function()
	-- go thru each spell in
	BL.log.info("Starting full burn")
end

return Burn
