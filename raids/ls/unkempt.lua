--- @type Mq
local mq               = require('mq')
--- @type BL
local BL               = require("biggerlib")

--- NOTES
--- Everyone runs this except the main tank
--- It runs 550 units from the farthest leash boundary when wasps'd
--- It echoes into /rs when dotted with sticky tick tockker
--- It requires companion script unkemptruner to be running on clerics/enchanters

local stickyDebuff = "Sticky Tick Tocker"
local waspDebuff = "War Wasps"

local SafeSpot = {
	x = 325,
	y = 1,
	z = -22
}

local lastEchoTime = 0
-- Only ask for sticky once every 30 seconds at most
local echoDelay = 30000

local function doWaspRunAway()
	BL.info('I have the Wasp debuff, running to safe spot')
	BL.cmd.pauseAutomation()
	mq.delay(500)
	mq.cmdf('/nav locyxz %s %s %s', SafeSpot.x, SafeSpot.y, SafeSpot.z)
	
	BL.info("Waiting for nav to safe spot to finish")
	BL.WaitForNav()
	
	BL.info('At safe spot, waiting for debuff to fade')
	mq.delay(30000,
	         function() return
	         not BL.IHaveBuff(debuffName)
	         end
	)
	
	BL.info("Debuff Gone, returning to the fight")
	BL.cmd.resumeAutomation()
end

while true do
	local now = mq.gettime()
	if
		now - lastEchoTime > echoDelay
		and BL.IHaveBuff(stickyDebuff)
	then
		mq.cmdf("/rs IAMSTICKY %s IAMSTICKY", mq.TLO.Me.CleanName())
		lastEchoTime = now
	end
	
	if BL.IHaveBuff(waspDebuff) then
		doWaspRunAway()
	end
	
	mq.delay(1023)
end