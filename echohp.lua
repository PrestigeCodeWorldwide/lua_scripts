---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')

BL.info("EchoHP script 1.0 loaded")

-- Global table to store HP data
local hpData = {}
local collectingHP = false
local shouldExit = false

local function announceHP()
    -- Get current HP
    local currentHP = mq.TLO.Me.CurrentHPs()
    local maxHP = mq.TLO.Me.MaxHPs()
    local myName = mq.TLO.Me.Name()
    
    -- Check if HP value is valid
    if currentHP ~= nil and maxHP ~= nil then
        -- Announce HP in raid say with standardized format
        mq.cmd("/rs " .. myName .. " HP: " .. currentHP .. "/" .. maxHP)
        BL.info("Announced HP in raid say: " .. currentHP .. "/" .. maxHP)
    else
        BL.error("Error: Unable to retrieve HP value")
    end
end

local function parseAndSortHP()
    -- Debug: Show what data we have
    local count = 0
    for _ in pairs(hpData) do count = count + 1 end
    BL.info("Current HP data entries: " .. count)
    for name, data in pairs(hpData) do
        BL.info("Entry - " .. name .. ": " .. (data.current or "nil") .. "/" .. (data.max or "nil"))
    end
    
    -- Sort HP data by current HP (ascending)
    local sortedHP = {}
    for name, data in pairs(hpData) do
        table.insert(sortedHP, {name = name, hp = data.current, max = data.max})
    end
    
    table.sort(sortedHP, function(a, b) return a.hp < b.hp end)
    
    -- Report the 9 lowest HP toons
    local reportCount = math.min(9, #sortedHP)
    if reportCount > 0 then
        local message = "Lowest HP: "
        for i = 1, reportCount do
            local toon = sortedHP[i]
            message = message .. toon.name .. "(" .. toon.hp .. "/" .. toon.max .. ")"
            if i < reportCount then
                message = message .. ", "
            end
        end
        mq.cmd("/rs " .. message)
        BL.info("Reported " .. reportCount .. " lowest HP toons")
    else
        BL.error("No HP data found to sort")
    end
    
    -- Clear the HP data after reporting
    hpData = {}
end

-- Event handler to capture HP announcements
local function onRaidMessage(line)
    BL.info("Raid message detected: " .. (line or "nil"))
    if collectingHP then
        -- Parse format directly from the full line: "PlayerName tells the raid, 'PlayerName HP: current/max'"
        local name, hp, maxHP = string.match(line, "(%w+) tells the raid, '(%w+) HP: (%d+)/(%d+)'")
        if name and hp and maxHP then
            hpData[name] = {
                current = tonumber(hp),
                max = tonumber(maxHP)
            }
            BL.info("Captured HP data for " .. name .. ": " .. hp .. "/" .. maxHP)
        else
            -- Try alternative parsing - maybe the name in message is different
            local msgName, hp, maxHP = string.match(line, "tells the raid, '(%w+) HP: (%d+)/(%d+)'")
            if msgName and hp and maxHP then
                local sender = string.match(line, "(%w+) tells the raid")
                if sender then
                    hpData[msgName] = {
                        current = tonumber(hp),
                        max = tonumber(maxHP)
                    }
                    BL.info("Captured HP data for " .. msgName .. ": " .. hp .. "/" .. maxHP .. " (from " .. sender .. ")")
                end
            else
                BL.info("Failed to parse HP from message: " .. (line or "nil"))
            end
        end
    end
end

-- Register event handler for all raid messages
mq.event("raidhp", "#*# tells the raid, '*#'", onRaidMessage)

local function main(args)
    if args and args[1] == "sort" then
        -- Start collecting and immediately process events
        collectingHP = true
        BL.info("HP collection enabled for sorting")
        
        -- Process events for a few seconds to capture recent messages
        local startTime = os.time()
        while os.time() - startTime < 3 do
            mq.doevents()
            mq.delay(100)
        end
        
        parseAndSortHP()
        shouldExit = true
    else
        announceHP()
        shouldExit = true
    end
end

-- Call the function with arguments
main({...})

-- Keep script running briefly to collect events if needed
if not shouldExit then
    while not shouldExit do
        mq.doevents()
        mq.delay(100)
    end
end

