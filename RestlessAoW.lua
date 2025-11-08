---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

--handles the duck emote on the group mission and raid as well as the remove weapon emote on the raid.
BL.info("RestlessAoW script v1.0 loaded.")
BL.info("Must have a bandolier set named 'Empty' for the raid remove weapon emote to work.")
BL.warn("untested as of 11-07-2025. Reminder to test when MQ is back up.")

-- Configuration
local BANDO_SWAP_NAME = "Empty"

-- State tracking
local isDucking = false
local lastDuckTime = 0
local DUCK_DURATION = 10000  -- 10 seconds duck duration(might have to change, needs testing)

-- Bandolier functions
local function waitIfCasting()
    while mq.TLO.Me.Casting() do
        mq.delay(100)
    end
end

local function swapToBando()
    waitIfCasting()
    mq.cmdf('/bandolier activate %s', BANDO_SWAP_NAME)
    BL.info("Swapped to %s bandolier", BANDO_SWAP_NAME)
end

local function swapBackBando()
    waitIfCasting()
    mq.cmd('/bandolier activate previous')
    BL.info("Swapped back to previous bandolier")
end

-- Event handlers
local function handleDuckEmote(line)
    if isDucking then return end  -- Already ducking
    if os.clock() * 1000 - lastDuckTime < 15000 then return end  -- Cooldown check
    
    -- Extract names from the emote
    local names = line:match("bend the knee: (.-)%.?%s*$")
    if not names then return end
    
    -- Check if our name is in the list
    local myName = mq.TLO.Me.CleanName()
    for name in names:gmatch("([^,]+)") do
        name = name:match("^%s*(.-)%s*$")
        if name:lower() == myName:lower() then
            isDucking = true
            lastDuckTime = os.clock() * 1000
            
            -- Duck logic
            BL.cmd.pauseAutomation()
            mq.delay(1000)
            if not mq.TLO.Me.Ducking then
                BL.info("Ducking from Avatar's command!")
                mq.cmd('/keypress DUCK')
                mq.delay(500)
            end
            
            -- Set up timer to stand back up
            mq.delay(DUCK_DURATION, function()
                if isDucking then
                    mq.cmd('/keypress DUCK')
                    isDucking = false
                    BL.cmd.resumeAutomation()
                    BL.info("Stopped ducking")
                end
            end)
            break
        end
    end
end

local function handleSwapEmote()
    swapToBando()
    -- Swap back after a 10 second delay (might have to change, needs testing)
    mq.delay(10000, swapBackBando)
end

-- Main event handler
local function eventHandler(line, event)
    if event == "AoWDuck" then
        handleDuckEmote(line)
    elseif event == "AoWSwap" then
        handleSwapEmote()
    end
end

-- Register events
mq.event("AoWDuck", "#*#The ice-encrusted Avatar of War shouts that each of these must bend the knee#*#", eventHandler)
mq.event("AoWSwap", "#*#The rage of Rallos Zek channels through his avatar into#*#", eventHandler)

-- Main loop
while true do
    BL.checkChestSpawn("an_icebound_chest")
    mq.doevents()
    mq.delay(100)
end