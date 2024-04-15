local mq = require('mq')

local my_class = mq.TLO.Me.Class.ShortName()

local function brdaction()
    mq.cmd('/dgt I am BRD Stopping Attack!')
    mq.cmd('/boxr Pause')
    mq.cmd('/attack off')
    mq.cmd('/keypress esc')
    mq.delay(30)
    mq.cmd('/twist stop')
end

local function kaaction()
    mq.cmd('/dgt I am KA Toon Stopping Attack!')
    mq.cmd('/boxr Pause')
    mq.cmd('/attack off')
    mq.cmd('/keypress esc')
end

local function tankaction()
    mq.cmd('/dgt I am Manual Tanking!')
    mq.cmd('/cwtns mode 0')
    mq.cmd('/attack off')
    mq.cmd('/keypress esc')
end

local function cwtnaction()
    mq.cmd('/dgt I am CWTN Stopping Attack!')
    mq.cmd('/boxr Pause')
    mq.cmd('/cwtns mode 0')
    mq.cmd('/attack off')
    mq.cmd('/keypress esc')
end

local actions = {
    BRD = brdaction,
    RNG = kaaction,
    WIZ = kaaction,
    PAL = tankaction,
    SHD = tankaction,
    WAR = tankaction,
    BER = cwtnaction,
    BST = cwtnaction,
    ENC = cwtnaction,
    MAG = cwtnaction,
    MNK = cwtnaction,
    NEC = cwtnaction,
    ROG = cwtnaction,       
}

local function event_handler()
    return actions[my_class]()
end

return {eventfunc=event_handler}
