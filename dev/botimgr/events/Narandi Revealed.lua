local mq = require('mq')

local my_class = mq.TLO.Me.Class.ShortName()

local function brdaction()
    mq.cmd('/dgt I am BRD Unpaused!')
    mq.cmd('/boxr Unpause')
    mq.delay(30)
    mq.cmd('/twist start')
end

local function kaaction()
    mq.cmd('/dgt I am KA Toon Unpaused!')
    mq.cmd('/boxr Unpause')
end

local function tankaction()
    mq.cmd('/dgt I am switching to Tank Mode 4!')
    mq.cmd('/cwtns mode 4')
end

local function cwtnaction()
    mq.cmd('/dgt I am CWTN Unpaused!')
    mq.cmd('/boxr Unpause')
    mq.cmd('/cwtns mode 2')
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
