---@type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")
--- @type BL
local BL = require("biggerlib")

BL.info("Offtank v1.13 loaded")
--local _chosenMode = mq.TLO.CWTN.Mode()


---@class ScriptState
local State = {
	MIN_DIST = 15,
	MAX_DIST = 9999,
	distance = 60,
	Paused = true,  -- Start in paused state
	chosenMode = nil,
	waypoints = {},  -- Store waypoint data
	current_waypoint = nil,  -- Active waypoint for tanking
	use_waypoint = false,  -- Whether to use waypoint positioning
	cwtnModeList = {
		"Manual",
		"Assist",
		"ChaseAssist",
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
	my_class = mq.TLO.Me.Class.ShortName(),
	last_waypoint_time = 0,  -- Track last waypoint movement time
	no_xtar_warning_shown = false,  -- Track if no xtar warning has been shown
	nil_selection_warning_shown = false,  -- Track if nil selection warning has been shown
	last_selected_xtar = nil,  -- Track last selection to detect actual changes
	targeting_mode = "xtar",  -- "xtar" or "mobname"
	mob_name_input = "",  -- Input field for mob name
	mob_names = {},  -- Parsed mob names from input (like original offtank)
	current_mob_target = nil,  -- Current target when in mobname mode
	last_mob_input_change = 0,  -- Track last mob name input change for debouncing
	last_mode_change = 0,  -- Track last mode change for UI context detections
}

local function initMQBindings()
	mq.bind("/offtank reset", function()
		-- Check if CWTN is available before accessing it
		if BL.NotNil(mq.TLO.CWTN) then
			State.chosenMode = mq.TLO.CWTN.Mode()
		else
			State.chosenMode = "Manual"
		end
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
	-- Check if CWTN is available before accessing it
	if BL.NotNil(mq.TLO.CWTN) and mq.TLO.CWTN.Mode() ~= State.chosenMode then
		BL.info("Returning to chosen non-tank mode")
		mq.cmd("/squelch /nav stop")
		mq.cmd("/target clear")
		mq.cmdf("/%s mode %s", State.my_class, State.chosenMode)
		State.last_mode_change = mq.gettime()
	end
end

local function cwtnTANK()
	-- Check if CWTN is available before accessing it
	if BL.NotNil(mq.TLO.CWTN) and mq.TLO.CWTN.Mode() ~= "Tank" then
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


local function checkGroupTankRoleIsEmpty()
    local groupHasMainTank = mq.TLO.Group.MainTank()
	
	if BL.IsNil(groupHasMainTank) then
		return true
	end
	
	local mainTank = mq.TLO.Group.MainTank.CleanName()
	
    if mainTank ~= mq.TLO.Me.CleanName()
	then
		return true
	else
		--print("WARNING: GROUP MAIN TANK ROLE IS SET!")
		--mq.cmd("/rs WARNING: MY GROUP MAIN TANK ROLE IS ENABLED")
		removeMainTankRole(mainTank)
		return false
	end
end

local function SaveWaypoint()
	-- Save current position as a waypoint
	local loc = mq.TLO.Me.Loc()
	local zone = mq.TLO.Zone.ShortName()
	
	local waypoint = {
		name = "WP" .. #State.waypoints + 1,
		x = mq.TLO.Me.X(),
		y = mq.TLO.Me.Y(),
		z = mq.TLO.Me.Z(),
		zone = zone,
		heading = mq.TLO.Me.Heading()
	}
	
	table.insert(State.waypoints, waypoint)
	print("\arSaved waypoint: " .. waypoint.name .. " at (" .. string.format("%.1f, %.1f, %.1f", waypoint.y, waypoint.x, waypoint.z) .. ") in " .. zone .. "\ax")
end

local function GetWaypointNames()
	local names = {"NONE"}
	for i, wp in ipairs(State.waypoints) do
		table.insert(names, wp.name)
	end
	return names
end

local function MoveToWaypoint(waypoint)
	if not waypoint or waypoint.name == "NONE" then
		return false
	end
	
	-- Check if we're in the right zone
	if waypoint.zone ~= mq.TLO.Zone.ShortName() then
		print("\arWaypoint " .. waypoint.name .. " is in zone " .. waypoint.zone .. ", but you're in " .. mq.TLO.Zone.ShortName() .. "\ax")
		return false
	end
	
	-- Navigate to waypoint location
	mq.cmdf("/nav loc %f %f %f", waypoint.y, waypoint.x, waypoint.z)
	print("\arMoving to waypoint " .. waypoint.name .. "\ax")
	return true
end

local function ParseMobNames(mobNameInput)
	-- cache UI input for later change comparison
	State.mob_name_input = mobNameInput
	--split mobNameInput by newline and push each resulting string into State.mob_names
	local mobNames = {}
	for line in mobNameInput:gmatch("[^\r\n]+") do
		-- Trim whitespace and add if not empty
		local trimmed = line:match("^%s*(.-)%s*$")
		if trimmed and trimmed ~= "" then
			table.insert(mobNames, trimmed)
		end
	end
	
	State.mob_names = mobNames
	-- Clear current target when mob list changes to prevent targeting removed mobs
	State.current_mob_being_tanked = nil
	State.IAmTanking = false
	cwtnCHOSEN()
end

local function FindMobByName()
	if #State.mob_names == 0 then
		return nil
	end
	
	-- Search for mobs by exact name match, prioritize closest
	local closestMob = nil
	local closestDistance = 999999
	
	-- Check each mob name in our list
	for _, mobName in ipairs(State.mob_names) do
		local spawn = mq.TLO.Spawn(mobName)
		if spawn() and not spawn.Dead() and spawn.Distance() and spawn.Distance() < State.distance then
			local distance = spawn.Distance()
			if distance < closestDistance then
				closestDistance = distance
				closestMob = spawn
			end
		end
	end
	
	return closestMob
end

local function IsNotIgnored(targetName)
	-- check if targetName is in State.ignored_mobs (case insensitive)
	if not targetName or targetName == "" then
		return false  -- Can't ignore a nil/empty name
	end
	local targetNameLower = string.lower(targetName)
	for _, ignored in ipairs(State.ignored_mobs) do
		if targetNameLower == string.lower(ignored) then
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
	
	-- Handle different targeting modes
	if State.targeting_mode == "xtar" then
		-- XTar mode logic (original)
		if BL.IsNil(State.selected_xtar_to_tank) or State.selected_xtar_to_tank == "NONE" then
			if not State.no_xtar_warning_shown then
				BL.info("NO SELECTED XTAR")
				State.no_xtar_warning_shown = true
			end
			if State.IAmTanking then
				cwtnTANK()
				State.IAmTanking = false
			end
			return
		end
		
		-- Get entire xtar list so we can filter out the ignored ones
		local xtarCount = mq.TLO.Me.XTarget()
		State.filtered_xtar_list = {}
		State.no_xtar_warning_shown = false  -- Reset warning flag when we have targets
		for i = 1, xtarCount do
			local currtar = mq.TLO.Me.XTarget(i)
			if not BL.IsNil(currtar) and currtar.CleanName() and IsNotIgnored(currtar.CleanName()) then
				table.insert(State.filtered_xtar_list, currtar)
			end
		end
		
		-- Get target from xtar list
		local xtar = State.filtered_xtar_list[State.selected_xtar_to_tank]
		if xtar ~= nil and not xtar.Dead() then
			local xtarSpawn = mq.TLO.Spawn(xtar.ID())
			State.current_mob_being_tanked = xtarSpawn
		else
			State.current_mob_being_tanked = nil
			cwtnCHOSEN()
			State.IAmTanking = false
		end
		
	else -- mobname mode
		-- MobName mode logic
		if #State.mob_names == 0 then
			if not State.no_xtar_warning_shown then
				BL.info("NO MOB NAMES SPECIFIED")
				State.no_xtar_warning_shown = true
			end
			if State.IAmTanking then
				cwtnTANK()
				State.IAmTanking = false
			end
			return
		end
		
		State.no_xtar_warning_shown = false  -- Reset warning flag when we have mob names
		
		-- Find target by mob name
		local targetMob = FindMobByName()
		if targetMob then
			State.current_mob_being_tanked = targetMob
		else
			State.current_mob_being_tanked = nil
			cwtnCHOSEN()
			State.IAmTanking = false
		end
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
	local spawn_los = spawn_to_tank.LineOfSight()
	-- Check if CWTN is available before accessing it
	local current_mode = BL.NotNil(mq.TLO.CWTN) and mq.TLO.CWTN.Mode() or 0
	
	-- Check if we're currently in manual mode (navigating) and should continue
	if current_mode == 0 and State.IAmTanking then
		-- We're navigating to target, continue until we get close or gain LOS
		if spawn_distance < 15 then
			-- Close enough, switch to tank mode
			cwtnTANK()
			BL.info("Reached target location, switching to tank mode")
		elseif spawn_los then
			-- Gained LOS during navigation, switch to tank mode
			cwtnTANK()
			BL.info("Gained LOS to %s, switching to tank mode", spawn_to_tank.CleanName())
		else
			-- Still navigating, continue
			return
		end
	end
	
	if
	BL.NotNil(spawn_to_tank) and BL.NotNil(spawn_distance)
		and spawn_distance < State.distance
		and (mq.TLO.Target.ID() ~= State.current_mob_being_tanked.ID() or not mq.TLO.Me.Combat())
	--and (not State.IAmTanking or State.UserChangedSelectionFlag)
	then
		-- Check if we have line of sight, if not, navigate manually
		if not spawn_los then
			-- Switch to manual mode and navigate to target location
			mq.cmdf("/%s mode 0", State.my_class)
			mq.cmdf("/nav loc %f %f %f", spawn_to_tank.Y(), spawn_to_tank.X(), spawn_to_tank.Z())
			BL.info("No LOS to %s, navigating to location", spawn_to_tank.CleanName())
			return
		end
		
		if State.UserChangedSelectionFlag then State.UserChangedSelectionFlag = false end
		-- We want to tank this mob
		TargetAssignedMob()
		-- Stand up if sitting
		if mq.TLO.Me.Sitting() then
			mq.cmd("/stand")
			mq.delay(500)
		end
		if BL.NotNil(State.current_mob_being_tanked) and State.current_mob_being_tanked() then
			if State.targeting_mode == "xtar" then
				BL.info("Tanking %s (ID %s) (xtar %d)", State.current_mob_being_tanked.CleanName(), State.current_mob_being_tanked.ID(), State.selected_xtar_to_tank)
			else
				BL.info("Tanking %s (ID %s)", State.current_mob_being_tanked.CleanName(), State.current_mob_being_tanked.ID())
			end
		else
			BL.info("Trying to tank a NULL mob, something went wrong!")
		end
		
		StartTankingTarget()
		State.IAmTanking = true
	end
	
	-- Move to waypoint if we have 100% aggro and a waypoint is selected
	if State.IAmTanking and State.use_waypoint and State.current_waypoint then
		local target = mq.TLO.Target
		local current_time = mq.gettime()
		local my_x = mq.TLO.Me.X()
		local my_y = mq.TLO.Me.Y()
		local wp_distance = math.sqrt((my_x - State.current_waypoint.x)^2 + (my_y - State.current_waypoint.y)^2)
		
		-- Always check aggro and switch back to tank mode if not 100%
		if target() and target.PctAggro() < 100 then
			cwtnTANK()
			mq.cmd("/squelch /nav stop")
			return
		end
		
		-- Only move to waypoint every 3 seconds when at 100% aggro and not already at waypoint
		if target() and target.PctAggro() == 100 and (current_time - State.last_waypoint_time) > 3000 then
			if wp_distance > 20 then  -- Only nav if more than 20 units away
				-- Switch to manual mode to prevent fighting with navigation
				mq.cmdf("/%s mode 0", State.my_class)
				MoveToWaypoint(State.current_waypoint)
				State.last_waypoint_time = current_time
			else
				-- Stop navigation and switch back to tank mode when at waypoint
				mq.cmd("/squelch /nav stop")
				cwtnTANK()
			end
		end
	end
end

------------ GUI ---------------------------
local function draw_combo_box(label, resultvar, options, showClearTarget)
	local changed = false
	if ImGui.BeginCombo(label, resultvar) then
		if showClearTarget and ImGui.Selectable("Clear target", resultvar == "") then
            resultvar = ""
			changed = true
		end
		for _, j in ipairs(options) do
			if ImGui.Selectable(j, j == resultvar) then
                resultvar = j
				changed = true
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
	-- Warning for group leaders (regardless of MT role status)
	if mq.TLO.Group.Leader() == mq.TLO.Me.CleanName() then
		ImGui.TextColored(1.0, 0.0, 0.0, 1.0, "WARNING: You are Group Leader!")
		ImGui.TextColored(1.0, 0.0, 0.0, 1.0, "Change leader to prevent role conflicts")
		ImGui.Separator()
	-- Warning for non-leaders with main tank role
	elseif mq.TLO.Group.MainTank() and mq.TLO.Group.MainTank.CleanName() == mq.TLO.Me.CleanName() then
		ImGui.TextColored(1.0, 0.5, 0.0, 1.0, "You are MT but NOT Group Leader!")
		ImGui.TextColored(1.0, 0.5, 0.0, 1.0, "Unset your MT role on leader")
		ImGui.Separator()
	end
	
	-- Start/Stop button with mode pickers on the right
	local buttonText = State.Paused and "Start" or "Stop"
	if State.Paused then
		ImGui.PushStyleColor(ImGuiCol.Button, 0.0, 0.5, 0.0, 1.0)  -- Green when paused
		ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.0, 0.7, 0.0, 1.0)
		ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.0, 0.8, 0.0, 1.0)
	else
		ImGui.PushStyleColor(ImGuiCol.Button, 0.7, 0.0, 0.0, 1.0)  -- Red when running
		ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.9, 0.0, 0.0, 1.0)
		ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1.0, 0.0, 0.0, 1.0)
	end
	
	if ImGui.Button(buttonText) then
		if State.Paused then
			-- Start tanking
			State.Paused = false
			mq.cmd("/" .. State.my_class .. " aoecount 99 nosave")
			BL.info("Offtank started - ready to tank")
		else
			-- Stop tanking
			State.Paused = true
			mq.cmd("/" .. State.my_class .. " reload")
			mq.cmd("/attack off")
			mq.cmd("/target clear")
			cwtnCHOSEN()
			State.IAmTanking = false
			BL.info("Offtank stopped - returned to non-tanking mode")
		end
	end
	
	ImGui.PopStyleColor(3)
	
	-- Mode pickers on the right side
	ImGui.SameLine()
	ImGui.Text("Mode:")
	ImGui.SameLine()
	local xtar_selected = (State.targeting_mode == "xtar")
	local mobname_selected = (State.targeting_mode == "mobname")
	
	xtar_selected, changed = ImGui.Checkbox("XTar", xtar_selected)
	if ImGui.IsItemHovered() then
		ImGui.SetTooltip("Offtanks mobs based on selected Extended Target selection (1-20)")
	end
	if changed and xtar_selected then
		State.targeting_mode = "xtar"
	end
	
	ImGui.SameLine()
	mobname_selected, changed = ImGui.Checkbox("Name", mobname_selected)
	if ImGui.IsItemHovered() then
		ImGui.SetTooltip("Offtanks mobs based on the list of NPC names below")
	end
	if changed and mobname_selected then
		State.targeting_mode = "mobname"
	end
	
	ImGui.Separator()
	
	ImGui.SetNextItemWidth(100)  -- Set width for distance input
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
	
	-- Non-Tanking Mode selection (appears after distance for both modes)
	local changedMode = false
	local selectedMode = State.chosenMode
	ImGui.SetNextItemWidth(100)  -- Set width for mode combo (same as distance/xtar)
	selectedMode, changedMode = draw_combo_box("Non-Tanking Mode", selectedMode, State.cwtnModeList)
	if changedMode then
		State.chosenMode = selectedMode
		State.UserChangedModeFlag = true
	end
	
	-- Show appropriate controls based on mode
	if State.targeting_mode == "xtar" then
		local selected = tostring(State.selected_xtar_to_tank) or "NONE"
		local changedXtarSelection = false
		ImGui.SetNextItemWidth(100)  -- Set width for xtar combo (same as distance)
		selected, changedXtarSelection = draw_combo_box("XTar to Tank", selected, State.xtar_options)
		if changedXtarSelection then
			State.UserChangedSelectionFlag = true
			
			local selectionNum = tonumber(selected)
			if BL.IsNil(selectionNum) then
				-- Only show message if selection actually changed to NONE
				if State.last_selected_xtar ~= "NONE" then
					BL.info("Sel num is nil, setting to NONE")
				end
				State.current_mob_being_tanked = nil
				State.selected_xtar_to_tank = "NONE"
				-- Stop combat and return to non-tanking mode when switching to NONE
				if State.IAmTanking then
					mq.cmd("/attack off")
					mq.cmd("/target clear")
					cwtnCHOSEN()
					State.IAmTanking = false
					BL.info("Stopped tanking - switched to NONE")
				end
			else
				-- Only show message if selection actually changed to this number
				if State.last_selected_xtar ~= tostring(selectionNum) then
					BL.info("Sel xtar num is " .. tostring(selectionNum))
				end
				State.selected_xtar_to_tank = selectionNum
			end
			
			-- Update last selection tracker
			State.last_selected_xtar = selected
		end
	else -- mobname mode
		ImGui.Text("NPC's to tank (one per line):")
		local mobNameInput = State.mob_name_input or ""
		local changed = false
		ImGui.SetNextItemWidth(200)  -- Set width for mob name input
		mobNameInput, changed = ImGui.InputTextMultiline("##mobnames", mobNameInput, 200, 80, 0)
		if changed then
			ParseMobNames(mobNameInput)
		end
		
		-- Add Current Target button
		if ImGui.Button("Add Target") then
			local currentTarget = mq.TLO.Target
			if currentTarget() and currentTarget.Type() ~= "PC" then
				local targetName = currentTarget.CleanName()
				-- Check if target is already in mob list
				local alreadyAdded = false
				for _, mobName in ipairs(State.mob_names) do
					if mobName == targetName then
						alreadyAdded = true
						break
					end
				end
				
				if not alreadyAdded then
					table.insert(State.mob_names, targetName)
					-- Update the input text to show the new mob list
					State.mob_name_input = table.concat(State.mob_names, "\n")
					print("Added " .. targetName .. " to mob list")
				else
					print(targetName .. " is already in mob list")
				end
			else
				print("No valid target selected (or targeting a PC)")
			end
		end
	end
	
	-- Waypoint controls
	ImGui.Separator()
	
	-- Save current position as waypoint
	if ImGui.Button("Save WP") then
		SaveWaypoint()
	end
	ImGui.SameLine()
	if ImGui.Button("Go to Selected WP") then
		MoveToWaypoint(State.current_waypoint)
	end
	
	-- Waypoint checkboxes
	ImGui.Text("Select Waypoint:")
	
	for i, wp in ipairs(State.waypoints) do
		local is_checked = (State.current_waypoint and State.current_waypoint.name == wp.name)
		local changed = false
		
		is_checked, changed = ImGui.Checkbox(wp.name .. " (" .. string.format("%.1f, %.1f", wp.y, wp.x) .. ")", is_checked)
		
		if changed then
			if is_checked then
				-- Uncheck all other waypoints by setting this as the only selected one
				State.current_waypoint = wp
				State.use_waypoint = true
				print("\arSelected waypoint: " .. wp.name .. "\ax")
			else
				-- Uncheck this waypoint
				State.current_waypoint = nil
				State.use_waypoint = false
				print("\arDeselected waypoint: " .. wp.name .. "\ax")
			end
		end
		
		-- Delete button for this waypoint
		ImGui.SameLine()
		if ImGui.Button("Delete##" .. wp.name) then
			-- Remove waypoint from table
			for j, check_wp in ipairs(State.waypoints) do
				if check_wp.name == wp.name then
					table.remove(State.waypoints, j)
					-- If this was the selected waypoint, clear selection
					if State.current_waypoint and State.current_waypoint.name == wp.name then
						State.current_waypoint = nil
						State.use_waypoint = false
					end
					print("\arDeleted waypoint: " .. wp.name .. "\ax")
					break
				end
			end
		end
	end
	
	-- Accept user input for list of names and put them into string array State.ignored_mobs
	ImGui.Text("Ignored NPC's")
	local ignoredMobsInput = State.ignored_mobs_input or ""
	local changed = false
	ImGui.SetNextItemWidth(300)  -- Set width for ignored mobs input
	ignoredMobsInput, changed = ImGui.InputTextMultiline("##ignoredmobs", ignoredMobsInput, 265, 100, 0)
	if changed then
		ParseIgnoredMobs(ignoredMobsInput)
	end
	
	-- Add Ignore Current Target button
	if ImGui.Button("Ignore Current Target") then
		local currentTarget = mq.TLO.Target
		if currentTarget() and currentTarget.Type() ~= "PC" then
			local targetName = currentTarget.CleanName()
			-- Check if target is already in ignore list
			local alreadyIgnored = false
			for _, ignoredName in ipairs(State.ignored_mobs) do
				if ignoredName == targetName then
					alreadyIgnored = true
					break
				end
			end
			
			if not alreadyIgnored then
				table.insert(State.ignored_mobs, targetName)
				-- Update the input text to show the new ignore list
				State.ignored_mobs_input = table.concat(State.ignored_mobs, "\n")
				print("Added " .. targetName .. " to ignore list")
			else
				print(targetName .. " is already in ignore list")
			end
		else
			print("No valid target selected (or targeting a PC)")
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--print("\arStarting OFFTANK XTAR script\ax")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function init()
	initMQBindings()	
	-- Check if CWTN is available before accessing it
	if BL.NotNil(mq.TLO.CWTN) then
		State.chosenMode = mq.TLO.CWTN.Mode()
	else
		State.chosenMode = "Manual"  -- Default mode when no CWTN plugin
	end
	--UI Init
	BL.Gui:Init({
		            WindowName = "Offtank",
		            ScriptName = "offtank",
		            ScriptState = State,
		            DrawFunction = DrawUI,
	            })
	
	return checkGroupTankRoleIsEmpty()
end

local function main()
	if State.Paused then
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
	mq.doevents()
	mq.delay(500)
end
