---@type Mq
local mq = require('mq')
---@type BL
local BL = require("biggerlib")

BL.info("Bannerback Script v1.22 Started")

local zonedIn = false
local zoneName = nil

local function handleGuildHallPortal()
    BL.info("Navigating to portal location in Guild Hall...")
    BL.cmd.pauseAutomation()
    mq.cmd("/nav locxy 162 -5")
    BL.WaitForNav()
    mq.delay(1000)
    BL.cmd.resumeAutomation()
    mq.delay(6500)
    BL.info("Clicking yes to portal.")
    mq.cmd("/yes")
    return true
end

local function handlePlaneOfKnowledge()
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
        mq.delay(5000)
    end
end
