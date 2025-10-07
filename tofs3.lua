--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("TOFS3 Script v 1.1 Started")
-- Personal Trigger emote(doesn't appear to work): The mirror takes your image
-- Everyone sees: The mirror image that resembles Choppaah flashes a terrifying toothy grin.
local triggerPhrase = "#*#The mirror image that resembles " .. mq.TLO.Me.CleanName() .. " flashes a terrifying toothy grin#*#"

local function findMatchingReflection()
    local myRace = mq.TLO.Me.Race()
    for i = 0, 6 do
        local mobName = string.format("A_shadow_reflection%02d", i) --A_shadow_reflection%02d
        if mq.TLO.Spawn("npc "..mobName).Race.Name() == myRace then
            return i
        end
    end
    return -1
end

local function handleRunEvent()
    BL.info('I was called out. Finding matching reflection...')
    
    -- First announce the race immediately
    local raceMessage = "I am a " .. mq.TLO.Me.Race()
    mq.cmd("/rs " .. raceMessage)
    
    -- Then find and announce the reflection after a delay
    mq.delay(5000) -- 5000ms = 5 seconds
    
    local reflectionNum = findMatchingReflection()
    if reflectionNum >= 0 then
        local reflectionMessage = string.format("My reflection is A_shadow_reflection%02d", reflectionNum) --A_shadow_reflection%02d
        BL.info(reflectionMessage)
        mq.cmd("/rs " .. reflectionMessage)
    else
        BL.info("Could not find matching reflection!")
        mq.cmd("/rs Could not find my reflection!")
    end
end

mq.event("myrace", triggerPhrase, handleRunEvent)

while true do
    mq.doevents()
    mq.delay(250)
end
