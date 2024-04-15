local mq = require('mq')
    
local function event_handler()
   if mq.TLO.Me.Class.ShortName() == 'PAL' then
    mq.cmd('/pal splashcureonly on')
    mq.cmd('/pal pause on')
    mq.cmd('/stopcast')
    mq.cmd('/target clear')
    mq.delay(1500)
    mq.cmd('/cast Splash of Repentance')
    mq.delay(1400)
    mq.cmd('/assist ${Raid.MainAssist.Name}')
    mq.delay(700)
    mq.cmd('/attack on')
    mq.cmd('/stick front 14')
    mq.delay(17500)
    mq.cmd('/stopcast')
    mq.cmd('/target clear')
    mq.cmd('/cast Splash of Repentance')
    mq.delay(1400)
    mq.cmd('/assist ${Raid.MainAssist.Name}')
    mq.delay(700)
    mq.cmd('/attack on')
    mq.cmd('/stick front 14')
  end
end
return {eventfunc=event_handler}