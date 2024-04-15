local mq = require('mq')

local function Event_Dimming()
    print(mq.TLO.Me.Name() .. " will get the cure")
    mq.cmdf('/%s pause on', mq.TLO.Me.Class.ShortName())
    mq.cmd('/mqp on')
    if mq.TLO.Me.Class.ShortName() == "BRD" then
        mq.cmd('/twist stop')
    end
    mq.cmd('/attack off')
    mq.delay(250)
    mq.cmd('/nav spawn spirit')
    mq.delay(100, function() return mq.TLO.Nav.Active() end)
    mq.delay(15000, function() return not mq.TLO.Nav.Active() end)
    mq.cmd('/mqtar spirit')
    mq.delay(750)
    mq.cmd('/say help')
    mq.delay(2000)
    mq.cmd('/mqp off')
    mq.cmdf('/%s pause off', mq.TLO.Me.Class.ShortName())
end

return {eventfunc=Event_Dimming}