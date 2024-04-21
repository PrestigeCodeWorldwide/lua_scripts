---@type Mq
local mq = require('mq')
--- @type ImGui
require('ImGui')
--- @type BL
local BL = require('biggerlib')

-- This goes up by the NPC
local debuffName = 'Song of Echoes'
local otherDebuffName = 'Song of Calling'

local WaitDuration = 36
local StartedWaitingTime = 0


local function IHaveWaitedLongEnough()
    if os.clock() - StartedWaitingTime > WaitDuration then
        return true
    end
    
    return false
end

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
    
    BL.cmd.pauseAutomation()
    mq.cmd('/g Growing myself with RC kit clicky horde cube')
    mq.TLO.Me.DoTarget()
    mq.delay(1)
    mq.cmd('/useitem luclinite horde cube')
    mq.delay(3500)
    
    mq.cmd('/g Levitating the group')
    mq.cmd('/aa act perfected levitation')
    mq.delay(3500)
    BL.cmd.resumeAutomation()
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

local function IHaveADebuff()
    return BL.IHaveBuff(debuffName) or BL.IHaveBuff(otherDebuffName)
end

local function handleAoEEvent()
    if IHaveADebuff() then
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
        mq.cmd('/rs AOE debuff is gone, resuming')
    else
        -- I had the debuff but its gone now, lets wait 36 sec for aura despawn
        if FSM == FSMStates.HaveDebuffRun then
            FSM = FSMStates.DebuffDroppedGoWait
            StartedWaitingTime = os.clock()
        end
    end
    
    -- We're waiting for aura despawn
    if FSM == FSMStates.DebuffDroppedGoWait then
        if IHaveWaitedLongEnough() then
            FSM = FSMStates.Default
            StartedWaitingTime = 0
            BL.cmd.resumeAutomation()
        end 
    end
    
end

init()

while true do
    handleEggs()
    handleAoEEvent()    
    mq.delay(112)
end
