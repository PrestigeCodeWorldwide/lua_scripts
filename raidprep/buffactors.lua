--v1.11
---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")
--- @type ImGui
local imgui = require("ImGui")
--- @type Actors
local ActorsLib = require("actors")

-- Fixed order of classes
local classOrder = {"CLR", "DRU", "ENC", "SHM"}

local myBuffs = {
    CLR = {
        {name = "Unified Hand of Aegolism XV",    type = "group", checkName = "Aegolism XV"},
        {name = "Unified Hand of Sharosh",        type = "group", checkName = "Symbol of Sharosh"},
        {name = "Shining Rampart IX",             type = "single"},
        { name = "Divine Interstition",           type = "single" },
        { name = "Unified Hand of Helmsbane",     type = "group", checkName = "Symbol of Helmsbane" },
        { name = "Unified Hand of Infallibility", type = "group", checkName = "Commitment" },
        { name = "Shining Steel",                 type = "single" },
        { name = "Unified Hand of Certitude",     type = "single", checkName = "Certitude" }
    },
    SHM = {
        { name = "Talisman of Unity X",    type = "group", checkName = "Spirit's Focusing XIV" },
        { name = "Talisman of the Heroic", type = "group", checkName = "Heroic Focusing" },
    },
    ENC = {
        { name = "Hastening of Elluria", type = "group" },
        { name = "Voice of Clairvoyance XVIII", type = "group" },

    },
    DRU = {
        { name = "Grovewood Blessing", type = "group" },

    }
    -- Add other classes as needed
}

local actor = nil
local lastBuffRequest = {} -- Track last request time per buff
local REQUEST_COOLDOWN = 2 -- 2 seconds cooldown between same buff requests
local pendingCleanups = {} -- Track pending request cleanups
local pendingCasts = {}    -- Queue for pending casts
local selectedClass = "CLR" -- Default to Cleric
local selectedBuffChar = nil
local matchingChars = {}  -- class → list of characters
local availableBuffs = {} -- charName → list of buff names
local activeRequests = {}
local requestId = 0
local ACTOR_NAME = "buffactors"

-- Spell loading variables
local spellLoadAttempts = {} -- Track spell loading attempts per spell
local spellLoadTimestamps = {} -- Track when attempts were made for timeout
local MAX_LOAD_ATTEMPTS = 5 -- Maximum attempts to load a spell
local LOAD_TIMEOUT = 30 -- timeout before resetting attempts (in seconds)

-- Function to get the actual buff name to check for a given spell
local function getBuffCheckName(spellName)
    -- Search through all classes to find the buff entry
    for className, buffs in pairs(myBuffs) do
        for _, buff in ipairs(buffs) do
            if buff.name == spellName then
                return buff.checkName or buff.name
            end
        end
    end
    return spellName -- Fallback to spell name if not found
end

-- Function to check if we currently have a specific buff
local function hasBuff(buffName)
    local checkName = getBuffCheckName(buffName)
    return mq.TLO.Me.Buff(checkName)() ~= nil
end

-- Auto-request checkbox states for each buff
local autoRequestBuffs = {}
local lastBuffCheck = 0
local BUFF_CHECK_INTERVAL = 10 -- Check buffs every 10seconds
local knownBuffs = {} -- Track which buffs we currently have

-- Function to find an available gem slot
local function findAvailableGem()
    local maxGems = mq.TLO.Me.NumGems() or 13 -- Default to 13 if not available
    for i = 1, maxGems do
        local gemSpell = mq.TLO.Me.Gem(i).Name()
        if not gemSpell or gemSpell == "" then
            return i
        end
    end
    -- If no empty slots found, return gem 14 (or max gems if less than 14)
    return math.min(14, maxGems)
end

-- Function to check if a spell is loaded in the spell bar
local function isSpellLoaded(spellName)
    local maxGems = mq.TLO.Me.NumGems() or 13
    for i = 1, maxGems do
        local gemSpell = mq.TLO.Me.Gem(i).Name()
        if gemSpell and gemSpell == spellName then
            return true, i
        end
    end
    return false, nil
end

