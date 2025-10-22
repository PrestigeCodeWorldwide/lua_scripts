-- v1.11
local mq = require 'mq'
local BL = require("biggerlib")

local useInvis = true
local function new(myAch)
    local helpers = {}


    -- Print format function
    function helpers.printf(...)
        BL.info(string.format(...))
    end

    function helpers.setUseInvis(value)
        useInvis = value
    end

    function helpers.isMouseButtonDown(button)
    -- 0 = left, 1 = right, 2 = middle
    return ImGui.IsMouseDown(button)
end

    -- Check if a spawn is within a certain Z-axis distance from the player
    -- @param spawnID number - The ID of the spawn to check
    -- @param maxZDistance number - Maximum allowed Z-axis distance
    -- @return boolean - True if within Z distance, false otherwise
    -- @return number - The actual Z distance
    function helpers.checkZDistance(spawnID, maxZDistance)
        local spawn = mq.TLO.Spawn(spawnID)
        if not spawn or not spawn.ID() or spawn.ID() == 0 then
            return false, 0
        end
        
        local myZ = mq.TLO.Me.Z() or 0
        local spawnZ = spawn.Z() or 0
        local zDiff = math.abs(myZ - spawnZ)
        
        return zDiff <= maxZDistance, zDiff
    end

    -- Find spawn by name
    function helpers.findSpawn(spawn, nameMap)
        if not spawn then return 0 end
        if nameMap and nameMap[spawn] then spawn = nameMap[spawn] end
        local mySpawn = mq.TLO and mq.TLO.Spawn and mq.TLO.Spawn(string.format('npc "%s"', spawn))
        if mySpawn and mySpawn.ID() and mySpawn.ID() > 0 then
            return mySpawn.ID()
        end
        return 0
    end

    -- Normalize mob names for comparison
    function helpers.normalizeName(name)
        if not name then return "" end
        return name:lower():gsub(" ", "_")
    end

    -- Check for any mobs on extended target (including PHs and named)
    function helpers.hasNonPHTargets(phList, hoodAch, currentZoneID)
        -- Get current zone if not provided
        if not currentZoneID then
            currentZoneID = mq.TLO.Zone.ID()
        end
        
        -- Only check XTargets, ignore current target
        local xtargetCount = mq.TLO.Me.XTarget() or 0
        local closestAdd = nil
        local closestDistance = math.huge
        
        for i = 1, xtargetCount do
            local target = mq.TLO.Me.XTarget(i)
            if target() and target.ID() > 0 then
                local spawn = mq.TLO.Spawn(target.ID())
                if spawn() and not spawn.Dead() then
                    local spawnName = spawn.CleanName()
                    local spawnDistance = spawn.Distance3D() or math.huge
                    
                    -- Skip if too far away (over 400 range) unless it's a named mob
                    local isNamed = false
                    for _, mob in ipairs(hoodAch.Spawns) do
                        if mob.name == spawnName then
                            isNamed = true
                            break
                        end
                    end
                    
                    if spawnDistance > 400 and not isNamed then
                        helpers.printf("\aySkipping add %s - too far away (%.1f)", spawnName, spawnDistance)
                        goto continue
                    end
                    
                    -- Track the closest mob on extended target
                    if spawnDistance < closestDistance then
                        closestDistance = spawnDistance
                        closestAdd = spawn
                        --helpers.printf("\arEngaging target: %s (%.1f away)", spawnName, spawnDistance)
                    end
                end
            end
            ::continue::
        end
        
        return closestAdd ~= nil, closestAdd
    end

    -- Get achievement ID for a zone
    function helpers.getHoodAchID(zoneID, zoneMap)
        if zoneID and zoneMap[zoneID] then
            return zoneMap[zoneID]
        end
        return 0
    end

    -- Get current zone's achievement ID
    function helpers.getCurrentZoneAchID(zoneMap)
        local zoneID = mq.TLO.Zone.ID()
        local zoneName = mq.TLO.Zone.Name() or ""
        printf('Debug: Current zone ID: %d, Zone name: %s', zoneID, zoneName)
        
        -- First try direct zone ID mapping
        if zoneMap[zoneID] then
            printf('Debug: Found achievement ID %d for zone %d', zoneMap[zoneID], zoneID)
            return zoneMap[zoneID]
        end
        
        -- If no direct mapping, try to find achievement by zone name
        printf('Debug: No direct mapping for zone %d, trying name-based lookup', zoneID)
        
        -- Try different achievement name patterns
        local patterns = {
            "Hunter of the " .. zoneName,
            "Hunter of " .. zoneName,
            zoneName .. " Hunter"
        }
        
        -- Check each pattern
        for _, pattern in ipairs(patterns) do
            local ach = mq.TLO.Achievement(pattern)
            if ach and ach() and ach.ID() > 0 then
                printf('Debug: Found achievement by name "%s": ID %d', pattern, ach.ID())
                return ach.ID()
            end
        end
        
        printf('Debug: No achievement found for zone %d (%s)', zoneID, zoneName)
        return 0
    end

    -- Calculate percentage of completed objectives
    function helpers.getPctCompleted(achID, myHunterSpawn, curHunterAch)
        local tmp = 0
        local ach = myAch(achID)
        for _, hunterSpawn in ipairs(myHunterSpawn) do
            if ach and ach.Objective(hunterSpawn) and ach.Objective(hunterSpawn).Completed() then
                tmp = tmp + 1
            end
        end
        local totalDone = string.format('%d/%d', tmp, curHunterAch.Count)
        if tmp == curHunterAch.Count then 
            totalDone = 'Completed!' 
        end
        return tmp / curHunterAch.Count, totalDone
    end

    -- Check group member status in zone and distance
    -- Returns: isAllInRange, statusTable
    -- statusTable is a list of {name, status} where status is either:
    --   - true if in zone and within maxDistance
    --   - false if not in zone
    --   - number (distance) if in zone but beyond maxDistance
    function helpers.getGroupMemberStatus(maxDistance)
        maxDistance = maxDistance or 200 -- Default to 200 units if not specified
        local status = {}
        local allInRange = true
        
        -- If not in a group, return true with empty status
        if not mq.TLO.Group() or mq.TLO.Group.Members() == 0 then
            return true, {}
        end
        
        -- Check each group member (note: Group.Members() does not include yourself)
        for i = 1, mq.TLO.Group.Members() do
            local member = mq.TLO.Group.Member(i)
            if member() then
                local name = member.CleanName()
                
                -- Skip if we can't get the member's name (they're not loaded)
                if not name or name == "" then
                    goto continue
                end
                
                local spawn = mq.TLO.Spawn(string.format('pc =%s', name))
                
                if not spawn() or spawn.ID() == 0 then
                    -- Member is not in zone - only fail if they're actually online
                    if member.Level() and member.Level() > 0 then
                        table.insert(status, {name = name, status = false})
                        -- Don't set allInRange to false for out of zone members
                        -- They might be on another task or waiting at zone line
                    end
                else
                    -- Member is in zone, check distance
                    local distance = spawn.Distance3D() or 0
                    if distance > maxDistance then
                        table.insert(status, {name = name, status = distance})
                        allInRange = false
                    else
                        table.insert(status, {name = name, status = true})
                    end
                end
            end
            ::continue::
        end
        
        return allInRange, status
    end

    -- Get the current zone's data
    function helpers.getCurrentZoneData(zoneMap, zone_lists)
        local currentZoneID = mq.TLO.Zone.ID()
        local currentZoneName = mq.TLO.Zone.Name()
        
        if not currentZoneID or currentZoneID == 0 then return nil, nil end
        
        -- First check zoneMap for exact match
        if zoneMap[currentZoneID] then
            for exp, zones in pairs(zone_lists) do
                for _, zone in ipairs(zones) do
                    if zone.id == currentZoneID then
                        return exp, zone
                    end
                end
            end
        end
        
        -- If no exact match, check zone names (case-insensitive)
        if currentZoneName then
            currentZoneName = currentZoneName:lower()
            for exp, zones in pairs(zone_lists) do
                for _, zone in ipairs(zones) do
                    local zoneName = zone.name()
                    if zoneName and zoneName:lower():find(currentZoneName, 1, true) then
                        return exp, zone
                    end
                end
            end
        end
        
        return nil, nil
    end

    -- Check if group needs invisibility
    function helpers.groupNeedsInvis()
        -- First check if invis is disabled
        if not useInvis then
            return false
        end
        
        -- Check for any active targets
        local xtargetCount = mq.TLO.Me.XTarget() or 0
        if xtargetCount > 0 then
            printf("\\arCannot check invis - mobs on extended target!")
            return false
        end
        
        local groupSize = mq.TLO.Group.GroupSize() or 0
        
        local membersNeedingInvis = 0
        local totalMembersChecked = 0
        
        -- First check the script runner
        local myInvis = mq.TLO.Me.Invis()
        
        if myInvis ~= nil then
            totalMembersChecked = totalMembersChecked + 1
            if myInvis == false then
                --printf("\\ayDEBUG: I am not invisible")
                membersNeedingInvis = membersNeedingInvis + 1
            end
        else
            printf("\\ayDEBUG: Can't see my own invis status")
        end
        
        -- Then check other group members if in a group
        if groupSize > 1 then
            for i = 1, groupSize - 1 do
                local member = mq.TLO.Group.Member(i)
                if member() then
                    local spawn = member.Spawn
                    if spawn() and not member.Mercenary() then
                        local memberInvis = spawn.Invis()
                        
                        if memberInvis ~= nil then
                            totalMembersChecked = totalMembersChecked + 1
                            if memberInvis == false then
                                --printf("\\ayDEBUG: %s is not invisible", spawn.CleanName() or "Unknown")
                                membersNeedingInvis = membersNeedingInvis + 1
                            end
                        end
                    end
                end
            end
        end
        
        return membersNeedingInvis > 0
    end

    return helpers
end

return {
    new = new,
    areAllGroupMembersInZone = function()
        return new().areAllGroupMembersInZone()
    end,
    getGroupMembersNotInZone = function()
        return new().getGroupMembersNotInZone()
    end
}