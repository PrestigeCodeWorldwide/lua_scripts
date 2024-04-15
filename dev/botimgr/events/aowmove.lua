local mq = require('mq')

local function event_handler()
    -- Implement the handling for the event here.
    mq.cmd('/tar npc Icebound Avatar of War')
    mq.cmd('/attack on')
    mq.cmd('/nav spawn Icebound Avatar of War')
end

return {eventfunc=event_handler}