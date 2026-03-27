--- @type Mq
local mq = require('mq')
---@type BL
local BL = require("biggerlib")

BL.info("Xanaxbar Script 1.06 Started")
BL.info("Type /stopxanax to stop the script rather than wait on chest to spawn")
local myClass = mq.TLO.Me.Class.ShortName()
local shouldExit = false

-- Command bind for manual stop
mq.bind('/stopxanax', function()
    BL.info("Manual stop triggered - will exit after cleanup...")
    shouldExit = true
end)

--mq.cmdf("/%s byos off nosave", myClass)
mq.cmdf("/%s memsplash off nosave", myClass)
mq.cmdf("/%s usewardaa off nosave", myClass)
mq.cmdf("/%s usesquall off nosave", myClass)
mq.cmdf("/%s usesplash off nosave", myClass)
mq.cmdf("/%s usenatureboon off nosave", myClass)

-- Only disable alliance for priests (DRU, CLR, SHM)
if myClass == "DRU" or myClass == "CLR" or myClass == "SHM" then
    mq.cmdf("/%s usealliance off nosave", myClass)
end

-- Loop until chest spawns or manual stop
BL.info("Waiting for chest to spawn...")
while not shouldExit do
    -- Check for chest spawn directly instead of using BL.checkChestSpawn
    local chest = mq.TLO.Spawn("A_root-covered_strongbox")
    if chest() and chest.ID() > 0 then
        BL.info("Chest 'A_root-covered_strongbox' has spawned!")
        break
    end
    mq.delay(1000) -- Wait 1 second before checking again
end

if shouldExit then
    BL.info("Manual stop detected - reloading and exiting...")
    -- Check if CWTN TLO exists and any CWTN plugin is loaded
    if mq.TLO.CWTN and mq.TLO.CWTN() then
        mq.cmdf("/%s reload", myClass)
    else
        BL.info("No CWTN plugin loaded, skipping reload")
    end
else
    BL.info("Chest spawned - reloading and exiting...")
    -- Check if CWTN TLO exists and any CWTN plugin is loaded
    if mq.TLO.CWTN and mq.TLO.CWTN() then
        mq.cmdf("/%s reload", myClass)
    else
        BL.info("No CWTN plugin loaded, skipping reload")
    end
end
