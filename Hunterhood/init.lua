local mq = require 'mq'
require 'ImGui'
local bit = require 'bit'
local Open, ShowUI = true, true
local BL = require("biggerlib")

BL.info('HunterHood v2.03 loaded')

-- Load and initialize zone data
local zoneData = require("Hunterhood.zone_data").create(mq)
local zoneMap = zoneData.zoneMap
local zone_lists = zoneData.zone_lists
local combo_items = zoneData.combo_items
local getZoneDisplayName = zoneData.getZoneDisplayName
-- Navigation coroutine
local navCoroutine = nil
local navActive = false

-- Helper function to check for non-PH mobs on extended target
local function hasNonPHTargets(phList, hoodAch)
    local xtargetCount = mq.TLO.Me.XTarget() or 0
    for i = 1, xtargetCount do
        local target = mq.TLO.Me.XTarget(i)
        if target() and target.ID() > 0 then
            local spawn = mq.TLO.Spawn(target.ID())
            if spawn() and not spawn.Dead() then
                local isPHorNamed = false
                local spawnName = spawn.CleanName()

                -- Check if it's one of our named mobs
                for _, mob in ipairs(hoodAch.Spawns) do
                    if mob.name == spawnName then
                        isPHorNamed = true
                        break
                    end
                end

                -- Check if it's a PH for any of our mobs
                if not isPHorNamed then
                    for _, phs in pairs(phList) do
                        for _, ph in ipairs(phs) do
                            if ph == spawnName then
                                isPHorNamed = true
                                break
                            end
                        end
                        if isPHorNamed then break end
                    end
                end

                -- If we found a non-PH, non-named mob on extended target
                if not isPHorNamed then
                    return true, spawn
                end
            end
        end
    end
    return false, nil
end

-- Function to handle navigation to targets
local function navigateToTargets(hoodAch, mobCheckboxes)
    return coroutine.create(function()
        local phList = require("Hunterhood.ph_list").ph_list
        local currentTarget = nil
        local navComplete = true

        while navActive do
            -- Check for non-PH mobs on extended target
            local hasAdd, addSpawn = hasNonPHTargets(phList, hoodAch)
            if hasAdd and addSpawn then
                -- If we're currently navigating to a target, stop that navigation
                if mq.TLO.Navigation.Active() then
                    mq.cmd("/nav stop")
                    navComplete = true
                end

                printf("\arAdd detected: \ay%s\ar - Engaging first", addSpawn.CleanName())
                mq.cmdf("/nav id %d log=error", addSpawn.ID())
                mq.cmdf("/tar id %d", addSpawn.ID())
                mq.cmd("/docommand /${Me.Class.ShortName} resetcamp")
                navComplete = false
                currentTarget = addSpawn

                -- Wait for add to die
                while navActive and addSpawn() and not addSpawn.Dead() do
                    -- Check if more adds appear while fighting this one
                    local newAdd = hasNonPHTargets(phList, hoodAch)
                    if newAdd then
                        printf("\ayNew add detected, will engage after current target")
                    end
                    coroutine.yield()
                end

                -- Short delay after killing add
                for i = 1, 10 do
                    if not navActive then break end
                    coroutine.yield()
                end
                goto continue
            end

            -- If we get here, no adds are present, proceed with normal targeting
            if navComplete then
                -- Reset variables for this iteration
                local closestSpawn = nil
                local closestDistance = math.huge
                local checkedMobs = {}

                -- Get all checked mobs
                for _, spawn in ipairs(hoodAch.Spawns) do
                    if mobCheckboxes[spawn.name] then
                        table.insert(checkedMobs, spawn)
                    end
                end

                if #checkedMobs > 0 then
                    -- Find closest spawn
                    for _, mob in ipairs(checkedMobs) do
                        -- Check named mob
                        local spawnID = mq.TLO.Spawn("npc " .. mob.name).ID()
                        if spawnID ~= nil and spawnID > 0 then
                            local spawn = mq.TLO.Spawn(spawnID)
                            if spawn() and not spawn.Dead() then
                                local distance = spawn.Distance3D() or math.huge
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestSpawn = spawn
                                end
                            end
                        end

                        -- Check placeholders
                        local placeholders = phList[mob.name] or {}
                        for _, phName in ipairs(placeholders) do
                            local phID = mq.TLO.Spawn("npc " .. phName).ID()
                            if phID ~= nil and phID > 0 then
                                local phSpawn = mq.TLO.Spawn(phID)
                                if phSpawn() and not phSpawn.Dead() then
                                    local distance = phSpawn.Distance3D() or math.huge
                                    if distance < closestDistance then
                                        closestDistance = distance
                                        closestSpawn = phSpawn
                                    end
                                end
                            end
                        end
                    end

                    -- If we found a valid target, navigate to it
                    if closestSpawn and (not currentTarget or currentTarget.ID() ~= closestSpawn.ID()) then
                        printf("\ayNavigating to \ag%s\ay (%.1f away)",
                            closestSpawn.CleanName(),
                            closestSpawn.Distance3D() or 0)
                        mq.cmdf("/nav id %d log=error", closestSpawn.ID())
                        mq.cmdf("/tar id %d", closestSpawn.ID())
                        if not mq.TLO.Me.Combat() then
                        end
                        currentTarget = closestSpawn
                        navComplete = false
                    end
                end
            end

            -- Check if we've reached our current target
            if currentTarget and currentTarget() and not currentTarget.Dead() then
                if currentTarget.Distance3D() <= 10 then
                    mq.cmd("/docommand /${Me.Class.ShortName} mode 4")
                    mq.cmd("/docommand /${Me.Class.ShortName} pause off")
                    mq.cmd("/docommand /${Me.Class.ShortName} resetcamp")
                    if not mq.TLO.Me.Combat() and currentTarget.Distance3D() <= 15 then
                        mq.cmd("/attack on")
                    end
                    -- Wait at the target for a bit
                    for i = 1, 10 do
                        if not navActive then break end
                        coroutine.yield()
                    end
                    navComplete = true
                end
            else
                navComplete = true
            end

            ::continue::
            coroutine.yield()
        end
    end)
