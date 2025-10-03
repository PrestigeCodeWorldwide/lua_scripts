--- @type Mq
local mq = require('mq')
---@type BL
local BL = require("biggerlib")

BL.info("VelksRaid Script v1.0 Started")

--Debuff name= Acidic Ice Pool
local debuffName = "Acidic Ice Pool"
local locX = 121
local locY = -100
local iAmWaiting = false

while true do
    -- Normal check for getting the debuff trigger
    if BL.IHaveBuff(debuffName) and not iAmWaiting then
        iAmWaiting = true
        BL.info('I have the AOE debuff, running to safe spot')

        BL.cmd.pauseAutomation()
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
        BL.cmd.resumeAutomation()
        BL.cmd.StandIfFeigned()
    end

    BL.checkChestSpawn("a_large_chest")
    mq.delay(1023)
end
