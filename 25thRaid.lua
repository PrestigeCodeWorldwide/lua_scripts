local mq = require("mq")
local BL = require("biggerlib")

BL.info("25th Anni Raid Script v1.06 Started")


local my_name = mq.TLO.Me.CleanName()
local my_class = mq.TLO.Me.Class.ShortName()
mq.cmdf ("/%s autostandonduck off nosave", my_class)
local shouldExit = false

-- Command bind for manual stop
mq.bind('/stop25th', function()
    BL.info("Manual stop triggered - will exit after cleanup...")
    shouldExit = true
end)

local function duck_handler(line, target)
    print("Duck emote detected!")
    print("My class:", my_class)
    
    -- Wait 4 seconds before processing
    print("Waiting 5 seconds before ducking...")
    mq.delay(5000)
    
    -- Classes that should NOT duck
    local exempt_classes = {"CLR", "DRU", "SHM", "SHD", "PAL", "WAR"}
    local should_duck = true
    
    -- Check if my class is exempt
    for _, exempt_class in ipairs(exempt_classes) do
        if my_class == exempt_class then
            should_duck = false
            break
        end
    end
    
    if should_duck then
        BL.info("Ducking for 12 seconds...")
        BL.cmd.pauseAutomation()
        -- Stop any casting/songs
        mq.cmd("/stopcast")
        mq.cmd("/stopsong")
        mq.cmd("/target clear")
        mq.cmd("/attack off")
        mq.delay(300)
        -- Make sure we're standing before ducking
        local my_state = mq.TLO.Me.State()
        if my_state and (my_state == "SIT" or my_state == "FEIGN") then
            mq.cmd("/stand")
            mq.delay(1000)  -- Wait for stand to complete
        end
        -- Only duck if not already ducked
        if not mq.TLO.Me.Ducking() then
            mq.cmd("/keypress DUCK")
        end
        -- Wait 12 seconds while ensuring we stay ducked
        local duck_duration = 12000
        local start_time = os.clock()
        local check_interval = 500  -- Check every 500ms
        
        while (os.clock() - start_time) * 1000 < duck_duration do
            -- Check if we're still ducked, if not re-press duck
            if not mq.TLO.Me.Ducking() then
                BL.info("Lost duck state - re-ducking...")
                mq.cmd("/keypress DUCK")
            end
            mq.delay(check_interval)
        end
        mq.cmd("/stand")
        BL.cmd.resumeAutomation()
        BL.info("Duck complete - resuming automation")
    else
        BL.info(string.format("I'm a %s -- Register duck emote (affects everyone)", my_class))
    end
end

