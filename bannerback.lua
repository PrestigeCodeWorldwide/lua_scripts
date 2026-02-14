---@type Mq
local mq = require('mq')
---@type BL
local BL = require("biggerlib")
local imgui = require 'ImGui'

BL.info("Bannerback Script v1.23 Started")

-- UI State
local ui_open = true
local script_paused = false
local current_step = "Initializing..."
local last_action = "None"
local portal_countdown = 0

local zonedIn = false
local zoneName = nil

-- UI Rendering function
local function drawUI()
    if not ui_open then return end
    
    local should_show, show = imgui.Begin('Bannerback Script', ui_open, bit32.bor(ImGuiWindowFlags.AlwaysAutoResize, ImGuiWindowFlags.NoTitleBar))
    ui_open = show
    
    if should_show then
        -- Pause/Unpause toggle button
        local button_text = script_paused and "Resume" or "Pause"
        if imgui.Button(button_text) then
            script_paused = not script_paused
            if script_paused then
                BL.info("Script paused by user")
                last_action = "Paused"
            else
                BL.info("Script resumed by user")
                last_action = "Resumed"
            end
        end
        if imgui.IsItemClicked(1) then -- Right click
            if script_paused then
                mq.cmd("/dga /bannerback_resume")
            else
                mq.cmd("/dga /bannerback_pause")
            end
        end
        if imgui.IsItemHovered() then
            imgui.SetTooltip("Left: Normal | Right: Broadcast to all toons")
        end
        
        imgui.SameLine()
        if imgui.Button("END") then
            BL.info("Bannerback Script terminated by user")
            mq.exit()
        end
        if imgui.IsItemClicked(1) then -- Right click
            mq.cmd("/dga /lua stop bannerback")
        end
        if imgui.IsItemHovered() then
            imgui.SetTooltip("Left: Normal | Right: Broadcast to all toons")
        end
        
        -- Status information
        imgui.Text("Status: " .. (script_paused and "PAUSED" or "RUNNING"))
        local step_text = current_step
        if portal_countdown > 0 then
            step_text = step_text .. " (" .. portal_countdown .. ")"
        end
        imgui.Text("Step: " .. step_text)
        imgui.Text("Zone: " .. (mq.TLO.Zone.ShortName() or "Unknown"))
    end
    
    imgui.End()
end

-- Bind ImGui rendering
mq.imgui.init('Bannerback', drawUI)

-- Add command to toggle UI
mq.bind('/bannerback_show', function()
    ui_open = not ui_open
    if ui_open then
        BL.info("Bannerback UI opened")
    else
        BL.info("Bannerback UI closed")
    end
end)

-- Add command to pause script
mq.bind('/bannerback_pause', function()
    script_paused = true
    last_action = "Paused by command"
    BL.info("Bannerback Script paused by command")
end)

-- Add command to resume script
mq.bind('/bannerback_resume', function()
    script_paused = false
    last_action = "Resumed by command"
    BL.info("Bannerback Script resumed by command")
end)

local function handleGuildHallPortal()
    current_step = "Nav to GH portal..."
    BL.info("Navigating to portal location in Guild Hall...")
    BL.cmd.pauseAutomation()
    mq.cmd("/nav locxy 162 -5")
    BL.WaitForNav()
    mq.delay(1000)
    BL.cmd.resumeAutomation()
    
    -- Countdown before clicking portal
    current_step = "Clicking Yes in"
    portal_countdown = 7
    for i = portal_countdown, 1, -1 do
        portal_countdown = i
        mq.delay(1000)
    end
    portal_countdown = 0
    
    BL.info("Clicking Yes in 7 seconds.")
    mq.cmd("/yes")
    
    return true
end

local function handlePlaneOfKnowledge()
    current_step = "/travelto guild lobby..."
    BL.info("In Plane of Knowledge - traveling to Guild Lobby...")
    BL.cmd.pauseAutomation()
    mq.cmd("/travelto guild lobby")
    
    -- Wait for zoning to complete
    local startTime = os.clock()
    local timeout = 30
    while mq.TLO.Zone.ShortName() ~= 'guildlobby' and os.clock() - startTime < timeout do
        mq.delay(500)
    end
    
    if mq.TLO.Zone.ShortName() == 'guildlobby' then
        BL.info("Successfully arrived at Guild Lobby")
        BL.cmd.resumeAutomation()
        return true
    else
        BL.warn("Failed to travel to Guild Lobby within timeout")
        BL.cmd.resumeAutomation()
        return false
    end
end

