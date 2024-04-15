local require = ('mq')
local require = ('os')

local function event_handler(line, name)
    if name == mq.TLO.Me.Class.ShortName() == 'PAL' then
        mq.cmd('/boxr Pause')
        mq.delay(4000)
        mq.cmd('/dgt Casting Splash Cure')
        mq.cmd('/cast Splash Of Repentance')
    end
        mq.cmd('/dgt Unpausing Plugin!')
        mq.cmd('/boxr Unpause')
end

return {eventfunc=event_handler}