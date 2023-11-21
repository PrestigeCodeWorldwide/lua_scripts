local mq = require('mq')
local os = require('os')
mq.cmd('/plugin mq2boxr load')

local function runToGrik(line, name)
	if name ~= mq.TLO.Me.Name() then
		return
	end

	local startTime = os.time()
	mq.cmd('/boxr Pause')
	while os.time() - startTime <= 11 do
		mq.cmd('/nav spawn griklor')
		if mq.TLO.Spawn('griklor').Distance() > 20 and not mq.TLO.Nav.Active() then
			mq.cmd('/nav spawn griklor')
		end
		mq.delay(100)
	end
	mq.cmd('/nav spawn pc =' .. mq.TLO.Raid.MainAssist.Name())
	mq.cmd('/boxr Unpause')
end

mq.event('pointed', 'Griklor the Restless roars and points at #1#.', runToGrik)

local function mainLoop()
	while true do
		mq.doevents('pointed')
		mq.delay(50)
	end
end

mainLoop()
