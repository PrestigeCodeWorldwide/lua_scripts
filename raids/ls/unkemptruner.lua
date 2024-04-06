--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

-- ONLY enchanters run this!  It uses group level 69 rune

local ScriptState = {
	Paused = false,
	RuneSpell = "Rune of Rikkukin",
	RuneWaitingRoom = {}
}

local function castSpellOnTarget(spellName, target)
	BL.cmd.pauseAutomation()
	--finish casting a spell if we already were
	if mq.TLO.Me.Casting() then
		mq.cmd('/stopcast')
	end
	mq.delay(100)
	local targetSpawn = mq.TLO.Spawn("pc " .. target)
	targetSpawn.DoTarget()
	mq.delay(1)
	
	mq.cmdf('/cast %s ', spellName)
	mq.delay(5000, function() return not mq.TLO.Me.Casting() end)
	-- GCD cooldown so it doesn't try to cast a second too early
	mq.delay(2000)
	BL.cmd.resumeAutomation()
end

local function HandleStickyTickTocker(line, runeTarget)
	ScriptState.RuneWaitingRoom[runeTarget]= true
end

local function DoNextRune()
	local peopleList = {}
	-- key is toon name, value is boolean true/false for whether they need runed
	for key, value in pairs(ScriptState.RuneWaitingRoom) do
		if value then
			table.insert(peopleList, key)
		end
	end
	local nextRuneTarget= peopleList[math.random(#peopleList)]
	if BL.NotNil(nextRuneTarget) then
		BL.info("Casting RUNE on " .. nextRuneTarget)
		-- Wait for possible GCD cooldown
		mq.delay(3000, function() return not mq.TLO.Me.SpellInCooldown() end)
		-- Cast the spell itself
		castSpellOnTarget(ScriptState.RuneSpell, nextRuneTarget)
		-- Mark person as runed
		ScriptState.RuneWaitingRoom[nextRuneTarget] = false
	end
end

local function init()
	-- set rune spell based on which class
	if mq.TLO.Me.Class.ShortName() ~= "ENC" then
		BL.info("I'm NOT an enchanter")
		mq.cmd("/rs I AM NOT AN ENCHANTER but i'm running the unkempt Rune script, SOMETHING IS WRONG")
		
	end
	-- mem rune
	local currentSpell = mq.TLO.Me.Gem(13)
	local spellName = currentSpell.Name()
	if spellName ~= ScriptState.RuneSpell then
		mq.cmd("/enc byos on")
		mq.delay(2000)
		mq.cmdf('/memspell 13 "%s"', ScriptState.RuneSpell)
		mq.delay(2000)
	end
end

mq.event('StickyTickTocker', '#*#IAMSTICKY #1# IAMSTICKY#*#', HandleStickyTickTocker)

init()

while true do
	mq.doevents()
	DoNextRune()
	mq.delay(511)
end
