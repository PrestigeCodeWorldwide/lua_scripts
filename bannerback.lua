---@type Mq
local mq = require('mq')
---@type BL
local BL = require("biggerlib")

BL.info("Bannerback Script v1.2 Started")

local zonedIn = false
local zoneName = nil

-- Event handler for zoning message
mq.event("ZoneConfirm", "You have entered The Cult of Personality Village, 200 Guild Way, Modest Guild Hall.", function(z)
    zonedIn = true
    zoneName = z
    BL.info("Zoned into: " .. z)
end)

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
        if currentZoneCheck and currentZoneCheck ~= initialZone then
            zonedIn = true
            zoneName = currentZoneCheck
            BL.info("Zoned into (fallback): " .. zoneName)
            break
        end
        mq.delay(250)
    end

    if zonedIn then
        BL.info("Successfully zoned into the Guild Hall.")
        mq.delay(1500)
        mq.cmd("/nav locxy 162 -5")
        BL.WaitForNav()
        mq.delay(1000)
        BL.cmd.resumeAutomation()
        mq.delay(6500)
        BL.info("Clicking yes to portal.")
        mq.cmd("/yes")
        return true
    else
        BL.warn("Failed to detect zoning within " .. timeout .. " seconds.")
        return false
    end
end

-- 🔁 Continuous check loop
while true do
    if mq.TLO.Zone.ShortName() == 'guildlobby' then
        local success = zoneToGuildHall()
        if success then
            -- Wait 10 seconds before checking again to avoid spamming
            mq.delay(10000)
        end
    else
        -- Not in Guild Lobby, recheck every 5 seconds
        mq.delay(5000)
    end
end
