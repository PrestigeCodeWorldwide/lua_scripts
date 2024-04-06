--- @type Mq
local mq               = require('mq')
--- @type BL
local BL = require("biggerlib")

local debuffName       = "Hot Flames"
local secondDebuffName = "Cold Flames"
local SafeSpot         = {
	x = 952,
	y = -850,
	z = 3
}

local SafeSpotTwo         = {
	x = 980,
	y = -825,
	z = 1
}


while true do
	if BL.IHaveBuff(debuffName) or BL.IHaveBuff(secondDebuffName) then
		BL.info("Running to safe spot now")
		BL.cmd.pauseAutomation()
		mq.delay(500)
		
		-- loop while we have debuff running from place to place
		local nextNav = SafeSpot
		local navTo = "first"
		
		mq.cmdf('/nav locyxz %s %s %s', nextNav.x, nextNav.y, nextNav.z)
		
		BL.info("Waiting for nav to safe spot to finish")
        BL.WaitForNav()
		
		while BL.IHaveBuff(debuffName) or BL.IHaveBuff(secondDebuffName) do
            if navTo == "first" then
                nextNav = SafeSpotTwo
                navTo = "second"
            else
                nextNav = SafeSpot
                navTo = "first"
            end
			
            mq.cmdf('/nav locyxz %s %s %s', nextNav.x, nextNav.y, nextNav.z)
			BL.WaitForNav()
		end
		
		
		BL.info("Debuff Gone, returning to the fight")
		BL.cmd.resumeAutomation()
	end
	
	mq.delay(1023)
end