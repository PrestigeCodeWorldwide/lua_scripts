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

local hideSpot = ""
local TriggerStartRunning = false

-- THESE ARE locYXZ
local hide1 = "152 -1145 193"
local hide2 = "249 -1257 193"

-- LEM group emote
-- #*#Shalowain links the sounds of footfalls and heartbeats of several people to her musical magic. That music starts to form into a solid object that begins to move toward #1# and #2#.#*#

-- RAID ADDITION
-- #*#Shalowain links the sounds of footfalls and heartbeats of several people to her musical magic. That music starts to form into a solid object that begins to move toward #1#, #2#, #3, and #4#.#*#
--[Sat Apr 27 04:37:04 2024]
--Shalowain links the sounds of footfalls and heartbeats of several people to her musical magic. That music starts to form into a solid object that begins to move toward Dyllana and Enemabot.
--Shalowain links the sounds of footfalls and heartbeats of several people to her musical magic. That music starts to form into a solid object that begins to move toward #1# and #2#.
--#*#Shalowain links the sounds of footfalls and heartbeats of several people to her musical magic. That music starts to form into a solid object that begins to move toward #1# and #2#.#*#
--#*#Shalowain links the sounds of footfalls and heartbeats of several people to her musical magic. That music starts to form into a solid object that begins to move toward #1# and #2#.#*#

mq.event(
    'ShalowainRunAway',
    '#*#Shalowain links the sounds of footfalls and heartbeats of several people to her musical magic. That music starts to form into a solid object that begins to move toward #1# and #2#.#*#',
    function(line, nameOne, nameTwo)
        local myName = mq.TLO.Me.CleanName()
        mq.cmd("/g EVENT CAUGHT IN GENERAL calling out %s and %s", nameOne, nameTwo)

        if nameOne == myName then
            mq.cmd("/g EVENT CAUGHT - I'm name ONE running")
            hideSpot = hide1
            TriggerStartRunning = true
        elseif nameTwo == myName then
            mq.cmd("/g EVENT CAUGHT - I'm name TWO running")
            hideSpot = hide2
            TriggerStartRunning = true
        end
    end
)


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
        or myClass == 'SHM'
        or myClass == 'SHD'
    then
        IAmPetClass = true
        mq.cmd('/g I AM a pet class, prioritizing eggs')
    else
        mq.cmd('/g I am NOT a pet class, ignoring eggs')
    end

    BL.cmd.pauseAutomation()
    --mq.cmd('/g Growing myself with RC kit clicky horde cube')
    --mq.TLO.Me.DoTarget()
    --mq.delay(1)
    --mq.cmd('/useitem luclinite horde cube')
    --mq.delay(3500)

    mq.cmd('/g Levitating the group')
    mq.cmd('/aa act perfected levitation')
    mq.delay(500)
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

local function RunWhileDebuffed()
    if FSM == FSMStates.Default then
        mq.cmd('/g I have the AOE debuff, running to safe spot')
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
    mq.cmd("/g My Debuff is gone")
    TriggerStartRunning = false
end

local function handleAoEEvent()
    -- We got the debuff event and we're one of the called-out people, run
    if TriggerStartRunning then
        RunWhileDebuffed()
    end

    -- I had the debuff but its gone now, lets move to safe spot
    if not IHaveADebuff() and FSM == FSMStates.HaveDebuffRun then
        mq.cmdf("/g Debuff Dropped on %s", mq.TLO.Me.CleanName())
        FSM = FSMStates.DebuffDroppedGoWait
        StartedWaitingTime = os.clock()
    end

    -- We're waiting for aura despawn
    if FSM == FSMStates.DebuffDroppedGoWait then
        mq.cmdf("/nav locyxz %s", hideSpot)
        mq.cmd("/g Running to hide spot since debuff is gone")
        if IHaveWaitedLongEnough() then
            FSM = FSMStates.Default
            StartedWaitingTime = 0
            BL.cmd.resumeAutomation()
            mq.cmd('/g I Have waited long enough after debuff at hiding spot, resuming')
        end
    end
