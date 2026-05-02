--v1.0
---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")
---@type ImGui
local imgui = require("ImGui")

-- Epic items configuration (using correct IDs)
local epics = {
    {
        id = 77640, -- Blade of Vesagran
        name = "Blade of Vesagran",
        class = "Bard",
        enabled = true, -- Auto-enabled on startup
        lastUsed = 0
    },
    {
        id = 57405, -- Blessed Spiritstaff of the Heyokah
        name = "Blessed Spiritstaff of the Heyokah",
        class = "Shaman", 
        enabled = true, -- Auto-enabled on startup
        lastUsed = 0
    }
}

-- Local variables for epics functionality
local autoCheckTimer = 0
local debugTimer = 0
local statusUpdateTimer = 0
local cachedStatus = {}

-- Helper functions
local function useEpicItem(itemID, itemName)
    -- Check if we're casting, but allow bard songs
    local isCasting = mq.TLO.Me.Casting()
    local class = mq.TLO.Me.Class()
    
    if isCasting and class ~= "Bard" then
        BL.info("Already casting, cannot use epic: " .. itemName)
        return
    end
    
    -- Bards can use items while singing songs, so allow epic usage for bards
    if isCasting and class == "Bard" then
        -- Allow bards to use epics while singing (they can do this)
        BL.info("Bard using epic while singing: " .. itemName)
    end
    
    -- Use name for activation (ID finds the right item but name works better for /useitem)
    mq.cmdf("/useitem \"%s\"", itemName)
    BL.info("Using epic: " .. itemName)
    -- Cannot use delay in ImGui callback - remove it
end

local function isEpicAvailable(itemID)
    local find = mq.TLO.FindItem(itemID)()
    local available = find ~= nil
    return available
end

local function isEpicReady(itemID, itemName)
    -- Use item ID for reliable detection
    local find = mq.TLO.FindItem(itemID)
    if not find then
        return false
    end
    
    -- Try both ID-based and name-based ItemReady checks
    local readyByID = mq.TLO.Me.ItemReady(itemID)()
    local readyByName = mq.TLO.Me.ItemReady(itemName)()
    
    -- Use only ID-based result for UI (name-based finds ornament)
    return readyByID
end

-- Function to update cached status periodically
local function updateCachedStatus()
    if os.time() - statusUpdateTimer >= 2 then -- Update every 2 seconds
        for _, epic in ipairs(epics) do
            local available = isEpicAvailable(epic.id)
            local ready = isEpicReady(epic.id, epic.name)
            cachedStatus[epic.id] = {
                available = available,
                ready = ready,
                timestamp = os.time()
            }
        end
        statusUpdateTimer = os.time()
    end
end

-- Function to get cached status
local function getCachedStatus(itemID)
    local status = cachedStatus[itemID]
    if status and (os.time() - status.timestamp < 5) then -- Cache for 5 seconds
        return status.available, status.ready
    end
    return nil, nil
end

local function hasHostileXTarget()
    -- Check if we have hostile NPCs on XTarget
    if mq.TLO.Me.XTarget() == 0 then return false end
    
    for i = 1, 13 do -- XTarget has 13 slots
        local xtarget = mq.TLO.Me.XTarget(i)
        if xtarget() then
            local targetType = xtarget.Type()
            local targetSubType = xtarget.TargetType()
            
            -- Check if it's an NPC and hostile (Auto Hater)
            if targetType == "NPC" and targetSubType == "Auto Hater" then
                return true
            end
        end
    end
    
    return false
end

local function autoUseEpics()
    -- Only auto-use if we have hostile NPCs on XTarget
    local hasHostile = hasHostileXTarget()
    if not hasHostile then
        return
    end
    
    for _, epic in ipairs(epics) do
        if epic.enabled then
            if isEpicAvailable(epic.id) and isEpicReady(epic.id, epic.name) then
                useEpicItem(epic.id, epic.name)
                epic.lastUsed = os.time()
            end
        end
    end
end

-- Main epics tab drawing function
local function drawEpicsTab()
    -- Update cached status periodically
    updateCachedStatus()
    
    imgui.Text("Epic Items Auto-Use Manager")
    imgui.Separator()
    
    for i, epic in ipairs(epics) do
        imgui.PushID(i)
        
        -- Checkbox for auto-use (using raidprep pattern)
        local varName = "epic_" .. epic.id
        _G[varName] = _G[varName] or epic.enabled
        local checked, changed = imgui.Checkbox("##auto", _G[varName])
        _G[varName] = checked
        
        if changed then
            epic.enabled = checked
            BL.info(string.format("Auto-use for %s: %s", epic.name, checked and "ON" or "OFF"))
        end
        
        -- Same line positioning
        imgui.SameLine()
        
        -- Epic info and use button (class only)
        imgui.Text(string.format("%s", epic.class))
        imgui.SameLine()
        
        -- Use button
        if imgui.Button("Use##use") then
            useEpicItem(epic.id, epic.name)
        end
        
        -- Status indicator with timer
        imgui.SameLine()
        -- Use cached status instead of expensive checks
        local available, ready = getCachedStatus(epic.id)
        
        if available and ready then
            imgui.TextColored(0, 1, 0, 1, "Ready")
        elseif available then
            -- Get current timer for display
            local find = mq.TLO.FindItem(epic.id)
            local timer = find and find.TimerReady() or 0
            imgui.TextColored(1, 1, 0, 1, string.format("Cooldown (%ds)", timer))
        else
            imgui.TextColored(1, 0, 0, 1, "Not Found")
        end
        
        imgui.PopID()
    end
    
    imgui.Separator()
    
    -- Auto-use status
    local autoEnabled = false
    for _, epic in ipairs(epics) do
        if epic.enabled then
            autoEnabled = true
            break
        end
    end
    
    if autoEnabled then
        imgui.TextColored(0, 1, 0, 1, "Auto-use: Active")
    else
        imgui.TextColored(0.5, 0.5, 0.5, 1, "Auto-use: Disabled")
    end
end

-- Auto-use loop function (called from main raidprep loop)
local function updateEpics()
    -- Auto-use check every 2 seconds
    if os.time() - autoCheckTimer >= 2 then
        autoUseEpics()
        autoCheckTimer = os.time()
    end
end

-- Export functions for raidprep integration
return {
    drawEpicsTab = drawEpicsTab,
    updateEpics = updateEpics,
    saveEpicsSettings = function(settings)
        -- Save epic enabled states
        for _, epic in ipairs(epics) do
            settings["epic_" .. epic.id .. "_enabled"] = epic.enabled
        end
    end,
    loadEpicsSettings = function(settings)
        -- Load epic enabled states
        for _, epic in ipairs(epics) do
            local key = "epic_" .. epic.id .. "_enabled"
            if settings[key] ~= nil then
                epic.enabled = settings[key]
                _G["epic_" .. epic.id] = settings[key]
            end
        end
    end
}
