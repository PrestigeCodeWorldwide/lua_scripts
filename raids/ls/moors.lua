--- @type Mq
local mq = require('mq')
local BL = require("biggerlib")

while true do
    local debuffName = "Attractive Enemies"		
    local locX = 1002
    local locY = -3

    if BL.IHaveBuff(debuffName) then
        BL.info('I have the AOE debuff, running to safe spot in 12 seconds or when ')
        mq.delay(18000, function() return not BL.IHaveBuff(debuffName) end)
        
        BL.info("Running to safe spot now")
        BL.cmd.pauseAutomation()
        mq.delay(500)
        mq.cmdf('/nav locyx %s %s', locX, locY)
        
        BL.info("Waiting for nav to safe spot to finish")
        BL.WaitForNav()
        
        BL.info('At safe spot, waiting for 18 seconds based on parsed timer')
        mq.delay(18000)
        
        BL.info("Returning to the fight")
        BL.cmd.resumeAutomation()
    end
    
    mq.delay(1023)
end