---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

local BL = require("biggerlib")

-- CHANGE THIS TO WHICHEVER CLERIC SHOULD DO THE REZZING
local CLERIC = "Caelinaex"

-- this is how far you will look to drag corpses
local mindistance = 50
local maxdistance = 9999

local function navToCleric()
	local cleric = mq.TLO.Spawn(CLERIC)
	if cleric then
		cleric.DoTarget()
		mq.delay(1)
		mq.cmd("/nav target")
		BL.WaitForNav()
	else
		BL.error("Corpse dragger script cannot find the cleric to nav to!")
	end
end

local function drag(dragid, dragname)
    if mq.TLO.Target.Distance() <= maxdistance
        and mq.TLO.Target.Distance() >= mindistance
        and mq.TLO.Target.Distance() ~= nil
    then
		BL.cmd.pauseAutomation()
		mq.cmd("/rs Dragging %s", dragname)
		mq.delay(100)
		mq.cmdf('/tar ID %s', dragid)
		mq.delay(500)
		-- cache corpse for later dropping
		local corpseCache = mq.TLO.Target
		mq.cmd("/nav target")
		BL.WaitForNav()
		mq.cmd('/corpsedrag')
		mq.delay(500)
		navToCleric()
		-- restore corpse cache after targeting cleric to nav
		corpseCache.DoTarget()
		mq.delay(1)
		mq.cmd("/corpsedrop")
		mq.delay(500)
        mq.cmd("/rs Done dragging %s", dragname)
		BL.cmd.resumeAutomation()
	end
end

local function dragcheck()
	local corpsecount = mq.TLO.SpawnCount('pccorpse radius ' .. maxdistance)()
	if corpsecount ~= nil then
		for c = 1, corpsecount do
			--set the corpse variables
			local corpseCache = mq.TLO.NearestSpawn(c .. ',pccorpse radius ' .. maxdistance)
			local corpsename = corpseCache.CleanName()
			local corpseid = corpseCache.ID()
			local raidcount = mq.TLO.Raid.Members()

			-- are we in a raid for dragging?
			if raidcount > 0 then
				if mq.TLO.Spawn('id ' .. corpseid).Distance() >= mindistance then
					drag(corpseid, corpsename)
				end
			else
				BL.error("Not in a raid, not dragging any corpses!")
			end
		end
	end
end

------------------------------ UI
local paused = true
local openGUI = true

local function imguiMain(openGUI)
	local main_viewport = imgui.GetMainViewport()
	imgui.SetNextWindowPos(main_viewport.WorkPos.x + 650, main_viewport.WorkPos.y + 20, ImGuiCond.FirstUseEver)

	-- change the window size
	imgui.SetNextWindowSize(200, 100, ImGuiCond.FirstUseEver)

	local show = false
	openGUI, show = imgui.Begin("Corpse Dragger", openGUI)

	if not show then
		ImGui.End()
		return openGUI
	end

	ImGui.PushItemWidth(ImGui.GetFontSize() * -12);

	-- Main window element area --

	-- Beginning of window elements
	--imgui.Text("Text")
	--imgui.Text("\n") -- To create a new line

	if paused then
		if ImGui.Button("Run") then
			-- What you want the button to do
			paused = false
		end
	else
		if ImGui.Button("Pause") then
			-- What you want the button to do
			paused = true
		end
	end
	local success = false
	local cleric, success = ImGui.InputText("Rezzer", CLERIC)
	if success then
		CLERIC = cleric
	end
	--imgui.SameLine()
	--checkBox1 = imgui.Checkbox("Box 1", checkBox1) -- toggling this updates the checkBox1 variable. Use in other 'if' statements
	--imgui.SameLine(300)                         -- You can specify distance. Number is how many pixels from left side of window
	--checkBox2 = imgui.Checkbox("Box 2", checkBox2)
	ImGui.Separator()

	-- End of main window element area --

	-- Required for window elements
	imgui.Spacing()
	imgui.PopItemWidth()
	imgui.End()
	return openGUI
end



ImGui.Register('Corpse Dragger', function()
	openGUI = imguiMain(openGUI)
end)

local function main()
	while true do
		while not paused do
			dragcheck()
		end
		mq.doevents()
		mq.delay(1023)
	end
end

main()