-- Trash pickup handler
local function trash_handler(line, target)
    print("Trash pickup emote detected!")
    print("My class:", my_class)
    
    -- Classes that should NOT pick up trash
    local exempt_classes = {"CLR", "DRU", "SHM"}
    local should_pickup = true
    
    -- Check if my class is exempt
    for _, exempt_class in ipairs(exempt_classes) do
        if my_class == exempt_class then
            should_pickup = false
            break
        end
    end
    
    if should_pickup then
        BL.info("Looking for trash to pick up...")
        BL.cmd.pauseAutomation()
        
        -- Find nearest ground spawn (trash)
        BL.info("Searching for ground items...")
        
        -- Wait for ground spawns to appear (up to 10 seconds)
        local max_wait_time = 150000  -- 15 seconds max wait
        local wait_start = os.clock()
        local ground_search = nil
        
        while (os.clock() - wait_start) * 1000 < max_wait_time do
            ground_search = mq.TLO.Ground.Search("")
            BL.info("Ground search result: " .. tostring(ground_search))
            if ground_search then
                break  -- Found items, stop waiting
            end
            BL.info("No ground items found yet, waiting...")
            mq.delay(1000)  -- Wait 1 second before retrying
        end
        
        if ground_search then
            -- Try to find and pick up ALL valid ground items within range
            local max_distance = 800  -- Maximum distance to travel for pickup
            local processed_ids = {}  -- Track processed IDs to avoid duplicates
            local items_picked_up = 0
            
            -- Keep looping until no more valid items found
            local found_any = true
            while found_any do
                found_any = false
                
                for i = 1, 10 do  -- Check first 10 items
                    local item = ground_search[i]
                    if item and item.ID and item.ID() > 0 then
                        local item_id = item.ID()
                        
                        -- Skip if we already processed this ID
                        if processed_ids[item_id] then
                            --BL.info("Skipping duplicate ground item ID: " .. item_id)
                        else
                            processed_ids[item_id] = true
                            local distance = item.Distance()
                            BL.info("Ground item at index " .. i .. " with ID: " .. item_id .. " distance: " .. distance)
                            
                            if distance and distance <= max_distance then
                                found_any = true
                                items_picked_up = items_picked_up + 1
                                BL.info("Picking up item " .. items_picked_up .. " at index " .. i .. " with ID: " .. item_id .. " distance: " .. distance)
                                
                                -- Navigate to ground spawn
                                local item_x, item_y, item_z = item.X(), item.Y(), item.Z()
                                if item_x and item_y and item_z then
                                    mq.cmdf("/nav locxyz %d %d %d", item_x, item_y, item_z)
                                    BL.WaitForNav()
                                else
                                    BL.info("Item coordinates invalid, skipping")
                                    break
                                end
                                
                                -- Pick up item
                                if item and item.ID() > 0 then
                                    item.Grab()
                                    mq.delay(1000)
                                else
                                    BL.info("Item disappeared before pickup, skipping")
                                    break
                                end
                                
                                -- Wait for item to appear on cursor
                                local cursor_wait = 0
                                local max_cursor_wait = 5000  -- Wait up to 5 seconds for cursor
                                local saved_item_name = nil  -- Store item name from cursor
                                
                                while not mq.TLO.Cursor() and cursor_wait < max_cursor_wait do
                                    mq.delay(100)
                                    cursor_wait = cursor_wait + 100
                                end
                                
                                if mq.TLO.Cursor() and mq.TLO.Cursor() ~= "" then
                                    local cursor_item_name = mq.TLO.Cursor()
                                    saved_item_name = cursor_item_name
                                end
                                
                                -- Now open inventory and use the saved item name
                                mq.cmd("/autoinventory")
                                mq.delay(500)  -- Wait for inventory to update
                                
                                if saved_item_name and saved_item_name ~= "" then
                                    mq.cmdf("/useitem %s", saved_item_name)
                                    mq.delay(1000)  -- Wait for item use to complete
                                end
                                
                                -- Refresh search after pickup
                                local new_search = mq.TLO.Ground.Search("")
                                if new_search then
                                    ground_search = new_search
                                else
                                    ground_search = nil
                                end
                                break  -- Restart loop with fresh search
                            else
                                BL.info("Ground item too far: " .. distance .. " > " .. max_distance)
                            end
                        end
                    end
                end
                
                if not found_any then
                    BL.info("No more valid ground items found within range")
                end
            end
            
            BL.info("Total items picked up: " .. items_picked_up)
        else
            BL.info("No ground items found")
        end
        
        BL.cmd.resumeAutomation()
    else
        BL.info(string.format("I'm a %s - exempt from trash pickup", my_class))
    end
end

-- Register events
mq.event('duck_event', '#*#Everyone feels a compulsion to duck#*', duck_handler)
--mq.event('trees_event', '#*#Everyone feels a compulsion to touch trees#*', trees_handler)
mq.event('trash_event', '#*#Everyone feels a compulsion to pick up the trash#*', trash_handler)

-- Loop until chest spawns or manual stop
BL.info("Waiting for chest to spawn...")
while not shouldExit do
    mq.doevents()
    
    -- Check for chest spawn
    local chest = mq.TLO.Spawn("a_wavering_chest") -- a_wavering_chest
    if chest() and chest.ID() > 0 then
        BL.info("a wavering chest has spawned! Reloading CWTN plugins and ending script")
        break
    end
    mq.delay(100)
end

if shouldExit then
    BL.info("Manual stop detected - reloading and exiting...")
    -- Check if CWTN TLO exists and any CWTN plugin is loaded
    if mq.TLO.CWTN and mq.TLO.CWTN() then
        mq.cmdf("/%s reload", my_class)
    else
        BL.info("No CWTN plugin loaded, skipping reload")
    end
else
    BL.info("Chest spawned - reloading and exiting...")
    -- Check if CWTN TLO exists and any CWTN plugin is loaded
    if mq.TLO.CWTN and mq.TLO.CWTN() then
        mq.cmdf("/%s reload", my_class)
    else
        BL.info("No CWTN plugin loaded, skipping reload")
    end
end
