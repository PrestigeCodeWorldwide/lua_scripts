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

local function performHealing(healSpells, postHealActions)
	mq.cmd('/target Dusk')
	local healtimer = mq.gettime()
	local now = mq.gettime()
	while now - healtimer < 30000 do
		if not mq.TLO.Me.Casting() then
			for _, spell in ipairs(healSpells) do
				mq.cmd('/cast ' .. spell.name)
				mq.delay(spell.delay)
			end
		end
		now = mq.gettime()
	end
	
	if postHealActions then postHealActions() end
end

local function DuskConfusionHeal()
	mq.cmd('/multiline ; /boxr pause; /mqp on; /backoff on')
	luaCHECK()
	mq.delay('50ms')
	--check to see if my class is shm or cleric
	local myClass = mq.TLO.Me.Class.ShortName()
	if myClass == 'SHM' then
		mq.cmd('/rs Spamming Shaman heals on Dusk')
		performHealing(
			{
				{ name = 'Reckless Rejuvenation', delay = 50 },
				{ name = 'Reckless Renewal', delay = 50 },
				{ name = 'Reckless Resurgence', delay = 100 }
			},
			function()
				mq.cmd('/nav spawn pc =' .. mq.TLO.Raid.MainAssist.Name())
				mq.cmd('/multiline ; /mqp off; /boxr unpause')
			end
		)
	elseif myClass == 'CLR' then
		mq.cmd('/rs Spamming cleric heals on Dusk')
		performHealing(
			{
				{ name = 'Guileless Remedy', delay = 50 },
				{ name = 'Sincere Remedy', delay = 100 }
			},
			function()
				mq.cmd('/nav spawn pc =' .. mq.TLO.Raid.MainAssist.Name())
				mq.cmd('/multiline ; /mqp off; /boxr unpause')
			end
		)
	elseif myClass == 'RNG' then
		mq.cmd('/rs Spamming Ranger heals on Dusk')
		performHealing(
			{
				{ name = 'Darkflow Spring', delay = 50 },
				{ name = 'Lunar Balm', delay = 100 }
			},
			function()
				mq.cmd('/nav spawn pc =' .. mq.TLO.Raid.MainAssist.Name())
				mq.cmd('/multiline ; /mqp off; /boxr unpause')
			end
		)
	elseif myClass == 'BST' then
		mq.cmd('/rs Spamming Beastlord heals on Dusk')
		performHealing(
			{
				{ name = 'Korah', delay = 100 }
			},
			function()
				mq.cmd('/nav spawn pc =' .. mq.TLO.Raid.MainAssist.Name())
				mq.cmd('/multiline ; /mqp off; /boxr unpause')
			end
		)
	end
	
end

mq.event("DuskConfusionHeal", "#*#Dusk is confused for a moment#*#", DuskConfusionHeal)

init()



while true do
	handleEvents()
	mq.delay(100)
end

