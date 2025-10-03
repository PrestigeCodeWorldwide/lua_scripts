---@type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")
---@type BL
local BL = require('biggerlib')

BL.info("Heros Forged Raid Script v1.4 Started")

local Paused = false

mq.bind("/zm pause on", function()
	Paused = true
	mq.cmd("/squelch /nav stop")
	print("Mission  paused")
end)

mq.bind("/zm pause off", function()
	Paused = false
	print("Mission resumed")
end)

mq.bind("/zm pause", function()
	Paused = true
	mq.cmd("/squelch /nav stop")
	print("Mission paused")
end)

local IAmPetClass = false
local function init()
	--get my classs and cache it to see if i'm pet class
	local myClass = mq.TLO.Me.Class.ShortName()
	if
		myClass == "NEC"
		or myClass == "MAG"
		or myClass == "BST"
		or myClass == "SHD"
		or myClass == "ENC"
		or myClass == "SHM"
	then
		IAmPetClass = true
		mq.cmd("/clap")
	else
		mq.cmd("/wave")
	end

	mq.cmd("/em farts")
	mq.cmd("/useitem luclinite horde cube")
	mq.delay(3500)

	mq.cmd("/em farts")
	mq.cmd("/aa act perfected levitation")
	mq.delay(3500)
end

-- grow clicky
--

local function handleEggs()
	if IAmPetClass then
		-- see if egg is up
		local egg = mq.TLO.Spawn("npc egg").ID()
		if egg ~= nil and egg > 0 then
			-- send pets on eggs
			mq.cmd("/farts")
			mq.delay(1000)
			mq.cmd("/target npc egg")
			mq.delay(1000)
			mq.cmd("/pet attack")

			-- wait for egg to die
			while mq.TLO.Spawn("npc egg").ID() ~= nil and mq.TLO.Spawn("npc egg").ID() > 0 do
				mq.cmd("/target npc egg")
				mq.delay(1000)
				mq.cmd("/pet attack")
			end
			mq.cmd("/farts")
			mq.cmd("/boxr unpause")
		end
	end
end

-- This goes up by the NPC
local safeSpotYXZ = "568 -1317 327"

local function handleAoEEvent()
	local debuffName = "Song of Calling"
	--local debuffName = "Grim Aura" -- for testing with SK

	if BL.IHaveBuff(debuffName) then
		-- we have the debuff, run to safe spot
		mq.cmd("/emote runs")
		BL.cmd.pauseAutomation()
		mq.delay(500)
		BL.cmd.StandIfFeigned()
		mq.cmdf("/nav locyxz %s", safeSpotYXZ)

		while BL.IHaveBuff(debuffName) do
			mq.delay(1000)
		end
		mq.cmd("/emote returns")
		BL.cmd.resumeAutomation()
		BL.cmd.StandIfFeigned()
	end
end

local function mainLoop()
	if Paused then
		mq.delay(1000)
		return
	end
	-- Check if a fading chest has spawned and end script
    BL.checkChestSpawn("a_fading_chest")
	-- We need to do 2 things - make pet classes send their pets on eggs during spider and run from aoe when called
	handleEggs()
	handleAoEEvent()
	mq.delay(50)
	--doAoeEvent() -- this is the event bind
end

------------------------------- Execution -------------------------------

init()
while true do
	mainLoop()
end
