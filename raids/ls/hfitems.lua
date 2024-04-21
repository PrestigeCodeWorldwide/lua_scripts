---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

local TOONNAMECHANGEME = "Notalaren"

local RunLoop = function()
    -- do autoinventory
    mq.cmd("/autoinventory")
    local itemFound = false
    -- watch for item to appear in inventory
    local findItem = mq.TLO.FindItem("Heroic Ember")
    
    if findItem() and findItem.ID() > 2 then
        itemFound = true
    end
    -- early out since we don't have the item yet
    if not itemFound then return end;
    
    -- need to stop automation
    BL.cmd.pauseAutomation()
    mq.cmd("/brd pause on")
    mq.cmd("/stopcast")
    mq.delay(500)
    
    mq.cmd('/itemnotify "Heroic Ember" rightmouseup')
    mq.delay(500)
    
    -- stop cast -- probably unnecessary
    -- Give Item Hotkey (Edit to change item name then click have an unlimited number of tunes turn in the item.)
    local Target = mq.TLO.Spawn("pc " .. TOONNAMECHANGEME)
    mq.cmdf("/target ID %s", Target.ID())    
    mq.delay(500)
    BL.TargetAndNavTo(TOONNAMECHANGEME)
    
    mq.cmd('/itemnotify "Cinerarium of the Fallen" leftmouseup')
    mq.cmd("/click left target")
    mq.cmd("/notify GiveWnd GVW_Give_Button leftmouseup")
    mq.delay(500)
    BL.cmd.resumeAutomation()
end

while true do
    RunLoop()
    mq.doevents()
    mq.delay(513)
end