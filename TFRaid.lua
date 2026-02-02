--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("TFRaid Script v1.1 Started")
mq.cmd("/plugin boxr load")

--Debuff name= Seed of Hate
local debuffName = "Seed of Hate"
local locX = 1005
local locY = -2146
local iAmWaiting = false

while true do
    -- Normal check for getting the debuff trigger
    if BL.IHaveBuff(debuffName) and not iAmWaiting then
        iAmWaiting = true
        BL.info('I have the AOE debuff, running to safe spot')

        --BL.cmd.pauseAutomation()
        --mq.cmd("/docommand /${Me.Class.ShortName} mode 0")
        BL.cmd.ChangeAutomationModeToManual()
        mq.delay(100)
        BL.cmd.StandIfFeigned()
        BL.cmd.removeZerkerRootDisc()
        mq.cmdf('/nav locyx %s %s', locX, locY)

        BL.WaitForNav()
        BL.info("Arrived at safe spot")
    end

    -- Check for resuming if we're waiting and the debuff falls off
    if not BL.IHaveBuff(debuffName) and iAmWaiting then
        iAmWaiting = false
        BL.info("Returning to the fight")
        --BL.cmd.resumeAutomation()
        --mq.cmd("/docommand /${Me.Class.ShortName} mode 2")
        BL.cmd.ChangeAutomationModeToChase()
        BL.cmd.StandIfFeigned()
    end

    -- Check if a dark chest has spawned and end script
    BL.checkChestSpawn("a_dark_chest")
    mq.delay(1023)
end