-- Function to load a spell into an available gem (non-blocking version)
local function loadSpellToAvailableGem(spellName)
    -- First check if spell is already loaded
    local isLoaded, gemNum = isSpellLoaded(spellName)
    if isLoaded then
        BL.info(string.format("%s is already loaded in gem %d", spellName, gemNum or 14))
        return true -- Already loaded, no need to do anything
    end
    
    -- Check if we already tried to load this spell too many times
    local currentTime = os.time()
    
    -- Reset attempts if timeout has passed
    if spellLoadTimestamps[spellName] and (currentTime - spellLoadTimestamps[spellName]) > LOAD_TIMEOUT then
        BL.info(string.format("Resetting load attempts for %s after timeout", spellName))
        spellLoadAttempts[spellName] = 0
        spellLoadTimestamps[spellName] = nil
    end
    
    spellLoadAttempts[spellName] = (spellLoadAttempts[spellName] or 0) + 1
    spellLoadTimestamps[spellName] = currentTime
    
    if spellLoadAttempts[spellName] > MAX_LOAD_ATTEMPTS then
        BL.warn(string.format("Already attempted to load %s %d times, giving up. Will retry in %d seconds", 
            spellName, MAX_LOAD_ATTEMPTS, LOAD_TIMEOUT))
        return false
    end
    
    -- Find an available gem slot
    local availableGem = findAvailableGem()
    local maxGems = mq.TLO.Me.NumGems() or 13
    
    -- Check if we're overwriting gem 14 (or the last available gem)
    local isOverwriting = (availableGem == math.min(14, maxGems))
    local currentSpell = mq.TLO.Me.Gem(availableGem).Name()
    
    if isOverwriting and currentSpell and currentSpell ~= "" then
        BL.warn(string.format("Overwriting gem %d: replacing '%s' with '%s'", availableGem, currentSpell, spellName))
    else
        BL.info(string.format("Loading %s into gem %d", spellName, availableGem))
    end
    
    -- Check if spell exists in spellbook
    local spellRank = mq.TLO.Spell(spellName).Rank()
    if not spellRank or spellRank == "" then
        BL.error(string.format("Spell %s not found in spellbook", spellName))
        return false
    end
    
    -- Load spell into the available gem
    mq.cmdf('/memorize "%s" %d', spellName, availableGem)
    
    -- Return immediately - the actual verification will happen asynchronously
    return true
end

-- Function to check if spell loading completed (called from main loop)
local function checkSpellLoading()
    for spellName, _ in pairs(spellLoadAttempts) do
        if spellLoadAttempts[spellName] > 0 then
            local isLoaded, gemNum = isSpellLoaded(spellName)
            if isLoaded then
                BL.info(string.format("Successfully loaded %s into gem %d", spellName, gemNum or 14))
                spellLoadAttempts[spellName] = 0 -- Reset attempts on success
                spellLoadTimestamps[spellName] = nil -- Reset timestamp on success
            else
                -- Check if we should retry (simple timeout check)
                -- Note: In a more complex implementation, we'd track timestamps
                local currentTime = os.time()
                if spellLoadTimestamps[spellName] and (currentTime - spellLoadTimestamps[spellName]) > LOAD_TIMEOUT then
                    BL.info(string.format("Timeout reached for %s, resetting attempts", spellName))
                    spellLoadAttempts[spellName] = 0
                    spellLoadTimestamps[spellName] = nil
                end
            end
        end
    end
end

-- Function to ensure spell is available for casting
local function ensureSpellAvailable(spellName)
    local isLoaded, gemNum = isSpellLoaded(spellName)
    if isLoaded then
        return true
    end
    
    -- Check if this spell is currently being loaded
    if spellLoadAttempts[spellName] and spellLoadAttempts[spellName] > 0 then
        BL.info(string.format("Spell %s is currently being loaded, please wait", spellName))
        return false -- Don't try to load again, just wait
    end
    
    BL.warn(string.format("Spell %s not loaded in spell bar, attempting to load", spellName))
    local loadResult = loadSpellToAvailableGem(spellName)
    
    -- For immediate requests, we can't wait for the async load to complete
    -- So we return false and let the caller handle the retry
    return loadResult
end

