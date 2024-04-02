

local mq = require('mq')

local function healTank()
    for i=1,mq.TLO.Group() do
        mq.cmdf('/target %s', mq.TLO.Group.Member(i).CleanName())
        mq.cmd('/cast "Healing"')
    end
end

local function checkTankHP()
    for i=1,mq.TLO.Group() do
        if mq.TLO.Group.Member(i).PctHPs() < 60 then
            healTank()
        end
    end
end

local function checkTankBuff()
    if not mq.TLO.Target.Buff("Protect")() then
        mq.cmd('/cast "Protect"')
        mq.delay(2000) -- Wait for casting to finish
    end
    if not mq.TLO.Target.Buff("Frenzy")() then
        mq.cmd('/cast "Frenzy"')
    end
end


local function checkHealerStats()
    if mq.TLO.Me.PctHPs() < 20 or mq.TLO.Me.PctMana() < 20 then
        if mq.TLO.Me.Moving() then
            mq.cmd('/echo HEALER IS MOVING, STOP THE GROUP TO HEAL')
            mq.delay(1000) -- Add a delay to give time for the group to stop
        end
        mq.cmd('/target self')
        mq.cmd('/cast "Healing"')
        mq.delay(2000)
    end
end

local function checkEnemy()
    --FIRST WE NEED TO ACTUALLY TARGET THE ENEMY
    mq.cmd('/assist group')
    if not mq.TLO.Target.Buff("Drowsy")() then
        mq.cmd('/cast "Drowsy"')
    end
    --RETARGET THE TANK BEFORE EXITING
    mq.cmd('/target tanky')
end

local function main()
    mq.cmd('/echo STARTING LUA SCRIPT')
    mq.cmd('/memspell 1 "Healing"')
    mq.cmd('/delay 50')
    mq.cmd('/memspell 2 "Protect"')
    mq.cmd('/delay 50')
    mq.cmd('/memspell 3 "Frenzy"')
    mq.cmd('/delay 50')
    mq.cmd('/memspell 4 "Drowsy"')


    while true do
        if mq.TLO.Me.XTarget() > 0 then
            -- In combat
            checkTankHP()
            checkTankBuff()
            checkHealerStats()
            -- only wanna check enemy if we are in combat
            -- and we are good on buffs and heals for tank & healer
            if mq.TLO.Me.PctHPs() > 20 or mq.TLO.Me.PctMana() > 20
            and mq.TLO.Target.Buff("Protect")() 
            and mq.TLO.Target.Buff("Frenzy")() 
            and mq.TLO.Group.Member(1).PctHPs() > 60 then
                checkEnemy()
            end
        else
            -- Out of combat
            checkTankBuff()
            checkHealerStats()
        end
        mq.delay(2000)
    end
end

main()