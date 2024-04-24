---@type Mq
local mq = require("mq")

while true do
    local me = mq.TLO.Me
    local target = mq.TLO.Target 
    local xtarCount = me.XTarget()
    
    if xtarCount < 3 and
       not mq.TLO.Target.Named() and
       not me.Bandolier("2H").Active()
    then
        mq.cmd("/bandolier activate 2H")
    end
    
    if (me.XTarget() >= 3 or target.Named()) and
        not me.Bandolier("Shield").Active()
    then 
        mq.cmd("/bandolier activate Shield")
    end
    
    mq.delay(223)
end