-- Function to queue a cast (called from actor callback)
local function queueCast(targetName, spellName, requestId, requester)
    if #pendingCasts > 3 then -- max queue amount
        BL.error("Cast queue full, dropping request")
        return false
    end
    table.insert(pendingCasts, {
        targetName = targetName,
        spellName = spellName,
        requestId = requestId,
        requester = requester,
        timestamp = os.clock()
    })
    BL.info(string.format("Queued cast of %s on %s", spellName, targetName))
end

-- Function to process the cast queue (called from main loop)
local lastProcessedCast = 0
local CAST_PROCESS_DELAY = 0.5  -- Half second between casts
local function processCasts()
    if #pendingCasts == 0 then return end
    
    -- Add a small delay between processing casts
    local now = os.clock()
    if now - lastProcessedCast < CAST_PROCESS_DELAY then
        return
    end

    local cast = pendingCasts[1]

    -- Check if we're already casting
    if mq.TLO.Me.Casting() then
        return -- Wait for current cast to finish
    end

    BL.info(string.format("Processing cast of %s on %s", cast.spellName, cast.targetName))

    -- Final check to ensure spell is available before casting
    if not ensureSpellAvailable(cast.spellName) then
        -- Check if spell is currently being loaded
        if spellLoadAttempts[cast.spellName] and spellLoadAttempts[cast.spellName] > 0 then
            BL.info(string.format("Spell %s is still loading, keeping request in queue", cast.spellName))
            return -- Keep the cast in queue for retry
        else
            BL.error(string.format("Cannot cast %s - spell not available", cast.spellName))
            
            -- Send failure response
            if actor and actor.send then
                actor:send({
                    id = "buffResponse",
                    requestId = cast.requestId,
                    buffName = cast.spellName,
                    from = mq.TLO.Me.CleanName(),
                    success = false
                })
            end
            
            table.remove(pendingCasts, 1)
            return
        end
    end

    -- Pause CWTN
    mq.cmdf('/docommand /%s pause on', mq.TLO.Me.Class.ShortName())

    -- Target the player
    mq.cmdf('/target pc %s', cast.targetName)
    mq.delay(100, function() return mq.TLO.Target.CleanName() == cast.targetName end)

    -- Verify target
    if not mq.TLO.Target() or mq.TLO.Target.CleanName() ~= cast.targetName then
        BL.error(string.format("Failed to target %s", cast.targetName))
        mq.cmdf('/docommand /%s pause off', mq.TLO.Me.Class.ShortName())

        -- Send failure response
        if actor and actor.send then
            actor:send({
                id = "buffResponse",
                requestId = cast.requestId,
                buffName = cast.spellName,
                from = mq.TLO.Me.CleanName(),
                success = false
            })
        end

        table.remove(pendingCasts, 1)
        return
            mq.delay(100)
    end

    -- Cast the spell
    mq.cmdf('/g CASTING %s ON %s', cast.spellName, cast.targetName)
    mq.cmdf('/cast "%s"', cast.spellName)

    -- Wait for cast to complete (no timeout - let EQ handle it naturally)
    while mq.TLO.Me.Casting() do
        mq.delay(100)
    end
    
    -- Cast completed (either successfully or failed - EQ handles this)
    local castCompleted = true -- We assume it worked unless we detect otherwise

    -- Resume CWTN
    mq.cmdf('/docommand /%s pause off', mq.TLO.Me.Class.ShortName())

    -- Send success response
    if actor and actor.send then
        actor:send({
            id = "buffResponse",
            requestId = cast.requestId,
            buffName = cast.spellName,
            from = mq.TLO.Me.CleanName(),
            success = castCompleted
        })
    end

    -- Remove from queue
    table.remove(pendingCasts, 1)
    lastProcessedCast = now
end

