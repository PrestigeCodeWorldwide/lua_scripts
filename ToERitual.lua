---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')

BL.info("ToERitual Script v1.23Started")

mq.cmdf("/noparse /dgge /docommand /${Me.Class.ShortName} mode 2")
mq.cmdf("/noparse /dgge /docommand /${Me.Class.ShortName} chasedistance 10 nosave")
mq.cmdf("/noparse /dgge /docommand /${Me.Class.ShortName} raidmode off")
mq.cmdf("/docommand /${Me.Class.ShortName} raidmode on")
mq.cmdf("/docommand /grouproles set ${Me.Name} 2")
mq.cmdf("/dgge /docommand /${Me.Class.ShortName} useselos off nosave")
mq.cmdf("/dgga /docommand /removebuff Selo's Accelerato")

local ritualinprogress = false
local canMoveToCircles = false
local movingToCircle = false
local circleQueue = {}
local lastCircleSequence = {}

-- Define nav positions for each circle
local circleLocations = {
    red = {x=497, y=1337, z=-1.4},
    green = {x=442, y=1286, z=-1.5},
    blue = {x=388, y=1340, z=-1.5},
    yellow = {x=443, y=1396, z=-1.5},
}

local function copyTable(tbl)
    local new = {}
    for i = 1, #tbl do
        new[i] = tbl[i]
    end
    return new
end

-- Check if any group member is dead
local function isAnyGroupMemberDead()
    local groupSize = mq.TLO.Group.Members() or 0
    for i = 1, groupSize do
        local member = mq.TLO.Group.Member(i)
        if member() and member.Dead() then
            BL.info(string.format("Pausing movement - %s is dead", member.Name() or "Unknown"))
            return true
        end
    end
    return false
end
-- Move to next circle in the queue
local function moveToNextCircle()
    if movingToCircle or not canMoveToCircles or #circleQueue == 0 or isAnyGroupMemberDead() then return end

    local nextColor = table.remove(circleQueue, 1)
    local loc = circleLocations[nextColor]

    if loc then
        BL.info("Moving to "..nextColor.." circle.")
        BL.cmd.StandIfFeigned()
        BL.cmd.removeZerkerRootDisc()
        mq.cmdf("/nav locyxz %d %d %.1f", loc.x, loc.y, loc.z)
        movingToCircle = true
    else
        BL.info("Unknown circle color: "..tostring(nextColor))
    end
end

-- Ritual Start
local function BeginRitual(line)
    if ritualinprogress then return end
    ritualinprogress = true
    canMoveToCircles = false
    movingToCircle = false
    circleQueue = {}
    lastCircleSequence = {}
    BL.info("Ritual Started, moving to center.")
    mq.cmdf("/docommand /%s mode 0", mq.TLO.Me.Class.ShortName())
    mq.cmd("/target")
    BL.cmd.removeZerkerRootDisc()
    BL.cmd.StandIfFeigned()
    mq.delay(100)
    mq.cmd("/nav locyxz 438 1343 -1.9")
end

-- Ritual ends, movement can start
local function CanMovetoCircles(line)
    BL.info("Ritual ended, ready to move through circles.")
    canMoveToCircles = true
    moveToNextCircle()
end

-- Ritual Success
local function RitualSuccess(line)
    BL.info("Ritual Completed Successfully, returning to fight.")
    ritualinprogress = false
    canMoveToCircles = false
    movingToCircle = false
    circleQueue = {}
    lastCircleSequence = {}
    mq.cmdf("/docommand /%s mode 2", mq.TLO.Me.Class.ShortName())
end

-- Ritual Failure → retry same sequence
local function RitualFail(line)
    BL.info("Ritual Failed. Resetting and trying again.")
    ritualinprogress = false
    canMoveToCircles = false
    movingToCircle = false
    circleQueue = {}

    BL.cmd.StandIfFeigned()
    mq.cmd("/nav locyxz 438 1343 -1.9")
    mq.delay(5000)

    BL.info("Retrying previous circle sequence.")
    circleQueue = copyTable(lastCircleSequence)
    canMoveToCircles = true
    moveToNextCircle()
end

-- Circle completed, try to move to the next one
local function CircleSuccess(line)
    BL.info("Circle Completed Successfully.")
    movingToCircle = false
    mq.delay(200)
    moveToNextCircle()
end

-- Circle color triggers: queue the color and remember sequence
local function RedCircle(line)
    BL.info("Red Circle spotted.")
    table.insert(circleQueue, "red")
    table.insert(lastCircleSequence, "red")
end

local function GreenCircle(line)
    BL.info("Green Circle spotted.")
    table.insert(circleQueue, "green")
    table.insert(lastCircleSequence, "green")
end

local function BlueCircle(line)
    BL.info("Blue Circle spotted.")
    table.insert(circleQueue, "blue")
    table.insert(lastCircleSequence, "blue")
end

local function YellowCircle(line)
    BL.info("Yellow Circle spotted.")
    table.insert(circleQueue, "yellow")
    table.insert(lastCircleSequence, "yellow")
end

-- Event registration
mq.event("RitualStart", "#*#War trainer Prime begins a ritual spell.#*#", BeginRitual)
mq.event("CanMovetoCircles", "#*#A faint glow of the recent spell ritual spell casting remains#*#", CanMovetoCircles)
mq.event("SuccessRitual", "#*#With a flash of light, the ritual spell shatters. War Trainer Prime seems more vulnerable#*#", RitualSuccess)
mq.event("FailRitual", "#*#A group attempted to dispel the wrong part of the ritual#*#", RitualFail)
mq.event("CircleSuccess", "#*#The runes of the ritual spell glow brighter.#*#", CircleSuccess)
mq.event("RedCircle", "#*#The circle to the north flashes with red energy#*#", RedCircle)
mq.event("GreenCircle", "#*#The circle to the east flashes with green energy#*#", GreenCircle)
mq.event("BlueCircle", "#*#The circle to the south flashes with blue energy#*#", BlueCircle)
mq.event("YellowCircle", "#*#The circle to the west flashes with yellow energy#*#", YellowCircle)

-- Main loop
while true do
    BL.checkChestSpawn("a_military_chest")
    
    -- If we were moving to a circle but a group member died, stop movement
    if movingToCircle and isAnyGroupMemberDead() then
        mq.cmd("/nav stop")
        movingToCircle = false
        BL.info("Movement paused due to dead group member")
    end

    mq.doevents()
    mq.delay(200)
end
