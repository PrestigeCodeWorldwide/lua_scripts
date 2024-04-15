local mq = require('mq')

local function condition()
	return mq.TLO.SpawnCount('datiar xi tavuelim npc')() > 0
end

local function action()
	local my_class = mq.TLO.Me.Class.ShortName():lower()
	local slumber = mq.TLO.Spell('Slumber of Jembel').RankName()

	--mq.cmd('/mqp on')
	if mq.TLO.Target.CleanName() ~= 'datiar xi tavuelim' then
		mq.cmd('/twist off')
		mq.cmd('/tar datiar xi tavuelim npc')
		mq.delay(50)
	end
	if mq.TLO.Me.SpellReady(slumber)() and not mq.TLO.Me.Casting() then
		mq.cmdf('/cast %s', slumber)
        mq.delay(100)
        mq.cmd('/g MEZZING')
		mq.delay(900 + mq.TLO.Spell(slumber).MyCastTime())
	end
	--mq.cmd('/mqp off')
end

return { condfunc = condition, actionfunc = action }