end

-- icons for the checkboxes
local done = mq.FindTextureAnimation('A_TransparentCheckBoxPressed')
local notDone = mq.FindTextureAnimation('A_TransparentCheckBoxNormal')

-- Some WindowFlags
local WindowFlags = bit.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoResize, ImGuiWindowFlags.AlwaysAutoResize)
local HoodWindowFlags = bit.bor(ImGuiWindowFlags.NoTitleBar, ImGuiWindowFlags.NoScrollbar)

-- print format function
local function printf(...)
    print(string.format(...))
end

local oldZone = 0
local myZone = mq.TLO.Zone.ID
local showOnlyMissing = false
local minimize = false
local showGrind = false
local onlySpawned = false
local spawnUp = 0
local totalDone = ''
local currentTab = "Hunter"                          -- Track which tab is active
local hoodWindowSize = { width = 270, height = 350 } -- Saved size for Hood tab
local lastTab = "Hunter"                             -- Track the last active tab

-- shortening the mq bind for achievements
local myAch = mq.TLO.Achievement

-- Current Achievement information for Hunter tab
local curHunterAch = {}
local myHunterSpawn = {}

-- nameMap that maps wrong achievement objective names to the ingame name.
local nameMap = {
    ["Pli Xin Liako"]           = "Pli Xin Laiko",
    ["Xetheg, Luclin's Warder"] = "Xetheg, Luclin`s Warder",
    ["Itzal, Luclin's Hunter"]  = "Itzal, Luclin`s Hunter",
    ["Ol' Grinnin' Finley"]     = "Ol` Grinnin` Finley"
}

-- Track selected zone per group for Hood tab
local selected_zone_index = 1
local selected_index = 1 -- default to first expansion

local function findspawn(spawn)
    if not spawn then return 0 end
    if nameMap[spawn] then spawn = nameMap[spawn] end
    local mySpawn = mq.TLO and mq.TLO.Spawn and mq.TLO.Spawn(string.format('npc "%s"', spawn))
    return (mySpawn and mySpawn.CleanName and mySpawn.CleanName() == spawn) and (mySpawn.ID and mySpawn.ID() or 0) or 0
end

-- Achievement information for Hood tab
local hoodAch = { ID = 0, Name = "", Count = 0, Spawns = {} }
local mobCheckboxes = {}
local selectedZoneID = nil
local hasInitialized = false

-- Rename the original AchID to getHoodAchID for clarity
local function getHoodAchID(zoneID)
    if zoneID and zoneMap[zoneID] then
        return zoneMap[zoneID]
    end
    return nil
end

