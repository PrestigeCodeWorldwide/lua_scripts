--v1.05
---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")
--- @type ImGui
local imgui = require("ImGui")
--- @type Actors
local ActorsLib = require("actors")

local myBuffs = {
    CLR = {
        {name = "Unified Hand of Aegolism XV",    type = "group"},
        {name = "Unified Hand of Sharosh",        type = "group"},
        {name = "Shining Rampart IX",             type = "single"},
        { name = "Unified Hand of Helmsbane",     type = "group" },
        { name = "Unified Hand of Infallibility", type = "group" },
        { name = "Shining Steel",                 type = "single" },
        { name = "Divine Interference",           type = "single" },
        { name = "Aegolism",                      type = "group" },
        { name = "Symbol of Naltron",             type = "single" },
        { name = "Courage",                       type = "single" }
    },
    SHM = {
        { name = "Talisman of Unity X",    type = "group" },
        { name = "Talisman of the Heroic", type = "group" },
        { name = "Talisman of the Raptor", type = "single" },
        { name = "Talisman of the Brute",  type = "single" },
        { name = "Talisman of the Cat",    type = "single" }
    },
    ENC = {
        { name = "Hastening of Elluria", type = "group" },
        { name = "Voice of Clairvoyance XVIII", type = "group" },
        { name = "Speed of the Shissar", type = "group" },
        { name = "Tashanian",            type = "single" }
    }
    -- Add other classes as needed
}

local actor = nil
local lastBuffRequest = {} -- Track last request time per buff
local REQUEST_COOLDOWN = 2 -- 2 seconds cooldown between same buff requests
local pendingCleanups = {} -- Track pending request cleanups
local pendingCasts = {}    -- Queue for pending casts
local selectedClass = nil
local selectedBuffChar = nil
local matchingChars = {}  -- class → list of characters
local availableBuffs = {} -- charName → list of buff names
local activeRequests = {}
local requestId = 0
local ACTOR_NAME = "buffactors"

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

    -- Pause CWTN
    mq.cmdf('/docommand /${Me.Class.ShortName} pause on')

    -- Target the player
    mq.cmdf('/target pc %s', cast.targetName)
    mq.delay(100, function() return mq.TLO.Target.CleanName() == cast.targetName end)

    -- Verify target
    if not mq.TLO.Target() or mq.TLO.Target.CleanName() ~= cast.targetName then
        BL.error(string.format("Failed to target %s", cast.targetName))
        mq.cmdf('/docommand /${Me.Class.ShortName} pause off')

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

    -- Wait for cast to complete
    local castStart = os.clock()
    while mq.TLO.Me.Casting() and (os.clock() - castStart < 5) do
        mq.delay(100)
    end

    local success = not mq.TLO.Me.Casting()

    if not success then
        BL.error(string.format("Failed to complete cast of %s on %s", cast.spellName, cast.targetName))
    end

    -- Resume CWTN
    mq.cmdf('/docommand /${Me.Class.ShortName} pause off')

    -- Send success response
    if actor and actor.send then
        actor:send({
            id = "buffResponse",
            requestId = cast.requestId,
            buffName = cast.spellName,
            from = mq.TLO.Me.CleanName(),
            success = success
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
                BL.info(string.format("Checking buff: %s == %s ?", tostring(buff.name), tostring(content.buffName)))

                if buff.name == content.buffName then
                    local myName = mq.TLO.Me.CleanName()
                    local requestKey = string.format("%s:%s", content.requestId, content.requester) -- Use requester instead of myName

                    if not activeRequests[requestKey] then
                        activeRequests[requestKey] = true
                        BL.info(string.format("Buff %s matches for %s (requestId: %s, key: %s)",
                            content.buffName, content.requester, content.requestId, requestKey))

                        -- Let the requester know we're handling it
                        if actor and actor.send then
                            actor:send({
                                id = "buffClaim",
                                requestId = content.requestId,
                                from = mq.TLO.Me.CleanName()
                            })
                        end

                        -- Queue the cast instead of executing immediately
                        queueCast(content.requester, content.buffName, content.requestId, content.requester)

                        -- Schedule cleanup
                        table.insert(pendingCleanups, {
                            requestId = requestKey,
                            expireTime = os.clock() + 300 -- 5 minutes from now
                        })
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
    -- Draw class selection buttons with character counts
    for class, _ in pairs(myBuffs) do
        local charCount = #getCharsOfClass(class)
        local buttonText = string.format("%s (%d)", class, charCount)
        if imgui.Button(buttonText) then
            selectedClass = class
        end
        imgui.SameLine()
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
            if imgui.Button(buff.name) then
                -- Check cooldown
                local now = os.clock()
                if lastBuffRequest[buff.name] and (now - lastBuffRequest[buff.name] < REQUEST_COOLDOWN) then
                    BL.warn(string.format("Please wait before requesting %s again", buff.name))
                    return
                end
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
    
    for i = #pendingCleanups, 1, -1 do
        local cleanup = pendingCleanups[i]
        if cleanup.expireTime <= now then
            -- Remove all variations of this request
            for k, _ in pairs(activeRequests) do
                if k:match("^" .. cleanup.requestId .. ":") then
                    activeRequests[k] = nil
                    BL.info(string.format("Cleaned up request: %s", k))
                    removed = removed + 1
                end
            end
            table.remove(pendingCleanups, i)
        end
    end
    
    -- If we still have too many active requests, clean up the oldest ones
    if removed == 0 and table_count(activeRequests) > 20 then
        BL.warn("Too many active requests, forcing cleanup")
        local oldest = nil
        for _, cleanup in ipairs(pendingCleanups) do
            if not oldest or cleanup.expireTime < oldest.expireTime then
                oldest = cleanup
            end
        end
        if oldest then
            for k, _ in pairs(activeRequests) do
                if k:match("^" .. oldest.requestId .. ":") then
                    activeRequests[k] = nil
                    BL.info(string.format("Force cleaned up old request: %s", k))
                end
            end
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
    processCasts = processCasts
}
