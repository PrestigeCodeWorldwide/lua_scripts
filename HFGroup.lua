---@type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")
---@type BL
local BL = require("biggerlib")

BL.info("Heros Forged Group Script v1.41 Started")
mq.cmd("/plugin boxr load")

local Paused = false

mq.bind("/zm pause on", function()
	Paused = true
	mq.cmd("/squelch /nav stop")
	print("Mission paused")
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
	local myClass = mq.TLO.Me.Class.ShortName()
	if myClass == "NEC" or myClass == "MAG" or myClass == "BST" or myClass == "SHD" or myClass == "ENC" or myClass == "SHM" then
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

local function handleEggs()
	if IAmPetClass then
		local egg = mq.TLO.Spawn("npc egg").ID()
		if egg and egg > 0 then
			mq.cmd("/farts")
			mq.delay(1000)
			mq.cmd("/target npc egg")
			mq.delay(1000)
			mq.cmd("/pet attack")

			while mq.TLO.Spawn("npc egg").ID() and mq.TLO.Spawn("npc egg").ID() > 0 do
				mq.cmd("/target npc egg")
				mq.delay(1000)
				mq.cmd("/pet attack")
			end
			mq.cmd("/farts")
			mq.cmd("/boxr unpause")
		end
	end
end

local safeSpotYXZ = "568 -1317 327"

local function handleAoEEvent()
	local debuffName = "Song of Echoes"
	if BL.IHaveBuff(debuffName) then
		mq.cmd("/g I'm running for the debuff")
		--BL.cmd.pauseAutomation()
		BL.cmd.ChangeAutomationModeToManual()
		mq.delay(500)
		BL.cmd.StandIfFeigned()
		BL.cmd.removeZerkerRootDisc()
		mq.cmdf("/nav locyxz %s", safeSpotYXZ)

		while BL.IHaveBuff(debuffName) do
			mq.delay(1000)
		end

		mq.cmd("/g Debuff faded, running back to group")
		--BL.cmd.resumeAutomation()
		BL.cmd.ChangeAutomationModeToChase()
		BL.cmd.StandIfFeigned()
	end
end

local function mainLoop()
	if Paused then
		mq.delay(1000)
		return
	end

	handleEggs()
	handleAoEEvent()

	BL.checkChestSpawn("a_fading_chest")
	mq.delay(50)
end

------------------------------- Execution -------------------------------
init()
while true do
	mainLoop()
end