-- Single message handler for all actor messages
local function handleMessage(message)
    if not actor then
        BL.error("Actor not initialized in handleMessage")
        return
    end

    local msgId = message.id or (message.content and message.content.id)
    local content = message.content or message

    --BL.info("Received message id: " .. tostring(msgId))

    if msgId == "buffRequest" then
        BL.info("buffRequest handler entered")
        BL.info("=== New Message Received ===")
        BL.info("Message type: " .. tostring(message and message.content and message.content.id or "unknown"))
    end
    if not actor then
        BL.error("Actor not initialized in handleMessage")
        return
    end

    --BL.info("Message details:")
    --BL.info("  ID: " .. tostring(content.id))
    --BL.info("  From: " .. tostring(message.from))
    --BL.info("  BuffName: " .. tostring(content.buffName))
    --BL.info("  RequestID: " .. tostring(content.requestId))
    --BL.info("  Requester: " .. tostring(content.requester))

    -- Handle buff requests
    if msgId == "buffRequest" then
        local myClass = mq.TLO.Me.Class.ShortName()
        BL.info(string.format("Received buff request for %s, my class is %s", tostring(content.buffName),
            tostring(myClass)))

        if myBuffs[myClass] then
            BL.info("I have buffs for my class")
            for _, buff in ipairs(myBuffs[myClass]) do
                --print(string.format("Checking buff: %s == %s ?", tostring(buff.name), tostring(content.buffName)))

                if buff.name == content.buffName then
                    print(string.format("Found matching buff: %s", buff.name))
                    
                    -- Check if requester is within range (100 units)
                    local requesterSpawn = mq.TLO.Spawn(content.requester)
                    if not requesterSpawn then
                        BL.info(string.format("Cannot find requester %s, skipping", content.requester))
                        return
                    end
                    
                    local distance = requesterSpawn.Distance() or 999
                    if distance > 100 then
                        BL.info(string.format("Requester %s is %d units away (max 100), skipping", content.requester, distance))
                        return
                    end
                    
                    BL.info(string.format("Requester %s is %d units away, accepting request", content.requester, distance))
                    
                    local myName = mq.TLO.Me.CleanName()
                    local requestType = content.requestType or "manual"
                    local requestKey = string.format("%s:%s:%s", content.requestId, content.requester, requestType)
                    print(string.format("Request key: %s", requestKey))

                    if not activeRequests[requestKey] then
                        print("Not already processing this request, proceeding...")
                        
                        activeRequests[requestKey] = true
                        BL.info(string.format("Buff %s matches for %s (requestId: %s, key: %s)",
                            content.buffName, content.requester, content.requestId, requestKey))

                        -- Let the requester know we're handling it
                        print("Sending buffClaim message...")
                        if actor and actor.send then
                            actor:send({
                                id = "buffClaim",
                                requestId = content.requestId,
                                from = mq.TLO.Me.CleanName()
                            })
                            print("buffClaim sent successfully")
                        else
                            print("ERROR: actor or actor.send is nil")
                        end

                        -- Queue the cast instead of executing immediately
                        print("Queuing cast...")
                        queueCast(content.requester, content.buffName, content.requestId, content.requester)
                        print("Cast queued successfully")

                        -- Schedule cleanup
                        print("Scheduling cleanup...")
                        table.insert(pendingCleanups, {
                            requestId = tostring(content.requestId), -- Use only requestId, not requestKey
                            expireTime = os.clock() + 300 -- 5 minutes from now
                        })
                        print("Cleanup scheduled")
                    else
                        print("Already processing this request, skipping...")
                    end
                    return
                end
            end
        else
            BL.info(string.format("No buffs found for my class %s", myClass))
        end -- closes if myBuffs[myClass]
    end     -- closes if content.id == "buffRequest"

    -- Handle buff announcements
    if msgId == "announceBuffs" and content.class and content.name then
        matchingChars[content.class] = matchingChars[content.class] or {}
        matchingChars[content.class][content.name] = {
            timestamp = os.time(),
        }
        availableBuffs[content.name] = content.buffs
    end
end

-- Initialize the actor system
local function init()
    local success, result = pcall(function()
        return ActorsLib.register(ACTOR_NAME, handleMessage)
    end)

    if not success then
        BL.error("Failed to initialize actor: " .. tostring(result))
        return
    end

    actor = result
    BL.info("BUFFACTORS REGISTERED AS " .. ACTOR_NAME .. " ON " .. mq.TLO.Me.CleanName())

    local myClass = mq.TLO.Me.Class.ShortName()
    local myName = mq.TLO.Me.CleanName()

    if myBuffs[myClass] then
        actor:send({
            id = "announceBuffs",
            class = myClass,
            name = myName,
            buffs = myBuffs[myClass]
        })
    end
