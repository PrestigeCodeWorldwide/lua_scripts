--- @type Mq
local mq = require("mq")
local BL = require("biggerlib")

local Loot = {}
Loot.isLooting = false

function Loot.checkCursor()
	local currentItem = nil
	while mq.TLO.Cursor() do
		-- can't do anything if there's nowhere to put the item, either due to no free inventory space
		-- or no slot of appropriate size
		if mq.TLO.Me.FreeInventory() == 0 or mq.TLO.Cursor() == currentItem then
			BL.warn("My bags are full, I can't stash this loot on my cursor anymore!")
			mq.cmd("/autoinv")
			return
		end
		currentItem = mq.TLO.Cursor()
		mq.cmd("/autoinv")
		mq.delay(100)
	end
end

---@param index number @The current index we are looking at in loot window, 1-based.

---@param button string @The mouse button to use to loot the item. Currently only leftmouseup implemented.
function Loot.lootItem(index, button)
	BL.info("Enter lootItem")

	local itemName = mq.TLO.Corpse.Item(index).Name()
	mq.cmdf("/nomodkey /shift /itemnotify loot%s %s", index, button)
	-- Looting of no drop items is currently disabled with no flag to enable anyways
	--mq.delay(5000, function() return mq.TLO.Window('ConfirmationDialogBox').Open() or not mq.TLO.Corpse.Item(index).NoDrop() end)
	--if mq.TLO.Window('ConfirmationDialogBox').Open() then mq.cmd('/nomodkey /notify ConfirmationDialogBox Yes_Button leftmouseup') end
	mq.delay(5000, function()
		return mq.TLO.Cursor() ~= nil or not mq.TLO.Window("LootWnd").Open()
	end)
	mq.delay(1) -- force next frame
	-- The loot window closes if attempting to loot a lore item you already have, but lore should have already been checked for
	if not mq.TLO.Window("LootWnd").Open() then
		return
	end
	BL.warn("Looting %s", itemName)

	if mq.TLO.Cursor() then
		checkCursor()
	end
end

return Loot
