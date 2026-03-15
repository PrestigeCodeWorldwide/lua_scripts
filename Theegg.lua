---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

BL.info("TheEgg Script v1.11 started")

local myClass = mq.TLO.Me.Class.ShortName()
local shouldExit = false
local eggTimer = 0
local eggActive = false
local EGG_DURATION = 15 -- seconds

-- Command bind for manual stop
mq.bind('/eggstop', function()
    BL.info("Manual stop triggered - will exit after cleanup...")
    shouldExit = true
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
        
        -- Navigate to archsage spawn location
        -- You may need to adjust the coordinates based on your zone
        mq.cmd("/nav spawn archsage")
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
    -- TODO: Replace with actual chest name
    local chestName = "a_tangled_chest" -- Placeholder from spiteangle.lua
    if BL.checkChestSpawn(chestName) then
        BL.info("Chest spawned! Encounter complete - ending script...")
        return true
    end
    return false
end

-- Register event handler for silk stringer emote
mq.event("silk_stringer", "#*# is hit with a silk stringer.", event_silk_stringer)

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
