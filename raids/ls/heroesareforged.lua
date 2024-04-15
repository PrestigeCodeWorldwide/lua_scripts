---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

local TOONNAMECHANGEME = "Kodajii"

local RunLoop = function()
    -- do autoinventory
    mq.cmd("/autoinventory")
    -- watch for item to appear in inventory
    local findItem = mq.TLO.FindItem("Cinerarium of the Fallen")
    local itemFound = false
    
    if findItem and findItem.ID() > 2 then
        itemFound = true
    end
    -- early out since we don't have the item yet
    if not itemFound then return end;
    
    -- need to stop automation
    BL.cmd.pauseAutomation()
    -- stop cast -- probably unnecessary
    --mq.cmd("/stopcast")
    -- Give Item Hotkey (Edit to change item name then click have an unlimited number of tunes turn in the item.)
    local Target = mq.TLO.Spawn("pc " .. TOONNAMECHANGEME)
    mq.cmdf("/target ID %s", Target.ID())
    mq.cmd('/itemnotify "Cinerarium of the Fallen" leftmouseup')
    mq.cmd("/click left target")
    mq.cmd("/notify GiveWnd GVW_Give_Button leftmouseup")



    BL.cmd.resumeAutomation()
end



while true do
    RunLoop()
    mq.doevents()
    mq.delay(513)
end