local mq = require('mq')

local function event_handler(line, name)
    if name == mq.TLO.Me.CleanName() and not mq.TLO.Me.Ducking() then
        -- pause automation, alternatively have autostand off
        mq.cmdf('/%s pause on', mq.TLO.Me.Class.ShortName())
        mq.cmd('/keypress DUCK')
    end
end

return {eventfunc=event_handler}