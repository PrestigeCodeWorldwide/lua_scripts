---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')

BL.info("FFBandoSwap Script v1.1 Started")

local function SwapBandoToMain(line, arg1, arg2)
    if mq.TLO.Me.Class.ShortName() == "BRD" or mq.TLO.Me.Class.ShortName() == "ROG" then
        BL.info("Swapping to main bando")
        mq.cmd("/bandolier activate main")
    else
        BL.info("You are not a bard or rogue, skipping bando swap")
    end
end

local function SwapBandoToStun(line, arg1, arg2)
    if mq.TLO.Me.Class.ShortName() == "BRD" or mq.TLO.Me.Class.ShortName() == "ROG" then
        BL.info("Swapping to stun bando")
        mq.cmd("/bandolier activate stun")
    else
        BL.info("You are not a bard or rogue, skipping bando swap")
    end
end

mq.event("SwapToStun", "#*#Kar roars, pulls his shield from his back, and sets his feet.#*#", SwapBandoToStun)
mq.event("SwapToMain", "#*#Kar is finally distracted by blows to the head and drops his shield.#*#", SwapBandoToMain)


while true do
    BL.checkChestSpawn("a_war_chest")
    mq.doevents()
    mq.delay(100)
end
