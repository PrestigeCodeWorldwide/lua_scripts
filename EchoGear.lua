--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("EchoGear Script v1.1 Started")
mq.cmd("/plugin boxr load")

-- Configuration: which slots to manage
local config = {
    slots = {
        "leftwrist", "rightwrist", "leftear", "rightear", "shoulder"
        -- Add more slots here as needed
    }
}

-- Track removed items: {slotName = {name = "ItemName", stored = true}}
local removed_items = {}

-- Find first open bag/inventory slot
local function find_first_open_slot()
    -- Check bags in main inventory first (pack1-10 = slots 23-32)
    for pack = 1, 10 do
        local bag = mq.TLO.Me.Inventory(pack + 22)  -- pack1 = slot 23, pack2 = slot 24, etc.
        if bag() and bag.Container() and bag.Container() > 0 then
            for slot = 1, bag.Container() do
                local item = bag.Item(slot)
                if not item() then
                    return pack, slot  -- Return pack number (1-10) and inner slot number
                end
            end
        end
    end

    -- Check general inventory slots (1-22 are equipped, 23-34 are main inventory)
    for invSlot = 23, 34 do
        local item = mq.TLO.Me.Inventory(invSlot)
        if not item() then
            return invSlot, nil  -- Main inventory slot, no bag slot needed
        end
    end

    return nil, nil  -- No space found
end

-- Remove item from equipped slot and stow in first open slot
local function remove_and_stow(slotName)
    -- Check if slot has an item
    local item = mq.TLO.Me.Inventory(slotName)
    if not item() then
        BL.info("No item in " .. slotName .. " slot")
        return false
    end

    local itemName = item.Name()
    local slotNum = item.ItemSlot()

    -- Check if cursor is free
    if mq.TLO.Cursor() then
        BL.info("Cursor not free, cannot remove " .. slotName)
        return false
    end

    -- Pick up the item
    mq.cmdf('/itemnotify %s leftmouseup', slotName)
    mq.delay('1s')

    -- Verify item is on cursor
    if not mq.TLO.Cursor() then
        BL.info("Failed to pick up item from " .. slotName)
        return false
    end

    -- Find first open slot
    local invSlot, bagSlot = find_first_open_slot()
    if not invSlot then
        BL.info("No open inventory/bag space found")
        return false
    end

    -- Stow the item
    if bagSlot then
        -- Put in bag slot (invSlot is pack number 1-10)
        BL.info(string.format("Stowing in pack%d slot%d", invSlot, bagSlot))
        mq.cmdf('/itemnotify in pack%d %d leftmouseup', invSlot, bagSlot)
    else
        -- Use autoinventory for main inventory slots
        BL.info("Using autoinventory to stow item")
        mq.cmd('/autoinventory')
    end
    mq.delay('500ms')

    -- Verify cursor is clear
    if mq.TLO.Cursor() then
        BL.info("Failed to stow item from " .. slotName)
        return false
    end

    -- Track the removed item
    removed_items[slotName] = {
        name = itemName,
        stored = true
    }

    BL.info("Successfully removed and stowed " .. slotName .. " (" .. itemName .. ")")
    return true
end

-- Find item in inventory/bags by name
local function find_item_in_inventory(itemName)
    -- Check main inventory slots
    for invSlot = 23, 34 do
        local item = mq.TLO.Me.Inventory(invSlot)
        if item() and item.Name() == itemName then
            return invSlot, nil
        end
    end

    -- Check bags
    for pack = 1, 10 do
        local bag = mq.TLO.Me.Inventory(pack + 22)
        if bag() and bag.Container() and bag.Container() > 0 then
            for slot = 1, bag.Container() do
                local item = bag.Item(slot)
                if item() and item.Name() == itemName then
                    return pack + 22, slot
                end
            end
        end
    end

    return nil, nil
end

-- Equip item back to its original slot
local function equip_item(slotName)
    local itemInfo = removed_items[slotName]
    if not itemInfo or not itemInfo.stored then
        BL.info("No tracked item for " .. slotName)
        return false
    end

    -- Check if cursor is free, if not clear it
    if mq.TLO.Cursor() then
        BL.info("Cursor not free, running /autoinventory to clear")
        mq.cmd('/autoinventory')
        mq.delay('500ms')
        if mq.TLO.Cursor() then
            BL.info("Cursor still not free after /autoinventory")
            return false
        end
    end

    -- Find the item in inventory
    local invSlot, bagSlot = find_item_in_inventory(itemInfo.name)
    if not invSlot then
        BL.info("Could not find " .. itemInfo.name .. " in inventory")
        return false
    end

    -- Pick up the item
    if bagSlot then
        mq.cmdf('/itemnotify in pack%d %d leftmouseup', invSlot - 22, bagSlot)
    else
        mq.cmdf('/itemnotify %d leftmouseup', invSlot)
    end
    mq.delay('1s')

    -- Verify item is on cursor
    if not mq.TLO.Cursor() then
        BL.info("Failed to pick up " .. itemInfo.name)
        return false
    end

    -- Use autoinventory to equip it back to its original slot
    BL.info("Equipping " .. itemInfo.name .. " back to " .. slotName)
    mq.cmd('/autoinventory')
    mq.delay('500ms')

    -- Verify cursor is clear
    if mq.TLO.Cursor() then
        BL.info("Failed to equip " .. itemInfo.name)
        return false
    end

    -- Update tracking
    removed_items[slotName] = {
        name = itemInfo.name,
        stored = false
    }

    BL.info("Successfully equipped " .. slotName .. " (" .. itemInfo.name .. ")")
    return true
end

-- Remove all configured slots
local function unequip_all()
    -- Clear cursor before starting
    if mq.TLO.Cursor() then
        BL.info("Cursor not free, running /autoinventory to clear before unequipping")
        mq.cmd('/autoinventory')
        mq.delay('500ms')
    end

    for _, slotName in ipairs(config.slots) do
        remove_and_stow(slotName)
    end
end

-- Equip all configured slots
local function equip_all()
    for _, slotName in ipairs(config.slots) do
        local success, err = pcall(equip_item, slotName)
        if not success then
            BL.info("Error equipping " .. slotName .. ": " .. tostring(err) .. ", continuing to next item")
        end
    end
end

-- Command handler
local function echo_gear_command(cmd)
    local args = string.lower(cmd)
    if args == "equip" then
        BL.info("EchoGear: Equipping all items")
        equip_all()
    elseif args == "unequip" then
        BL.info("EchoGear: Unequipping all items")
        unequip_all()
    else
        BL.info("EchoGear Usage: /echogear equip | /echogear unequip")
    end
end

-- Register command
mq.bind('/echogear', echo_gear_command)
BL.info("EchoGear: Commands registered - /echogear equip, /echogear unequip")

-- Main event loop
local running = true
while running do
    mq.delay('1s')
end






