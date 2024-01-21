--- @type Mq
local mq = require("mq")
local BL = require("biggerlib")


while true do
	local inCombat = mq.TLO.Me.Combat()
	
	if not inCombat then
		--target that dude nearby
		local toTarget = mq.TLO.Spawn("npc radius 75")
		if toTarget() then
		--pull it
			BL.cmd.pauseAutomation()
			toTarget.DoTarget()
			BL.info("Aggroing %s", toTarget.CleanName())
			mq.cmd("/alt act 826") -- Cast AA snare to aggro
			mq.delay(1000)
			BL.cmd.resumeAutomation()
		end
	end
	mq.delay(100)
end