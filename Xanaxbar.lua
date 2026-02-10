--- @type Mq
local mq = require('mq')
---@type BL
local BL = require("biggerlib")

BL.info("Xanaxbar Script 1.01 Started")
local myClass = mq.TLO.Me.Class.ShortName()

mq.cmdf("/%s byos off nosave", myClass)
mq.cmdf("/%s memsplash off nosave", myClass)
mq.cmdf("/%s usewardaa off nosave", myClass)
mq.cmdf("/%s usesquall off nosave", myClass)
mq.cmdf("/%s usesplash off nosave", myClass)
mq.cmdf("/%s usenatureboon off nosave", myClass)

-- Only disable alliance for priests (DRU, CLR, SHM)
if myClass == "DRU" or myClass == "CLR" or myClass == "SHM" then
    mq.cmdf("/%s usealliance off nosave", myClass)
end
