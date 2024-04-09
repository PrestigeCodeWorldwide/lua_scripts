---@type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")
--- @type BL
local BL = require("biggerlib")

--local _chosenMode = mq.TLO.CWTN.Mode()

---@type ScriptState
local State = {
	MIN_DIST = 50,
	MAX_DIST = 9999,
	distance = 150,
	Paused = false,
	chosenMode = nil,
	cwtnModeList = {
		"Manual",
		"Assist",
		"Chase",
		"SicTank",
		"Vorpal",
	},
	selected_xtar_to_tank = "NONE", -- chosen xtar i should be tanking
	xtar_options = {
		"NONE",
		"1",
		"2",
		"3",
		"4",
		"5",
		"6",
		"7",
		"8",
		"9",
		"10",
		"11",
		"12",
		"13",
		"14",
		"15",
		"16",
		"17",
		"18",
		"19",
		"20",
	},
	ignored_mobs = {},
	ignored_mobs_input = "",
	current_mob_being_tanked = nil,
	filtered_xtar_list = {},
	IAmTanking = false,
	UserChangedSelectionFlag = false,
	UserChangedModeFlag = false,
	my_class = mq.TLO.Me.Class.ShortName()
}

local function initMQBindings()
	mq.bind("/offtank reset", function()
		State.chosenMode = mq.TLO.CWTN.Mode()
		print("Setting idle mode to " .. State.chosenMode)
	end)
	
	mq.bind("/offtank pause on", function()
		State.Paused = true
		mq.cmd("/squelch /nav stop")
		print("Offtank paused")
	end)
	
	mq.bind("/offtank pause off", function()
		State.Paused = false
		print("Offtank resumed")
	end)
	
	mq.bind("/offtank pause", function()
		State.Paused = true
		mq.cmd("/squelch /nav stop")
		print("Offtank paused")
	end)
end


local function cwtnCHOSEN()
	if mq.TLO.CWTN.Mode() ~= State.chosenMode then
		BL.info("Returning to chosen non-tank mode")
		BL.cmd.pauseAutomation()
		mq.cmd("/squelch /nav stop")
		mq.delay(250)
		mq.cmdf("/%s mode %s", State.my_class, State.chosenMode)
		mq.delay(250)
		BL.cmd.resumeAutomation()
	end
end

local function cwtnTANK()
	if mq.TLO.CWTN.Mode() ~= "Tank" then
		mq.cmdf("/%s mode 4", State.my_class)
	end
end

local function TargetAssignedMob()
	if mq.TLO.Target.ID() ~= State.current_mob_being_tanked.ID() then
		--mq.cmdf("/target %s", State.selected_xtar_to_tank)
		--BL.info("Changing target to currently assigned, which is:")
		--BL.dump(State.current_mob_being_tanked.ID())
		--BL.dump(State.current_mob_being_tanked.Name())
		State.current_mob_being_tanked.DoTarget()
		mq.delay(1)
	end
end

local function removeMainTankRole(mtName)
	mq.cmd("/grouproles unset " .. mtName .. " 1")
	print("Removed main tank role")
end

local function getGroupMainTank()
	return mq.TLO.Group.MainTank()
end

local function checkGroupTankRoleIsEmpty()
	local groupRole = getGroupMainTank()
	
	if groupRole == nil then
		return true
	else
		print("WARNING: GROUP MAIN TANK ROLE IS SET!")
		mq.cmd("/rs WARNING: MY GROUP MAIN TANK ROLE IS ENABLED")
		removeMainTankRole(groupRole)
		return false
	end
end

local function IsNotIgnored(targetName)
	-- check if targetName is in State.ignored_mobs
	for _, ignored in ipairs(State.ignored_mobs) do
		if targetName == ignored then
			return false
		end
	end
	return true
end

local function UpdateAggroState()
	
	if State.UserChangedModeFlag then
		cwtnCHOSEN()
		State.UserChangedModeFlag = false
	end
	
	if BL.IsNil(State.selected_xtar_to_tank)
		or State.selected_xtar_to_tank == "NONE"
	then
		if State.IAmTanking then
			cwtnTANK()
			State.IAmTanking = false
		end
		return
	end
	
	-- Get entire xtar list so we can filter out the ignored ones
	local xtarCount = mq.TLO.Me.XTarget()
	State.filtered_xtar_list = {}
	for i = 1, xtarCount do
		local currtar = mq.TLO.Me.XTarget(i)
		if not BL.IsNil(currtar)
			and IsNotIgnored(currtar.CleanName())
		
		then
			table.insert(State.filtered_xtar_list, currtar)
		end
	end
	--BL.dump(State.filtered_xtar_list)
	--BL.dump(State.selected_xtar_to_tank)
	--- @type xtarget
	local xtar = State.filtered_xtar_list[State.selected_xtar_to_tank]
	--BL.dump(xtar)
	if xtar ~= nil and not xtar.Dead()   then
		local xtarId = xtar.ID()
		local xtarName = xtar.Name()
		local targetType = xtar.TargetType()
		local xtarSpawn = mq.TLO.Spawn(xtarId)
		--BL.dump(xtarName, "xtarName")
		--BL.dump(State.selected_xtar_to_tank, "selected xtar")
		State.current_mob_being_tanked = xtarSpawn
	else
		State.current_mob_being_tanked = nil
		cwtnCHOSEN()
		State.IAmTanking = false
	end
end

