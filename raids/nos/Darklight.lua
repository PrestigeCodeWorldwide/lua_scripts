local mq = require('mq')

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Luas = {
	'zzbardraid',
	'zzbeast',
	'zzbeastraid',
	'zzerk',
	'zzrogueraid',
	'zzrogue',
	'zzerkraid',
	'zzbard',
	'offtanking',
}
-- HUGE NOTE: THIS WILL TURN OFF THE OFFTANKING LUA
local function luaCHECK()
	for k, v in ipairs(Luas) do
		if
			mq.TLO.Lua.Script(v).Status() == 'RUNNING'
			or mq.TLO.Lua.Script(v).Status() == 'PAUSED'
		then
			mq.cmdf('/lua pause %s', v)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function correct_zone()
	return mq.TLO.Zone.ID() == 855
end

local function init()
	print('Starting Darklight Lua')
	if not mq.TLO.Plugin('mq2boxr')() then
		mq.cmd('/plugin mq2boxr')
	end
end

local function handleEvents()
	mq.doevents()
end

local function ThinningFades()
	mq.cmd('/multiline ; /boxr unpause; /mqp off; /backoff off')
	luaCHECK()
end

local function At_Grakaw()
	local thinningSkinBuff = mq.TLO.Me.Buff('Thinning Skin')()
	if thinningSkinBuff then
		mq.cmd('/multiline ; /boxr pause; /mqp on; /backoff on')
		luaCHECK()
		mq.delay('5ms')
		mq.cmd('/nav loc 900.77 -760.70 190.37')
	end
end

local function At_Spirits()
	local thinningSkinBuff = mq.TLO.Me.Buff('Thinning Skin')()
	if thinningSkinBuff then
		mq.cmd('/multiline ; /boxr pause; /mqp on; /backoff on')
		luaCHECK()
		mq.delay('5ms')
		mq.cmd('/nav loc 688 -849 205')
	end
end

local function At_Grakaw_And_Spirits()
	local thinningSkinBuff = mq.TLO.Me.Buff('Thinning Skin')()
	if thinningSkinBuff then
		mq.cmd('/multiline ; /boxr pause; /mqp on; /backoff on')
		luaCHECK()
		mq.delay('5ms')
		mq.cmd('/nav loc 775 -595 190')
	end
end

local function At_Center()
	local thinningSkinBuff = mq.TLO.Me.Buff('Thinning Skin')()
	if thinningSkinBuff then
		mq.cmd('/multiline ; /boxr pause; /mqp on; /backoff on')
		luaCHECK()
		mq.delay('5ms')
		mq.cmd('/nav loc 688 -849 205')
	end
end

mq.event('AtGrakaw', '#*#Weakness Evinced sends energy at Grakaw.#*#', At_Grakaw)
mq.event('AtSpirits', '#*#Weakness Evinced sends energy at the great spirits.#*#', At_Spirits)
mq.event(
	'AtGrakawAndSpirits',
	'#*#Weakness Evinced sends energy at Grakaw and the great spirits.#*#',
	At_Grakaw_And_Spirits
)
mq.event(
	'AtCenter',
	'#*#Weakness Evinced sends energy toward the center of the cave.#*#',
	At_Center
)
mq.event('ThinningSkinFades', '#*#Your skin is restored#*#', ThinningFades)

init()

while true do
	if correct_zone() then
		handleEvents()
	end
	mq.delay(100)
end
