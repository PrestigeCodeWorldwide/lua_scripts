---@type mq
local mq = require('mq')
local BL = require('biggerlib')
-- Possibly unused and useless
local animItems = mq.FindTextureAnimation('A_DragItem')

GLOBAL_AMMO_SLOT = mq.TLO.Me.Inventory(22).ID()

-- Heavenly Glorious Void Binding Wrist Muhbis (Container)
----------------right click that and put
-- 1 Emblem of the Deceiver,
-- 1 Heavenly Glorious Void Transmogrificant,
-- 1 Exultant Inhabited Muhbis
-- example item to find
local wrist_muhbis = mq.TLO.FindItem("Heavenly Glorious Void Binding Wrist Muhbis")
-- itemslot is which top level inv slot its in
-- these range from to 23 to 32, as priors are for equipment inv slots
local itemslot = wrist_muhbis.ItemSlot()
-- This is sub slot, which is the slot inside of the top level container.
local itemslot2 = wrist_muhbis.ItemSlot2()
BL.log.dump(itemslot .. " : " .. itemslot2)

-- Use the FIRST slot, make it empty in top level inv, this is 23
local TopInventorySlot = mq.TLO.Me.Inventory(23)
local TopInventorySlotID = TopInventorySlot.ID()
BL.log.info("Dumping top inv")
BL.log.dump(TopInventorySlot)
BL.log.dump(TopInventorySlotID)
-- move item to first slot

mq.cmd('/itemnotify "Heavenly Glorious Void Binding Wrist Muhbis" leftmouseup')
mq.delay(250)
-- 23 is pack1, move item to that first slot
mq.cmd('/itemnotify pack1 leftmouseup')
mq.delay(250)
-- right click it to open it
mq.cmd('/itemnotify pack1 rightmouseup')
mq.delay(250)
-- get the first component
mq.cmd('/ctrlkey /itemnotify "Emblem of the Coercer" leftmouseup')
mq.delay(250)
-- put it in first slot
mq.cmd('/itemnotify in pack1 1 leftmouseup')

-- get the second component
mq.cmd('/ctrlkey /itemnotify "Heavenly Glorious Void Transmogrificant" leftmouseup')
mq.delay(250)
-- put it in second slot
mq.cmd('/itemnotify in pack1 2 leftmouseup')

-- get the third component
mq.cmd('/ctrlkey /itemnotify "Exultant Inhabited Muhbis" leftmouseup')
mq.delay(250)
-- put it in third slot
mq.cmd('/itemnotify in pack1 3 leftmouseup')

-- reminder, The window open can be found in /windows open
-- You can also use Window Inspector via MQConsole.  Ex ContainerWindow Container_Combine to hit the combine button
-- local combine_window = mq.TLO.Window("ContainerWindow")

-- This will wait until the combine window is ready, but we shouldn't need to
--while not mq.TLO.Window('ContainerWindow').Child('Container_Combine').Enabled() do
--	mq.delay(10)
--end
mq.cmd('/notify ContainerWindow Container_Combine leftmouseup')
