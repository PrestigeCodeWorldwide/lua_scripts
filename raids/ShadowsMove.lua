--- @type Mq
local mq = require("mq")

Luas = {
	'offtankmanual',
	'offtank',
	'offtanking'
}
-- HUGE NOTE: THIS WILL TURN OFF THE OFFTANKING LUA
local function luaCHECK()
	for k, v in ipairs(Luas) do
		if mq.TLO.Lua.Script(v).Status() == 'RUNNING' or mq.TLO.Lua.Script(v).Status() == 'PAUSED' then
			mq.cmdf('/lua pause %s', v)
		end
	end
end

local function init()
	print('Starting ShadowsMove Raid Lua')
	if mq.TLO.Plugin('mq2boxr')() then
		print("\apMQ2Boxr Already Loaded\ap") -- plugin is loaded.. we are good to go
	else
		print("\apLoading MQ2BOXR!\ap")
		mq.cmd("/plugin mq2boxr")
	end
end

local function handleEvents()
	mq.doevents()
end

local function SettingSunReturn()
	mq.cmd('/nav spawn pc ='..mq.TLO.Raid.MainAssist.Name())
	mq.cmd('/multiline ; /mqp off; /boxr unpause')
	luaCHECK()
end

local function SettingSunTriggered()
	mq.cmd('/multiline ; /boxr pause; /mqp on; /backoff on')
	luaCHECK()
	mq.delay('5ms')
	mq.cmd('/rs running from setting sun')
	mq.cmd('/nav loc 930 80 0')
	
end

local function RisingSunCompleted()
	mq.cmd('/nav spawn pc ='..mq.TLO.Raid.MainAssist.Name())
	mq.cmd('/multiline ; /mqp off; /boxr unpause')
	luaCHECK()
	
end

local function RisingSunTriggered()
	mq.cmd('/multiline ; /boxr pause; /mqp on; /backoff on')
	luaCHECK()
	mq.delay('5ms')
	mq.cmd('/rs running to Dawn due to rising sun')
	mq.cmd('/target Dawn')
	mq.delay('1s')
	mq.cmd('/nav target')
end

mq.event("SettingSunRunAway", "#*#Your sun begins to set.#*#", SettingSunTriggered)
mq.event("SettingSunReturn", "#*#Your sun sets.#*#", SettingSunReturn)
mq.event("RisingSunTriggered", "#*#Your sun rises, painfully bright. Less so if you stay at Dawn.#*#", RisingSunTriggered)
mq.event("RisingSunCompleted", "#*#Dawn removes your fear of the Blinding Day ahead.#*#", RisingSunCompleted)


init()

-- if healer, get the Dusk is confused for a moment emote, spam heals on Dusk

while true do
	handleEvents()
	mq.delay(100)
end