end



init()

while true do
    handleEggs()
    handleAoEEvent()
    mq.delay(112)
end



























-----@type Mq
--local mq = require('mq')
----- @type ImGui
--require('ImGui')
----- @type BL
--local BL = require('biggerlib')
--local Paused = false


--mq.bind('/zm pause on', function()
--	Paused = true
--	mq.cmd('/squelch /nav stop')
--	print('Mission  paused')
--end)

--mq.bind('/zm pause off', function()
--	Paused = false
--	print('Mission resumed')
--end)

--mq.bind('/zm pause', function()
--	Paused = true
--	mq.cmd('/squelch /nav stop')
--	print('Mission paused')
--end)

--local IAmPetClass = false
--local function init()
--	--get my classs and cache it to see if i'm pet class
--	local myClass = mq.TLO.Me.Class.ShortName()
--	if
--		myClass == 'NEC'
--		or myClass == 'MAG'
--		or myClass == 'BST'
--		or myClass == 'SHD'
--		or myClass == 'ENC'
--		or myClass == 'SHM'
--	then
--		IAmPetClass = true
--		mq.cmd('/g I AM a pet class')
--	else
--		mq.cmd('/g I am NOT a pet class')
--	end

--    BL.cmd.pauseAutomation()
--    mq.cmd('/g Growing the group')
--    mq.TLO.Me.DoTarget()
--    mq.delay(1)
--	mq.cmd('/useitem luclinite horde cube')
--	mq.delay(3500)

--	mq.cmd('/g Levitating the group')
--	mq.cmd('/aa act perfected levitation')
--    mq.delay(3500)
--    BL.cmd.resumeAutomation()
--end


--local function handleEggs()
--	if IAmPetClass then
--		-- see if egg is up
--		local egg = mq.TLO.Spawn('npc egg').ID()
--		if egg ~= nil and egg > 0 then
--            -- send pets on eggs
--			mq.cmd("/boxr pause")
--			mq.cmd('/g Sending my pet on egg')
--			mq.delay(1000)
--			mq.cmd('/target npc egg')
--			mq.delay(1000)
--			mq.cmd('/pet attack')

--			-- wait for egg to die
--			while mq.TLO.Spawn('npc egg').ID() ~= nil and mq.TLO.Spawn('npc egg').ID() > 0 do
--				mq.cmd('/target npc egg')
--				mq.delay(500)
--				mq.cmd('/pet attack')
--			end
--			mq.cmd('/g Egg is dead, resuming')
--			mq.cmd('/boxr unpause')
--		end
--	end
--end

---- This goes up by the NPC
--local debuffName = 'Song of Echoes'
---- raid only
--local otherDebuffName = 'Song of Calling'

--local function handleAoEEvent()

--    if BL.IHaveBuff(debuffName) or BL.IHaveBuff(otherDebuffName) then
--		-- we have the debuff, run to safe spot
--		mq.cmd('/g I have the AOE debuff, running to safe spot')
--		BL.cmd.pauseAutomation()
--        mq.delay(500)
--        mq.cmd("/attack off")
--        mq.cmdf("/target %s", mq.TLO.Me.CleanName())
--        mq.delay(250)
--        mq.cmd("/nav locyxz 568 -1317 327")

--		while BL.IHaveBuff(debuffName) or BL.IHaveBuff(otherDebuffName) do

--			mq.delay(100)
--		end
--		mq.cmd('/g AOE debuff is gone, resuming')
--		BL.cmd.resumeAutomation()
--	end
--end

--local function mainLoop()
--	-- We need to do 2 things - make pet classes send their pets on eggs during spider and run from aoe when called
--	handleEggs()
--	handleAoEEvent()
--end

--------------------------------- Execution -------------------------------

--init()
--while true do
--    if not Paused then
--        mainLoop()
--    end
--    mq.doevents()
--    mq.delay(512)

--end