-- New function to get current zone's achievement ID for Hunter tab
local function getCurrentZoneAchID()
    local zoneID = mq.TLO.Zone.ID()
    if zoneMap[zoneID] then
        return zoneMap[zoneID]
    end

    -- Fallback for zones with different achievement name patterns
    local achName = 'Hunter of the ' .. mq.TLO.Zone.Name()
    if myAch(achName).ID() then
        return myAch(achName).ID()
    else
        achName = 'Hunter of ' .. mq.TLO.Zone.Name()
        return myAch(achName).ID()
    end
end

local function updateHunterTab()
    myHunterSpawn = {}
    curHunterAch = {}
    local achID = getCurrentZoneAchID()

    if achID ~= nil then
        local ach = myAch(achID)
        curHunterAch = {
            ID = achID,
            Name = ach.Name(),
            Count = ach.ObjectiveCount()
        }
        printf('\a#f8bd21Updating Hunter Tab(\a#b08d42%s\a#f8bd21)', curHunterAch.Name)

        -- Get all objectives by name instead of by index to ensure we get them all
        for i = 1, curHunterAch.Count do
            local objective = ach.ObjectiveByIndex(i)
            if objective and objective() then
                table.insert(myHunterSpawn, objective())
            end
        end

        -- Debug output to verify we got all mobs
        printf('\a#f8bd21Found %d mobs for %s', #myHunterSpawn, curHunterAch.Name)
        for i, mob in ipairs(myHunterSpawn) do
            printf('  %d. %s', i, mob)
        end

        printf('\a#f8bd21Hunter Tab Update Done(\a#b08d42%s\a#f8bd21)', curHunterAch.Name)
    else
        print('\a#f8bd21No Hunts found in \a#b08d42' .. mq.TLO.Zone())
    end
end

local function getPctCompleted()
    local tmp = 0
    for index, hunterSpawn in ipairs(myHunterSpawn) do
        if myAch(curHunterAch.ID).Objective(hunterSpawn).Completed() then
            tmp = tmp + 1
        end
    end
    totalDone = string.format('%d/%d', tmp, curHunterAch.Count)
    if tmp == curHunterAch.Count then totalDone = 'Completed!' end
    return tmp / curHunterAch.Count
end

local function drawCheckBox(spawn)
    if myAch(curHunterAch.ID).Objective(spawn).Completed() then
        ImGui.DrawTextureAnimation(done, 15, 15)
        ImGui.SameLine()
    else
        ImGui.DrawTextureAnimation(notDone, 15, 15)
        ImGui.SameLine()
    end
end

local function textEnabled(spawn)
    ImGui.PushStyleColor(ImGuiCol.Text, 0.690, 0.553, 0.259, 1)
    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, 0.33, 0.33, 0.33, 0.5)
    ImGui.PushStyleColor(ImGuiCol.HeaderActive, 0.0, 0.66, 0.33, 0.5)
    local selSpawn = ImGui.Selectable(spawn, false, ImGuiSelectableFlags.AllowDoubleClick)
    ImGui.PopStyleColor(3)
    if selSpawn and ImGui.IsMouseDoubleClicked(0) then
        mq.cmdf('/nav id %d log=error', findspawn(spawn))
        printf('\ayMoving to \ag%s', spawn)
    end
end

local function hunterProgress()
    local x, y = ImGui.GetContentRegionAvail()
    ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0.690, 0.553, 0.259, 0.5)
    ImGui.PushStyleColor(ImGuiCol.FrameBg, 0.33, 0.33, 0.33, 0.5)
    ImGui.SetWindowFontScale(0.85)
    ImGui.Indent(2)
    ImGui.ProgressBar(getPctCompleted(), x - 4, 14, totalDone)
    ImGui.PopStyleColor(2)
    ImGui.SetWindowFontScale(1)
end

local function createLines(spawn)
    if findspawn(spawn) ~= 0 then
        drawCheckBox(spawn)
        textEnabled(spawn)
    elseif not onlySpawned then
        drawCheckBox(spawn)
        ImGui.TextDisabled(spawn)
    end
end

