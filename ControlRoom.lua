---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')

BL.info("ControlRoom Script v1.44 Started")
BL.info("Type /crstop to stop the script and connect Dannet/BCS")

mq.cmd("/bccmd quit")
mq.cmd("/plugin dannet unload")
mq.cmd("/plugin boxr load")

--Strategy Info
mq.cmd("/rs Callouts at: 70%, 63%, 56%, 49%, 35%, 28%, 21%, 7%")
mq.cmd("/rs Two Adds at 90%, 80%, 71%, 62%, 51%, 44%, 35%, 26%, 17%, 8%. ")

local shouldExit = false
local lastSayTime = 0  -- Track last time we said something
local SAY_COOLDOWN = 47  -- 47 second cooldown
local queuedPhrase = nil  -- Track phrase waiting to be said
local queuedFunction = nil  -- Track function waiting to be executed

local function StopControlRoom()
    mq.cmd("/plugin dannet load")
    mq.cmd("/bccmd connect")
    BL.info("Control Room script stopped by command")
    return true
end

mq.bind('/crstop', function()
    shouldExit = true
    StopControlRoom()
end)

local function executeQueuedPhrase()
    if queuedFunction then
        BL.info(string.format("Executing queued phrase: %s", queuedPhrase))
        queuedFunction()
        queuedPhrase = nil
        queuedFunction = nil
    end
end

local function queuePhrase(phrase, func)
    local currentTime = os.time()
    local timeSinceLastSay = currentTime - lastSayTime
    
    if timeSinceLastSay >= SAY_COOLDOWN then
        -- Can say immediately
        BL.info(string.format("Saying phrase immediately: %s", phrase))
        func()
        lastSayTime = currentTime
    else
        -- Need to queue and wait
        local waitTime = SAY_COOLDOWN - timeSinceLastSay
        BL.info(string.format("Queuing phrase %s, waiting %d seconds", phrase, waitTime))
        queuedPhrase = phrase
        queuedFunction = func
    end
end

local function DropShield(line, arg1, arg2, arg3, arg4)
    local function executeKeikolin()
        BL.info("Dropping Boss Shield :Summoning Keikolin")
        mq.cmd("/boxr pause")
        mq.delay(1000)
        mq.cmd("/tar npc Darta")
        mq.delay(500)
        mq.cmd("/say Keikolin")
        mq.delay(300)
        mq.cmd("/boxr unpause")
        mq.cmd("/rs I said Keikolin, Shield should be down.")
    end
    
    queuePhrase("Keikolin", executeKeikolin)
end

local function StopManipulator(line, arg1, arg2, arg3, arg4)
    local function executeVenesh()
        BL.info("Stopping Manipulator DoT :Summoning Venesh")
        mq.cmd("/boxr pause")
        mq.delay(1000)
        mq.cmd("/tar npc Darta")
        mq.delay(500)
        mq.cmd("/say Venesh")
        mq.delay(300)
        mq.cmd("/boxr unpause")
        mq.cmd("/rs I said Venesh, Manipulator DoT should not happen.")
    end
    
    queuePhrase("Venesh", executeVenesh)
end

local function StopPests(line, arg1, arg2, arg3, arg4)
    local function executeHarlaDar()
        BL.info("Stopping Venomous Pests :Summoning Harla Dar")
        mq.cmd("/boxr pause")
        mq.delay(1000)
        mq.cmd("/tar npc Darta")
        mq.delay(500)
        mq.cmd("/say Harla Dar")
        mq.delay(300)
        mq.cmd("/boxr unpause")
        mq.cmd("/rs I said Harla Dar, Venomous Pests should despawn soon.")
    end
    
    queuePhrase("Harla Dar", executeHarlaDar)
end

local function StopSuffering(line, arg1, arg2, arg3, arg4)
    local function executeSilverwing()
        BL.info("Stopping Suffering :Summoning Silverwing")
        mq.cmd("/boxr pause")
        mq.delay(1000)
        mq.cmd("/tar npc Darta")
        mq.delay(500)
        mq.cmd("/say Silverwing")
        mq.delay(300)
        mq.cmd("/boxr unpause")
        mq.cmd("/rs I said Silverwing, Suffering should stop.")
    end
    
    queuePhrase("Silverwing", executeSilverwing)
end

mq.event("SayKeikolin", "#*#General Usira surrounds himself with an impenetrable barrier.#*#", DropShield)
mq.event("SayVenesh", "#*#A grand manipulator teleports into the room and begins accessing its power.#*#",
    StopManipulator)
mq.event("SayHarlaDar", "#*#The general summons a horde of venomous beasts.#*#", StopPests)
mq.event("SaySilverwing",
    "#*#The general activates one of the secondary control crystals, bringing the leviathan's magic and pain to bear on his enemies.#*#",
    StopSuffering)


while not shouldExit do
    -- Check if we have a queued phrase waiting to be executed
    if queuedPhrase and queuedFunction then
        local currentTime = os.time()
        local timeSinceLastSay = currentTime - lastSayTime
        
        if timeSinceLastSay >= SAY_COOLDOWN then
            executeQueuedPhrase()
            lastSayTime = currentTime
        end
    end
    
    -- Check if a gilded chest has spawned and end script
    local chest = mq.TLO.Spawn("a_gilded_chest")
    if chest() and chest.ID() > 0 then
        shouldExit = StopControlRoom()
    end

    -- Check if Darta exists before accessing distance and navigating
    local darta = mq.TLO.Spawn("Darta")
    if darta() and darta.Distance() > 20 and not mq.TLO.Navigation.Active() then
        mq.cmd("/nav spawn Darta")
        mq.delay(300)
    end

    mq.doevents()
    mq.delay(100)
end
