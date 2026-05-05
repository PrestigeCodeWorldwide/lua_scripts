---@type Mq
local mq = require("mq")

-- Achievement ID Dumper
-- This script will dump all achievement IDs and names to console
-- Run with: /lua run achievementid.lua

local function dumpAchievements()
    printf("\ay=== Achievement ID Dump Started ===\ax")
    
    -- Get total achievement count using Achievement TLO
    local totalAchievements = 0
    
    -- Try to find achievements by iterating through IDs
    printf("\agScanning for achievements...\ax")
    
    local foundCount = 0
    local maxID = 20000 -- Start with a reasonable upper limit
    
    -- Loop through potential achievement IDs
    for i = 1, maxID do
        local achievement = mq.TLO.Achievement(i)
        
        if achievement and achievement() then
            local id = achievement.ID()
            local name = achievement.Name()
            
            if id and name then
                foundCount = foundCount + 1
                totalAchievements = i
                
                -- Simple format for easy extraction
                printf("\at[%d] ID: %d | Name: %s\ax", foundCount, id, name)
                
                -- Also output in Lua table format for easy copy-paste
                if foundCount <= 10 then -- Show first 10 in Lua format as example
                    if foundCount == 1 then
                        printf("\ay-- Lua table format (first 10 achievements):")
                        printf("local achievements = {")
                    end
                    printf('    ["%s"] = %d,', name:gsub('"', '\\"'), id)
                end
            end
        end
        
        -- Stop if we haven't found any achievements in a while
        if i > 100 and foundCount == 0 then
            printf("\arNo achievements found in first 100 IDs, trying higher range...\ax")
        elseif i > 1000 and foundCount < 10 then
            printf("\arFew achievements found, scanning higher range...\ax")
        end
    end
    
    if foundCount > 0 then
        printf("}")
        printf("")
    end
    
    printf("\ag=== Achievement Dump Complete ===\ax")
    printf("\agFound %d achievements (scanned up to ID %d)\ax", foundCount, totalAchievements)
    
    -- Search for achievements starting from 11000000
    printf("")
    printf("\ay=== Scanning Achievements (11000000-11000500) ===\ax")
    
    local foundCount = 0
    local startID = 11000000
    local endID = 11000500 -- Scan 500 IDs from 11000000
    
    for i = startID, endID do
        local achievement = mq.TLO.Achievement(i)
        
        if achievement and achievement() then
            local id = achievement.ID()
            local name = achievement.Name()
            
            if id and name then
                foundCount = foundCount + 1
                printf("\at[%d] ID: %d | Name: %s\ax", foundCount, id, name)
            end
        end
    end
    
    printf("\agFound %d achievements (scanned %d-%d)\ax", foundCount, startID, endID)
end

-- Command handler
local function achievementDumpCommand(...)
    local args = {...}
    local cmd = args[1] and args[1]:lower() or ""
    
    if cmd == "help" then
        printf("\ayAchievement ID Dumper Commands:")
        printf("\at/achdump\ax - Dump all achievements")
        printf("\at/achdump slayer\ax - Dump only slayer-related achievements")
        printf("\at/achdump help\ax - Show this help")
        return
    end
    
    if cmd == "slayer" then
        printf("\ay=== Scanning Achievements (11000000-11000500) ===\ax")
        
        local foundCount = 0
        local startID = 11000000
        local endID = 11000500 -- Scan 500 IDs from 11000000
        
        for i = startID, endID do
            local achievement = mq.TLO.Achievement(i)
            
            if achievement and achievement() then
                local id = achievement.ID()
                local name = achievement.Name()
                
                if id and name then
                    foundCount = foundCount + 1
                    printf("\at[%d] ID: %d | Name: %s\ax", foundCount, id, name)
                end
            end
        end
        
        printf("\agFound %d achievements (scanned %d-%d)\ax", foundCount, startID, endID)
    else
        -- Full dump
        dumpAchievements()
    end
end

-- Register command
mq.bind('/achdump', achievementDumpCommand)

printf("\agAchievement ID Dumper Loaded!")
printf("\atCommands: /achdump | /achdump slayer | /achdump help")

-- Auto-run full dump when script starts
printf("\ayAuto-running achievement dump...\ax")
dumpAchievements()