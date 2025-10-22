---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')

BL.info("ControlRoom Script v1.42 Started")
BL.info("Type /crstop to stop the script and connect Dannet/BCS")

mq.cmd("/bccmd quit")
mq.cmd("/plugin dannet unload")

--Strategy Info
mq.cmd("/rs Callouts at: 70%, 63%, 56%, 49%, 35%, 28%, 21%, 7%")
mq.cmd("/rs Two Adds at 90%, 80%, 71%, 62%, 51%, 44%, 35%, 26%, 17%, 8%. ")

local shouldExit = false

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

local function DropShield(line, arg1, arg2, arg3, arg4)
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

local function StopManipulator(line, arg1, arg2, arg3, arg4)
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

local function StopPests(line, arg1, arg2, arg3, arg4)
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

local function StopSuffering(line, arg1, arg2, arg3, arg4)
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

mq.event("SayKeikolin", "#*#General Usira surrounds himself with an impenetrable barrier.#*#", DropShield)
mq.event("SayVenesh", "#*#A grand manipulator teleports into the room and begins accessing its power.#*#",
    StopManipulator)
mq.event("SayHarlaDar", "#*#The general summons a horde of venomous beasts.#*#", StopPests)
mq.event("SaySilverwing",
    "#*#The general activates one of the secondary control crystals, bringing the leviathan's magic and pain to bear on his enemies.#*#",
    StopSuffering)


while not shouldExit do
    -- Check if a gilded chest has spawned and end script
    local chest = mq.TLO.Spawn("a_gilded_chest")
    if chest() and chest.ID() > 0 then
        shouldExit = StopControlRoom()
    end

    -- Check if Darta exists before accessing distance and navigating
    local darta = mq.TLO.Spawn("Darta")
    if darta() and darta.Distance() > 20 and not mq.TLO.Nav.Active() then
        mq.cmd("/nav spawn darta")
        mq.delay(300)
    end

    mq.doevents()
    mq.delay(100)
end
