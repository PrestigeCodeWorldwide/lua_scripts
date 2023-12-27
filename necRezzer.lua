-- version 0.01 - Watches a radius for PC corpses and rezzes them
---@type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")
--- @type BL
local BL = require("biggerlib")

-- CHANGE ME
local CORPSE_WATCH_RADIUS = "100"
local pauseAutomation = true

-- DON'T TOUCH ANYTHING BELOW THIS LINE
local open_gui = true
local should_draw_gui = true
local pause = false

local CWTNIsRunning = function()
	local isPaused = mq.TLO.CWTN.Paused()
	BL.info("CWTN is paused? %s", isPaused)
	return not isPaused
end

local function doConvergence()
	mq.cmd("/alt activate 676")
	-- wait for cast time 2s
	mq.delay(2500)
end

local function BASIC_UI()
	if not open_gui or mq.TLO.MacroQuest.GameState() ~= "INGAME" then
		return
	end
	open_gui, should_draw_gui = ImGui.Begin("Necrezzer", open_gui)

	if should_draw_gui then
		if pause then
			if ImGui.Button("Resume") then
				pause = false
			end
		else
			if ImGui.Button("Pause") then
				pause = true
			end
		end
	end
	ImGui.End()
end

mq.imgui.init("Necrezzer", BASIC_UI)

if not mq.TLO.Me.Class() == "Necromancer" then
	BL.warn("I am not a necromancer, no use for this script!")
	mq.cmd("/g I am not a necromancer, no use for this script!")
	return
end

while true do
	if pause or mq.TLO.MacroQuest.GameState() ~= "INGAME" then
		mq.delay(1000)
		return
	end
	-- Check for dead pc corpses
	local theCorpse = mq.TLO.Spawn("pccorpse radius " .. CORPSE_WATCH_RADIUS)

	if theCorpse() then
		local cwtnIsRunning = CWTNIsRunning()
		if pauseAutomation and cwtnIsRunning then
			mq.cmd("/boxr pause")
			mq.delay(1000)
		end

		theCorpse.DoTarget()
		mq.cmd("/corpse")
		mq.delay(100)
		BL.info("Necro Rezzing: " .. tostring(theCorpse))
		mq.cmd("/fs Necro Rezzing: " .. tostring(theCorpse))
		doConvergence()
		if pauseAutomation and cwtnIsRunning then
			mq.cmd("/boxr unpause")
		end
	end

	mq.delay(1000)
end
