-- v1.124
local mq = require 'mq'
local BL = require("biggerlib")

local useInvis = true
local function new(myAch)
    local helpers = {}
    helpers.pathCache = {}
    helpers.lastCacheClear = os.clock()

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

    -- Check if a spawn is within a certain Z-axis distance from the reference point
    -- @param spawnID number - The ID of the spawn to check
    -- @param maxZDistance number - Maximum allowed Z-axis distance
    -- @param minZDistance number - Minimum allowed Z-axis distance (optional, defaults to 0)
    -- @param refZ number - Reference Z coordinate (optional, uses current player Z if not provided)
    -- @return boolean - True if within Z distance range, false otherwise
    -- @return number - The actual Z distance (spawnZ - refZ)
    function helpers.checkZDistance(spawnID, maxZDistance, minZDistance, refZ)
        minZDistance = minZDistance or 0 -- Default to 0 for backward compatibility
        refZ = refZ or (mq.TLO.Me.Z() or 0) -- Use provided refZ or current position
        
        local spawn = mq.TLO.Spawn(spawnID)
        if not spawn or not spawn.ID() or spawn.ID() == 0 then
            return false, 0
        end

        local spawnZ = spawn.Z() or 0
        local zDiff = spawnZ - refZ -- Directional difference (positive = above, negative = below)
        
        -- Check if spawn is within Z range
        local inRange = zDiff >= minZDistance and zDiff <= maxZDistance
        return inRange, zDiff
    end

    -- Calculate 2D distance from a reference point to a spawn (for map comparison)
    -- @param spawnID number - The ID of the spawn to check
    -- @param refX number - Reference X coordinate
    -- @param refY number - Reference Y coordinate
    -- @return number - The 2D distance from reference point to spawn
    function helpers.distanceFromReference2D(spawnID, refX, refY)
        local spawn = mq.TLO.Spawn(spawnID)
        if not spawn or not spawn.ID() or spawn.ID() == 0 then
            return math.huge
        end

        local spawnX = spawn.X() or 0
        local spawnY = spawn.Y() or 0
        
        -- Calculate 2D distance (X/Y only, like the map circle)
        local xDiff = spawnX - refX
        local yDiff = spawnY - refY
        
        return math.sqrt(xDiff * xDiff + yDiff * yDiff)
    end

    -- Calculate distance from a reference point to a spawn
    -- @param spawnID number - The ID of the spawn to check
    -- @param refX number - Reference X coordinate
    -- @param refY number - Reference Y coordinate
    -- @param refZ number - Reference Z coordinate (optional, uses current player Z if not provided)
    -- @return number - The 3D distance from reference point to spawn
    function helpers.distanceFromReference(spawnID, refX, refY, refZ)
        local spawn = mq.TLO.Spawn(spawnID)
        if not spawn or not spawn.ID() or spawn.ID() == 0 then
            return math.huge
        end

        local spawnX = spawn.X() or 0
        local spawnY = spawn.Y() or 0
        local spawnZ = spawn.Z() or 0
        
        -- Use provided refZ or current player Z as fallback
        refZ = refZ or (mq.TLO.Me.Z() or 0)
        
        -- Calculate 3D distance from reference point
        local xDiff = spawnX - refX
        local yDiff = spawnY - refY
        local zDiff = spawnZ - refZ
        
        return math.sqrt(xDiff * xDiff + yDiff * yDiff + zDiff * zDiff)
    end

    -- Reference circle functions for distance visualization
    function helpers.showReferenceCircle(referenceX, referenceY, referenceZ, pullRadius)
        if referenceX ~= 0 or referenceY ~= 0 then
            -- More aggressive cleanup - remove all possible circles first
            mq.cmd('/squelch /maploc remove hunter_ref')
            mq.cmd('/squelch /maploc remove') -- Remove all maploc markers as fallback
            
            -- Small delay to ensure removal completes
            if not ImGui then
                mq.delay(100)
            end
            
            -- Create new circle at reference point with red color
            -- Minimize the X by setting smallest size/width and black color to blend with background
            local redR, redG, redB = 220, 20, 60 -- Crimson red
            mq.cmdf('/squelch /maploc %d %d %d size 10 width 1 color 0 0 0 radius %d rcolor %d %d %d label "Range: %d" hunter_ref',
                    referenceY, referenceX, referenceZ, pullRadius, redR, redG, redB, pullRadius)
        end
    end

    function helpers.hideReferenceCircle()
        -- Try specific removal first
        mq.cmd('/squelch /maploc remove hunter_ref')
        -- Fallback: remove all maploc markers (more aggressive)
        mq.cmd('/squelch /maploc remove')
    end

    ------- Sound System
    local ffi = require("ffi")

    -- C code definitions for Windows sound API
    ffi.cdef [[
    int sndPlaySoundA(const char *pszSound, unsigned int fdwSound);
    uint32_t waveOutSetVolume(void* hwo, uint32_t dwVolume);
    uint32_t waveOutGetVolume(void* hwo, uint32_t* pdwVolume);
    ]]

    local winmm = ffi.load("winmm")

    local SND_ASYNC = 0x0001
    local SND_LOOP = 0x0008
    local SND_FILENAME = 0x00020000
    local flags = SND_FILENAME + SND_ASYNC

    -- Function to play sound using Windows API
    function helpers.playSound(name)
        -- Try full path from MacroQuest directory
        local filename = mq.TLO.MacroQuest.Path() .. "\\lua\\hunterhood\\" .. name
        local result = winmm.sndPlaySoundA(filename, flags)
        if result == 0 then
            -- Try fallback path
            local fallback = "lua\\hunterhood\\" .. name
            result = winmm.sndPlaySoundA(fallback, flags)
        end
    end

    -- Find spawn by name with case-insensitive matching
    function helpers.findSpawn(spawn, nameMap)
    if not spawn then return 0 end

    -- Skip the target clear and delay in coroutines to avoid interference
    -- Only do this when not in ImGui context (main thread)
    if not ImGui and not coroutine.running() then
        mq.cmd("/target clear")
        mq.delay(100) -- Small delay to allow spawn list to update
    end

    local originalName = spawn
    if nameMap and nameMap[spawn] then
        spawn = nameMap[spawn]
    end

    -- Try exact match with npc =name syntax first
    local spawnObj = mq.TLO.Spawn('npc =' .. spawn)
    if spawnObj and spawnObj.ID() and spawnObj.ID() > 0 then
        -- Double-check the name matches exactly (case-insensitive)
        local cleanName = spawnObj.CleanName()
        if cleanName and cleanName:lower() == spawn:lower() then
            return spawnObj.ID()
        end
    end

    -- If no match, try with quotes for names with spaces
    spawnObj = mq.TLO.Spawn('npc ="' .. spawn .. '"')
    if spawnObj and spawnObj.ID() and spawnObj.ID() > 0 then
        local cleanName = spawnObj.CleanName()
        if cleanName and cleanName:lower() == spawn:lower() then
            return spawnObj.ID()
        end
    end

    -- If still no match, try without the = but with quotes
    spawnObj = mq.TLO.Spawn('npc "' .. spawn .. '"')
    if spawnObj and spawnObj.ID() and spawnObj.ID() > 0 then
        local cleanName = spawnObj.CleanName()
        if cleanName and cleanName:lower() == spawn:lower() then
            return spawnObj.ID()
        end
    end

    -- Last resort, try without quotes or = but verify the name matches exactly
    spawnObj = mq.TLO.Spawn('npc ' .. spawn)
    if spawnObj and spawnObj.ID() and spawnObj.ID() > 0 then
        local cleanName = spawnObj.CleanName()
        if cleanName and cleanName:lower() == spawn:lower() then
            return spawnObj.ID()
        end
    end

    return 0