local function popupmenu()
    ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize('HunterHUD')) * 0.5)
    ImGui.TextColored(0.973, 0.741, 0.129, 1, 'HunterHUD')
    ImGui.Separator()
    ImGui.PushStyleColor(ImGuiCol.Text, 0.690, 0.553, 0.259, 1)
    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, 0.33, 0.33, 0.33, 0.5)
    ImGui.PushStyleColor(ImGuiCol.HeaderActive, 0.0, 0.66, 0.33, 0.5)

    minimize = ImGui.MenuItem('Minimize', '', minimize)
    if ImGui.Selectable('Hide') then
        printf('\a#f8bd21Hiding HunterHud(\a#b08d42\'/hh\' to show\ax)')
        ShowUI = not ShowUI
    end
    onlySpawned = ImGui.MenuItem('Toggle Spawned Only', '', onlySpawned)
    showOnlyMissing = ImGui.MenuItem('Toggle Missing Hunts', '', showOnlyMissing)
    ImGui.Separator()
    ImGui.PushStyleColor(ImGuiCol.Text, 0.973, 0.741, 0.129, 1)
    if ImGui.Selectable('Stop HunterHUD') then Open = false end
    ImGui.PopStyleColor(4)
    ImGui.EndPopup()
end

local function PCList()
    ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize('Players in Zone')) * 0.5)
    ImGui.TextColored(0.973, 0.741, 0.129, 1, 'Players in Zone')
    ImGui.Separator()
    ImGui.PushStyleColor(ImGuiCol.Text, 0.690, 0.553, 0.259, 1)
    --ImGui.PushStyleColor(ImGuiCol.HeaderHovered, 0.33, 0.33, 0.33, 0.5)
    --ImGui.PushStyleColor(ImGuiCol.HeaderActive, 0.0, 0.66, 0.33, 0.5)

    for i = 1, mq.TLO.SpawnCount('pc')() do
        local player = mq.TLO.NearestSpawn(i, 'pc')
        ImGui.Text(string.format('%s [%d - %s] - %s', player.Name(), player.Level(), player.Class(),
            player.Guild() or 'No Guild'))
    end
    ImGui.Separator()
    ImGui.PushStyleColor(ImGuiCol.Text, 0.973, 0.741, 0.129, 1)
    --bottom line
    ImGui.PopStyleColor(2)
    ImGui.EndPopup()
end

local function InfoLine()
    ImGui.Separator()
    ImGui.TextColored(0.690, 0.553, 0.259, 1, '\xee\x9f\xbc')
    --[[if ImGui.BeginPopupContextItem('pcpopup') then
        PCList()
    end]] --
    ImGui.SameLine()
    local pcs = mq.TLO.SpawnCount('pc')() - mq.TLO.SpawnCount('group pc')()

    if pcs > 50 then
        ImGui.TextColored(0.95, 0.05, 0.05, 1, tostring(pcs))
    elseif pcs > 25 then
        ImGui.TextColored(0.95, 0.95, 0.05, 1, tostring(pcs))
    elseif pcs > 0 then
        ImGui.TextColored(0.05, 0.95, 0.05, 1, tostring(pcs))
    else
        ImGui.TextDisabled(tostring(pcs))
    end

    ImGui.SameLine()
    ImGui.TextDisabled('|')
    if mq.TLO.Group() ~= nil then
        for i = 0, mq.TLO.Group.Members() do
            local member = mq.TLO.Group.Member(i)
            if member.Present() and not member.Mercenary() then
                ImGui.SameLine()
                if not member.Invis() then
                    ImGui.TextColored(0.0, 0.95, 0.0, 1, 'F' .. i + 1)
                elseif member.Invis('NORMAL')() and not member.Invis('IVU')() then
                    ImGui.TextDisabled('F' .. i + 1)
                end
            end
        end
    else
        if not mq.TLO.Me.Invis() then
            ImGui.SameLine()
            ImGui.TextColored(0.0, 0.95, 0.0, 1, 'F1')
        end
    end
    ImGui.SameLine()
    ImGui.TextDisabled('|')
    ImGui.SameLine()
    spawnUp = 0
    if spawnUp == 0 then ImGui.TextDisabled('\xee\x9f\xb5') end
    if spawnUp == 1 then ImGui.TextColored(0.973, 0.741, 0.129, 1, '\xee\x9f\xb5') end
    if spawnUp == 2 then ImGui.TextColored(0.0129, 0.973, 0.129, 1, '\xee\x9f\xb5') end
end

local function RenderTitle()
    ImGui.SetWindowFontScale(1.15)
    local title = 0
    if curHunterAch.ID then
        title = curHunterAch.Name
    else
        title = mq.TLO.Zone.Name()
    end
    ImGui.SetCursorPosX((ImGui.GetWindowWidth() - ImGui.CalcTextSize(title)) * 0.5)
    ImGui.TextColored(0.973, 0.741, 0.129, 1, title)
    ImGui.SetWindowFontScale(1)
    if ImGui.BeginPopupContextItem('titlepopup') then
        popupmenu()
    end
