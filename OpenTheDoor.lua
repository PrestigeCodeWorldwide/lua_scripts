---@type Mq
local mq = require('mq')

local required_zone = 'shadowhaventwo_raid'
local bane_mob_name = {'whirling_debris03', 'whirling_debris04', 'whirling_debris05'}
local bane_clean_name = 'whirling_debris'

local banes = {
    BRD={name='Aria of Absolution',type='spell'},
    CLR={name='Sanctified Blood',type='spell'},
    Pal={name='Cure Corruption',type='spell'},
    SHM={name='Cure Corruption',type='spell'},
    DRU={name='Sanctified Blood',type='spell'},
    RNG={name='Lunar Balm',type='spell'}
}

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Luas = {
	'zzbardraid',
	'zzbeast',
	'zzbeastraid',
	'zzerk',
	'zzrogueraid',
	'zzrogue',
	'zzerkraid',
	'zzbard'
}

local function luaCHECK()
	for k,v in ipairs(Luas) do
		if mq.TLO.Lua.Script(v).Status() == 'RUNNING' or mq.TLO.Lua.Script(v).Status() == 'PAUSED'then
			mq.cmdf('/lua pause %s', v)
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
print('\arBrought\ar \ayto\ar \agyou\ag \apby\ap \atZzaddy\ar')

if mq.TLO.Plugin('mq2boxr')() then
    print("\ap MQ2Boxr is loaded!\ap") -- plugin is loaded.. we are good to go 
	else mq.cmd("/plugin mq2boxr") 
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function StopDPS()
    mq.cmd('/squelch /mqp on')
    mq.delay(10)
    if mq.TLO.Me.Class.ShortName() == 'BRD' then
        mq.cmd('/squelch /twist off')
        mq.delay(10)
        mq.cmd('/squelch /stopsong')
        mq.delay(10)
    end
    mq.cmd('/squelch /boxr pause')
    mq.delay(10)
    while mq.TLO.Me.Casting.ID() do
       mq.delay(200)
    end
end
local function ResumeDPS()
   mq.cmd('/squelch /mqp off')
   mq.delay(10)
   if mq.TLO.Me.Class.ShortName() == 'BRD' then
    mq.cmd('/squelch /twist on')
    mq.delay(10)
   end
   mq.cmd('/squelch /boxr unpause')
   mq.delay(10)
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function on_load()
    if mq.TLO.Zone.ShortName() ~= required_zone then return end
    local bane = banes[mq.TLO.Me.Class.ShortName()]
    local spellname = mq.TLO.Spell(bane.name).RankName()
    if bane and bane.type == 'spell' then
        if mq.TLO.Me.Gem('13')() == spellname then return 
        else
            StopDPS()
            mq.cmdf('/memspellslot 13 %s', spellname)
            mq.cmdf('/g Memming %s', spellname)
			while mq.TLO.Window("SpellBookWnd").Open() do
				mq.delay(50)
            end
            ResumeDPS()
        end  
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function cast(spell)
    mq.cmdf('/cast %s', spell.RankName())
    mq.delay(50+spell.MyCastTime())
end

local function use_aa(aa)
    mq.cmdf('/alt activate %s', aa.ID())
    mq.delay(50+aa.Spell.CastTime())
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function bane_ready(bane)
    if bane.type == 'spell' then
        return mq.TLO.Me.SpellReady(bane.name) and not mq.TLO.Me.Casting()
    elseif bane.type == 'aa' then
        return mq.TLO.Me.AltAbilityReady(bane.name) and not mq.TLO.Me.Casting()
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function correct_zone()
    if mq.TLO.Zone.ShortName() ~= required_zone then
        printf('\ag-->\arWrong Zone - Exiting\ag<--')
        mq.exit()
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local Lulling_Dust = function (LullingDust, arg1)
	if not(string.find(arg1,mq.TLO.Me.Name())) then
		mq.cmd('/echo not me')
        mq.cmd('/echo it returned '.. arg1)
        return
	end
    mq.cmd('/echo me')
    mq.cmd('/multiline ; /mqp on; /boxr pause')
    luaCHECK()
    mq.delay('5ms')
    mq.cmd('/g  Im running')
    mq.cmd('/nav loc 652.88 -879.63 -89.41')
    while mq.TLO.Navigation.Active() == true do
        mq.delay('3s')
    end
    mq.delay('15s')
    mq.cmd('/multiline ; /mqp off; /boxr unpause')
    luaCHECK()
    mq.flushevents()
end

local emote_2 = function (arg1, arg2, arg3, arg4, arg5)
	if string.find(arg1,mq.TLO.Me.CleanName()) or string.find(arg2,mq.TLO.Me.CleanName()) or string.find(arg3,mq.TLO.Me.CleanName()) or string.find(arg4,mq.TLO.Me.CleanName()) or string.find(arg5,mq.TLO.Me.CleanName()) then
        luaCHECK()
        mq.cmd('/multiline ; /mqp on; /boxr pause')
        mq.delay('5ms')
        mq.cmd('/g Im running')
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
mq.event('Run_away', "#*#The monstrosity's single bobbing eye turns toward #1#, #2#, #3#, #4#, and #5##*#", emote_2)





---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local function main()
    local my_class = mq.TLO.Me.Class.ShortName()
    local bane = banes[my_class]
	for k,v in ipairs(bane_mob_name) do
        if (mq.TLO.SpawnCount(bane_clean_name)() > 3) and (mq.TLO.SpawnCount((v ..' radius 125'):format(v))() > 0) then
            mq.cmd('/echo Attempting to Bane ' .. v)
        else
            return
        end
            if not bane then return end
            if my_class ~= 'BRD' and not bane_ready(bane) then return end
            StopDPS()
            if mq.TLO.Target.CleanName() ~= v then
                mq.cmdf('/mqtar %s npc', v)
                mq.delay(50)
            end
            mq.delay('2s')
            if bane.type == 'spell' then
                cast(mq.TLO.Spell(bane.name))
            else
                use_aa(mq.TLO.Me.AltAbility(bane.name))
            end
            while mq.TLO.Me.Casting() do
                mq.doevents()
                mq.delay(50)
            end
        ResumeDPS()
        if mq.TLO.SpawnCount(bane_clean_name)() < 4 then
            return
        end
    end
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
while true do
	correct_zone()
    if mq.TLO.Me.Class.ShortName() == 'BRD' or mq.TLO.Me.Class.ShortName() == 'SHM' or mq.TLO.Me.Class.ShortName() == 'PAL' or mq.TLO.Me.Class.ShortName() == 'DRU' or mq.TLO.Me.Class.ShortName() == 'RNG' then
        on_load()
    end
    mq.doevents()
    if mq.TLO.Me.Class.ShortName() == 'BRD' or mq.TLO.Me.Class.ShortName() == 'SHM' or mq.TLO.Me.Class.ShortName() == 'PAL' or mq.TLO.Me.Class.ShortName() == 'DRU' or mq.TLO.Me.Class.ShortName() == 'RNG' then
        if mq.TLO.SpawnCount(bane_clean_name)() > 3 then
        main()
        else
        mq.delay ('2s')
        end
    end
end