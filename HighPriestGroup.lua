--- @type Mq
local mq = require('mq')
local BL = require("biggerlib")

BL.info("High Priest Group Script v1.0 Started")

--Debuff name SE= Disinfection of Veeshan
--Debuff name NW= Contrition for Disobedience
local debuffNameSE = "Disinfection of Veeshan"
local debuffNameNW = "Contrition for Disobedience"
local locX1 = 232
local locY1 = -331
local locX2 = 626
local locY2 = 209
local iAmWaiting = false

while true do
    -- Normal check for getting the SE debuff trigger
    if BL.IHaveBuff(debuffNameSE) and not iAmWaiting then
        iAmWaiting = true
        BL.info('I have the SE Disinfection debuff, running to safe spot')

        BL.cmd.pauseAutomation()
        mq.delay(100)
        BL.cmd.StandIfFeigned()
        BL.cmd.removeZerkerRootDisc()
        mq.cmdf('/nav locyx %s %s', locX1, locY1)

        BL.WaitForNav()
        mq.delay(1500)
        BL.info("Arrived at safe spot")
    end
    -- Normal check for getting the NW debuff trigger
    if BL.IHaveBuff(debuffNameNW) and not iAmWaiting then
        iAmWaiting = true
        BL.info('I have the NW Contrition debuff, running to safe spot')

        BL.cmd.pauseAutomation()
        mq.delay(100)
        BL.cmd.StandIfFeigned()
        BL.cmd.removeZerkerRootDisc()
        mq.cmdf('/nav locyx %s %s', locX2, locY2)

        BL.WaitForNav()
        mq.delay(1500)
        BL.info("Arrived at safe spot")
    end

    -- Check for resuming if we're waiting and the debuff falls off. 
    -- May have to add a 2nd one later if both debuffs can land at once. 
    if not BL.IHaveBuff(debuffNameSE) and not BL.IHaveBuff(debuffNameNW) and iAmWaiting then
        iAmWaiting = false
        BL.info("Returning to the fight")
        BL.cmd.resumeAutomation()
        BL.cmd.StandIfFeigned()
    end
    BL.checkChestSpawn("a_golden_chest")
    mq.doevents()
    mq.delay(1023)
end