local function handleEastFreeport()
    current_step = "Handling East Freeport transport..."
    BL.info("In East Freeport - checking transport options...")
    
    -- Check for Primary Anchor Transport Device
    local primaryAnchor = mq.TLO.FindItem("Primary Anchor Transport Device")
    local primaryReady = primaryAnchor and primaryAnchor.TimerReady() == 0
    
    -- Check for Secondary Anchor Transport Device  
    local secondaryAnchor = mq.TLO.FindItem("Secondary Anchor Transport Device")
    local secondaryReady = secondaryAnchor and secondaryAnchor.TimerReady() == 0
    
    if primaryReady then
        BL.info("Primary Anchor Transport Device is ready - using to return to Guild Hall")
        BL.cmd.pauseAutomation()
        mq.cmd('/useitem "Primary Anchor Transport Device"')
        BL.cmd.resumeAutomation()
        return true
    elseif secondaryReady then
        BL.info("Secondary Anchor Transport Device is ready - using to return to Guild Hall")
        BL.cmd.pauseAutomation()
        mq.cmd('/useitem "Secondary Anchor Transport Device"')
        BL.cmd.resumeAutomation()
        return true
    else
        -- Check for Throne of Heroes AA as fallback
        local throneReady = mq.TLO.Me.AltAbilityReady(511)
        --BL.info("Throne of Heroes debug - AltAbilityReady value: " .. tostring(throneReady))
        
        if throneReady == true then
            BL.info("Both anchors on cooldown, using Throne of Heroes AA to return to Guild Lobby")
            BL.cmd.pauseAutomation()
            mq.cmd('/alt act 511')
            BL.cmd.resumeAutomation()
            return true
        else
            -- Check for Philter of Major Translocation as final fallback
            local philter = mq.TLO.FindItem("Philter of Major Translocation")
            local philterReady = philter and philter.TimerReady() == 0
            
            if philterReady then
                BL.info("All previous options on cooldown, using Philter of Major Translocation")
                BL.cmd.pauseAutomation()
                mq.cmd('/useitem "Philter of Major Translocation"')
                BL.cmd.resumeAutomation()
                return true
            else
                BL.warn("All transport options (Primary Anchor, Secondary Anchor, Throne of Heroes, Philter) are on cooldown")
                return false
            end
        end
    end
end

local function zoneToGuildHall()
    current_step = "Zoning to GH..."
    zonedIn = false
    local currentZone = mq.TLO.Zone.ShortName()
    if currentZone ~= 'guildlobby' then
        BL.info("Not in the Guild Lobby. Current zone: " .. (currentZone or "unknown"))
        return false
    end

    BL.info("In Guild Lobby. Navigating to Guild Hall door...")
    BL.cmd.pauseAutomation()
    BL.cmd.StandIfFeigned()
    BL.cmd.removeZerkerRootDisc()
    mq.cmd('/nav door id 1')
    BL.WaitForNav()
    mq.delay(1000)

    BL.info("Clicking door to zone into Guild Hall...")
    mq.cmd('/doortarget')
    mq.delay(1000)
    mq.cmd('/click left door')

    local startTime = os.clock()
    local timeout = 45
    local initialZone = mq.TLO.Zone.ShortName()

    while not zonedIn and os.clock() - startTime < timeout do
        local currentZoneCheck = mq.TLO.Zone.ShortName()
        if currentZoneCheck and currentZoneCheck ~= initialZone and currentZoneCheck == 'guildhall3_int' then
            zonedIn = true
            zoneName = currentZoneCheck
            BL.info("Zoned into: " .. zoneName)
            break
        end
        mq.delay(250)
    end

    if zonedIn then
        BL.info("Successfully zoned into the Guild Hall.")
        mq.delay(1500)
        return handleGuildHallPortal()
    else
        BL.warn("Failed to detect zoning within " .. timeout .. " seconds.")
        return false
    end
end

-- 🔁 Continuous check loop
while true do
    -- Check if script is paused
    if script_paused then
        mq.delay(100) -- Small delay when paused to prevent high CPU usage
        current_step = "Script paused"
        goto continue
    end
    
    local currentZone = mq.TLO.Zone.ShortName()
    if currentZone == 'freeporteast' then
        local success = handleEastFreeport()
        if success then
            -- Wait 3 seconds before checking again (will detect guildhall3_int next)
            mq.delay(3000)
        else
            -- All options on cooldown, wait longer before retrying
            mq.delay(10000) -- 30 seconds
        end
    elseif currentZone == 'poknowledge' then
        local success = handlePlaneOfKnowledge()
        if success then
            -- Wait 3 seconds before checking again (will detect guildlobby next)
            mq.delay(3000)
        end
    elseif currentZone == 'guildlobby' then
        local success = zoneToGuildHall()
        if success then
            -- Wait 10 seconds before checking again to avoid spamming
            mq.delay(10000)
        end
    elseif currentZone == 'guildhall3_int' then
        local success = handleGuildHallPortal()
        if success then
            -- Wait 10 seconds before checking again to avoid spamming
            mq.delay(10000)
        end
    else
        -- Not in target zones, recheck every 5 seconds
        current_step = "Waiting for target zone..."
        mq.delay(5000)
    end
    
    ::continue::
end
