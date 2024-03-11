local mq = require('mq')
local BL = require("biggerlib")

local spawnTypes = {
    "A Wizened Sot",
    "A drunken celebrant",
    "a tipsy bargoer",
    
}


while true do
    local spawns = mq.TLO.Spawn("npc radius 50 los targetable")
    --BL.dump(spawns)
    if BL.NotNil(spawns)
        and not mq.TLO.Me.Combat()
    then
        spawns.DoTarget()
        mq.delay(500)
        mq.cmd("/cast 6") -- terror it
    end
    mq.delay(1023)
end