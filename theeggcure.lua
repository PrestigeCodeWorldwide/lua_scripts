---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

BL.info("TheEggCure Script v1.1 started")

-- Configuration
local DEBUFF_NAME = "Incipient Poison" -- Incipient Poison
local CURE_SPELL = "Eradicate Poison" -- Eradicate Poison
local EMOTE_PATTERN = "#*#Tallongast injects incipient poison into #1#, #2#, and #3#.#*#"

-- State variables
local cureTargets = {}
local isProcessing = false

-- Function to extract toon names from emote
local function parseEmote(emoteText)
    local name1, name2, name3 = string.match(emoteText, EMOTE_PATTERN)
    if name1 and name2 and name3 then
        return {name1, name2, name3}
    end
    return nil
end

-- Function to target a toon
local function targetToon(toonName)
    BL.info("Targeting: " .. toonName)
    
    -- Try exact name first
    local spawn = mq.TLO.Spawn(toonName)
    local actualTargetName = toonName
    
    -- If spawn exists, get its actual name for targeting
    if spawn() then
        actualTargetName = spawn.Name()
    else
        -- Try variations for dummies
        local baseName = string.match(toonName, "Combat Dummy (.+)")
        if baseName then
            local variations = {
                "Combat_Dummy_" .. baseName .. "00",
                "Combat_Dummy_" .. baseName .. "01", 
                "Combat_Dummy_" .. baseName,
                baseName
            }
            
            for _, variant in ipairs(variations) do
                spawn = mq.TLO.Spawn(variant)
                if spawn() then
                    actualTargetName = variant
                    break
                end
            end
        end
    end
    
    if not spawn() then
        BL.warn("Spawn not found for: " .. toonName)
        return false
    end
    
    -- Target the found spawn
    mq.cmdf("/target %s", actualTargetName)
    
    -- Wait and verify targeting (with safety check)
    local targetTimeout = 0
    while targetTimeout < 10 do -- Max 1 second
        mq.delay(100)
        if mq.TLO.Target.Name() == actualTargetName then
            BL.info("Successfully targeted: " .. actualTargetName)
            return true
        end
        targetTimeout = targetTimeout + 1
    end
    
    BL.warn("Failed to target: " .. actualTargetName)
    return false
end

-- Function to check if target has the debuff
local function hasDebuff()
    for i = 1, 47 do
        local buffName = mq.TLO.Target.Buff(i).Name()
        if buffName and string.find(buffName, DEBUFF_NAME, 1, true) then
            return true
        end
    end
    return false
end

-- Function to cast cure until debuff is gone
local function cureTarget(targetName)
    BL.info("Curing " .. targetName .. " until debuff is gone")
    
    local maxAttempts = 3 -- Safety limit to prevent infinite loop
    local attempts = 0
    
    while hasDebuff() and attempts < maxAttempts do
        attempts = attempts + 1
        BL.info("Cure attempt " .. attempts .. " for " .. targetName)
        
        -- Check if spell is ready
        if not mq.TLO.Me.SpellReady(CURE_SPELL)() then
            BL.info("Waiting for spell to be ready...")
            for i = 1, 10 do -- Wait max 10 seconds for spell
                mq.delay(1000)
                if mq.TLO.Me.SpellReady(CURE_SPELL)() then
                    break
                end
                if i == 10 then
                    BL.warn("Spell not ready after 10 seconds, skipping " .. targetName)
                    return
                end
            end
        end
        
        -- Cast the cure
        BL.info("Casting " .. CURE_SPELL)
        mq.cmdf("/cast %s", CURE_SPELL)
        
        -- Wait for casting to complete (with timeout)
        local castingTimeout = 0
        while mq.TLO.Me.Casting() and castingTimeout < 50 do -- Max 5 seconds
            mq.delay(100)
            castingTimeout = castingTimeout + 1
        end
        
        if castingTimeout >= 50 then
            BL.warn("Casting timeout for " .. targetName)
            return
        end
        
        -- Brief delay before checking again
        mq.delay(500)
    end
    
    if attempts >= maxAttempts then
        BL.warn("Max cure attempts reached for " .. targetName)
    else
        BL.info("Debuff cured on " .. targetName)
    end
end

-- Function to process all three targets
local function processTargets()
    if isProcessing then
        return
    end
    
    isProcessing = true
    BL.cmd.pauseAutomation()
    
    BL.info("Processing targets: " .. cureTargets[1] .. ", " .. cureTargets[2] .. ", " .. cureTargets[3])
    
    for _, targetName in ipairs(cureTargets) do
        BL.info("Processing: " .. targetName)
        
        -- Target the person
        if targetToon(targetName) then
            -- Wait 1 second for targeting to stabilize
            mq.delay(1000)
            
            -- Check if they have the debuff
            if hasDebuff() then
                BL.info(targetName .. " has debuff, curing...")
                cureTarget(targetName)
            else
                BL.info(targetName .. " does not have debuff")
            end
        else
            BL.warn("Could not target: " .. targetName)
        end
        
        -- Clear target before moving to next
        mq.cmd("/target clear")
        mq.delay(200)
    end
    
    -- Reset for next emote
    cureTargets = {}
    isProcessing = false
    BL.cmd.resumeAutomation()
    BL.info("Target processing complete")
end

-- Event handler for emote
local function onEmote(text, name1, name2, name3)
    if name1 and name2 and name3 then
        -- Only process if we're not already processing and targets list is empty
        if isProcessing or #cureTargets > 0 then
            BL.info("Emote detected but already processing, ignoring")
            return
        end
        
        BL.info("Detected cure emote: " .. text)
        BL.info("Targets to cure: " .. name1 .. ", " .. name2 .. ", " .. name3)
        
        cureTargets = {name1, name2, name3}
        
        -- Start processing after brief delay
        mq.delay(1000)
        processTargets()
    else
        BL.warn("Pattern matched but names were not captured properly")
    end
end

-- Register event handler
mq.event("tallongast_emote", EMOTE_PATTERN, onEmote)

BL.info("Waiting for emote: 'Tallongast injects incipient poison into...'")
BL.info("Debuff to check: " .. DEBUFF_NAME)
BL.info("Cure spell: " .. CURE_SPELL)

-- Main loop
while true do
    mq.doevents()
    mq.delay(500)
end