end

    -- Target named mob or nearest PH (for right-click functionality)
    -- @param mobName string - Name of named mob to target
    -- @param zoneID number - Zone ID to search in (current zone if nil)
    -- @param nameMap table - Name mapping table for spawn name corrections
    -- @return boolean - True if successfully targeted something, false otherwise
    function helpers.targetMobOrPH(mobName, zoneID, nameMap)
        if not mobName then return false end
        
        zoneID = zoneID or mq.TLO.Zone.ID()
        local spawnID = helpers.findSpawn(mobName, nameMap)
        
        if spawnID > 0 then
            -- Named mob is up, target it
            mq.cmd('/target id ' .. spawnID)
            printf('\a#f8bd21Targeted named mob: %s (ID: %d)', mobName, spawnID)
            return true
        else
            -- Named not up, try to target nearest PH
            local phList = require('Hunterhood.ph_list')
            local phs = phList.getPlaceholders(mobName, zoneID)
            
            if phs and #phs > 0 then
                local nearestPH = nil
                local nearestDist = 999999
                
                for _, ph in ipairs(phs) do
                    local phID = helpers.findSpawn(ph, nameMap)
                    if phID > 0 then
                        local phSpawn = mq.TLO.Spawn(phID)
                        if phSpawn() and not phSpawn.Dead() then
                            local dist = phSpawn.Distance()
                            if dist < nearestDist then
                                nearestDist = dist
                                nearestPH = phID
                            end
                        end
                    end
                end
                
                if nearestPH then
                    local phName = mq.TLO.Spawn(nearestPH).CleanName()
                    mq.cmd('/target id ' .. nearestPH)
                    printf('\a#f8bd21Targeted nearest PH for %s: %s (ID: %d)', mobName, phName, nearestPH)
                    return true
                else
                    printf('\arNo PHs found for %s', mobName)
                end
            else
                printf('\arNo PHs defined for %s', mobName)
            end
        end
        
        return false
    end

    -- Normalize mob names for comparison
    function helpers.normalizeName(name)
        if not name then return "" end
        return name:lower():gsub(" ", "_")
    end

    -- Check for any mobs on extended target (including PHs and named)
    function helpers.hasNonPHTargets(phList, hoodAch, currentZoneID, nameMap)
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
                -- Skip PC targets
                if spawn.Type() == "PC" then
                    goto continue
                end

                local spawnName = spawn.CleanName()
                local spawnDistance = spawn.Distance3D() or math.huge

                -- Check if this is a named mob (using nameMap if available)
                local isNamed = false
                for _, mob in ipairs(hoodAch.Spawns) do
                    local mobName = nameMap and nameMap[mob.name] or mob.name
                    if mobName == spawnName then
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
        --printf('Debug: Current zone ID: %d, Zone name: %s', zoneID, zoneName)

        -- First try direct zone ID mapping
        if zoneMap[zoneID] then
            --printf('Debug: Found achievement ID %d for zone %d', zoneMap[zoneID], zoneID)
            return zoneMap[zoneID]
        end

        -- If no direct mapping, try to find achievement by zone name
        --printf('Debug: No direct mapping for zone %d, trying name-based lookup', zoneID)

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
                        table.insert(status, { name = name, status = false })
                        -- Don't set allInRange to false for out of zone members
                        -- They might be on another task or waiting at zone line
                    end
                else
                    -- Member is in zone, check distance
                    local distance = spawn.Distance3D() or 0
                    if distance > maxDistance then
                        table.insert(status, { name = name, status = distance })
                        allInRange = false
                    else
                        table.insert(status, { name = name, status = true })
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

    -- Simple path validation using PathLength
    -- @param spawn table - The spawn to check
    -- @return boolean - True if spawn has valid path, false otherwise
    function helpers.hasValidPath(spawn)
        if not spawn or not spawn() then 
            return false 
        end
        
        local pathLength = mq.TLO.Navigation.PathLength("id " .. spawn.ID())()
        local hasPath = pathLength and pathLength > 0
        
        -- printf("DEBUG: Spawn '%s' (ID: %d) -> PathLength: %s, HasPath: %s", 
        --     spawn.CleanName() or "unknown", 
        --     spawn.ID(), 
        --     pathLength and tostring(pathLength) or "nil",
        --     hasPath and "YES" or "NO")
        
        return hasPath
    end

    -- Check if player is facing the target within 20 degrees
    ---@return boolean - True if facing target, false otherwise
    function helpers.FacingTarget()
        if mq.TLO.Target.ID() == 0 then return true end
        return math.abs(mq.TLO.Target.HeadingTo.DegreesCCW() - mq.TLO.Me.Heading.DegreesCCW()) <= 20
    end

    function helpers.findNearestSpawnWithPathing(spawns, maxCandidates)
        local now = os.clock()
        local pathCache = helpers.pathCache or {}
        local lastCacheClear = helpers.lastCacheClear or 0
        local CACHE_DURATION = 5 -- seconds
        
        -- Clear cache every CACHE_DURATION seconds
        if now - lastCacheClear > CACHE_DURATION then
            pathCache = {}
            lastCacheClear = now
            helpers.pathCache = pathCache
            helpers.lastCacheClear = lastCacheClear
        end

        -- First pass: find closest candidates by direct distance
        local candidates = {}
        for _, spawn in ipairs(spawns) do
            if spawn and spawn() and not spawn.Dead() then
                local dist = spawn.Distance3D() or math.huge
                table.insert(candidates, {
                    spawn = spawn,
                    dist = dist,
                    id = spawn.ID()
                })
            end
        end

        -- Sort by direct distance
        table.sort(candidates, function(a, b) return a.dist < b.dist end)

        -- Only check the closest N candidates with pathfinding
        local bestSpawn = nil
        local minPathDist = math.huge
        local checked = 0

        for _, candidate in ipairs(candidates) do
            if checked >= (maxCandidates or 5) then break end
            
            -- Check cache first
            local pathLength = pathCache[candidate.id]
            
            if not pathLength then
                -- Not in cache, calculate path
                pathLength = mq.TLO.Navigation.PathLength(candidate.id)()
                pathCache[candidate.id] = pathLength
                helpers.pathCache = pathCache
                coroutine.yield() -- Prevent freezing
            end

            -- Only consider valid paths
            if pathLength > 0 and pathLength < minPathDist then
                minPathDist = pathLength
                bestSpawn = candidate.spawn
            end

            checked = checked + 1
        end

        -- If no valid paths found, fall back to direct distance
        return bestSpawn or (candidates[1] and candidates[1].spawn)
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
            --printf("\\arCannot check invis - mobs on extended target!")
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

    -- Function to check for non-guild members within range (for panic detection)
    function helpers.checkNonGuildInRange(maxRange)
        maxRange = maxRange or 200 -- Default 200 range
        
        -- Get your guild name
        local my_guild = mq.TLO.Me.Guild() or ""
        local in_guild = my_guild ~= "" and my_guild ~= "unknown"
        
        -- Get all PC spawns
        local spawn_filter = function(spawn)
            return spawn.Type() == "PC" and spawn.ID() ~= mq.TLO.Me.ID() and (spawn.Distance3D() or 999) <= maxRange
        end
        
        local pc_spawns = mq.getFilteredSpawns(spawn_filter)
        local nonGuildCount = 0
        
        for _, spawn_obj in ipairs(pc_spawns) do
            if spawn_obj and spawn_obj.Name and spawn_obj.Name() then
                local guild = ""
                
                -- Get guild information with fallbacks
                local freshSpawn = mq.TLO.Spawn(spawn_obj.ID())
                if freshSpawn() then
                    guild = freshSpawn.Guild() or ""
                end
                
                if guild == "unknown" or guild == "" then
                    local nameSpawn = mq.TLO.Spawn("pc " .. spawn_obj.Name())
                    if nameSpawn() then
                        guild = nameSpawn.Guild() or ""
                    end
                end
                
                if guild == "unknown" then guild = "" end
                
                -- If not in your guild (or no guild), count it
                if in_guild then
                    if guild ~= my_guild then
                        nonGuildCount = nonGuildCount + 1
                    end
                else
                    -- If not in a guild, all players count as non-guild
                    nonGuildCount = nonGuildCount + 1
                end
            end
        end
        
        return nonGuildCount
    end

    -- Check if all group members are in the same zone
    -- Uses distance as proxy since member.Zone TLO access has issues
    function helpers.areAllGroupMembersInZone()
        local groupSize = mq.TLO.Group.GroupSize() or 0
        if groupSize <= 1 then
            return true -- Only you, so trivially all in zone
        end

        for i = 1, groupSize - 1 do
            local member = mq.TLO.Group.Member(i)
            if member() then
                local spawn = member.Spawn
                if spawn() then
                    local distance = spawn.Distance3D() or 0
                    -- If distance is >= 999999, member is likely in different zone
                    if distance >= 999999 then
                        return false
                    end
                end
            end
        end

        return true
    end

    -- Get list of group members not in the same zone
    -- Uses distance as proxy since member.Zone TLO access has issues
    function helpers.getGroupMembersNotInZone()
        local notInZone = {}
        local groupSize = mq.TLO.Group.GroupSize() or 0
        if groupSize <= 1 then
            return notInZone -- Only you, so no one to check
        end

        for i = 1, groupSize - 1 do
            local member = mq.TLO.Group.Member(i)
            if member() then
                local spawn = member.Spawn
                if spawn() then
                    local distance = spawn.Distance3D() or 0
                    -- If distance is >= 999999, member is likely in different zone
                    if distance >= 999999 then
                        table.insert(notInZone, spawn.CleanName() or "Unknown")
                    end
                end
            end
        end

        return notInZone
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
    end,
    checkNonGuildInRange = function(maxRange)
        return new().checkNonGuildInRange(maxRange)
    end
}