end

local function RenderHunter()
    hunterProgress()
    if not minimize then
        ImGui.Separator()
        -- Always show all mobs, but use different styling based on completion and spawn status
        for _, hunterSpawn in ipairs(myHunterSpawn) do
            if showOnlyMissing then
                if not myAch(curHunterAch.ID).Objective(hunterSpawn).Completed() then
                    createLines(hunterSpawn)
                end
            else
                createLines(hunterSpawn)
            end
        end
    end
end

local function updateHoodAchievement(zoneID)
    -- Reset the achievement data
    hoodAch = { ID = 0, Name = "", Count = 0, Spawns = {} }
    mobCheckboxes = mobCheckboxes or {} -- Initialize if nil, keep existing if not

    if not zoneID then return false end

    local achID = getHoodAchID(zoneID) or 0

    -- Try to find achievement by name as fallback if no direct mapping exists
    if achID == 0 then
        local zoneName = mq.TLO.Zone(zoneID) and mq.TLO.Zone(zoneID).Name() or ("Zone %d"):format(zoneID)

        -- Try different naming patterns
        local patterns = {
            "Hunter of the " .. zoneName,
            "Hunter of " .. zoneName,
            zoneName .. " Hunter"
        }

        for _, pattern in ipairs(patterns) do
            local ach = myAch(pattern)
            if ach and ach() and ach.ID() > 0 then
                achID = ach.ID()
                break
            end
        end

        if achID == 0 then
            --printf("No hunter achievement found for zone ID: %d (%s)", zoneID, zoneName) --debug
            return false
        end
    end

    local ach = myAch(achID)
    if not ach or not ach() or ach.ID() == 0 then
        printf("Invalid achievement ID: %d for zone ID: %d", achID, zoneID)
        return false
    end

    -- Get achievement details
    local achName = ach.Name() or "Hunter Achievement"
    local achCount = ach.ObjectiveCount() or 0

    -- Update hoodAch with the new achievement data
    hoodAch.ID = achID
    hoodAch.Name = achName
    hoodAch.Count = achCount
    hoodAch.Spawns = {}

    -- Populate spawns
    for i = 0, achCount do
        local objective = ach.ObjectiveByIndex(i)
        if not objective or not objective() then
            objective = ach.Objective(i) -- Fallback to Objective if ObjectiveByIndex fails
        end

        if objective and objective() ~= nil then
            local objName = objective()
            if type(objName) == "string" and objName ~= "" then
                if nameMap[objName] then
                    objName = nameMap[objName]
                end
                table.insert(hoodAch.Spawns, {
                    name = objName,
                    done = objective.Completed() or false,
                    id = findspawn(objName) or 0
                })
            end
        end
    end

    --printf("Loaded achievement '%s' with %d objectives", achName, #hoodAch.Spawns)  --Uncomment for debug
    return true
end

local function renderHoodTab()
    -- Initialize with first zone's achievement if not already loaded
    if not hasInitialized and #combo_items > 0 then
        hasInitialized = true
        local group_name = combo_items[1]
        local zones = zone_lists[group_name] or {}
        if #zones > 0 and zones[1].id then
            updateHoodAchievement(zones[1].id)
        end
    end

    -- Expansion selector combo
    ImGui.SetNextItemWidth(190)
    if ImGui.BeginCombo("Expansion", combo_items[selected_index]) then
        for i, item in ipairs(combo_items) do
            if ImGui.Selectable(item, i == selected_index) then
                selected_index = i
                selected_zone_index = 1
                local zones = zone_lists[item] or {}
                if #zones > 0 and zones[1].id then
                    updateHoodAchievement(zones[1].id)
                end
            end
            if i == selected_index then
                ImGui.SetItemDefaultFocus()
            end
        end
        ImGui.EndCombo()
    end

    -- Zone selector combo
    local currentZoneName = "Select a zone"
    local zones = zone_lists[combo_items[selected_index] or ""] or {}
    if #zones > 0 and selected_zone_index >= 1 and selected_zone_index <= #zones then
        currentZoneName = zones[selected_zone_index].name()
    end

    ImGui.SetNextItemWidth(190)
    if ImGui.BeginCombo("Zone", currentZoneName) then
        for i, zone in ipairs(zones) do
            local zoneText = getZoneDisplayName(zone.id)
            if ImGui.Selectable(zoneText, i == selected_zone_index) then
                selected_zone_index = i
                updateHoodAchievement(zone.id)
            end
        end
        ImGui.EndCombo()
    end

    -- Display achievement mob list
    if hoodAch.ID > 0 and #hoodAch.Spawns > 0 then
        -----------------------------------------------------
        -- FIXED HEADER SECTION (aligned with body columns)
        -----------------------------------------------------
        local windowWidth = select(1, ImGui.GetContentRegionAvail())

        local col1MinWidth = 200
        local col2Width = 50
        local remainingSpace = windowWidth - col2Width - 20
        local col1Width = math.max(col1MinWidth, remainingSpace * 0.5)
        local col3Width = remainingSpace - col1Width

        ImGui.Columns(3, "##mob_columns_header", false)
        ImGui.SetColumnWidth(0, col1Width)
        ImGui.SetColumnWidth(1, col2Width)
        ImGui.SetColumnWidth(2, col3Width)

        -- Header col 1: Completed
        local completed, total = 0, #hoodAch.Spawns
        for _, spawn in ipairs(hoodAch.Spawns) do
            if spawn.done then completed = completed + 1 end
        end
        ImGui.Text(string.format("Completed ( %d/%d )", completed, total))
ImGui.SameLine(0, 10)  -- Add space after text
ImGui.PushStyleColor(ImGuiCol.Button, 0.2, 0.2, 0.2, 1)
ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
if ImGui.SmallButton("GO##ExecuteAction") then
    if not navActive then
        navActive = true
        navCoroutine = navigateToTargets(hoodAch, mobCheckboxes)
        printf("\ayStarted navigation to selected mobs")
    else
        navActive = false
        navCoroutine = nil
        mq.cmd("/nav stop")
        printf("\ayStopped navigation")
    end
end
ImGui.PopStyleColor(2)
ImGui.NextColumn()

        -- Header col 2: Check All
        local allChecked = true
        for _, spawn in ipairs(hoodAch.Spawns) do
            if not mobCheckboxes[spawn.name] then
                allChecked = false
                break
            end
        end
        local checkPosX = ImGui.GetCursorPosX()
        ImGui.SetCursorPosX(checkPosX + 8) -- Add 15px offset
        local newAllChecked = ImGui.Checkbox("##CheckAll", allChecked)
        ImGui.SetCursorPosX(checkPosX)     -- Reset cursor position
        if newAllChecked ~= allChecked then
            for _, s in ipairs(hoodAch.Spawns) do
                mobCheckboxes[s.name] = newAllChecked
            end
            printf("%s all mobs in zone: %s", newAllChecked and "Checked" or "Unchecked", hoodAch.Name)
        end
        ImGui.NextColumn()

        ImGui.Columns(1)
        ImGui.Separator()

        -----------------------------------------------------
        -- SCROLLABLE BODY (same column widths)
        -----------------------------------------------------
        local availX, availY = ImGui.GetContentRegionAvail()
        ImGui.BeginChild("MobList", 0, availY, ImGuiChildFlags.Border)

        ImGui.Columns(3, "##mob_columns_body", false)
        ImGui.SetColumnWidth(0, col1Width)
        ImGui.SetColumnWidth(1, col2Width)
        ImGui.SetColumnWidth(2, col3Width)


        -- Mob rows
        for _, spawn in ipairs(hoodAch.Spawns) do
            -- Column 1: completion + name
            if spawn.done then
                ImGui.DrawTextureAnimation(done, 15, 15)
            else
                ImGui.DrawTextureAnimation(notDone, 15, 15)
            end
            ImGui.SameLine(0, 5)

            local isSpawned = mq.TLO.SpawnCount("npc " .. spawn.name)() > 0
            if isSpawned then
                ImGui.PushStyleColor(ImGuiCol.Text, 0.973, 0.741, 0.129, 1)
            else
                ImGui.PushStyleColor(ImGuiCol.Text, 0.5, 0.5, 0.5, 1)
            end

            ImGui.PushID("mob_" .. tostring(spawn.id or 0) .. "_" .. spawn.name)
            local selected = ImGui.Selectable(spawn.name, false, ImGuiSelectableFlags.AllowDoubleClick)
            if selected and ImGui.IsMouseDoubleClicked(0) then
                local spawnID = mq.TLO.Spawn("npc " .. spawn.name).ID()
                if spawnID ~= nil and spawnID > 0 then
                    mq.cmdf('/nav id %d log=error', spawnID)
                    printf('\ayMoving to \ag%s', spawn.name)
                else
                    printf('\arCould not find spawn ID for %s', spawn.name)
                end
            end
            ImGui.PopID()
            ImGui.PopStyleColor()

            -- Tooltip for PH info (unchanged)
            if ImGui.IsItemHovered() then
                local phList = require("Hunterhood.ph_list").ph_list
                local function normalizeName(name)
                    return name:lower():gsub(" ", "_"):gsub("'", ""):gsub("-", "")
                end
                local normalizedSpawnName = normalizeName(spawn.name)
                local placeholders = phList[spawn.name] or {}
                if #placeholders == 0 then
                    for mobName, phs in pairs(phList) do
                        if normalizeName(mobName):find(normalizedSpawnName, 1, true)
                            or normalizedSpawnName:find(normalizeName(mobName), 1, true) then
                            placeholders = phs
                            break
                        end
                    end
                end
                local spawnedPHs, totalSpawned = {}, 0
                for _, phName in ipairs(placeholders) do
                    local count = mq.TLO.SpawnCount("npc " .. phName)() or 0
                    if count > 0 then
                        table.insert(spawnedPHs, { name = phName, count = count })
                        totalSpawned = totalSpawned + count
                    end
                end
                if #placeholders > 0 or #spawnedPHs > 0 then
                    ImGui.BeginTooltip()
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.973, 0.741, 0.129, 1)
                    ImGui.Text("PH(s) for " .. spawn.name .. ":")
                    if #spawnedPHs > 0 then
                        ImGui.Text(string.format("\nCurrently spawned (%d):", totalSpawned))
                        for _, ph in ipairs(spawnedPHs) do
                            ImGui.BulletText(string.format("%s (x%d)", ph.name, ph.count))
                        end
                    end
                    if #placeholders > 0 then
                        ImGui.Text("\nPossible placeholders:")
                        for _, ph in ipairs(placeholders) do
                            ImGui.BulletText(ph)
                        end
                    end
                    ImGui.PopStyleColor()
                    ImGui.EndTooltip()
                end
            end

            ImGui.NextColumn()

            -- Column 2: checkbox
            local state = mobCheckboxes[spawn.name]
            local newState = ImGui.Checkbox("##" .. spawn.name, state)
            mobCheckboxes[spawn.name] = newState
            ImGui.NextColumn()

            -- Column 3: action buttons
            ImGui.BeginGroup()
            ImGui.PushStyleColor(ImGuiCol.Button, 0, 0, 0, 1)
            ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
            if ImGui.Button("PH1##" .. spawn.name, 40, 0) then
                printf("Location button clicked for: %s", spawn.name)
            end
            ImGui.SameLine(0, 4)
            if ImGui.Button("PH2##" .. spawn.name, 40, 0) then
                printf("Info button clicked for: %s", spawn.name)
            end
            ImGui.PopStyleColor(2)
            ImGui.EndGroup()
            ImGui.NextColumn()
        end

        ImGui.Columns(1)
        ImGui.EndChild()
    else
        ImGui.BeginChild("MobList", 0, 50, ImGuiChildFlags.Border)
        ImGui.Text("No hunter achievement found for this zone.")
        ImGui.EndChild()
    end
