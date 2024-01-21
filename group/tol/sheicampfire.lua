--sheicampfire.lua

local mq = require('mq')

local function checkcamp()
	if mq.TLO.Me.Fellowship.CampfireZone() ~= mq.TLO.Zone.Name() and mq.TLO.Me.Fellowship.Campfire() and mq.TLO.FindItem("Fellowship Registration Insignia").TimerReady() == 0 and not mq.TLO.Me.Hovering() then
		mq.cmd('/makemevisible')
		mq.cmd("/useitem Fellowship Registration Insignia")
		mq.delay(5000)
		mq.cmd("/useitem Fellowship Registration Insignia")
		mq.delay(1000)
		print('\ayClicking back to camp!')
	end
end
local function CheckMerc()
	if mq.TLO.Mercenary.State() == 'DEAD' then
		mq.cmd('/nomodkey /notify MMGW_ManageWnd MMGW_SuspendButton LeftMouseUp')
	end
	if mq.TLO.Mercenary.State() == 'ACTIVE' and mq.TLO.Mercenary.Stance() == 'Passive' and mq.TLO.Me.Fellowship.CampfireZone() == mq.TLO.Zone.Name() then
		mq.cmd('/nomodkey /stance Balanced')
		print('\agSetting Mercenary to Balanced')
	end
end
local function dead()
	if mq.TLO.Me.Hovering() then
		mq.cmd('/nomodkey /notify RespawnWnd RW_SelectButton LeftMouseUp')
	end
end

while true do
	checkcamp()
	mq.delay(1000)
	--CheckMerc()
	mq.delay(1000)
	dead()
	mq.delay(1000)
end
