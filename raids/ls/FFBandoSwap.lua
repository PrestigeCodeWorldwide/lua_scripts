---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')

local function SwapBandoToMain(line, arg1, arg2)
    BL.info("Swapping to main bando")
    mq.cmd("/bandolier activate main")
end

local function SwapBandoToStun(line, arg1, arg2)
    BL.info("Swapping to stun bando")
    mq.cmd("/bandolier activate stun")
end

mq.event("SwapToStun", "#*#Kar roars, pulls his shield from his back, and sets his feet.#*#", SwapBandoToStun)
mq.event("SwapToMain", "#*#Kar is finally distracted by blows to the head and drops his shield.#*#", SwapBandoToMain)


while true do  
    mq.doevents()
    mq.delay(100)
end
