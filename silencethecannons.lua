--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("SilenceTheCannons Script v1.11 Started")
BL.info("REMINDER 70 and 51(skyguard) INACTIVE - target yourself")
mq.cmd("/plugin boxr load")

local locX = 5
local locY = 345
local locZ = 111.5
local iAmWaiting = false

local triggerPhrase = "#*#An overcharged orb moves toward #1#.#*#"

local function handleRunEvent(line, toonname)
    if (toonname ~= mq.TLO.Me.CleanName()) then
        BL.info("Event not applied to me, returning")
        return
    end

    BL.info('I have the AOE debuff, running to safe spot')

    --BL.cmd.pauseAutomation()
    --mq.cmd("/docommand /${Me.Class.ShortName} mode 0")
    BL.cmd.ChangeAutomationModeToManual()
    mq.delay(500)
    BL.cmd.StandIfFeigned()
    BL.cmd.removeZerkerRootDisc()
    mq.cmdf('/nav locyxz %s %s %s', locX, locY, locZ)

    mq.delay(30000) -- Wait 30 sec before resuming
    --BL.cmd.resumeAutomation()
    --mq.cmd("/docommand /${Me.Class.ShortName} mode 2")
    BL.cmd.ChangeAutomationModeToChase()
    BL.cmd.StandIfFeigned()
end

mq.event("orbwalk", triggerPhrase, handleRunEvent)

while true do
    -- Check if an outworld provision chest has spawned and end script
    BL.checkChestSpawn("an_outworld_provision_chest")
    mq.doevents()
    mq.delay(323)
end
