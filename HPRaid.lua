--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("HPRaid Script v2.05 Started - Combined Mez, run aways and stickhow flipping on boss")
BL.info("add a messenger name to enable mezzing. /lua run hpraid health")

-- Shared State
local mezSpell = ""
local shouldDoMez = false
local isMezPaused = false
local isHandlingDebuff = false
local iAmWaiting = false
local debuffStateMachine = "IDLE"
local IWasCalled = false
local hadMessengersLastCheck = true
local messengerType = "messenger" -- Can be overridden by command line arg

-- Boss Campfire Location: /nav locxyz-113 539 1470
-- Safe Spot Campfire Location: /nav locxyz 42 380 1470

-- Debuff names: SE== "Purification of Veeshan" NW= "Penance for Disobedience"
local debuffNameSE = "Purification of Veeshan"
local debuffNameNW = "Penance for Disobedience"

-- Locations
local locX1, locY1 = 232, -331 -- SE debuff cure spot
local locX2, locY2 = 626, 209  -- NW debuff cure spot

-- Calculate distance using Pythagorean theorem
local function calculateDistance(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- Function to stick Behind
local function StickBehind(line, arg1)
    if mq.TLO.Target.CleanName() ~= "Yaran" then ---High Priest Yaran
        return
    end
    BL.info("Changing StickHow to Behind")
    local classShort = mq.TLO.Me.Class.ShortName()
    mq.cmdf("/docommand /%s stickhow 0", classShort)
    mq.delay(12000)
    mq.cmdf("/docommand /%s stickhow 3", classShort)
    mq.cmd("/stick set nohottfront on")
    mq.delay(10000)
    mq.cmdf("/docommand /%s stickhow 0", classShort)
end

-- Debuff Handlers
local function Purif1Handler(line)
    IWasCalled = string.find(line, mq.TLO.Me.CleanName()) ~= nil
    debuffStateMachine = "FIRSTDEBUFFOUT"
end

local function Purif2Handler(line)
    local imCalled2 = string.find(line, mq.TLO.Me.CleanName()) ~= nil
    if imCalled2 then
        IWasCalled = true
    end
    debuffStateMachine = "SECONDDEBUFFOUT"
end

-- Register events
mq.event("Behind", "#*#The High Priest tenses and takes a deep breath.#*#", StickBehind)
mq.event("Purif1", "#*#The High Priest demands the Penance from #*#", Purif1Handler)
mq.event("Purif2", "#*#And he sets the Purification of Veeshan upon #*#", Purif2Handler)

-- Handle debuff movement and state
local function handleDebuffs()
    -- Check for SE debuff
    if BL.IHaveBuff(debuffNameSE) and not iAmWaiting then
        iAmWaiting = true
        isHandlingDebuff = true
        BL.info('I have the SE Purification debuff, running to cure spot')
        -- Coordinate with off-tanks - handle everything inside the coordination block
        BL.cmd.coordinateWithScript("offtank", function()
            BL.info("Coordinating with off-tanks - pausing their automation during SE run away")
            BL.cmd.pauseAutomation()
            mq.delay(100)
            mq.cmd("/tar")
            BL.cmd.removeZerkerRootDisc()
            BL.cmd.StandIfFeigned()
            mq.cmdf('/nav locyx %s %s', locX1, locY1)
            BL.WaitForNav()
            mq.delay(1200)
            BL.info("Arrived at cure spot")
            -- Wait here for debuff to clear
            while BL.IHaveBuff(debuffNameSE) do
                mq.delay(1000) -- Check every second
            end
            BL.info("SE debuff cleared, ending coordination")
        end)
        return
    end

    -- Check for NW debuff
    if BL.IHaveBuff(debuffNameNW) and not iAmWaiting then
        iAmWaiting = true
        isHandlingDebuff = true
        BL.info('I have the NW Penance debuff, running to cure spot')
        -- Coordinate with off-tanks - handle everything inside the coordination block
        BL.cmd.coordinateWithScript("offtank", function()
            BL.info("Coordinating with off-tanks - pausing their automation during NW run away")
            BL.cmd.pauseAutomation()
            BL.cmd.removeZerkerRootDisc()
            mq.delay(100)
            mq.cmd("/tar")
            BL.cmd.StandIfFeigned()
            mq.cmdf('/nav locyx %s %s', locX2, locY2)
            BL.WaitForNav()
            mq.delay(1200)
            BL.info("Arrived at cure spot")
            -- Wait here for debuff to clear
            while BL.IHaveBuff(debuffNameNW) do
                mq.delay(1000) -- Check every second
            end
            BL.info("NW debuff cleared, ending coordination")
        end)
        return
    end

    -- Check for resuming if debuffs fall off
    if not BL.IHaveBuff(debuffNameSE) and not BL.IHaveBuff(debuffNameNW) and iAmWaiting then
        iAmWaiting = false
        isHandlingDebuff = false
        BL.info("Returning to the fight")
        BL.cmd.resumeAutomation()
        BL.cmd.StandIfFeigned()
        mq.delay(100)
    end

    -- Handle when I'm NOT called by running away
    if debuffStateMachine == "SECONDDEBUFFOUT" then
        if not IWasCalled then
            -- Only run to the middle if we're not currently mezzing a messenger
            local currentTarget = mq.TLO.Target.CleanName()
            if not (currentTarget and string.find(currentTarget, messengerType)) then
                isHandlingDebuff = true
                BL.info("I was not called and not mezzing, running to middle")
                mq.cmdf("/docommand /%s mode 0", mq.TLO.Me.Class.ShortName())
                mq.cmd("/nav locyx 467 51")
                mq.delay(20000)
                mq.cmdf("/docommand /%s mode 2", mq.TLO.Me.Class.ShortName())
                isHandlingDebuff = false
            else
                BL.info("Currently mezzing a messenger, ignoring callout")
            end
        end

        -- Reset state machine vars for next callout phase
        debuffStateMachine = "IDLE"
        IWasCalled = false
    end
end

-- Handle mezzing mechanics
local function handleMez()
    -- Skip if we're handling debuffs
    if isHandlingDebuff then
        if not isMezPaused then
            isMezPaused = true
            BL.info("Handling debuffs, pausing mez activity")
        end
        return
    end

    local highPriest = mq.TLO.Spawn("Yaran") ---High Priest Yaran or just Yaran
    if not highPriest() or highPriest.ID() == 0 then
        BL.info("High Priest not found")
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
    local minDistance = 200 -- Only consider messenger within 200 units
    local messengerCount = tonumber(mq.TLO.SpawnCount(messengerType)()) or 0
    
    for i = 1, messengerCount do
        local messenger = mq.TLO.NearestSpawn(i, messengerType)
        if messenger() and messenger.ID() ~= 0 then
            -- Check if this messenger matches the specific type we want
            local messengerName = messenger.CleanName():lower()
            if messengerName:find(messengerType:lower()) then
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
    end

    -- Process the closest messenger if found
    if closestMessenger then
        BL.info(string.format("Found messenger %s at %.1f distance", closestMessenger.ID(), minDistance))
        hadMessengersLastCheck = true

        -- Target the messenger if not already targeted
        if mq.TLO.Target.ID() ~= closestMessenger.ID() then
            closestMessenger.DoTarget()
            mq.delay(100)
        end

        -- Check if we have line of sight and are in range to cast
        if closestMessenger.Distance() < 200 and closestMessenger.LineOfSight() then
            BL.info("messenger is in range, casting slumber")
            BL.cmd.pauseAutomation()
            isMezPaused = true
            mq.cmd("/stopsong")
            mq.delay(100)
            mq.cmdf("/cast \"%s\"", mezSpell)
            mq.delay(3700)
        elseif closestMessenger.Distance() > 180 or not closestMessenger.LineOfSight() then
            BL.info("Moving closer to messenger")
            mq.cmdf("/nav id %d", closestMessenger.ID())
        end
    else
        -- Only unpause if we previously paused and now have no messengers in range
        if isMezPaused then
            BL.info("No messengers in range, resuming automation")
            BL.cmd.resumeAutomation()
            isMezPaused = false
        end
        
        if hadMessengersLastCheck then -- Only log if we previously had messengers
            BL.info("No messengers in range (max 200 units)")
        end
        hadMessengersLastCheck = false
    end
end

-- Handle command line arguments
local args = { ... }
if #args > 0 then
    messengerType = args[1]:gsub("^%s*(.-)%s*$", "%1") -- Trim whitespace
    shouldDoMez = true                                 -- Only enable mez if messenger type is provided
    if shouldDoMez then
        local myClass = mq.TLO.Me.Class.ShortName()
        local myLevel = mq.TLO.Me.Level() or 125       -- Default to 125 if level check fails
        
        if myClass == "BRD" then
            -- Bard mez spells
            if myLevel >= 130 then
                mezSpell = "Slumber of Keftlik"
            else
                mezSpell = "Slumber of Suja"
            end
        elseif myClass == "ENC" then
            -- Enchanter mez spells
            if myLevel >= 130 then
                mezSpell = "Chaotic Enticement X"
            else
                mezSpell = "Chaotic Conundrum"
            end
        else
            BL.info("Mez mode ENABLED - but you are not a Bard or Enchanter!")
            shouldDoMez = false
            return
        end
        
        BL.info(string.format("Mez mode ENABLED - Using %s for mezzing (%s)", mezSpell, myClass))
    end
    BL.info(string.format("Mez mode ENABLED - Using messenger type: %s", messengerType))
end

-- Main loop
while true do
    mq.doevents() -- Process any events first
    handleDebuffs()
    -- Only run mez handling if we specified a messenger type
    if shouldDoMez then
        handleMez()
    end
    BL.checkChestSpawn("a_golden_chest")
    mq.delay(500)
end
