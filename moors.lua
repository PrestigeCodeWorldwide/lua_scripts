--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("Moors Script v1.1 Started")

local debuffName = "Freezing Grasp"
local locX = 480
local locY = 128
local iAmWaiting = false

while true do
    -- Normal check for getting the debuff trigger
    if BL.IHaveBuff(debuffName) and not iAmWaiting then
        iAmWaiting = true
        BL.info('I have the AOE debuff, running to safe spot')

        --BL.cmd.pauseAutomation()
        mq.cmd("/docommand /${Me.Class.ShortName} mode 0")
        BL.cmd.StandIfFeigned()
        BL.cmd.removeZerkerRootDisc()
        mq.delay(100)
        mq.cmdf('/nav locyx %s %s', locX, locY)

        BL.WaitForNav()
        BL.info("Arrived at safe spot")
    end

    -- Check for resuming if we're waiting and the debuff falls off
    if not BL.IHaveBuff(debuffName) and iAmWaiting then
        iAmWaiting = false
        BL.info("Returning to the fight")
        --BL.cmd.resumeAutomation()
        mq.cmd("/docommand /${Me.Class.ShortName} mode 2")
        BL.cmd.StandIfFeigned()
    end

    BL.checkChestSpawn("the_commander`s_chest")
    mq.delay(1023)
end

--local locXOutside = 1002
--local locYOutside = -3
--local locXAgainstWallBehindCampfire = 496 133
-- far corner behind campfire -- 447 133
-- campfire itself 508 115
