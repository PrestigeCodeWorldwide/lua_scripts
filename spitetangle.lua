---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

BL.info("Spitetangle Script v1.12 started")

local myClass = mq.TLO.Me.Class.ShortName()
--local myName = mq.TLO.Me.Name()
local isProcessingStickyWeb = false
local shouldExit = false
local lastDisarmAttempt = 0

-- Command bind for manual stop
mq.bind('/spitestop', function()
    BL.info("Manual stop triggered - will exit after cleanup...")
    shouldExit = true
end)

BL.info("Type /spitestop to stop the script and reload CWTN plugins")

mq.cmdf("/%s usecures on nosave", myClass)
mq.cmdf("/%s memcureall on nosave", myClass)
mq.cmdf("/%s memgroupcureall on nosave", myClass)
mq.cmdf("/%s memsplash off nosave", myClass)
mq.cmdf("/%s usewardaa off nosave", myClass)
mq.cmdf("/%s usesquall off nosave", myClass)
mq.cmdf("/%s usesplash off nosave", myClass)
mq.cmdf("/%s usenatureboon off nosave", myClass)
mq.cmdf("/%s activate cure \"Venenium\"", myClass)
mq.cmdf("/%s activate cure \"Cleansing Rod\"", myClass)
mq.cmdf("/%s activate cure \"Distillate of Antidote XV\"", myClass)

-- Only disable alliance for priests (DRU, CLR, SHM)
if myClass == "DRU" or myClass == "CLR" or myClass == "SHM" then
    mq.cmdf("/%s usealliance off nosave", myClass)
end

-- Non-rogues will loop and monitor for chest spawn or manual stop
if myClass ~= "ROG" then
    BL.info("Not a rogue - monitoring for chest spawn or manual stop...")
    while not shouldExit do
        -- Check if chest has spawned (encounter complete)
        if BL.checkChestSpawn("a_tangled_chest") then
            BL.info("Chest spawned! Encounter complete - ending script...")
            shouldExit = true
            break
        end
        
        mq.delay(1000) -- Check every second
    end
    
    -- Cleanup and reload
    BL.info("Script ending - reloading CWTN plugins...")
    if mq.TLO.CWTN and mq.TLO.CWTN() then
        mq.cmdf("/%s reload", myClass)
    else
        BL.info("No CWTN plugin loaded, skipping reload")
    end
    return
end

-- Sticky Web Rogue Functionality
local function processStickyWeb()
    if myClass ~= "ROG" then
        return false
    end

    -- Find sticky web spawn - only search if we have a reasonable chance of finding one
    local stickyWeb = nil
    local spawnCount = tonumber(mq.TLO.SpawnCount("sticky web")()) or 0  --sticky web
    
    if spawnCount > 0 then
        stickyWeb = mq.TLO.Spawn("sticky web")  --sticky web
    else
        return false
    end
    
    if stickyWeb() then
        BL.info("Found sticky web at distance: " .. stickyWeb.Distance())
        isProcessingStickyWeb = true
        BL.cmd.pauseAutomation()
        -- Navigate to sticky web if not already there
        if stickyWeb.Distance() > 10 then
            BL.info("Moving to sticky web...")
            mq.cmd("/nav id " .. stickyWeb.ID())
            
            -- Wait until we're close enough
            while stickyWeb.Distance() > 10 do
                mq.delay(500)
                if not stickyWeb() then
                    BL.info("Sticky web disappeared!")
                    BL.cmd.resumeAutomation()
                    return false
                end
            end
        end
        
        -- Target the sticky web
        if stickyWeb() then
            mq.cmd("/target id " .. stickyWeb.ID())
            mq.delay(100)
        else
            BL.info("Sticky web disappeared before targeting!")
            BL.cmd.resumeAutomation()
            return false
        end
        -- Use ability 1(Disarm Trap) on sticky web with 5.5 second throttle
        local currentTime = mq.gettime()
        if currentTime - lastDisarmAttempt >= 5500 then
            BL.info("Using ability 1 on sticky web...")
            mq.cmd("/doability 1")
            lastDisarmAttempt = currentTime
            mq.delay(1000)
        else
            BL.info("Disarm attempt throttled - waiting...")
            BL.cmd.resumeAutomation()
            return false
        end
        -- Auto inventory the wad of spider silk
        BL.info("Waiting on wad of spider silk...")
        mq.cmd("/autoinventory")
        mq.delay(300)
        -- Target npc rusher
        BL.info("Targeting npc rusher...")
        mq.cmd("/target npc rusher")  --rusher
        mq.delay(100)
        
        -- Use wad of spider silk item
        if mq.TLO.Target() and mq.TLO.Target.Name():find("rusher") then  --rusher
            -- Navigate to rusher if more than 20 feet away
            if mq.TLO.Target.Distance() > 20 then
                BL.info("Moving to rusher...")
                mq.cmd("/nav spawn rusher") --rusher
                
                -- Wait until we're close enough with timeout
                local navTimeout = mq.gettime() + 10000 -- 10 second timeout
                while mq.TLO.Target.Distance() > 20 do
                    mq.delay(500)
                    if not mq.TLO.Target() then
                        BL.info("Rusher disappeared!")
                        BL.cmd.resumeAutomation()
                        return false
                    end
                    if mq.gettime() > navTimeout then
                        BL.info("Navigation timeout - rusher too far or unreachable!")
                        BL.cmd.resumeAutomation()
                        return false
                    end
                end
            end
            
            BL.info("Using wad of spider silk on rusher...")
            mq.delay(1500) -- 1 second delay after navigation
            mq.cmd("/useitem wad of")  --wad of spider silk
            mq.delay(3500)
            -- Resume automation
            BL.cmd.resumeAutomation()
            return true
        else
            BL.info("Could not find npc rusher target!")
            -- Resume automation
            BL.cmd.resumeAutomation()
            return false
        end
    end
    
    -- Resume automation
    BL.cmd.resumeAutomation()
    return false
end

-- Main loop
while not shouldExit do
    -- Check if chest has spawned (encounter complete)
    if BL.checkChestSpawn("a_tangled_chest") then
        BL.info("Chest spawned! Encounter complete - ending script...")
        shouldExit = true
        break
    end
    
    if processStickyWeb() then
        BL.info("Sticky web cycle completed. Checking for another...")
    end
    mq.delay(100)
end

-- Cleanup and reload
BL.info("Script ending - reloading CWTN plugins...")
if mq.TLO.CWTN and mq.TLO.CWTN() then
    mq.cmdf("/%s reload", myClass)
else
    BL.info("No CWTN plugin loaded, skipping reload")
end
