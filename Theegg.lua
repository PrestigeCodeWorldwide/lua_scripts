---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

BL.info("TheEgg Script v1.14 started")
BL.info("/eggloc to change the run away loc on the fly. /eggstop to stop script and reset plugin settings")

local myClass = mq.TLO.Me.Class.ShortName()
local shouldExit = false
local eggTimer = 0
local eggActive = false
local EGG_DURATION = 15 -- seconds

-- Dynamic run location variables
local runLocationY = 847  -- Default Y coordinate
local runLocationX = -2256 -- Default X coordinate
local runLocationSet = false

-- Command bind for manual stop
mq.bind('/eggstop', function()
    BL.info("Manual stop triggered - will exit after cleanup...")
    shouldExit = true
end)

-- Command bind for announcing current location
mq.bind('/eggloc', function()
    local currentY = mq.TLO.Me.Y()
    local currentX = mq.TLO.Me.X()
    local currentZ = mq.TLO.Me.Z()
    mq.cmdf("/rs NEW RUN LOCATION: Y=%.0f X=%.0f Z=%.0f", currentY, currentX, currentZ)
    BL.info(string.format("Announced current location: Y=%.0f X=%.0f Z=%.0f", currentY, currentX, currentZ))
end)

-- Command bind for checking current location state
mq.bind('/eggstatus', function()
    BL.info(string.format("Location state: Set=%s, Y=%.0f, X=%.0f", tostring(runLocationSet), runLocationY, runLocationX))
end)

-- Command bind for manually setting run location
mq.bind('/eggsetloc', function(y, x)
    if y and x then
        local newY = tonumber(y)
        local newX = tonumber(x)
        if newY and newX then
            runLocationY = newY
            runLocationX = newX
            runLocationSet = true
            BL.info(string.format("Run location manually set to: Y=%.0f X=%.0f", runLocationY, runLocationX))
        else
            BL.info("Invalid coordinates provided")
        end
    else
        BL.info(string.format("Current run location: Y=%.0f X=%.0f", runLocationY, runLocationX))
    end
end)

mq.cmdf("/%s usecures off nosave", myClass)
mq.cmdf("/%s deactivate cure \"Venenium\"", myClass)
mq.cmdf("/%s deactivate cure \"Cleansing Rod\"", myClass)
mq.cmdf("/%s deactivate cure \"Distillate of Antidote XV\"", myClass)



-- Activate egg mode: manual mode + nav to archsage
local function activateEggMode()
    if not eggActive then
        eggActive = true
        eggTimer = mq.gettime()
        
        -- Switch to manual mode
       BL.cmd.ChangeAutomationModeToManual()
        
        -- Navigate to run location (dynamic or default)
        if runLocationSet then
            mq.cmdf("/nav locyx %.0f %.0f", runLocationY, runLocationX)
            BL.info(string.format("Navigating to dynamic run location: Y=%.0f X=%.0f", runLocationY, runLocationX))
        else
            mq.cmd("/nav locyx 847 -2256")
            BL.info("Navigating to default run location: Y=847 X=-2256")
        end
        BL.WaitForNav()
        
        BL.info("Egg mode activated: Manual mode engaged, navigating to archsage spawn")
    end
end

-- Event handler for silk stringer emote
local function event_silk_stringer(line)
    -- Skip our own debug messages to avoid recursion
    if string.find(line, "Silk stringer event triggered") then
        return
    end
    
    BL.info("Silk stringer event triggered for: " .. (line or "nil"))
    
    -- Parse the toon name from the captured line
    local toonName = string.match(line, "(.+) is hit with a silk stringer.")
    
    if toonName then
        -- Check if it's our toon that got hit
        if string.lower(toonName) == string.lower(mq.TLO.Me.Name()) then
            BL.info("Our toon was hit! Activating egg mode")
            activateEggMode()
        else
            BL.info("Not our toon: " .. toonName .. " vs " .. mq.TLO.Me.Name())
        end
    else
        BL.info("Could not parse toon name from: " .. line)
    end
end

-- Check if we should return to chase mode
local function checkEggTimer()
    if eggActive then
        local currentTime = mq.gettime()
        
        if (currentTime - eggTimer) >= (EGG_DURATION * 1000) then
            -- Return to chase mode
            eggActive = false
            BL.cmd.ChangeAutomationModeToChase()
            BL.info("Egg mode deactivated: Returning to chase mode")
        end
    end
end

-- Check for chest spawn
local function checkChestSpawn()
    local chestName = "a_floating_chest"
    if BL.checkChestSpawn(chestName) then
        BL.info("Chest spawned! Encounter complete - ending script...")
        return true
    end
    return false
end

-- Event handler for raid say messages (NEW RUN LOCATION)
local function event_raidsay(line)
    -- Skip our own messages to avoid recursion
    if string.find(line, mq.TLO.Me.Name()) then
        return
    end
    
    -- Find NEW RUN LOCATION anywhere in the message and trim everything before it
    local location_part = string.match(line, ".*NEW RUN LOCATION:(.*)")
    if location_part then
        -- Trim leading whitespace and remove trailing quote
        location_part = string.match(location_part, "^%s*(.*)")
        location_part = string.match(location_part, "(.*)'")
        
        -- Parse Y, X, Z coordinates
        local y, x, z = string.match(location_part, "Y=([%d%.%-]+)%s*X=([%d%.%-]+)%s*Z=([%d%.%-]+)")
        if y and x then
            local newY = tonumber(y)
            local newX = tonumber(x)
            if newY and newX then
                runLocationY = newY
                runLocationX = newX
                runLocationSet = true
                BL.info(string.format("Updated run location: Y=%.0f X=%.0f Z=%.0f", runLocationY, runLocationX, tonumber(z) or 0))
            end
        else
            -- Try parsing without Z coordinate
            local y2, x2 = string.match(location_part, "Y=([%d%.%-]+)%s*X=([%d%.%-]+)")
            if y2 and x2 then
                local newY = tonumber(y2)
                local newX = tonumber(x2)
                if newY and newX then
                    runLocationY = newY
                    runLocationX = newX
                    runLocationSet = true
                    BL.info(string.format("Updated run location: Y=%.0f X=%.0f", runLocationY, runLocationX))
                end
            end
        end
    end
end

-- Register event handlers
mq.event("silk_stringer", "#*# is hit with a silk stringer.", event_silk_stringer)
mq.event("raidsay", "#*# tells the raid, #*#", event_raidsay)

BL.info("Monitoring for silk stringer events")

-- Main loop
while not shouldExit do
    checkEggTimer()
    
    -- Check if chest has spawned (encounter complete)
    if checkChestSpawn() then
        shouldExit = true
        break
    end
    
    mq.doevents()
    mq.delay(100) -- Check every 100ms
end

BL.info("Egg script ended")

-- Cleanup and reload
BL.info("Script ending - reloading CWTN plugins...")
if mq.TLO.CWTN and mq.TLO.CWTN() then
    mq.cmdf("/%s reload", myClass)
else
    BL.info("No CWTN plugin loaded, skipping reload")
end
