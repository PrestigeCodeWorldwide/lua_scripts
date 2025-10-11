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
        --return name:lower():gsub(" ", "_"):gsub("'", ""):gsub("-", "") -- more aggressive stripping if needed later
    end

    -- Check for non-PH mobs on extended target
    function helpers.hasNonPHTargets(phList, hoodAch)
        -- Only check XTargets, ignore current target
        local xtargetCount = mq.TLO.Me.XTarget() or 0
        for i = 1, xtargetCount do
            local target = mq.TLO.Me.XTarget(i)
            if target() and target.ID() > 0 then
                local spawn = mq.TLO.Spawn(target.ID())
                if spawn() and not spawn.Dead() then
                    -- Make sure this isn't a PH
                    local isPH = false
                    for _, mob in ipairs(hoodAch.Spawns) do
                        local placeholders = phList[mob.name] or {}
                        for _, phName in ipairs(placeholders) do
                            if helpers.normalizeName(spawn.Name()) == helpers.normalizeName(phName) then
                                isPH = true
                                break
                            end
                        end
                        if isPH then break end
                    end
                    
                    if not isPH then
                        return true, spawn
                    end
                end
            end
        end
        
        return false, nil
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
    --printf("\\ayDEBUG: Checking group invis - Group size: %d", groupSize)
    
    local membersNeedingInvis = 0
    local totalMembersChecked = 0
    
    -- First check the script runner
    local myInvis = mq.TLO.Me.Invis()
    --printf("\\ayDEBUG: Checking self (%s) - Invis: %s", mq.TLO.Me.Name() or "Unknown", tostring(myInvis))
    
    if myInvis ~= nil then
        totalMembersChecked = totalMembersChecked + 1
        if myInvis == false then
            printf("\\ayDEBUG: I am not invisible")
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
                if spawn() and not spawn.Mercenary() then
                    local memberInvis = spawn.Invis()
                    --printf("\\ayDEBUG: Checking %s - Invis: %s", spawn.CleanName() or "Unknown", tostring(memberInvis))
                    
                    if memberInvis ~= nil then
                        totalMembersChecked = totalMembersChecked + 1
                        if memberInvis == false then
                            printf("\\ayDEBUG: %s is not invisible", spawn.CleanName() or "Unknown")
                            membersNeedingInvis = membersNeedingInvis + 1
                        end
                    end
                end
            end
        end
    end
    
    --printf("\\ayDEBUG: %d of %d members need invis", membersNeedingInvis, totalMembersChecked)
    return membersNeedingInvis > 0
end

    return helpers
end

return {
    new = new
}