end


local function HunterHUD()
    if ShowUI then
        ImGui.PushStyleColor(ImGuiCol.WindowBg, 0, 0, 0, 0.66)

        -- Use different window flags based on active tab
        local activeWindowFlags = (currentTab == "Hood") and HoodWindowFlags or WindowFlags

        -- Set window size for Hood tab before Begin
        if currentTab == "Hood" and lastTab ~= "Hood" then
            ImGui.SetNextWindowSize(hoodWindowSize.width, hoodWindowSize.height, ImGuiCond.Always)
        end

        Open, _ = ImGui.Begin('HunterHUD', Open, activeWindowFlags)

        -- Save Hood tab size when it's active
        if currentTab == "Hood" then
            hoodWindowSize.width = ImGui.GetWindowWidth()
            hoodWindowSize.height = ImGui.GetWindowHeight()
        end

        ImGui.PopStyleColor()

        if ImGui.BeginTabBar("HunterHUDTabs") then
            -- push custom colors
            ImGui.PushStyleColor(ImGuiCol.Tab, 0, 0, 0, 1)              -- inactive tab bg
            ImGui.PushStyleColor(ImGuiCol.TabActive, 0, 0, 0, 1)        -- active tab bg
            ImGui.PushStyleColor(ImGuiCol.TabHovered, 0.1, 0.1, 0.1, 1) -- hovered tab bg
            ImGui.PushStyleColor(ImGuiCol.TabUnfocused, 0, 0, 0, 1)
            ImGui.PushStyleColor(ImGuiCol.TabUnfocusedActive, 0, 0, 0, 1)
            ImGui.PushStyleColor(ImGuiCol.Text, 0.973, 0.741, 0.129, 1)   -- orange text
            ImGui.PushStyleColor(ImGuiCol.Border, 0.973, 0.741, 0.129, 1) -- orange border
            ImGui.PushStyleColor(ImGuiCol.BorderShadow, 0, 0, 0, 0)       -- clean border (no shadow)

            -- ensure borders are visible
            ImGui.PushStyleVar(ImGuiStyleVar.FrameBorderSize, 1.5)

            -- Hunter tab
            if ImGui.BeginTabItem("Hunter") then
                lastTab = currentTab  -- Save previous tab
                currentTab = "Hunter" -- Set active tab
                RenderTitle()
                if curHunterAch.ID then
                    RenderHunter()
                end
                InfoLine()
                ImGui.EndTabItem()
            end

            -- Hood tab
            if ImGui.BeginTabItem("Hood") then
                lastTab = currentTab -- Save previous tab
                currentTab = "Hood"  -- Set active tab
                -- push custom style
                ImGui.PushStyleColor(ImGuiCol.FrameBg, 0, 0, 0, 1)
                ImGui.PushStyleColor(ImGuiCol.FrameBgHovered, 0.1, 0.1, 0.1, 1)
                ImGui.PushStyleColor(ImGuiCol.FrameBgActive, 0.2, 0.2, 0.2, 1)
                ImGui.PushStyleColor(ImGuiCol.Text, 0.973, 0.741, 0.129, 1)
                ImGui.PushStyleColor(ImGuiCol.Border, 0.973, 0.741, 0.129, 1)
                ImGui.PushStyleColor(ImGuiCol.PopupBg, 0, 0, 0, 0.95)
                ImGui.PushStyleColor(ImGuiCol.HeaderHovered, 0.33, 0.33, 0.33, 0.5)
                ImGui.PushStyleColor(ImGuiCol.HeaderActive, 0.0, 0.66, 0.33, 0.5)
                ImGui.PushStyleVar(ImGuiStyleVar.FrameBorderSize, 1.5)

                -- Render the Hood tab content
                renderHoodTab()

                -- pop styles (vars first, then colors)
                ImGui.PopStyleVar(1)
                ImGui.PopStyleColor(8)

                ImGui.EndTabItem()
            end

            -- pop tab bar styles (vars first, then colors)
            ImGui.PopStyleVar(1)
            ImGui.PopStyleColor(8)

            ImGui.EndTabBar()
        end

        ImGui.End()
    end
