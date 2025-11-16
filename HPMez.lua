---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

BL.info("HPMez Script v1.2 Started")

local isPaused = false
local messengerType = "messenger"
local stateFile = mq.TLO.MacroQuest.Path() .. "\\logs\\hpraid_state.txt"

-- Function to check if HPRaid is currently handling debuffs
local function isHPRaidActive()
    local file = io.open(stateFile, "r")
    if file then
        local content = file:read("*line")
        file:close()
        return content == "DEBUFF_ACTIVE"
    end
    return false
end

-- Calculate distance using Pythagorean theorem
local function calculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx*dx + dy*dy)
end

local function doMezEnc()
    -- Check if HPRaid is handling debuffs - if so, skip mezzing
    if isHPRaidActive() then
        BL.info("HPRaid is handling debuffs, pausing mez activity")
        if not isPaused then
            isPaused = true
            BL.cmd.pauseAutomation()
        end
        return
    end
    
    --BL.info("Starting doMezEnc function")
    
    local highPriest = mq.TLO.Spawn("Yaran")
    if not highPriest() or highPriest.ID() == 0 then
        BL.info("High Priest not found")
        if isPaused then
            isPaused = false
            BL.cmd.resumeAutomation()
        end
        return
    end

    -- Get High Priest coordinates once
    local hpY = tonumber(highPriest.Y())
    local hpX = tonumber(highPriest.X())
    if not (hpY and hpX) then
        BL.info("Failed to get High Priest coordinates")
        return
    end

    -- Find all messenger and track the closest one within range
    local closestMessenger = nil
    local minDistance = 200  -- Only consider messenger within 200 units
    local messengerCount = tonumber(mq.TLO.SpawnCount(messengerType)()) or 0
    
    --BL.info(string.format("Found %d messenger in zone", messengerCount))
    
    for i = 1, messengerCount do
        local messenger = mq.TLO.NearestSpawn(i, messengerType)
        if messenger() and messenger.ID() ~= 0 then
            -- Get messenger coordinates
            local messengerY = tonumber(messenger.Y())
            local messengerX = tonumber(messenger.X())
            
            if messengerY and messengerX then
                local distance = calculateDistance(hpX, hpY, messengerX, messengerY)
                BL.info(string.format("messenger %s distance: %.1f", messenger.ID(), distance))
                
                -- Track the closest messenger within range
                if distance <= 200 and distance < minDistance then
                    minDistance = distance
                    closestMessenger = messenger
                end
            end
        end
    end

    -- Process the closest messenger if found
    if closestMessenger then
        BL.info(string.format("Found messenger %s at %.1f distance", closestMessenger.ID(), minDistance))
        
        -- Target the messenger if not already targeted
        if mq.TLO.Target.ID() ~= closestMessenger.ID() then
            closestMessenger.DoTarget()
            mq.delay(100)
        end

        -- Check if we have line of sight and are in range to cast
        if closestMessenger.Distance() < 190 and closestMessenger.LineOfSight() then
            BL.info("messenger is in range, casting slumber")
            BL.cmd.pauseAutomation()
            isPaused = true
            mq.cmd("/stopsong")
            mq.delay(100)
            mq.cmd("/cast slumber of suja")      
            mq.delay(3400)
            return  -- Exit after casting to avoid multiple casts in one cycle
        elseif closestMessenger.Distance() > 150 or not closestMessenger.LineOfSight() then
            BL.info("Moving closer to messenger")
            mq.cmdf("/nav id %d", closestMessenger.ID())
        end
    else
        if isPaused then
            isPaused = false
            BL.cmd.resumeAutomation()
        end
        BL.info("No messengers in range (max 200 units)")
    end
end

local args = {...}
if #args > 0 then
    messengerType = args[1]:gsub("^%s*(.-)%s*$", "%1")  -- Trim whitespace
    BL.info(string.format("Using messenger type: %s", messengerType))
end

-- Main loop
while true do
    doMezEnc()
    mq.delay(1000)  -- Check every second
end