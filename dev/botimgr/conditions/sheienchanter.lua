local mq = require('mq')

local function condition()
    return mq.TLO.SpawnCount('datiar xi tavuelim npc')() > 0
end

local function action()
    local my_class = mq.TLO.Me.Class.ShortName():lower()
    local addle = mq.TLO.Spell('Addle').RankName()

    mq.cmd('/enc pause on')
    if mq.TLO.Target.CleanName() ~= 'datiar xi tavuelim' then
        mq.cmd("/stopcast")
        mq.cmd('/mqtar datiar xi tavuelim npc')
        mq.delay(50)
    end
    if mq.TLO.Me.SpellReady(addle)() and not mq.TLO.Me.Casting() then
        mq.cmdf('/cast %s', addle)
        mq.delay(1000+mq.TLO.Spell(addle).MyCastTime())
    end
    mq.cmd('/enc pause off')
end

return {condfunc=condition, actionfunc=action}