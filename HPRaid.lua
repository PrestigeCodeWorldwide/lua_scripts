--- @type Mq
local mq = require('mq')
local BL = require("biggerlib")

BL.info("High Priest Raid Script v1.63 Started")

--Boss Campfire Location: /nav locxyz-113 539 1470
--Safe Spot Campire Location: /nav locxyz 42 380 1470

local stateFile = mq.TLO.MacroQuest.Path() .. "\\logs\\hpraid_state.txt"

-- Function to write state to file
local function writeState(state)
    local file = io.open(stateFile, "w")
    if file then
        file:write(state)
        file:close()
    end
end

-- Function to stick Behind
local function StickBehind(line, arg1)
    if mq.TLO.Target.CleanName() ~= "High Priest Yaran" then
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

mq.event("Behind", "#*#The High Priest tenses and takes a deep breath.#*#", StickBehind)

--Debuff name SE= Purification of Veeshan
--Debuff name NW= Penance for Disobedience
--Debuff SK Test SE= Cloak of Shadows II
local debuffNameSE = "Purification of Veeshan"
local debuffNameNW = "Penance for Disobedience"
--X1= 232 Y1= -331
local locX1 = 232
local locY1 = -331
local locX2 = 626
local locY2 = 209
local iAmWaiting = false

------ debuff handling for purifications
local debuffStateMachine = "IDLE" -- This is so we can track where we are in the debuff loop
local IWasCalled = false -- gets set to true if either of the callouts include my name

local function Purif1Handler(line)
    IWasCalled = string.find(line, mq.TLO.Me.CleanName()) ~= nil
    debuffStateMachine = "FIRSTDEBUFFOUT"
end

local function Purif2Handler(line)
    local imCalled2 = string.find(line, mq.TLO.Me.CleanName()) ~= nil
    -- Don't stomp on Purif1 if it was true and this is false
    if imCalled2 then   
        IWasCalled = true 
    end
    debuffStateMachine = "SECONDDEBUFFOUT"
end

mq.event("Purif1", "#*#The High Priest demands the Penance from #*#", Purif1Handler)
mq.event("Purif2", "#*#And he sets the Purification of Veeshan upon #*#", Purif2Handler)

-- Initialize state file
writeState("IDLE")

while true do
    -- Normal check for getting the SE debuff trigger
    if BL.IHaveBuff(debuffNameSE) and not iAmWaiting then
        iAmWaiting = true
        writeState("DEBUFF_ACTIVE")  -- Signal that we're handling debuffs
        BL.info('I have the SE Purification debuff, running to cure spot')

        BL.cmd.pauseAutomation()
        mq.delay(100)
        mq.cmd("/tar")
        BL.cmd.removeZerkerRootDisc()
        BL.cmd.StandIfFeigned()
        mq.cmdf('/nav locyx %s %s', locX1, locY1)
        
        BL.WaitForNav()
        mq.delay(1200)
        BL.info("Arrived at cure spot")
    end
    -- Normal check for getting the NW debuff trigger
    if BL.IHaveBuff(debuffNameNW) and not iAmWaiting then
        iAmWaiting = true
        writeState("DEBUFF_ACTIVE")  -- Signal that we're handling debuffs
        BL.info('I have the NW Penance debuff, running to cure spot')

        BL.cmd.pauseAutomation()
        BL.cmd.removeZerkerRootDisc()
        mq.delay(100)
        mq.cmd("/tar")
        BL.cmd.StandIfFeigned()
        mq.cmdf('/nav locyx %s %s', locX2, locY2)

        BL.WaitForNav()
        mq.delay(1200)
        BL.info("Arrived at cure spot")
    end

    -- Check for resuming if we're waiting and the debuff falls off.
    -- May have to add a 2nd one later if both debuffs can land at once.
    if not BL.IHaveBuff(debuffNameSE) and not BL.IHaveBuff(debuffNameNW) and iAmWaiting then
        iAmWaiting = false
        writeState("IDLE")  -- Signal that we're done handling debuffs
        BL.info("Returning to the fight")
        BL.cmd.resumeAutomation()
        BL.cmd.StandIfFeigned()
        mq.delay(100)
        local classShort = mq.TLO.Me.Class.ShortName()
        --mq.cmdf("/docommand /%s mode chase", classShort)
        --mq.delay(7500)
        --mq.cmdf("/docommand /%s mode vorpal", classShort)
    end
    
    -- Handle when I'm NOT called by running away
    if debuffStateMachine == "SECONDDEBUFFOUT" then
        if not IWasCalled then
            writeState("DEBUFF_ACTIVE")  -- Signal that we're handling debuffs
            BL.info("I was not called, running to middle")
            mq.cmdf("/docommand /%s mode 0", mq.TLO.Me.Class.ShortName())
            mq.cmd("/nav locyx 467 51")
            mq.delay(20000)
            mq.cmdf("/docommand /%s mode 2", mq.TLO.Me.Class.ShortName())
            writeState("IDLE")  -- Signal that we're done
        end
    
        -- reset state machine vars for next callout phase
        debuffStateMachine = "IDLE"
        IWasCalled = false
    end

    -- Check if a golden chest has spawned and end script
    BL.checkChestSpawn("a_golden_chest")

    mq.doevents()
    mq.delay(1023)
end