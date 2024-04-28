local mq = require('mq')
local BL = require("biggerlib")

--[[
Navulta first
Everyone move themselves back and out of knife aoe 
tank in corner to leave other corner free to move to during explosive barrels
move everyone back to safe spot during explosive barrels

-- Swarn
Adds every 12 percent starting at 86
Follow him into aura constantly even while tanking adds
monks turn off destructive/devastating assault
zerkers turn off their aoe discs

-- Commander

--]]

local ElemDebuff = "Elemental Convergence"

local State = {
    IDLE = 1,
    NEEDS_TO_RUN = 2,
    RUNNING = 3,
}
local currentState = State.IDLE
local safeSpots = {
    "1205 789 442",
    "1243 1107 452",
    "1454 1381 438"
}
local mySafeSpot = ""

mq.event("ElementalRunAway", "#*#Brigadier Swarn pulls elemental forces to gather around #1#, #2#, and #3#.#*#",
    function(line, nameOne, nameTwo, nameThree)
        local myName = mq.TLO.Me.CleanName()
        if myName == nameOne or myName == nameTwo or myName == nameThree then
            currentState = State.NEEDS_TO_RUN
            mySafeSpot = safeSpots[myName == nameOne and 1 or myName == nameTwo and 2 or 3]
        end
    end)

local function runToSafety()
    BL.cmd.pauseAutomation()
    mq.cmd("/gu Running in EIGHT SECONDS, taunt off me!")
    mq.delay(8000)
    mq.cmdf("/nav locyxz %s", mySafeSpot)
    currentState = State.RUNNING
end

local function checkSafeToReturn()
    if not BL.IHaveBuff(ElemDebuff) then
        mq.cmd("/gu Elem AOE fired on me, returning")
        BL.cmd.resumeAutomation()
        currentState = State.IDLE
    end
end

local function fsmUpdate()
    if currentState == State.NEEDS_TO_RUN then
        runToSafety()
    elseif currentState == State.RUNNING then
        checkSafeToReturn()
    end
end

while true do
    fsmUpdate()
    mq.doevents()
    mq.delay(113)
end
