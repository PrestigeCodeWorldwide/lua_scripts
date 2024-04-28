---@type Mq
local mq = require('mq')
--- @type ImGui
require('ImGui')
local BL = require('biggerlib')

-- This goes up by the NPC
local debuffName = 'Song of Echoes'
local otherDebuffName = 'Song of Calling'

local TriggerStartRunning = false

-- THESE ARE locYXZ
--local hide1 = "152 -1145 193"
--local hide2 = "249 -1257 193"
--local hide3 = "381 -914 193"
--local hide4 = "488 -1016 193"

-- LEM group emote
-- #*#Shalowain links the sounds of footfalls and heartbeats of several people to her musical magic. That music starts to form into a solid object that begins to move toward #1# and #2#.#*#

-- RAID ADDITION
-- #*#Shalowain links the sounds of footfalls and heartbeats of several people to her musical magic. That music starts to form into a solid object that begins to move toward #1#, #2#, #3, and #4#.#*#

mq.event(
    'ShalowainRunAway',
    '#*#music starts to form into a solid object that begins to move toward #1#, #2#, #3, and #4#.#*#',
    function(line, nameOne, nameTwo, nameThree, nameFour)
        local myName = mq.TLO.Me.CleanName()
        
        if nameOne == myName then 
            --hideSpot = hide1
            TriggerStartRunning = true
        elseif nameTwo == myName then 
            --hideSpot = hide2
            TriggerStartRunning = true
        elseif nameThree == myName then 
            --hideSpot = hide3
            TriggerStartRunning = true
        elseif nameFour == myName then
            --hideSpot = hide4
            TriggerStartRunning = true
        end
    end
)

mq.event(
    'ShalowainRunAwayTwo',
    '#*#music starts to form into a solid object that begins to move toward #1#, #2#, #3, and #4#.',
    function(line, nameOne, nameTwo, nameThree, nameFour)
        local myName = mq.TLO.Me.CleanName()

        if nameOne == myName then
            --hideSpot = hide1
            TriggerStartRunning = true
        elseif nameTwo == myName then
            --hideSpot = hide2
            TriggerStartRunning = true
        elseif nameThree == myName then
            --hideSpot = hide3
            TriggerStartRunning = true
        elseif nameFour == myName then
            --hideSpot = hide4
            TriggerStartRunning = true
        end
    end
)



local FSMStates = {
    Default = 1,
    HaveDebuffRun = 2,
    DebuffDroppedGoWait = 3,    
}

local FSM = FSMStates.Default

local IAmPetClass = false
local function init()
    --get my classs and cache it to see if i'm pet class
    local myClass = mq.TLO.Me.Class.ShortName()
    if
        myClass == 'NEC'
        or myClass == 'MAG'
        or myClass == 'BST'
        or myClass == 'ENC'
    then
        IAmPetClass = true
        mq.cmd('/g I AM a pet class, prioritizing eggs')
    else
        mq.cmd('/g I am NOT a pet class, ignoring eggs')
    end 
  
end

local function handleEggs()
    if IAmPetClass then
        -- see if egg is up
        local egg = mq.TLO.Spawn('npc egg').ID()
        if egg ~= nil and egg > 0 then
            -- send pets on eggs
            mq.cmd("/boxr pause")
            mq.cmd('/g Sending my pet on egg')
            mq.delay(1000)
            mq.cmd('/target npc egg')
            mq.delay(1000)
            mq.cmd('/pet attack')

            -- wait for egg to die
            while mq.TLO.Spawn('npc egg').ID() ~= nil and mq.TLO.Spawn('npc egg').ID() > 0 do
                mq.cmd('/target npc egg')
                mq.delay(500)
                mq.cmd('/pet attack')
            end
            mq.cmd('/g Egg is dead, resuming')
            mq.cmd('/boxr unpause')
        end
    end
end


local function handleAoEEvent()
    -- We got the debuff event and we're one of the called-out people, run
    if TriggerStartRunning then            
        if FSM == FSMStates.Default then
            mq.cmd('/rs I have the AOE debuff, running to safe spot')
        end
        FSM = FSMStates.HaveDebuffRun
        -- we have the debuff, run to safe spot
        if not mq.TLO.CWTN.Paused() then
            BL.cmd.pauseAutomation()
            mq.cmdf("/target %s", mq.TLO.Me.CleanName())
            mq.delay(250)
        end
        mq.cmd("/nav locyxz 568 -1317 327")
        while BL.IHaveBuff(debuffName) or BL.IHaveBuff(otherDebuffName) do
            mq.delay(100)
        end
    end
    
    -- REMOVED in favor of never bringing our boxes back and burning the fuck out of him instead
    ---- I had the debuff but its gone now, lets move to safe spot
    --if not IHaveADebuff() and FSM == FSMStates.HaveDebuffRun then
    --    FSM = FSMStates.DebuffDroppedGoWait
    --    StartedWaitingTime = os.clock()
    --end
    
    ---- We're waiting for aura despawn
    --if FSM == FSMStates.DebuffDroppedGoWait then
    --    mq.cmdf("/nav locyxz %s", hideSpot)
    --    if IHaveWaitedLongEnough() then
    --        FSM = FSMStates.Default
    --        StartedWaitingTime = 0
    --        BL.cmd.resumeAutomation()
    --        mq.cmd('/rs AOE debuff is gone, resuming')
    --    end
    --end
end

init()

while true do
    handleEggs()
    handleAoEEvent()    
    mq.delay(112)
end

--local function IHaveWaitedLongEnough()
--    if os.clock() - StartedWaitingTime > WaitDuration then
--        return true
--    end

--    return false
--end