end


local function bind_hh(cmd)
    local VividOrange = '\a#f8bd21'
    local DarkOrange  = '\a#b08d42'

    if cmd == nil then
        if ShowUI then
            printf('%sHiding HunterHUD', VividOrange)
            ShowUI = false
        else
            printf('%sShowing HunterHUD', VividOrange)
            ShowUI = true
        end
    elseif cmd == 'stop' then
        printf('%sHunterHUD Ended', VividOrange)
        Open = false
    else
        printf('%sHunterHUD usage:', VividOrange)
        printf('%s/hh %sToggles showing and hiding HunterHud', VividOrange, DarkOrange)
        printf('%s/hh stop %sStop HunterHUD', VividOrange, DarkOrange)
    end

    return
end

mq.imgui.init('hunterhud', HunterHUD)
mq.bind('/hh', bind_hh)

while Open do
    local currentZone = mq.TLO.Zone.ID() -- Get current zone ID directly from MQ
    if oldZone ~= currentZone then
        myZone = currentZone             -- Update myZone with the current zone
        updateHunterTab()
        oldZone = currentZone
    end
    -- Update navigation coroutine
    if navCoroutine and coroutine.status(navCoroutine) ~= "dead" then
        local success, err = coroutine.resume(navCoroutine)
        if not success then
            printf("\arNavigation error: %s", tostring(err))
            navActive = false
        end
    end
    mq.delay(250)
end
