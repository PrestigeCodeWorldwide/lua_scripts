--- @type Mq
local mq = require('mq')
local BL = require("biggerlib")

BL.info("High Priest Tank Flip Boss Raid Script v1.0 Started")

--Boss Campfire Location: /nav locxyz-113 539 1470
--Safe Spot Campire Location: /nav locxyz 42 380 1470
-- Function to stick Behind
local function StickBehind(line, arg1)
    if mq.TLO.Target.CleanName() ~= "High Priest Yaran" then
        return
    end
    BL.info("Waiting 12 seconds to move to spot 2")
    local classShort = mq.TLO.Me.Class.ShortName()
    mq.delay(12000)
    BL.info("Moving to spot 2")
    mq.cmdf("/docommand /%s mode 0", classShort)
    mq.cmd("/nav locyx 523 -77")
    BL.WaitForNav()
    mq.cmd("/face")
    mq.delay(500)
    mq.cmdf("/docommand /%s mode 4", classShort)
    mq.delay(10000)
    BL.info("Moving to Spot 1")
    mq.cmdf("/docommand /%s mode 0", classShort)
    mq.cmd("/nav locyx 553 -142")
    BL.WaitForNav()
    mq.cmd("/face")
    mq.delay(500)
    mq.cmdf("/docommand /%s mode 4", classShort)
    BL.info("Arrived at Spot 1")
end

mq.event("Behind", "#*#The High Priest tenses and takes a deep breath.#*#", StickBehind)

--Debuff name SE= Purification of Veeshan
--Debuff name NW= Penance for Disobedience
--Debuff SK Test SE= Cloak of Shadows II
while true do

    -- Check if a golden chest has spawned and end script
    BL.checkChestSpawn("a_golden_chest")

    mq.doevents()
    mq.delay(200)
end
