--- @type Mq
local mq               = require('mq')
--- @type BL
local BL               = require("biggerlib")

local debuffName       = "Linked Shadow Shackles"
local secondDebuffName = "Shadow Shackles"
local SafeSpot = {
	x = 835,
	y = 133,
	z = -120
}

while true do
	
	if BL.IHaveBuff(debuffName) or BL.IHaveBuff(secondDebuffName) then
		BL.info('I have the AOE debuff, running to safe spot in 12 seconds or when ')
		
		BL.info("Running to safe spot now")
		BL.cmd.pauseAutomation()
		mq.delay(500)
		mq.cmdf('/nav locyxz %s %s %s', SafeSpot.x, SafeSpot.y, SafeSpot.z)
		
		BL.info("Waiting for nav to safe spot to finish")
		BL.WaitForNav()
		
		BL.info('At safe spot, waiting for debuff to fade')
		mq.delay(30000,
		         function() return
		         not BL.IHaveBuff(debuffName)
			         and not BL.IHaveBuff(secondDebuffName)
		         end
		)
		
		BL.info("Debuff Gone, returning to the fight")
		BL.cmd.resumeAutomation()
	end
	
	mq.delay(1023)
end