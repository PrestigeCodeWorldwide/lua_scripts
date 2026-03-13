---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

BL.info("Spitetangle Script v1.0 started")

local myClass = mq.TLO.Me.Class.ShortName()
local myName = mq.TLO.Me.Name()
local isProcessingStickyWeb = false
local isHandlingPoisonWeave = false
local shouldExit = false

-- Command bind for manual stop
mq.bind('/spitestop', function()
    BL.info("Manual stop triggered - will exit after cleanup...")
    shouldExit = true
end)

BL.info("Type /spitestop to stop the script and reload CWTN plugins")

mq.cmdf("/%s byos off nosave", myClass)
mq.cmdf("/%s memsplash off nosave", myClass)
mq.cmdf("/%s usewardaa off nosave", myClass)
mq.cmdf("/%s usesquall off nosave", myClass)
mq.cmdf("/%s usesplash off nosave", myClass)
mq.cmdf("/%s usenatureboon off nosave", myClass)

-- Only disable alliance for priests (DRU, CLR, SHM)
if myClass == "DRU" or myClass == "CLR" or myClass == "SHM" then
    mq.cmdf("/%s usealliance off nosave", myClass)
end

-- Poison weave event handler (takes priority over sticky web)
local function handlePoisonWeave(emoteText)
    -- Prevent multiple simultaneous executions
    if isHandlingPoisonWeave then
        return
    end
    
    -- Only process if we have valid emote text
    if not emoteText or emoteText == "" then
        return
    end
    
    -- Check if the emote contains our character name
    if emoteText:find(myName, 1, true) then
        isHandlingPoisonWeave = true
        
        if isProcessingStickyWeb then
            BL.info("Poison weave detected during sticky web processing - interrupting!")
        else
            BL.info("Poison weave detected on " .. myName .. " - pausing automation")
        end
        
        BL.cmd.ChangeAutomationModeToManual()
        
        -- Target self
        mq.cmd("/target " .. myName)
        mq.delay(500)
        
        BL.info("Waiting 15 seconds for poison weave to complete...")
        mq.delay(15000)
        
        BL.info("Resuming automation after poison weave")
        BL.cmd.ChangeAutomationModeToChase()
        
        -- Reset flags
        isProcessingStickyWeb = false
        isHandlingPoisonWeave = false
    end
end

-- Register event handler for poison weave emote (affects all classes)
-- Pattern matches the exact emote text or variations for testing
mq.event('poisonWeave', "#*#The Spitetangle weaves poison around #1#", handlePoisonWeave)

-- Only rogues should process sticky webs
if myClass ~= "ROG" then
    BL.info("Not a rogue - only monitoring poison weave emotes")
    -- Keep script running for poison weave handling
    while not shouldExit do
        mq.delay(1000)
        mq.doevents() -- Process any events
    end
    
    -- Cleanup and reload
    BL.info("Manual stop detected - reloading and exiting...")
    if mq.TLO.CWTN and mq.TLO.CWTN() then
        mq.cmdf("/%s reload", myClass)
    else
        BL.info("No CWTN plugin loaded, skipping reload")
    end
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
                mq.doevents() -- Check for poison weave during navigation
                mq.delay(500)
                if not stickyWeb() then
                    BL.info("Sticky web disappeared!")
                    -- Resume automation
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
        -- Use ability 1(Disarm Trap) on sticky web
        BL.info("Using ability 1 on sticky web...")
        mq.cmd("/doability 1")
        mq.delay(1000)
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
            BL.info("Using wad of spider silk on rusher...")
            mq.cmd("/useitem wad of")  --wad of spider silk
            mq.delay(200)
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
    if BL.checkChestSpawn("spitetangle_chest_placeholder") then
        BL.info("Chest spawned! Encounter complete - ending script...")
        shouldExit = true
        break
    end
    
    mq.doevents() -- Process events immediately at start of loop
    if myClass == "ROG" then
        if processStickyWeb() then
            BL.info("Sticky web cycle completed. Checking for another...")
        end
        mq.delay(100)
    else
        mq.delay(500)
    end
end

-- Cleanup and reload
BL.info("Script ending - reloading CWTN plugins...")
if mq.TLO.CWTN and mq.TLO.CWTN() then
    mq.cmdf("/%s reload", myClass)
else
    BL.info("No CWTN plugin loaded, skipping reload")
end
