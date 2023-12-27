--- @type Mq
local mq = require("mq")
local BL = require("biggerlib")
local Loot = require("biggerlib.loot")

local function lootCorpseForItem(itemNameToLoot)
	BL.info("Enter lootCorpse")
	local didLoot = false
	if mq.TLO.Cursor() then
		Loot.checkCursor()
	end
	if mq.TLO.Me.FreeInventory() <= 0 then
		BL.warn("My bags are full, I can't loot anymore!")
	end
	for i = 1, 3 do
		mq.cmd("/loot")
		mq.delay(1000, function()
			return mq.TLO.Window("LootWnd").Open()
		end)
		if mq.TLO.Window("LootWnd").Open() then
			break
		end
	end

	mq.delay(3000, function()
		return mq.TLO.Window("LootWnd").Open()
	end)
	if not mq.TLO.Window("LootWnd").Open() then
		BL.warn("Can't loot %s right now", mq.TLO.Target.CleanName())
		
		return false
	end
	mq.delay(1000, function()
		return (mq.TLO.Corpse.Items() or 0) > 0
	end)
	local items = mq.TLO.Corpse.Items() or 0
	BL.info("Loot window open. Items: %s", items)

	if mq.TLO.Window("LootWnd").Open() and items > 0 then
		for i = 1, items do
			-- ACTUAL LOOTING HERE
			local corpseItem = mq.TLO.Corpse.Item(i)
			if corpseItem() then
				local itemName = corpseItem.Name()
				if itemName == itemNameToLoot then
					BL.info("Looting %s", itemName)
					Loot.lootItem(i, "leftmouseup")
					didLoot = true
					break
				end
			end
			if not mq.TLO.Window("LootWnd").Open() then
				break
			end
		end
	end
	mq.cmd("/nomodkey /notify LootWnd LW_DoneButton leftmouseup")

	mq.delay(3000, function()
		return not mq.TLO.Window("LootWnd").Open()
	end)

	return didLoot
end

local corpseToLoot = mq.TLO.Spawn("npc corpse radius 500")

if corpseToLoot then
	BL.info("Found npc corpse to loot")
	BL.cmd.pauseAutomation()

	corpseToLoot.DoTarget()
	mq.cmd("/nav target")
	BL.WaitForNav()
	local didLoot = lootCorpseForItem(corpseToLoot.ID(), "Clear Crystal")
	if didLoot then
		BL.info("Looted Successfully")
	else
		BL.warn("Failed to loot")
	end
	mq.delay(1000)
	BL.cmd.resumeAutomation()
else
	BL.info("No npc corpses to loot")
end
