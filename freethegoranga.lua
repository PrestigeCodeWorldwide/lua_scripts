---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')

BL.info("FreeTheGoranga Script v1.11 Started")

local my_name = mq.TLO.Me.CleanName()
local safe_location = "locxyz 133 835 -120"

local function SingleChains(line, target)
    if target ~= my_name then return end -- Only run if it's MY name

    BL.info("SingleChains triggered for: " .. target)
    mq.cmd("/rs I am running from chains1")
    mq.cmd("/docommand /${Me.Class.ShortName} mode 0")
    --BL.cmd.pauseAutomation()
    mq.cmd("/afollow off")
    mq.cmd("/stick off")
    mq.delay(100)

    BL.info("Navigating to: " .. safe_location)
    BL.cmd.StandIfFeigned()
    BL.cmd.removeZerkerRootDisc()
    mq.cmd("/nav " .. safe_location)
    mq.delay(36000)

    --BL.cmd.resumeAutomation()
    mq.cmd("/docommand /${Me.Class.ShortName} mode 2")
    BL.cmd.StandIfFeigned()
    BL.info("Resumed automation after chains1")
end

local function DoubleChains(line, target1, target2)
    if target1 ~= my_name and target2 ~= my_name then return end

    BL.info("DoubleChains triggered for: " .. target1 .. " and " .. target2)
    mq.cmd("/rs I am running from chains2")
    mq.cmd("/docommand /${Me.Class.ShortName} mode 0")
    --BL.cmd.pauseAutomation()
    mq.cmd("/afollow off")
    mq.cmd("/stick off")
    mq.delay(100)

    BL.info("Navigating to: " .. safe_location)
    BL.cmd.StandIfFeigned()
    BL.cmd.removeZerkerRootDisc()
    mq.cmd("/nav " .. safe_location)
    mq.delay(36000)

    --BL.cmd.resumeAutomation()
    mq.cmd("/docommand /${Me.Class.ShortName} mode 2")
    BL.cmd.StandIfFeigned()
    BL.info("Resumed automation after chains2")
end

mq.event("Chains1", "#*#A mass of shadowy chains begin to form around #1#.#*#", SingleChains)
mq.event("Chains2", "#*#Shadowy chains begin to form around #1# and #2#.#*#", DoubleChains)

while true do
    BL.checkChestSpawn("a_chest")
    mq.doevents()
    mq.delay(100)
end
