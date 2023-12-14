---@type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")

local BL = require("biggerlib")
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
		mq.cmd("/g I AM a pet class")
	else
		mq.cmd("/g I am NOT a pet class")
	end

	mq.cmd("/g Growing the group")
	mq.cmd("/useitem luclinite horde cube")
	mq.delay(3500)

	mq.cmd("/g Levitating the group")
	mq.cmd("/aa act perfected levitation")
	mq.delay(3500)
end

local function mainLoop()
	if Paused then
		mq.delay(1000)
		return
	end
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
