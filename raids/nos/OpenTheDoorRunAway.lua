---@type Mq
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
}

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
print('\arBrought\ar \ayto\ar \agyou\ag \apby\ap \atZzaddy\ar')

if mq.TLO.Plugin('mq2boxr')() then
	print('\ap MQ2Boxr is loaded!\ap') -- plugin is loaded.. we are good to go
else
	mq.cmd('/plugin mq2boxr')
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Lulling_Dust = function(LullingDust, arg1)
	if not (string.find(arg1, mq.TLO.Me.Name())) then
		mq.cmd('/echo not me')
		mq.cmd('/echo it returned ' .. arg1)
		return
	end
	mq.cmd('/echo me')
	mq.cmd('/multiline ; /mqp on; /boxr pause')
	luaCHECK()
	mq.delay('5ms')
	mq.cmd('/rs  Im running')
	mq.cmd('/nav loc 652.88 -879.63 -89.41')
	while mq.TLO.Navigation.Active() == true do
		mq.delay('3s')
	end
	mq.delay('15s')
	mq.cmd('/multiline ; /mqp off; /boxr unpause')
	luaCHECK()
	mq.flushevents()
end

local emote_2 = function(arg1, arg2, arg3, arg4, arg5)
	if
		string.find(arg1, mq.TLO.Me.CleanName())
		or string.find(arg2, mq.TLO.Me.CleanName())
		or string.find(arg3, mq.TLO.Me.CleanName())
		or string.find(arg4, mq.TLO.Me.CleanName())
		or string.find(arg5, mq.TLO.Me.CleanName())
	then
		luaCHECK()
		mq.cmd('/multiline ; /mqp on; /boxr pause')
		mq.delay('5ms')
		mq.cmd('/rs Im running')
		mq.cmd('/nav loc 652.88 -879.63 -89.41')
		while mq.TLO.Navigation.Active() == true do
			mq.delay('3s')
		end
		mq.delay('15s')
		mq.cmd('/multiline ; /mqp off; /boxr unpause')
		luaCHECK()
		mq.flushevents()
	end
end

mq.event('LullingDust', '#*#Lulling dust begins to move toward #1#', Lulling_Dust)
mq.event(
	'Run_away',
	'#*#The monstrosity\'s single bobbing eye turns toward #1#, #2#, #3#, #4#, and #5##*#',
	emote_2
)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
while true do
	mq.doevents()
	mq.delay(1000)
end
