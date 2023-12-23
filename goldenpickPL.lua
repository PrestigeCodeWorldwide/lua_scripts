--- @type Mq
local mq = require('mq')

local OnHitEventMatcher = '#1# hit#*#for 1 points of non-melee damage#*#'

mq.event('HitCurrentMobSuccessfullyEvent', OnHitEventMatcher, function()
	print('HitCurrentMobSuccessfullyEvent')
end)

local function main()
	local NumMobs = 1
	local MobAdded = 0
	local MobRadius = 180
	local MobHit = 0

	while true do
		mq.delay(1000)
	end
end
--Sub Main
--  /declare MobID[100] int outer
--  /declare i int outer
--  /declare j int outer
--  /declare k int outer
--  /declare NumMobs int outer 1
--  /declare MobAdded int outer 0
--  /declare MobRadius int outer 180
--  /declare MobHit int outer 0
--  :loop
--    /delay 1
--    /if (${NearestSpawn[1,NPC zradius 100].Distance}>${MobRadius} && ${NumMobs}>1) {
--      /bc Reseting NumMobs = 1
--      /varset NumMobs 1
--    }

--    /if (${NearestSpawn[1,NPC zradius 100].Distance}>${MobRadius}) /goto :loop

--    /for k 1 to ${SpawnCount[NPC radius ${MobRadius} zradius 100]}
--      /varset MobAdded 0

--      /for j 1 to ${NumMobs}
--        /if (${MobID[${j}]}==${NearestSpawn[${k},NPC zradius 100 radius ${MobRadius}].ID}) /varset MobAdded 1
--      /next j

--      /if (!${MobAdded}) {
--        /tar id ${NearestSpawn[${k},NPC zradius 100 radius ${MobRadius}].ID}
--        /delay 20 ${Target.ID}==${NearestSpawn[${k},NPC zradius 20 radius ${MobRadius}].ID}
--        /if (${Target.ID}) {
--           /varset MobHit 0
--           /face fast
--           /attack on
--           /stick 10

--           /doevents
--           /for i 1 to 5
--             /attack on
--             /delay 1s ${MobHit}
--             /if (${MobHit}) /goto :isHit
--             /doevents
--           /next i

--           :isHit
--           /if (${MobHit}) {
--            /varcalc NumMobs ${NumMobs}+1
--            /varset MobID[${NumMobs}] ${Target.ID}
--            /bc Added [+y+]${Target.ID} as target ${NumMobs}
--          }

--          /attack off
--        }
--      }
--  /next k

--  /goto :loop
--/return

--Sub Event_OnHit(Line, cName)
--    /if (${cName.Equal[${Me.Name}]}) /varset MobHit 1
--/return
