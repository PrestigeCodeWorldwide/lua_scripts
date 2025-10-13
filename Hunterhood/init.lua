local mq = require 'mq'
require 'ImGui'
local bit = require 'bit'
local Open, ShowUI = true, true
local BL = require("biggerlib")
--local helpers = require("Hunterhood.helpers")
local zoneData = require("Hunterhood.zone_data").create(mq)

BL.info('HunterHood v2.12 loaded')

local currentNavTarget = nil
local useInvis = true -- Default to using invisibility
local zoneMap = zoneData.zoneMap
local zone_lists = zoneData.zone_lists
local combo_items = zoneData.combo_items
local getZoneDisplayName = zoneData.getZoneDisplayName
local myAch = mq.TLO.Achievement
local helpers = require("Hunterhood.helpers").new(myAch) -- Pass myAch to helpers
local navCoroutine = nil
local navActive = false
currentNavTarget = nil  --clear the target

-- Function to handle navigation to targets
local function navigateToTargets(hoodAch, mobCheckboxes)
    return coroutine.create(function()
        local phList = require("Hunterhood.ph_list") -- Load the module (not .ph_list)
        local currentZoneID = mq.TLO.Zone.ID() -- Get current zone ID
        local currentTarget = nil
        local navComplete = true
        local engagedTarget = nil

        while navActive do
            -- Update zone ID each iteration in case of zone change
            currentZoneID = mq.TLO.Zone.ID()
            
            -- If we have an engaged target that's still valid, skip target selection
            if engagedTarget and engagedTarget() and not engagedTarget.Dead() and
                mq.TLO.Me.Combat() and mq.TLO.Target.ID() == engagedTarget.ID() then
                coroutine.yield()
            else
                if not mq.TLO.Me.Combat() or
                    (mq.TLO.Target() and mq.TLO.Target.ID() ~= (engagedTarget and engagedTarget.ID() or 0)) then
                    engagedTarget = nil
                end

                local shouldContinue = false

                -- Check for non-PH mobs on extended target
                local hasAdd, addSpawn = helpers.hasNonPHTargets(phList, hoodAch, currentZoneID)
                if hasAdd and addSpawn then
                    if not engagedTarget or engagedTarget.Dead() or not mq.TLO.Me.Combat() then
                        printf("\arAdd detected: \ay%s\ar - Engaging first", addSpawn.CleanName())
                        mq.cmdf("/nav id %d log=error", addSpawn.ID())
                        currentTarget = addSpawn
                        engagedTarget = addSpawn
                        navComplete = false
                        shouldContinue = true
                    end
                end

                if not shouldContinue and navComplete then
                    local closestSpawn = nil
                    local closestDistance = math.huge
                    local checkedMobs = {}

                    for _, spawn in ipairs(hoodAch.Spawns) do
                        if mobCheckboxes[spawn.name] then
                            table.insert(checkedMobs, spawn)
                        end
                    end

                    if #checkedMobs > 0 then
                        for _, mob in ipairs(checkedMobs) do
                            -- Check named mob first
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

                            -- Check placeholders for this mob
                            local placeholders = phList.getPlaceholders(mob.name, currentZoneID)
                            if placeholders and type(placeholders) == "table" then
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
                        end

                        if closestSpawn and (not engagedTarget or not mq.TLO.Me.Combat()) then
                            -- Add a small delay to ensure the mob is fully dead and removed from xtarget
                            for i = 1, 10 do  -- 10 ticks delay
                                if not navActive then break end
                                coroutine.yield()
                            end
                            
                            -- Make sure everyone in the group is invis before proceeding
                            local needsInvis = true
                            local attempts = 0
                            while needsInvis and attempts < 5 do  -- Try up to 5 times
                                if helpers.groupNeedsInvis() then
                                    printf("\ayGroup needs invisibility - casting... (Attempt %d/5)", attempts + 1)
                                    mq.cmd("/noparse /docommand /dgga /alt act 231")
                                    mq.cmd("/alt act 231")
                                    -- Wait for cast to complete
                                    for i = 1, 20 do
                                        if not navActive then break end
                                        coroutine.yield()
                                    end
                                    -- Check if we're still visible after casting
                                    if not helpers.groupNeedsInvis() then
                                        needsInvis = false
                                        printf("\ayGroup is now invisible, proceeding to next target")
                                    end
                                else
                                    needsInvis = false
                                end
                                attempts = attempts + 1
                                if needsInvis then
                                    -- Small delay before retry
                                    for i = 1, 10 do
                                        if not navActive then break end
                                        coroutine.yield()
                                    end
                                end
                            end
                            
                            if needsInvis then
                                printf("\arFailed to ensure group is invisible after 5 attempts, proceeding anyway")
                            end

                            currentNavTarget = closestSpawn
                            printf("\ayNavigating to \ag%s\ay (%.1f away)",
                                closestSpawn.CleanName(),
                                closestSpawn.Distance3D() or 0)
                            mq.cmdf("/nav id %d log=error", closestSpawn.ID())
                            currentTarget = closestSpawn
                            engagedTarget = closestSpawn
                            navComplete = false
                            
                            -- Check invisibility frequently while navigating
                            local lastInvisCheck = os.clock()
                            while not navComplete and mq.TLO.Navigation.Active() do
                                -- Check for adds and invisibility every 0.3 seconds for faster response
                                if os.clock() - lastInvisCheck >= 0.3 then
                                    -- First check for adds on extended target
                                    local hasAdd, addSpawn = helpers.hasNonPHTargets(phList, hoodAch, currentZoneID)
                                    if hasAdd and addSpawn and (not engagedTarget or engagedTarget.ID() ~= addSpawn.ID()) then
                                        printf("\arAdd detected during navigation: \ay%s\ar - Engaging", addSpawn.CleanName())
                                        mq.cmd("/nav stop")
                                        mq.cmdf("/target id %d", addSpawn.ID())
                                        currentTarget = addSpawn
                                        engagedTarget = addSpawn
                                        navComplete = false
                                        break  -- Exit the navigation loop to handle the add
                                    end
                                    
                                    -- Then check invisibility if no add was found
                                    if helpers.groupNeedsInvis() then
                                        printf("\ayGroup needs invisibility during navigation - recasting...")
                                        -- Clear any existing navigation to prevent movement during cast
                                        mq.cmd("/nav stop")
                                        -- Cast invisibility on group and self
                                        mq.cmd("/noparse /docommand /dgga /alt act 231")
                                        mq.cmd("/alt act 231")
                                        -- Wait for cast to complete
                                        for i = 1, 6 do  -- Reduced delay for faster response (0.6s)
                                            if not navActive then break end
                                            coroutine.yield()
                                        end
                                        -- Resume navigation if we still have a target
                                        if currentNavTarget and currentNavTarget() and not currentNavTarget.Dead() then
                                            mq.cmdf("/nav id %d log=error", currentNavTarget.ID())
                                            -- Small delay after resuming navigation
                                            for i = 1, 3 do
                                                if not navActive then break end
                                                coroutine.yield()
                                            end
                                        end
                                    end
                                    lastInvisCheck = os.clock()
                                end
                                coroutine.yield()
                            end
                        end
                    end
                end
            end

            if currentTarget and currentTarget() and not currentTarget.Dead() then
                if currentTarget.Distance3D() <= 25 then
                    printf("\ayDEBUG: In range, setting up combat...")

                    if mq.TLO.Target.ID() ~= currentTarget.ID() then
                        mq.cmdf("/target id %d", currentTarget.ID())
                        for i = 1, 5 do
                            coroutine.yield()
                        end
                    end

                    if mq.TLO.Target.ID() == currentTarget.ID() then
                        if not mq.TLO.Me.Combat() then
                            printf("\ayDEBUG: Enabling attack mode (in range)")
                            mq.cmd("/attack on")
                            engagedTarget = currentTarget
                        end

                        if mq.TLO.Me.Combat() then
                            mq.cmd("/stick 10 front moveback")
                            mq.cmd("/face")
                        end
                    end

                    for i = 1, 5 do
                        if not navActive then break end
                        coroutine.yield()
                    end
                    navComplete = true
                end
            else
                printf("\ayDEBUG: No valid target or target is dead")
                navComplete = true
                engagedTarget = nil
            end

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
local hoodWindowSize = { width = 280, height = 350 } -- Saved size for Hood tab
local lastTab = "Hunter"                             -- Track the last active tab

-- shortening the mq bind for achievements
local myAch = mq.TLO.Achievement
local helpers = require("Hunterhood.helpers").new(myAch) -- Pass myAch to helpers

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
-- Achievement information for Hood tab
local hoodAch = { ID = 0, Name = "", Count = 0, Spawns = {} }
local mobCheckboxes = {}
--local selectedZoneID = nil
local hasInitialized = false
--local lastHoodUpdate = 0
--local HOOD_UPDATE_INTERVAL = 1000 -- Update every second

local function updateHunterTab()
    myHunterSpawn = {}
    curHunterAch = {}
    local achID = helpers.getCurrentZoneAchID(zoneMap)
    printf('Debug: updateHunterTab called with achID: %s', tostring(achID))

    if achID and achID > 0 then
        local ach = myAch(achID)
        if not ach or not ach() then
            printf('Error: Achievement ID %d not found', achID)
            return
        end

        local achName = ach.Name() or "Unknown Achievement"
        local objCount = ach.ObjectiveCount() or 0
        printf('Debug: Found achievement "%s" with %d objectives', achName, objCount)

        curHunterAch = {
            ID = achID,
            Name = achName,
            Count = objCount
        }
        printf('\a#f8bd21Updating Hunter Tab(\a#b08d42%s\a#f8bd21)', curHunterAch.Name)

        -- Get all objectives by name
        for i = 1, objCount do
            local objective = ach.ObjectiveByIndex(i)
            if objective and objective() then
                local objName = objective()
                if objName and objName ~= "" then
                    table.insert(myHunterSpawn, objName)
                end
            end
        end

        -- Debug output
        printf('\a#f8bd21Found %d mobs for %s', #myHunterSpawn, curHunterAch.Name)
        for i, mob in ipairs(myHunterSpawn) do
            printf('  %d. %s', i, mob)
        end

        printf('\a#f8bd21Hunter Tab Update Done(\a#b08d42%s\a#f8bd21)', curHunterAch.Name)
    else
        print('\a#f8bd21No Hunts found in \a#b08d42' .. (mq.TLO.Zone() or "current zone"))
    end
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
    -- Check if the spawn is up
    local spawnID = helpers.findSpawn(spawn, nameMap)
    local isUp = spawnID ~= 0 and mq.TLO.Spawn(spawnID).ID() ~= nil

    -- Set text color based on spawn status
    if isUp then
        ImGui.PushStyleColor(ImGuiCol.Text, 0.973, 0.741, 0.129, 1) -- Gold for up
    else
        ImGui.PushStyleColor(ImGuiCol.Text, 0.5, 0.5, 0.5, 1)       -- Grey for down
    end

    ImGui.PushStyleColor(ImGuiCol.HeaderHovered, 0.33, 0.33, 0.33, 0.5)
    ImGui.PushStyleColor(ImGuiCol.HeaderActive, 0.0, 0.66, 0.33, 0.5)

    local selSpawn = ImGui.Selectable(spawn, false, ImGuiSelectableFlags.AllowDoubleClick)

    ImGui.PopStyleColor(3)

    if selSpawn and ImGui.IsMouseDoubleClicked(0) then
        mq.cmdf('/nav id %d log=error', spawnID)
        printf('\ayMoving to \ag%s', spawn)
    end
end

local function hunterProgress()
    local pct, doneText = helpers.getPctCompleted(curHunterAch.ID, myHunterSpawn, curHunterAch)
    totalDone = doneText -- Keep the global variable updated
    local x, y = ImGui.GetContentRegionAvail()
    ImGui.PushStyleColor(ImGuiCol.PlotHistogram, 0.690, 0.553, 0.259, 0.5)
    ImGui.PushStyleColor(ImGuiCol.FrameBg, 0.33, 0.33, 0.33, 0.5)
    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0) -- Text color (white)
    ImGui.SetWindowFontScale(0.85)
    ImGui.Indent(2)
    ImGui.ProgressBar(pct, x - 4, 16, totalDone)
    ImGui.PopStyleColor(3)
    ImGui.SetWindowFontScale(1)
end

local function createLines(spawn)
    -- Check if we should skip non-spawned mobs when onlySpawned is true
    if onlySpawned then
        local spawnID = helpers.findSpawn(spawn, nameMap)
        local isUp = spawnID ~= 0 and mq.TLO.Spawn(spawnID).ID() ~= nil
        if not isUp then
            return -- Skip this spawn if it's not up and we're only showing spawned
        end
    end

    -- Draw the checkbox and text for the spawn
    drawCheckBox(spawn)
    textEnabled(spawn)
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
    --printf('Debug: RenderHunter called, myHunterSpawn count: %d', #myHunterSpawn) --debug
    hunterProgress()
    if not minimize then
        ImGui.Separator()
        --printf('Debug: Showing %d mobs', #myHunterSpawn) --debug
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
    hoodAch = { ID = 0, Name = "", Count = 0, Spawns = {}, zoneID = zoneID }
    mobCheckboxes = mobCheckboxes or {}

    if not zoneID then return false end

    local achID = helpers.getHoodAchID(zoneID, zoneMap) or 0

    if achID == 0 then
        local zoneName = mq.TLO.Zone(zoneID) and mq.TLO.Zone(zoneID).Name() or ("Zone %d"):format(zoneID)

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
            return false
        end
    end

    local ach = myAch(achID)
    if not ach or not ach() or ach.ID() == 0 then
        printf("Invalid achievement ID: %d for zone ID: %d", achID, zoneID)
        return false
    end

    local achName = ach.Name() or "Hunter Achievement"
    local achCount = ach.ObjectiveCount() or 0

    hoodAch.ID = achID
    hoodAch.Name = achName
    hoodAch.Count = achCount
    hoodAch.Spawns = {}
    hoodAch.zoneID = zoneID

    for i = 0, achCount do
        local objective = ach.ObjectiveByIndex(i)
        if not objective or not objective() then
            objective = ach.Objective(i)
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
                    id = helpers.findSpawn(objName, nameMap) or 0
                })
            end
        end
    end

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
    ImGui.SetNextItemWidth(160)
    if ImGui.BeginCombo(":", combo_items[selected_index]) then
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
    ImGui.SameLine(0, 2)
    local newUseInvis = ImGui.Checkbox("Invis##InvisCheckbox", useInvis)
    if newUseInvis ~= useInvis then
        useInvis = newUseInvis
        helpers.setUseInvis(useInvis)
    end
    if ImGui.IsItemHovered() then
        ImGui.SetTooltip("Use Invis while navigating between mobs")
    end

    ImGui.SameLine(0, 10)
    ImGui.PushStyleColor(ImGuiCol.Button, 0.2, 0.2, 0.2, 1)
    ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)
    if ImGui.Button("GO##ExecuteAction") then
        if not navActive then
            -- Check if group needs invisibility before starting navigation
            if useInvis and helpers.groupNeedsInvis() then
                printf("\ayGroup members need invisibility, casting...")
                mq.cmd("/noparse /docommand /dgga /alt act 231")
            end
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
    if ImGui.IsItemHovered() then
        ImGui.SetTooltip("Start/Stop navigation to selected mobs")
    end
    ImGui.PopStyleColor(2)
    -- Zone selector combo
    local currentZoneName = "Select a zone"
    local zones = zone_lists[combo_items[selected_index] or ""] or {}
    if #zones > 0 and selected_zone_index >= 1 and selected_zone_index <= #zones then
        currentZoneName = zones[selected_zone_index].name()
    end

    ImGui.SetNextItemWidth(190)
    if ImGui.BeginCombo("##ZoneCombo", currentZoneName) then
        for i, zone in ipairs(zones) do
            local zoneText = getZoneDisplayName(zone.id)
            if ImGui.Selectable(zoneText, i == selected_zone_index) then
                selected_zone_index = i
                updateHoodAchievement(zone.id)
            end
        end
        ImGui.EndCombo()
    end
    -- Save the current style colors
    ImGui.SameLine(0, 4)
    local buttonTextColor = ImGui.GetStyleColor(ImGuiCol.Text)
    local buttonBgColor = ImGui.GetStyleColor(ImGuiCol.Button)

    -- Set the button colors
    ImGui.PushStyleColor(ImGuiCol.Button, 0xFF000000)        -- Black background
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0xFF333333) -- Dark gray on hover
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0xFF555555)  -- Lighter gray when pressed
    ImGui.PushStyleColor(ImGuiCol.Text, 0xFF00FF00)          -- Green text

    if ImGui.Button("Nav") then
        local zones = zone_lists[combo_items[selected_index] or ""] or {}
        if #zones > 0 and selected_zone_index >= 1 and selected_zone_index <= #zones then
            local zone = zones[selected_zone_index]
            printf("Traveling to %s (ID: %d)", zone.shortname, zone.id)
            mq.cmdf("/travelto %s", zone.shortname)
        end
    end

    local zones = zone_lists[combo_items[selected_index] or ""] or {}
    if #zones > 0 and selected_zone_index >= 1 and selected_zone_index <= #zones then
        local zone = zones[selected_zone_index]
        if ImGui.IsItemHovered() then
            ImGui.BeginTooltip()
            ImGui.Text("Click to /travelto %s", zone.shortname)
            ImGui.EndTooltip()
        end
    end
    -- Current Zone button
    ImGui.SameLine()
    ImGui.PushStyleColor(ImGuiCol.Button, 0.2, 0.2, 0.2, 1)
    ImGui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1) -- Cyan color
    if ImGui.Button("CZ##CurrentZone") then
        local exp, zone = helpers.getCurrentZoneData(zoneMap, zone_lists)
        if exp and zone then
            for i, item in ipairs(combo_items) do
                if item == exp then
                    selected_index = i
                    local zones = zone_lists[exp] or {}
                    for j, z in ipairs(zones) do
                        if z.id == zone.id then
                            selected_zone_index = j
                            break
                        end
                    end
                    updateHoodAchievement(zone.id)
                    break
                end
            end
        else
            printf("\\ayCurrent zone not found in HunterHood database.")
        end
    end
    if ImGui.IsItemHovered() then
        ImGui.SetTooltip("Click to select your current zone in the drop down")
    end
    ImGui.PopStyleColor(2)
    ImGui.PopStyleColor(4)

    -- Display achievement mob list
    if hoodAch.ID > 0 and #hoodAch.Spawns > 0 then
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

        -- Header col 1: Completed (check status dynamically)
        local completed, total = 0, #hoodAch.Spawns
        if hoodAch.ID > 0 then
            local ach = myAch(hoodAch.ID)
            if ach and ach() then
                for _, spawn in ipairs(hoodAch.Spawns) do
                    local objective = ach.Objective(spawn.name)
                    if objective and objective() and objective.Completed() then
                        completed = completed + 1
                    end
                end
            end
        end
        local completedText = string.format("Completed ( %d/%d )", completed, total)

        -- Add distance to target if navigating
        if navActive and currentNavTarget then
            local distance = currentNavTarget.Distance3D() or 0
            completedText = completedText .. string.format("  [%.1f]", distance)
        end

        ImGui.Text(completedText)

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
        ImGui.SetCursorPosX(checkPosX + 8)
        local newAllChecked = ImGui.Checkbox("##CheckAll", allChecked)
        ImGui.SetCursorPosX(checkPosX)
        if newAllChecked ~= allChecked then
            for _, s in ipairs(hoodAch.Spawns) do
                mobCheckboxes[s.name] = newAllChecked
            end
            printf("%s all mobs in zone: %s", newAllChecked and "Checked" or "Unchecked", hoodAch.Name)
        end
        ImGui.NextColumn()

        ImGui.Columns(1)
        ImGui.Separator()

        local availX, availY = ImGui.GetContentRegionAvail()
        ImGui.BeginChild("MobList", 0, availY, ImGuiChildFlags.Border)

        ImGui.Columns(3, "##mob_columns_body", false)
        ImGui.SetColumnWidth(0, col1Width)
        ImGui.SetColumnWidth(1, col2Width)
        ImGui.SetColumnWidth(2, col3Width)


        -- Mob rows
        for _, spawn in ipairs(hoodAch.Spawns) do
            -- Column 1: completion + name (check status dynamically)
            local isCompleted = false
            if hoodAch.ID > 0 then
                local ach = myAch(hoodAch.ID)
                if ach and ach() then
                    local objective = ach.Objective(spawn.name)
                    if objective and objective() then
                        isCompleted = objective.Completed() or false
                    end
                end
            end

            if isCompleted then
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

            -- Tooltip for PH info
            if ImGui.IsItemHovered() then
                local phList = require("Hunterhood.ph_list")
                local normalizedSpawnName = helpers.normalizeName(spawn.name)
                
                -- Get placeholders for this spawn in the current zone
                local placeholders = phList.getPlaceholders(spawn.name, hoodAch.zoneID)
                
                -- Ensure placeholders is a table
                if not placeholders or type(placeholders) ~= "table" then
                    placeholders = {}
                end
                
                -- If no direct match, try fuzzy matching
                if #placeholders == 0 then
                    local allZoneMobs = phList.getNamedMobsInZone(hoodAch.zoneID)
                    if allZoneMobs and type(allZoneMobs) == "table" then
                        for _, mobName in ipairs(allZoneMobs) do
                            if helpers.normalizeName(mobName):find(helpers.normalizeName(normalizedSpawnName), 1, true)
                                or helpers.normalizeName(normalizedSpawnName):find(helpers.normalizeName(mobName), 1, true) then
                                placeholders = phList.getPlaceholders(mobName, hoodAch.zoneID)
                                if type(placeholders) ~= "table" then
                                    placeholders = {}
                                end
                                break
                            end
                        end
                    end
                end
                
                local spawnedPHs, totalSpawned = {}, 0
                for _, phName in ipairs(placeholders) do
                    if type(phName) == "string" then
                        local count = mq.TLO.SpawnCount("npc " .. phName)() or 0
                        if count > 0 then
                            table.insert(spawnedPHs, { name = phName, count = count })
                            totalSpawned = totalSpawned + count
                        end
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
                            if type(ph) == "string" then
                                ImGui.BulletText(ph)
                            end
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
                lastTab = currentTab
                currentTab = "Hunter"
                RenderTitle()
                if curHunterAch.ID then
                    RenderHunter()
                end
                InfoLine()
                ImGui.EndTabItem()
            end

            -- Hood tab
            if ImGui.BeginTabItem("Hood") then
                lastTab = currentTab
                currentTab = "Hood"
                ImGui.PushStyleColor(ImGuiCol.FrameBg, 0, 0, 0, 1)
                ImGui.PushStyleColor(ImGuiCol.FrameBgHovered, 0.1, 0.1, 0.1, 1)
                ImGui.PushStyleColor(ImGuiCol.FrameBgActive, 0.2, 0.2, 0.2, 1)
                ImGui.PushStyleColor(ImGuiCol.Text, 0.973, 0.741, 0.129, 1)
                ImGui.PushStyleColor(ImGuiCol.Border, 0.973, 0.741, 0.129, 1)
                ImGui.PushStyleColor(ImGuiCol.PopupBg, 0, 0, 0, 0.95)
                ImGui.PushStyleColor(ImGuiCol.HeaderHovered, 0.33, 0.33, 0.33, 0.5)
                ImGui.PushStyleColor(ImGuiCol.HeaderActive, 0.0, 0.66, 0.33, 0.5)
                ImGui.PushStyleVar(ImGuiStyleVar.FrameBorderSize, 1.5)

                renderHoodTab()

                ImGui.PopStyleVar(1)
                ImGui.PopStyleColor(8)

                ImGui.EndTabItem()
            end

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