local function StartTankingTarget()
	cwtnTANK()
	mq.delay(1)
	if not mq.TLO.Me.Combat() then
		mq.cmd("/attack on")
	end
	mq.delay(50)
end

local function DoTanking()
	local assigned_mob = State.current_mob_being_tanked
	if assigned_mob == nil or assigned_mob == 0 then
		--BL.info("Early out cwtnChosen call from DoTanking")
		if State.IAmTanking then
			cwtnCHOSEN()
			State.IAmTanking = false
		end
		return
	end
	local spawn_to_tank = mq.TLO.Spawn(assigned_mob.ID())
	if BL.IsNil(spawn_to_tank) then
		BL.info("Early out from DoTanking because spawn_to_tank is nil")
		if State.IAmTanking then
			cwtnCHOSEN()
			State.IAmTanking = false
		end
	end
	local spawn_distance = spawn_to_tank.Distance()
	if
	BL.NotNil(spawn_to_tank) and BL.NotNil(spawn_distance)
		and spawn_distance < State.distance
		and (mq.TLO.Target.ID() ~= State.current_mob_being_tanked.ID() or not mq.TLO.Me.Combat())
	--and (not State.IAmTanking or State.UserChangedSelectionFlag)
	then
		if State.UserChangedSelectionFlag then State.UserChangedSelectionFlag = false end
		-- We want to tank this mob
		TargetAssignedMob()
		-- Stand up if sitting
		if mq.TLO.Me.Sitting() then
			mq.cmd("/stand")
			mq.delay(500)
		end
		if BL.NotNil(State.current_mob_being_tanked) then
			BL.info("Tanking %s (ID %s) (xtar %d)", State.current_mob_being_tanked.Name(), State.current_mob_being_tanked.ID(), State.selected_xtar_to_tank)
		else
			BL.info("Trying to tank a NULL mob, something went wrong!")
		end
		
		StartTankingTarget()
		State.IAmTanking = true
	end
end

------------ GUI ---------------------------
local function draw_combo_box(label, resultvar, options, showClearTarget)
	local changed = false
	if ImGui.BeginCombo(label, resultvar) then
		if showClearTarget and ImGui.Selectable("Clear target", resultvar == "") then
			resultvar = ""
		end
		for _, j in ipairs(options) do
			if ImGui.Selectable(j, j == resultvar) then
				resultvar = j
			end
		end
		ImGui.EndCombo()
	end
	return resultvar, changed
end
local function ParseIgnoredMobs(ignoredMobsInput)
	-- cache UI input for later change comparison
	State.ignored_mobs_input = ignoredMobsInput
	--split ignoredMobsInput by newline and push each resulting string into State.ignored_mobs
	local ignoredMobs = {}
	for line in ignoredMobsInput:gmatch("[^\r\n]+") do
		--BL.info("Adding %s to ignored mobs", line)
		table.insert(ignoredMobs, line)
	end
	
	--BL.dump(State.ignored_mobs, "State ignoredmobs")
	State.ignored_mobs = ignoredMobs
end

local DrawUI = function()
	State.distance, State.isChanged = ImGui.InputInt(
		"Distance",
		State.distance, 5,
		0, 0
	)
	
	if State.distance < State.MIN_DIST then
		State.distance = State.MIN_DIST
	end
	if State.distance > State.MAX_DIST then
		State.distance = State.MAX_DIST
	end
	
	local selected = tostring(State.selected_xtar_to_tank) or "NONE"
	local changedXtarSelection = false
	selected, changedXtarSelection = draw_combo_box("XTar to Tank", selected, State.xtar_options)
	if changedXtarSelection then
		State.UserChangedSelectionFlag = true
		local selectionNum = tonumber(selected)
		if BL.IsNil(selectionNum) then
			State.current_mob_being_tanked = nil
			State.selected_xtar_to_tank = "NONE"
		else
			State.selected_xtar_to_tank = selectionNum
		end
	end
	
	local changedMode = false
	local selectedMode = State.chosenMode
	selectedMode, changedMode = draw_combo_box("Non-Tanking Mode", selectedMode, State.cwtnModeList)
	if changedMode then
		State.chosenMode = selectedMode
		State.UserChangedModeFlag = true
	
	end
	
	-- Accept user input for list of names and put them into string array State.ignored_mobs
	local ignoredMobsInput = State.ignored_mobs_input or ""
	local changed = false
	ignoredMobsInput, changed = ImGui.InputTextMultiline("Ignored Mobs", ignoredMobsInput, 265, 100, 0)
	if changed then
		ParseIgnoredMobs(ignoredMobsInput)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
print("\arStarting OFFTANK XTAR script\ax")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function init()
	initMQBindings()
	local groupMT = getGroupMainTank()
	if groupMT ~= nil then
		removeMainTankRole(groupMT)
	end
	
	--UI Init
	BL.Gui:Init({
		            WindowName = "Offtank XTar",
		            ScriptName = "offtankX",
		            ScriptState = State,
		            DrawFunction = DrawUI,
	            })
	
	return checkGroupTankRoleIsEmpty()
end

local function main()
	if State.Paused then
		BL.info("Paused, skipping")
		return
	end
	-- Make sure group MT role didn't get switched back on
	checkGroupTankRoleIsEmpty()
	-- update from xtar
	UpdateAggroState()
	DoTanking()
end

init()

while true do
	main()
	mq.delay(500)
end