end

-- Initialize the system
init()

local function getCharsOfClass(className)
    local chars = {}
    if matchingChars and className and matchingChars[className] then
        for charName, _ in pairs(matchingChars[className]) do
            table.insert(chars, charName)
        end
    end
    return chars
end

-- Buff UI Functions
local function drawBuffsTab()
    -- Draw class selection buttons with character counts (in fixed order)
    for _, class in ipairs(classOrder) do
        if myBuffs[class] then -- Only show classes that have buffs defined
            local charCount = #getCharsOfClass(class)
            local buttonText = string.format("%s (%d)", class, charCount)
            if imgui.Button(buttonText) then
                selectedClass = class
            end
            imgui.SameLine()
        end
    end
    imgui.NewLine()
    imgui.Separator()

    -- Draw buffs for selected class
    if selectedClass then
        local charCount = #getCharsOfClass(selectedClass)
        if charCount > 0 then
            imgui.TextColored(0, 1, 0, 1, string.format("%d %s available", charCount, selectedClass))
        else
            imgui.TextColored(1, 0.5, 0, 1, "No " .. selectedClass .. " characters available")
        end
        imgui.Separator()
        
        for _, buff in ipairs(myBuffs[selectedClass] or {}) do
            imgui.PushID(buff.name) -- Unique ID for each checkbox/button pair
            
            -- Check if character currently has this buff
            local hasCurrentBuff = hasBuff(buff.name)
            
            -- Make the icon clickable with black background and no border (HunterHUD style)
            imgui.PushStyleColor(ImGuiCol.Button, 0, 0, 0, 1)           -- Black background
            imgui.PushStyleColor(ImGuiCol.ButtonHovered, 0, 0, 0, 1)      -- Black background on hover
            imgui.PushStyleColor(ImGuiCol.ButtonActive, 0, 0, 0, 1)       -- Black background when pressed
            imgui.PushStyleVar(ImGuiStyleVar.FrameBorderSize, 0)           -- No border
            
            if hasCurrentBuff then
                imgui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1)           -- Green for has buff
                imgui.Button('\xef\x84\x91##hasbuff_' .. buff.name, 20, 20)  -- Green circle
                imgui.PopStyleColor()
            else
                imgui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)           -- Red for missing buff
                imgui.Button('\xef\x84\x91##missingbuff_' .. buff.name, 20, 20)  -- Red circle
                imgui.PopStyleColor()
            end
            
            imgui.PopStyleVar(1)  -- Pop the border style
            imgui.PopStyleColor(4) -- Pop the colors
            imgui.SameLine()
            
            -- Auto-request checkbox on the left
            local varName = "auto_" .. buff.name:gsub("[^%w_]", "_")
            autoRequestBuffs[varName] = autoRequestBuffs[varName] or false
            local autoChecked, autoChanged = imgui.Checkbox("##" .. varName, autoRequestBuffs[varName])
            autoRequestBuffs[varName] = autoChecked
            
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text(string.format("Auto-request %s when the buff drops", buff.name))
                imgui.EndTooltip()
            end
            
            imgui.SameLine()
            
            -- Manual load button for buff classes (always show for buff classes)
            -- Check if current character is a buff class
            local myClass = mq.TLO.Me.Class.Name()
            -- Map full class names to 3-letter codes used in myBuffs
            local classMapping = {
                ['Cleric'] = 'CLR',
                ['Shaman'] = 'SHM', 
                ['Enchanter'] = 'ENC',
                ['Druid'] = 'DRU'
            }
            local classCode = classMapping[myClass] or myClass
            local isBuffClass = myBuffs[classCode] ~= nil
            
            if isBuffClass then
                -- Check if spell is already memmed
                local isLoaded, gemNum = isSpellLoaded(buff.name)
                
                -- Set button text color based on spell loading status
                if isLoaded then
                    imgui.PushStyleColor(ImGuiCol.Text, 0, 1, 0, 1) -- Green for memmed
                else
                    imgui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1) -- Red for not memmed
                end
                
                if imgui.Button("MEM##" .. buff.name, 40, 0) then
                    loadSpellToAvailableGem(buff.name)
                end
                imgui.PopStyleColor() -- Pop text color
                
                if imgui.IsItemHovered() then
                    imgui.BeginTooltip()
                    if isLoaded then
                        imgui.Text(string.format("%s is already memmed in gem %d", buff.name, gemNum or 14))
                    else
                        imgui.Text(string.format("Mem %s into an available gem(Gem 14 if none free)", buff.name))
                    end
                    imgui.EndTooltip()
                end
                imgui.SameLine()
            end
            
            -- Buff request button
            if imgui.Button(buff.name) then
                -- Check cooldown
                local now = os.clock()
                if lastBuffRequest[buff.name] and (now - lastBuffRequest[buff.name] < REQUEST_COOLDOWN) then
                    BL.warn(string.format("Please wait before requesting %s again", buff.name))
                else
                    lastBuffRequest[buff.name] = now
                    -- Generate a unique request ID
                    requestId = requestId + 1
                    local request = {
                        id = "buffRequest",
                        requestId = requestId,
                        buffName = buff.name,
                        requester = mq.TLO.Me.CleanName(),
                        timestamp = os.time()
                    }

                    BL.info(string.format("Sending buff request for %s to %s class", buff.name, selectedClass))

                    -- Send the request to all characters (broadcast)
                    local chars = getCharsOfClass(selectedClass)
                    BL.info(string.format("Found %d characters of class %s", #chars, selectedClass))

                    if actor and actor.send then
                        -- Broadcast to all instances of the actor
                        actor:send(request)

                        -- Schedule cleanup for this request
                        local requestKey = tostring(requestId)
                        table.insert(pendingCleanups, {
                            requestId = requestKey,
                            expireTime = os.clock() + 300 -- 5 minutes from now
                        })
                    else
                        if not actor then
                            BL.error("Actor is nil when trying to send buff request")
                        elseif not actor.send then
                            BL.error("Actor.send is not available")
                        end
                    end
                end
            end
            
            imgui.PopID()
        end
    end
end

local function announceBuffs()
    local myClass = mq.TLO.Me.Class.ShortName()
    local myName = mq.TLO.Me.CleanName()
    if myBuffs[myClass] and actor and actor.send then
        actor:send({
            id = 'announceBuffs',
            class = myClass,
            name = myName,
            buffs = myBuffs[myClass]
        })
    end
end

local function cleanupStaleEntries()
    local now = os.time()
    for class, charTable in pairs(matchingChars) do
        for name, info in pairs(charTable) do
            if now - (info.timestamp or 0) > 20 then -- 20 seconds threshold
                matchingChars[class][name] = nil
                availableBuffs[name] = nil
                if selectedBuffChar == name then
                    selectedBuffChar = nil
                end
            end
        end
        -- Clean up empty class table
        if next(matchingChars[class]) == nil then
            matchingChars[class] = nil
        end
    end
end

-- Process pending cleanups
-- Helper function to count table size
local function table_count(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

local function processCleanups()
    local now = os.clock()
    local removed = 0
    local activeCount = table_count(activeRequests)
    
    -- Debug logging every 30 seconds
    --[[ Commented out to reduce spam
    if math.floor(now) % 30 == 0 then
        local activeCount = table_count(activeRequests)
        BL.info(string.format("Active requests: %d, Pending cleanups: %d", activeCount, #pendingCleanups))
    end
    ]]
    
    for i = #pendingCleanups, 1, -1 do
        local cleanup = pendingCleanups[i]
        if cleanup.expireTime <= now then
            local removedCount = 0
            
            -- Remove all variations of this request
            for k, _ in pairs(activeRequests) do
                if k:match("^" .. cleanup.requestId .. ":") then
                    activeRequests[k] = nil
                    removedCount = removedCount + 1
                end
            end
            
            if removedCount > 0 then
                BL.info(string.format("Cleaned up %d requests for ID %s", removedCount, cleanup.requestId))
            end
            table.remove(pendingCleanups, i)
        end
    end
    
    -- If we still have too many active requests, clean up the oldest ones
    if table_count(activeRequests) > 20 then
        BL.warn("Too many active requests, forcing cleanup")
        
        -- Find the oldest cleanup entry
        local oldestIndex = nil
        local oldestTime = math.huge
        for i, cleanup in ipairs(pendingCleanups) do
            if cleanup.expireTime < oldestTime then
                oldestTime = cleanup.expireTime
                oldestIndex = i
            end
        end
        
        if oldestIndex then
            local oldest = pendingCleanups[oldestIndex]
            -- Remove all variations of this request
            for k, _ in pairs(activeRequests) do
                if k:match("^" .. oldest.requestId .. ":") then
                    activeRequests[k] = nil
                    BL.info(string.format("Force cleaned up old request: %s", k))
                end
            end
            -- Remove the cleanup entry itself
            table.remove(pendingCleanups, oldestIndex)
            BL.info("Removed oldest cleanup entry")
        else
            -- If no cleanup entries, just clear half the active requests
            local toRemove = {}
            local count = 0
            for k, _ in pairs(activeRequests) do
                table.insert(toRemove, k)
                count = count + 1
                if count >= 10 then break end
            end
            for _, k in ipairs(toRemove) do
                activeRequests[k] = nil
                BL.info(string.format("Emergency cleanup removed request: %s", k))
            end
        end
    end
end

-- Function to get the class that provides a specific buff
local function getClassForBuff(buffName)
    for className, buffs in pairs(myBuffs) do
        for _, buff in ipairs(buffs) do
            if buff.name == buffName then
                return className
            end
        end
    end
    return nil
end

-- Function to auto-request a buff when it drops
local function autoRequestBuff(buffName)
    local classForBuff = getClassForBuff(buffName)
    if not classForBuff then
        BL.warn(string.format("No class found for buff: %s", buffName))
        return
    end
    
    -- Check cooldown
    local now = os.clock()
    if lastBuffRequest[buffName] and (now - lastBuffRequest[buffName] < REQUEST_COOLDOWN) then
        return -- Skip if still on cooldown
    end
    lastBuffRequest[buffName] = now
    
    -- Generate a unique request ID
    requestId = requestId + 1
    local request = {
        id = "buffRequest",
        requestId = requestId,
        buffName = buffName,
        requester = mq.TLO.Me.CleanName(),
        timestamp = os.time(),
        requestType = "auto" -- Mark this as an auto-request
    }

    BL.info(string.format("Auto-requesting buff %s from %s class", buffName, classForBuff))

    -- Send the request to all characters of the appropriate class
    if actor and actor.send then
        actor:send(request)
        
        -- Schedule cleanup for this request
        local requestKey = tostring(requestId)
        table.insert(pendingCleanups, {
            requestId = requestKey, -- Store only the requestId, not the full key
            expireTime = os.clock() + 300 -- 5 minutes for normal operation
        })
    end
end

-- Function to monitor buffs and auto-request when they're missing
local function monitorBuffs()
    local now = os.clock()
    if now - lastBuffCheck < BUFF_CHECK_INTERVAL then
        return
    end
    lastBuffCheck = now

    -- Check all buffs that have auto-request enabled
    for varName, enabled in pairs(autoRequestBuffs) do
        if enabled then
            -- Extract buff name from variable name
            local buffName = varName:gsub("^auto_", ""):gsub("_", " ")
            
            -- Check if we currently have this buff
            local currentlyHasBuff = hasBuff(buffName)
            
            -- If we don't have the buff, auto-request it (respecting cooldown)
            if not currentlyHasBuff then
                autoRequestBuff(buffName)
            end
            
            -- Update our knowledge of this buff
            knownBuffs[varName] = currentlyHasBuff
        end
    end
end

return {
    drawBuffsTab = drawBuffsTab,
    matchingChars = matchingChars,
    availableBuffs = availableBuffs,
    actor = actor,
    cleanupStaleEntries = cleanupStaleEntries,
    announceBuffs = announceBuffs,
    processCleanups = processCleanups,
    processCasts = processCasts,
    monitorBuffs = monitorBuffs,
    checkSpellLoading = checkSpellLoading
}
