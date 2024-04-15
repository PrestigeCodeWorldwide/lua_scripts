local mq = require('mq')

local function event_handler()
    if mq.TLO.Me.Ducking() then
        mq.cmd('/stand')
        mq.cmdf('/%s pause off', mq.TLO.Me.Class.ShortName())
        mq.cmd('/mqp off')
    end
end

return {eventfunc=event_handler}