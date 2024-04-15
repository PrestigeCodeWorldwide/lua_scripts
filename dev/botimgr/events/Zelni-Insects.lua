local mq = require('mq')

local my_class = mq.TLO.Me.Class.ShortName()

local function event_handler(line, name)
    if not mq.TLO.Zone.ShortName() == 'umbraltwo_raid' then return end

    if name == mq.TLO.Me.CleanName() then
        if my_class == 'BER' and mq.TLO.Me.ActiveDisc.Name() == mq.TLO.Spell('Frenzied Resolve Discipline').RankName() then
            mq.cmd('/stopdisc')
        end
        mq.cmd('/boxr Pause')
        mq.cmd('/keypress Z')
        mq.cmd('/twist stop')
        mq.cmd('/attack off')
        mq.delay(10)
        mq.cmd('/moveto loc -584.06 -138.68')
        mq.delay(8000)
        mq.cmd('/moveto loc -604 -556')
        mq.delay(9500)
        mq.cmd('/moveto loc -864 -550')
        mq.delay(7000)
        mq.cmd('/moveto loc -882 -166')
        mq.delay(8000)
        mq.cmd('/dgt Going back to Raid MA!')
        mq.delay(10)
        mq.cmd('/nav spawn pc ='..mq.TLO.Raid.MainAssist.Name())
        mq.cmd('/boxr Unpause')
        mq.cmd('/twist start')
    end
end

return {eventfunc=event_handler}