---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

-- do autoinventory
-- watch for item to appear in inventory

-- need to stop automation
BL.cmd.pauseAutomation()
-- stop cast -- probably unnecessary
--mq.cmd("/stopcast")
-- Give Item Hotkey (Edit to change item name then click have an unlimited number of tunes turn in the item.)
local TOONNAMECHANGEME = "Kodajii"
local Target = mq.TLO.Spawn("pc " .. TOONNAMECHANGEME)
mq.cmdf("/target ID %s", Target.ID())
mq.cmd('/itemnotify "Cinerarium of the Fallen" leftmouseup')
mq.cmd("/click left target")
mq.cmd("/notify GiveWnd GVW_Give_Button leftmouseup")



BL.cmd.resumeAutomation()