--[[
    command=
    /docommand ${If[${EventArg1.Equal[${Me}]} && !${Me.ActiveDisc.Name.Equal[Frenzied Resolve Discipline]},
        /multiline ; /docommand /${Me.Class.ShortName} mode 0; /mqp on; /twist off; /timed 5 /afollow off; /nav stop; /target clear; /timed 10 /nav locyxz -101 -773 11; /timed 150 /docommand /${Me.Class.ShortName} mode 2; /timed 150 /mqp off; /twist on,
    /docommand ${If[${EventArg1.Equal[${Me}]} && ${Me.ActiveDisc.Name.Equal[Frenzied Resolve Discipline]},
        /multiline ; /docommand  /say smash,
    /echo BAD]}]}
]]--

local mq = require("mq")

local my_name = mq.TLO.Me.CleanName()
local my_class = mq.TLO.Me.Class.ShortName()

local function event_in_progress()
    -- return true until a darkwood chest spawns
    return mq.TLO.SpawnCount('a darkwood chest')() == 0
end

local function event_handler(line, target)
print(target)
print(my_name)
    local active_disc = mq.TLO.Me.ActiveDisc.Name()
    if target == my_name then
        if active_disc == 'Frenzied Resolve Discipline' then
			mq.cmd('/stopdisc')
		end
        mq.cmdf('/%s mode 0', my_class)
        mq.cmd('/mqp on')
		mq.cmd('/stopdisc')
		mq.cmd('/melee off')
        mq.cmd('/twist off')
        mq.cmd('/afollow off')
        mq.cmd('/nav stop')
        mq.cmd('/target clear')
        mq.cmd('/nav locyxz -101 -773 11')
        mq.delay(15000)
        mq.cmdf('/%s mode 2', my_class)
        mq.cmd('/mqp off')
        mq.cmd('/twist on')

    end
end

mq.event('event_points', '#*#Venril Sathir focuses his Intent on #1#', event_handler)

if not mq.TLO.Zone.ShortName() == 'karnor_raid' then return end
if not event_in_progress() then return end
print('event script started...')

while true
do
    if not event_in_progress() then break end
    mq.doevents()
    mq.delay(10)
end

print('event script ended')
