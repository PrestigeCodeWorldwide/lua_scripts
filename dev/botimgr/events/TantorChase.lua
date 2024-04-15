local mq = require('mq')

local my_class = mq.TLO.Me.Class.ShortName()

local function event_handler(line, name)
    if not mq.TLO.Zone.ShortName() == 'westernwastestwo_raid' then return end

    if name == mq.TLO.Me.CleanName() then
        if my_class == 'BER' and mq.TLO.Me.ActiveDisc.Name() == mq.TLO.Spell('Frenzied Resolve Discipline').RankName() then
            mq.cmd('/stopdisc')
        end
        mq.cmd('/boxr Pause')
        mq.cmd('/keypress Z')
        mq.cmd('/twist stop')
        mq.cmd('/attack off')
        mq.cmd('/keypress esc')
        mq.delay(10)
        mq.cmd('/circle on 204')
        mq.delay(10)
        mq.cmd('/circle loc -646.06 -936.68')
        mq.delay(15000)
        mq.cmd('/dgt Going back to Raid MA!')
        mq.cmd('/circle off')
        mq.delay(10)
        mq.cmd('/nav spawn pc ='..mq.TLO.Raid.MainAssist.Name())
        mq.cmd('/boxr Unpause')
        mq.cmd('/twist start')
    end
end

return {eventfunc=event_handler}