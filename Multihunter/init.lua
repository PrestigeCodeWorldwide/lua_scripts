--MultiHunter
--by:  Nerp
--priority sys by knave23

local mq = require("mq")
print('--MultiHunter--')
print('   v1.514')
math.randomseed((mq.gettime()-mq.TLO.Me.ID()) / (os.time()+mq.TLO.Me.ID()))

--Vars
local cycle_time = 500
local delayed_cycle_time = 6000
local xtars={}
local camp_radius = 1750
local camp_count
local engage_radius = 100
local camp_Z = 1000
local camp_ZLow = 600
local camp_ZHigh = 600
local me = mq.TLO.Me.Name()
local me_ID = mq.TLO.Me.ID()
local me_class = mq.TLO.Me.Class.ShortName()
local search_str 
local hunted, hunted_disp
local zone_short_name = mq.TLO.Zone.ShortName()
local item_current_idx, is_selected
local item_current_idx = 0
local saved_dist = false
local convergence_check_dist = 50
local convergence_rand = 8
local convergee
local path_eval_size = 20
local z_penalty = 0
local stuck_count = 0
local dist, dist1, dist2
local display1 = mq.TLO.Spawn(hunted).Name() or 'None'
local display2 = mq.TLO.Spawn(hunted).Distance() or '-'
local display3 = mq.TLO.SpawnCount('pc')() or 'Error'
local display4 = mq.TLO.SpawnCount('corpse') or 'Error'
local near1 = mq.TLO.NearestSpawn(1).Name() or '-'
local near2 = mq.TLO.NearestSpawn(1).Distance() or '-'
local raidcount = mq.TLO.Raid.Members() or mq.TLO.Group.Members()
local zonecount = mq.TLO.SpawnCount('pc')()
local stored_zonecount = zonecount
local me_X, me_Y, me_Z
local i, j, k, n, a, b, PL, X, Y, Z, rand
local convergence_count = 1
local melee_dist = 10
local priority_count = 0

--Flags
local HUNTING = false
local CAMPSET = false
local DEBUG = false
local DEBUG_UI = false
local DEBUG_SPAWNS = false
local DEBUG_MISC = false
local DEBUG_LOOP = false
local DEBUG_STUCK = false
local INFO = true
local OPENGUI = true
local DRAWGUI = true
local PAUSED = true
local USEPET = me_class == 'SHD' or me_class =='NEC' or me_class == 'MAG' or me_class == 'SHM' or me_class =='BST' or me_class =='ENC'
local USEFELLOWSHIP = false
local HIDECORPSES = false
local NOTIFY_POPULATION = true
local HUNT_ONLY_PRIORITIES = false
local HUNT_PRIORITIES_IN_ORDER = false
local PARTIAL_IGNORE = true
local PARTIAL_PRIORITY = true
local POP_STOP = true
local CONVERGED = false
local CONVERGED_TEMP = false
local DO_CONVERGENCE = true


--Arrays
local spawns = { }
local spawns_data = { }
local spawns_lostpath = { }
local ignores = {[zone_short_name]={}}
local priority = {[zone_short_name]={}}
local banlist = { }
local banlist_disp = { }
local mobprioritylist = { }
local mobprioritytext_input = ""
local ignoretext_input = ""
local priority1 = 1
local priority2 = 1
local leap_aa = { ['WAR'] = 3899,['SHD'] = 824,['PAL']=741,['BER']=3899,['BST']=240,['MNK']=1011,
    ['ROG']=1135,['BRD']=8202,['RNG']=616,['MAG']=3841,['NEC']=901,['ENC']=1024,['WIZ']=9701,
    ['SHM']=949,['CLR']=1023,['DRU']=813
    }

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
local function playSound(name)
    -- Try full path from MacroQuest directory
    local filename = mq.TLO.MacroQuest.Path() .. "\\lua\\multihunter\\" .. name
    local result = winmm.sndPlaySoundA(filename, flags)
    if result == 0 then
        -- Try fallback path
        local fallback = "lua\\multihunter\\" .. name
        result = winmm.sndPlaySoundA(fallback, flags)
    end
end

local lua_debug = debug -- preserve Lua debug module before shadowing
local function debug(string,...) if(DEBUG) then print(string.format('[%s] DEBUG: %s',mq.TLO.Time.Time24(),string.format(string,...))) end end
local function info(string,...) if(INFO) then print(string.format('[%s] MultiHunter: %s',mq.TLO.Time.Time24(),string.format(string,...))) end end
local function debug_spawns(string,...)
    if(DEBUG_SPAWNS) then print(string.format('DEBUG_SPAWNS: %s',string.format(string,...))) end
end
local function debug_loop(string,...)
    if(DEBUG_LOOP) then print(string.format('[%s] DEBUG_LOOP: %s',mq.TLO.Time.Time24(),string.format(string,...))) end
end
local function debug_misc(string,...)
    if(DEBUG_MISC) then print(string.format('[%s] DEBUG_MISC: %s',mq.TLO.Time.Time24(),string.format(string,...))) end
end
local function debug_stuck(string,...)
    if(DEBUG_STUCK) then print(string.format('DEBUG_STUCK: \ar%s',string.format(string,...))) end
end
local function debug_UI(string,...)
    if DEBUG_UI then print(string.format('DEBUG_UI: %s',string.format(string,...))) end
end
local function cwtn(string) mq.cmd('/'..def.class..' '..string) end
-----------------------------Ignore List-------------------------------

---from aqobot
--TO DO: Clean up
---Check whether the specified file exists or not.
---@param file_name string @The name of the file to check existence of.
---@return boolean @Returns true if the file exists, false otherwise.
function file_exists(file_name)
    local f = io.open(file_name, "r")
    if f ~= nil then io.close(f) return true else return false end
end

-- Return the first index with the given value (or nil if not found).
local function get_index(array, value)
    for i, v in ipairs(array) do
        if v == value then
            debug_UI('index return '..i)
            debug_UI('index has :'..table.concat(array,", "))
            return i
        end
    end
    return nil
end

local function is_member(array, value)
    if array ~= nil then
        for k, v in ipairs(array) do
            if v == value then return true
            --elseif k == value then return true
            end
        end
    end
    return false
end

local function is_member_partial(array, value)
    if array ~= nil and value ~= nil then
        local lower_value = value:lower()
        for k, v in ipairs(array) do
            if type(v) == 'string' and lower_value:find(v:lower()) then return true end
        end
    end
    return false
end

local function check_ignore(array, name)
    if PARTIAL_IGNORE then
        return is_member_partial(array, name)
    else
        return is_member(array, name)
    end
end

---Load/save type lists
function load_set(type, name)
    local type_file = ('%s\\%s'):format(mq.configDir, string.format('multihunter_%s.lua', name))
    print('Loading: '..type_file)
    if file_exists(type_file) then
        if name == 'ignores' then ignores = assert(loadfile(type_file))()
        elseif name == 'priority' then 
            priority = assert(loadfile(type_file))()
            if not is_member(priority[zone_short_name], 'none') then 
                priority[zone_short_name] = {'none'}
                mq.delay(math.random(2000))
                save_set(priority, 'priority')
            end
        end
    end
end

function save_set(type, name)
    local type_file = ('%s/%s'):format(mq.configDir, string.format('multihunter_%s.lua', name))
    store(type_file, type)
end

function add_type(type, name, zone_short_name, mob_name)
    if type[zone_short_name:lower()] and type[zone_short_name:lower()][get_index(type[zone_short_name:lower()],mob_name)] then return end
    if not type[zone_short_name:lower()] then type[zone_short_name:lower()] = {} end
    table.insert(type[zone_short_name:lower()],mob_name)
    printf('Added %s \ay%s\ax for zone \ar%s\ax', name, mob_name, zone_short_name)
    save_set(type, name)
end

function remove_type(type, name, zone_short_name, mob_name)
    if not type[zone_short_name:lower()] or not type[zone_short_name:lower()][get_index(type[zone_short_name:lower()],mob_name)] then print ('...') return end
    table.remove(type[zone_short_name:lower()], get_index(type[zone_short_name:lower()],mob_name))
    printf('Removed %s \ay%s\ax for zone \ar%s\ax', name, mob_name, zone_short_name)
    save_set(type, name)
end

function set_contains(type, zone_short_name, mob_name)
    return type[zone_short_name:lower()] and type[zone_short_name:lower()][mob_name]
end

-----------------------------File I/O--------------------------------
--Courtesy of aqobot
local write, writeIndent, writers, refCount;
store = function (path, ...)
    local file, e = io.open(path, "w");
    if not file then
        return error(e);
    end
    local n = select("#", ...);
    -- Count references
    local objRefCount = {}; -- Stores reference that will be exported
    for i = 1, n do
        refCount(objRefCount, (select(i,...)));
    end;
    -- Export Objects with more than one ref and assign name
    -- First, create empty tables for each
    local objRefNames = {};
    local objRefIdx = 0;
    file:write("-- Persistent Data\n");
    file:write("local multiRefObjects = {\n");
    for obj, count in pairs(objRefCount) do
        if count > 1 then
            objRefIdx = objRefIdx + 1;
            objRefNames[obj] = objRefIdx;
            file:write("{};"); -- table objRefIdx
        end;
    end;
    file:write("\n} -- multiRefObjects\n");
    -- Then fill them (this requires all empty multiRefObjects to exist)
    for obj, idx in pairs(objRefNames) do
        for k, v in pairs(obj) do
            file:write("multiRefObjects["..idx.."][");
            write(file, k, 0, objRefNames);
            file:write("] = ");
            write(file, v, 0, objRefNames);
            file:write(";\n");
        end;
    end;
    -- Create the remaining objects
    for i = 1, n do
        file:write("local ".."obj"..i.." = ");
        write(file, (select(i,...)), 0, objRefNames);
        file:write("\n");
    end
    -- Return them
    if n > 0 then
        file:write("return obj1");
        for i = 2, n do
            file:write(" ,obj"..i);
        end;
        file:write("\n");
    else
        file:write("return\n");
    end;
    if type(path) == "string" then
        file:close();
    end;
end;

load = function (path)
    local f, e;
    if type(path) == "string" then
        f, e = loadfile(path);
    else
        f, e = path:read('*a')
    end
    if f then
        return f();
    else
        return nil, e;
    end;
end;

-- write thing (dispatcher)
write = function (file, item, level, objRefNames)
	writers[type(item)](file, item, level, objRefNames);
end;
-- write indent
writeIndent = function (file, level)
	for i = 1, level do file:write("\t") end;
end;

-- recursively count references
refCount = function (objRefCount, item)
	-- only count reference types (tables)
    if not objRefCount or not item then 
        print('Error in refCount')
        return false 
    end
	if type(item) == "table" then
		-- Increase ref count
		if objRefCount[item] then
			objRefCount[item] = objRefCount[item] + 1;
		else
			objRefCount[item] = 1;
			-- If first encounter, traverse
			for k, v in pairs(item) do
				refCount(objRefCount, k);
				refCount(objRefCount, v);
			end;
		end;
	end;
end;

-- Format items for the purpose of restoring
writers = {
	["nil"] = function (file, item) file:write("nil"); end;
	["number"] = function (file, item) file:write(tostring(item)); end;
	["string"] = function (file, item) file:write(string.format("%q", item)); end;
	["boolean"] = function (file, item)	if item then file:write("true"); else file:write("false"); end;	end;
	["table"] = function (file, item, level, objRefNames)
			local refIdx = objRefNames[item];
			if refIdx then
				file:write("multiRefObjects["..refIdx.."]");-- Table with multiple references
			else-- Single use table
				file:write("{\n");
				for k, v in pairs(item) do
					writeIndent(file, level+1);
					file:write("[");
					write(file, k, level+1, objRefNames);
					file:write("] = ");
					write(file, v, level+1, objRefNames);
					file:write(";\n");
				end
				writeIndent(file, level);
				file:write("}");
			end;
		end;
	["function"] = function (file, item)
			-- Does only work for "normal" functions, not those with upvalues or c functions
			local dInfo = lua_debug.getinfo(item, "uS");
			if dInfo.nups > 0 then file:write("nil --[[functions with upvalue not supported]]");
			elseif dInfo.what ~= "Lua" then file:write("nil --[[non-lua function not supported]]");
			else
				local r, s = pcall(string.dump,item);
				if r then file:write(string.format("loadstring(%q)", s));
                else file:write("nil --[[function could not be dumped]]");
				end
			end
		end;
	["thread"] = function (file, item) file:write("nil --[[thread]]\n"); end;
	["userdata"] = function (file, item) file:write("nil --[[userdata]]\n"); end;
}

--========================================================================
--                              Main
--========================================================================

local function moveback(distance, angle)
    local val, headingMQ, headingLUA
    local me_X = mq.TLO.Me.X() -- .E TLO returns -X
    local me_Y = mq.TLO.Me.Y()
    local me_Z = mq.TLO.Me.Z()
    facing = 360 - mq.TLO.Me.Heading.Degrees() + 90
    local dx = distance * math.sin(math.rad(facing + angle))
    local dy = distance * math.cos(math.rad(facing + angle))
    local x2 = me_X - dx
    local y2 = me_Y - dy
    debug_stuck('me_X: %s me_Y: %s dx: %s dy: %s x2: %s y2: %s', me_X, me_Y, dx, dy, x2, y2)
    debug_stuck('Nav path check: %s  string: locxy %d %d', tostring(mq.TLO.Navigation.PathExists(string.format('locxy %d %d', x2, y2))()), x2, y2)
    debug_stuck('Nav path distance check: %s for distance: %s', tostring(mq.TLO.Navigation.PathLength(string.format('locxy %d %d %d', x2, y2, me_Z))()), distance)
    if mq.TLO.Navigation.PathExists(string.format('locxyz %d %d %d', x2, y2, me_Z))() then
        if mq.TLO.Navigation.PathLength(string.format('locxyz %d %d %d', x2, y2, me_Z))() > 1.25*distance then
            debug_stuck('PathLength too long - moveback Navigation canceled.')
        else
            debug_stuck('Moving back %s', distance)
            mq.cmd('/squelch /nav '..string.format('locxyz %d %d %d %s', me_X - dx, me_Y - dy, me_Z, 'setopt facing=backward log=off'))
            while mq.TLO.Navigation.Active() do mq.delay(125) end
        end
    end
end

local function get_priority(spawn)
	for i = 1, #mobprioritylist do
        if not spawn.Name() then return #mobprioritylist+1 end
        if PARTIAL_PRIORITY then
            if spawn.Name.Lower():find(mobprioritylist[i]:lower()) or (spawn.Surname() and spawn.Surname.Lower():find(mobprioritylist[i]:lower())) then
                return i
            end
        else
            if spawn.CleanName():lower() == mobprioritylist[i]:lower() then
                return i
            end
        end
	end
	return #mobprioritylist + 1
end

local function is_priority(spawn)
    return get_priority(spawn) <= #mobprioritylist 
end

local function hunt(spawn)
    if mq.TLO.Spawn(spawn).Dead() == true or mq.TLO.Spawn(spawn).ID() == 0 then return false end
    HUNTING = true
    hunted = spawn
    while (mq.TLO.Me.Casting() and me_class ~= 'BRD') do mq.delay(250) end --allow re-buffing
    mq.cmdf('/nav id %s distance=%s log=off',tostring(mq.TLO.Spawn(spawn).ID()),melee_dist)
end

local function hunt_clear()
    debug('Clearing Hunt')
    HUNTING = false
    CONVERGED = false
    mq.cmd('/attack off')
    mq.cmd('/squelch /target clear')
    hunted = 0
    if mq.TLO.Navigation.Active() then mq.cmd('/nav stop log=off') end
    if HIDECORPSES then mq.cmd('/hidec all') end
end

local function get_xtar_count()
    local m = mq.TLO.Me
    local xtc = 0
    for n = 1,20 do 
        if m.XTarget(n).ID() ~= nil and m.XTarget(n).ID() ~= 0 and m.XTarget(n).TargetType() == 'Auto Hater' then
            xtc = xtc+1
        end
    end
    return xtc
end

local function radar()
    if not CAMPSET then return end
    xtar_count = get_xtar_count()  -- because XTHaterCount is a dirty dirty liar
    if xtar_count > 0 then --check xtars for aggro
        xtars = {} --reset each cycle
        for i = 1, xtar_count do
            xtars[i] = mq.TLO.Me.XTarget(i).ID()
            local tmp = mq.TLO.Me.XTarget(i).Name()
            local dist = tonumber(mq.TLO.Spawn(xtars[i]).Distance()) or -1
            local dist2 = mq.TLO.Spawn(hunted).Distance() or -1
            debug_loop('Radar() checkvals: tmp: %s dist: %s Target: %s',tmp,math.floor(dist),tostring(mq.TLO.Target())) --..' ToT: '..ToT)
            if (dist >= 0) and (dist <= engage_radius) and mq.TLO.Navigation.PathExists('id '..xtars[i])() and (xtars[i] ~= hunted) and (dist2 > engage_radius or dist2 < 0) 
                and not CONVERGED then
                hunted = xtars[i]
                hunt(hunted)
                info('XTarget add -> Hunting '..mq.TLO.Spawn(xtars[i]).Name())
                break
            end
        end
    end
end

--is this spawn ok to hunt?
local function valid_spawn(id)
    if ( id == nil or mq.TLO.Spawn(id)() == nil or mq.TLO.Spawn(id)() == 0
        or not mq.TLO.Spawn(id).Targetable() 
        or mq.TLO.Spawn(id).Dead()
        or is_member(banlist, tonumber(id)) 
        or check_ignore(ignores[zone_short_name],mq.TLO.Spawn(id).CleanName()) )
        then return false
    end
    if mq.TLO.Navigation.PathExists('id '..id)() then
        return true
    else return false end
end

--is this still the spawn we should be hunting?
local function verify_spawn(id)
    local checkspawn = mq.TLO.NearestSpawn(1, search_str).ID() or 0
    local checkdist = mq.TLO.Spawn(id).Distance() or 100
    local check3d = mq.TLO.Spawn(id).Distance3D() or 0
    local xtar_count = get_xtar_count()
    if xtar_count > 0 then radar() end
    if ( id == nil or mq.TLO.Spawn(id).Dead() or mq.TLO.Spawn(id).ID() == 0 ) then 
        debug('verify_spawn: Target died - Clearing hunt id= %s',tostring(id))
        info('Target died - Clearing hunt.')
        hunt_clear() 
    elseif ( check_ignore(ignores[zone_short_name], mq.TLO.Spawn(id).CleanName()) and not is_member(xtars,id)) then
        debug('verify_spawn: Target on ignore list. Clearing Hunt') --this is to catch new ignores
        info('Target on ignore list - Clearing hunt.')
        hunt_clear()
    elseif ( check_ignore(ignores[zone_short_name], mq.TLO.Spawn(id).CleanName()) and is_member(xtars,id)) then
        debug('verify_spawn: Target on ignore list but aggro. Continuing Hunt')
    elseif ( is_member(banlist,id) and not is_member(xtars,id)) then
        debug('verify_spawn: Target on banlist - clearing hunt: %s',id) --catch new bans
        info('Target on ban list - Clearing hunt.')
        hunt_clear()
    elseif ( mq.TLO.Navigation.Paused() and not (checkdist < 50) ) then 
        debug('nav reactivated')
        hunt(id) 
    elseif is_member(xtars,id) then
        debug('verify_spawn: target on xtars, continuing hunt.')
    elseif ( not mq.TLO.Navigation.Active() and not mq.TLO.Navigation.PathExists('id '..id)() and check3d > 25 ) then
        debug('verify_spawn: Path to spawn is lost, resetting')
        if spawns_lostpath[id] == nil then
            spawns_lostpath[id] = { count = 1 }
        else
            spawns_lostpath[id]['count'] = spawns_lostpath[id]['count']+1
        end
        if spawns_lostpath[id]['count'] > 6 then
            table.insert(banlist, id)
            table.insert(banlist_disp, string.format('%d  (%s)', id, mq.TLO.Spawn(id).Name() or 'Unknown'))
        end
        hunt_clear()
    elseif ( HUNT_ONLY_PRIORITIES and valid_spawn(checkspawn) and get_priority(mq.TLO.Spawn(checkspawn))<= #mobprioritylist
    and mq.TLO.Navigation.PathLength('id '..id)() > mq.TLO.Navigation.PathLength('id '..checkspawn)() and not CONVERGED and not HUNT_PRIORITIES_IN_ORDER ) then
        debug('verify_spawn: Found closer priority mob enroute, switching hunt')
        hunt_clear()
        hunted = checkspawn
        hunt(checkspawn)
    elseif ( HUNT_PRIORITIES_IN_ORDER and valid_spawn(checkspawn) and get_priority(mq.TLO.Spawn(checkspawn)) <= get_priority(mq.TLO.Spawn(id))
    and mq.TLO.Navigation.PathLength('id '..id)() > mq.TLO.Navigation.PathLength('id '..checkspawn)() and not CONVERGED ) then
        debug('verify_spawn: Found closer priority mob of same priority enroute, switching hunt')
        hunt_clear()
        hunted = checkspawn
        hunt(checkspawn)
    elseif ( priority_count > 0 and is_priority(mq.TLO.Spawn(hunted)) ) then         
        return true --skip further checks if priority mob is hunted
    elseif ( valid_spawn(checkspawn) and mq.TLO.Navigation.PathLength('id '..id)() > mq.TLO.Navigation.PathLength('id '..checkspawn)() and not CONVERGED ) then
        debug_spawns('verify_spawn: path to current: %s id %s checkspawn pathlength: %s',mq.TLO.Navigation.PathLength('id '..id)(),id,mq.TLO.Navigation.PathLength('id '..checkspawn)())
        debug('verify_spawn: Found closer mob enroute, switching hunt')
        hunt_clear()
        hunted = checkspawn
        hunt(checkspawn)
    else
        debug_loop('verify_spawn = valid')
        return true
    end
end

local function engage_check(id)
    local dist = mq.TLO.Spawn(id).Distance() or -1
    if dist > 0 and dist < 100 then
        mq.cmd('/squelch /target id '..tostring(id))
        mq.delay(100)
        if not mq.TLO.Spawn(id)() then return false end
        if dist > melee_dist and not mq.TLO.Navigation.Active() then mq.cmd('/squelch /nav id '..id..' distance='..melee_dist..' log=off') end
        mq.cmd('/squelch /attack on')
        mq.cmd('/squelch /face fast')
        if USEPET then mq.cmd('/pet attack') end
        if mq.TLO.Target.ID() ~= id then
            mq.cmd('/squelch /target id '..tostring(id))
            mq.cmd('/squelch /attack on')
        end
    end
end

local function stuck_check()
    if not saved_dist then saved_dist = (mq.TLO.Spawn(hunted).Distance()) end
    local current_dist = mq.TLO.Spawn(hunted).Distance() or 0
    current_dist = math.floor(current_dist)
    debug_stuck('Stuck check: '..tostring(saved_dist == current_dist)..' saved: '..tostring(saved_dist)..' cur: '..current_dist)
    if saved_dist == current_dist and not mq.TLO.Navigation.Paused() and current_dist > 25 and saved_dist > 25 then
        stuck_count = stuck_count+1
        if stuck_count == 2 then
            info('\atStuck detected[L1]: Activating nearest door')
            mq.cmd('/doortarget')
            mq.delay(200)
            mq.cmd('/click left door')
        elseif stuck_count == 6 then
            PAUSED = true
            mq.cmd('/nav pause log=off')
            info('\atStuck detected[L2]: Trying moveback right')
            moveback(45,125)
            PAUSED = false
            hunt(hunted)
        elseif stuck_count == 7 then
            PAUSED = true
            mq.cmd('/nav pause log=off')
            info('\atStuck detected[L3]: Trying moveback left')
            moveback(45,-125)
            PAUSED = false
            hunt(hunted)
        elseif stuck_count > 10 and stuck_count <= 12 then
            print('\atStuck detected[L4]: Trying ducking')
            mq.cmd('/duck')
            mq.delay(1000)
            mq.cmd('/jump')
            mq.delay(500)
            mq.cmd('/stand')
        elseif stuck_count > 16 and USEFELLOWSHIP then
            info('\atStuck detected[L5]: Still stuck - using fellowship if able')
            mq.cmd('/useitem "Fellowship Registration Insignia"') 
        elseif stuck_count > 17 then
            info('\atStuck deteced[L5]: Still stuck, clearing current hunt target')
            hunt_clear()
            stuck_count = 0
        end
    else 
        stuck_count = 0
    end
    --TO DO: special case: no path to any spawn|off-mesh -> face nearest npc in los & leap
    saved_dist = current_dist
end

local function nav_check(id)
    if mq.TLO.Navigation.Paused() then
        hunt(id)
    end
end

local function in_camp(id)
    local s = mq.TLO.Spawn(id)
    if not s() or s.ID() == 0 then return false end
    local Xs = s.X()
    local Ys = s.Y()
    local Zs = s.Z()
    if Xs == nil or Ys == nil or Zs == nil or X == nil or Y == nil or Z == nil then return false end
    local Ds = math.sqrt(math.pow(X - Xs, 2) + math.pow(Y - Ys, 2))
    if ( Ds < camp_radius and ( Zs > (Z - camp_ZLow )) and ( Zs < (Z + camp_ZHigh)) ) then return true end
    return false
end

local function pc_near(id)
    return false
end

local function spawnfilter(spawn)
    if not spawn then return false end
    local id = spawn.ID()
    if not id or id == 0 then return false end
    if not spawn.Targetable() then return false
    elseif spawn.Dead() then return false
    elseif spawn.Type() ~= 'NPC' then return false
    elseif check_ignore(ignores[zone_short_name], spawn.CleanName() or '') then return false
    elseif is_member(banlist,id) then return false
    elseif not in_camp(id) then return false
    elseif pc_near(id) then return false
    --lag inducing
    --elseif not mq.TLO.Navigation.PathExists('id '..id)() then return false
    else return true
    end
end

local function sort_strictp_dist(a,b)
    --debug(tostring(a.name)..':  a.priority = '..tostring(a.priority)..' a.dist='..tostring(a.dist)..' | '..tostring(b.name)..': b.priority = '..tostring(b.priority)..' b.dist='..tostring(b.dist))
    if a.priority ~= b.priority then return a.priority < b.priority
    --elseif a.priority > b.priority then return false
    else return a.dist < b.dist
    end
end
local function sort_priority(a,b)
    --if is_priority(a.spawn) ~= is_priority(b.spawn) then return is_priority(a.spawn) and not is_priority(b.spawn)
    --elseif is_priority(a.spawn) == is_priority(b.spawn) then return is_priority(a.spawn)
    --elseif a.dist > b.dist then return false
    --else return a.dist <= b.dist
    if is_priority(a.spawn) ~= is_priority(b.spawn) then return is_priority(a.spawn)
    else return a.dist < b.dist
    end
end
local function sort_dist(a,b) return a.dist < b.dist end
local function sort_strictp(a,b)
    if a.priority ~= b.priority then return a.priority < b.priority
    else return false
    end
end
local function sort_strictp_pl(a,b)
    if a.priority ~= b.priority then return a.priority < b.priority
    else return a.PathL < b.PathL
    end
end
local function sort_priority_pl(a,b)
    if is_priority(a.spawn) ~= is_priority(b.spawn) then return is_priority(a.spawn) 
    else return a.PathL < b.PathL
    end
end
local function sort_pl(a,b) return a.PathL < b.PathL end

local function get_spawn()
    camp_count = mq.TLO.SpawnCount(search_str)()
    priority_count = 0
    spawns = { } -- reset lists
    spawns_data = { }
    spawns_sorting = { }
    spawns = mq.getFilteredSpawns(spawnfilter)
    xtar_count = get_xtar_count()
    if xtar_count > 0 then radar() end
    if HUNTING then return end
    -- spawns_data{} contains base data for all spawns inside camp radius minus pathlength
    for k = 1, #spawns do
        local sp = spawns[k]
        if not sp or not sp.ID or sp.ID() == 0 then break end
        local sp_id = sp.ID()
        local sp_dist3d = sp.Distance3D() or 0
        local sp_z = sp.Z() or 0
        local me_z = mq.TLO.Me.Z() or 0
        local sp_name = sp.Name() or 'Unknown'
        local sp_priority = get_priority(sp)
        table.insert(spawns_data, {
			ID = sp_id,
			dist = sp_dist3d + ( math.abs(sp_z - me_z) * z_penalty ),
			name = sp_name,
            spawn = sp,
            priority = sp_priority
		})
        if sp_priority <= #mobprioritylist then priority_count = priority_count + 1 end
    end
    debug('priority_count = %s',tostring(priority_count))
    if HUNT_ONLY_PRIORITIES and #mobprioritylist > 0 and priority_count == 0 then
        info('No Priority mobs up in camp radius, waiting')
    elseif HUNT_PRIORITIES_IN_ORDER and #mobprioritylist > 0 then
        --table.sort(spawns_data, sort_dist)
        --table.sort(spawns_data, sort_strictp)
        table.sort(spawns_data, sort_strictp_dist)
    elseif priority_count > 0 then 
        table.sort(spawns_data, sort_priority)
    else
        table.sort(spawns_data, sort_dist)
    end

    i = 1  
    if ( mq.TLO.SpawnCount('pc radius '..convergence_check_dist)() > convergence_count and not CONVERGED) then
        convergee = mq.TLO.NearestSpawn(convergence_count+1,'pc radius '..convergence_check_dist).ID()
        if convergee < me_ID then
            rand = math.floor(math.random(convergence_rand))
            debug('\agConvergence detected, selecting random skip ahead i = %s, rand = %s, camp_count = %s',i,rand,camp_count)
            info('\agConvergence detected. --> Skipping ahead.')
            CONVERGED = true
            CONVERGED_TEMP = true
        else
            info('\ag Convergence detected. --> My ID was lower. Continuing as normal.')
        end
    else 
        rand = 0 
    end

    local nopathcount = 0
    --i: spawns iterator, k:  spawns_data iterator
    while i < #spawns and not HUNTING do
        --chunk PathLength evals to reduce CPU spike on pathlength
        for n = i, i + path_eval_size do
            if spawns[n] == nil or spawns_data[n] == nil then
                debug_spawns('end of array at n = '..n)
                break
            end
            local raw_pl = mq.TLO.Navigation.PathLength('id '..tostring(spawns_data[n].ID))()
            PL = raw_pl and math.floor(raw_pl) or -1
            spawns_data[n]['PathL'] = PL
        end
        j = #spawns_sorting + 1
        --build a shorter array for sorting
        for k = j , j + path_eval_size do
            if spawns_data[k] == nil then break end 
            if HUNT_ONLY_PRIORITIES and get_priority(spawns_data[k].spawn) <= #mobprioritylist then 
                if spawns_data[k].PathL ~= -1 and spawns_data[k].PathL ~= nil then
                    table.insert(spawns_sorting, {
                        ID=spawns_data[k].ID,
                        dist=spawns_data[k].dist,
                        PathL=spawns_data[k].PathL,
                        name=spawns_data[k].name,
                        spawn=spawns_data[k].spawn,
                        priority=spawns_data[k].priority
                    })
                end
			elseif not HUNT_ONLY_PRIORITIES and spawns_data[k].PathL ~= -1 and spawns_data[k].PathL ~= nil then
                table.insert(spawns_sorting, {
					ID=spawns_data[k].ID,
					dist=spawns_data[k].dist,
					PathL=spawns_data[k].PathL,
					name=spawns_data[k].name,
                    spawn=spawns_data[k].spawn,
                    priority=spawns_data[k].priority
				})
            end
        end

        if #spawns_sorting > 0 then
            if DEBUG_SPAWNS then 
                --for k = 1 , #spawns_sorting do
                    --debug_spawns('spawns_sorting['..k..'].PathL = '..tostring(spawns_sorting[k].PathL)..' type '..type(spawns_sorting[k].PathL))
                --end
            end
            debug('#spawns : %s',tostring(#spawns))
            debug('#spawns_data : %s',tostring(#spawns_data))
            debug('#spawns_sorting : %s',tostring(#spawns_sorting))
            --check again for nil values (iterate backwards to avoid index shift)
            for k = #spawns_sorting, 1, -1 do
                if not spawns_sorting[k] or not spawns_sorting[k].ID
                    or mq.TLO.Spawn(spawns_sorting[k].ID).ID() == nil
                    or spawns_sorting[k].PathL == nil then
                    table.remove(spawns_sorting, k)
                end
            end
            
            --re-sort the additional spawns we just inserted for this cycle
            --[[table.sort(spawns_sorting, 
                function(a,b) 
                    if (a.priority > b.priority) then return a.priority < b.priority end
                    if (a.PathL > b.PathL) then return a.PathL < b.PathL end
                end )]]
            if HUNT_ONLY_PRIORITIES and #mobprioritylist > 0 then
                table.sort(spawns_sorting, sort_strictp_pl)
            elseif HUNT_PRIORITIES_IN_ORDER and #mobprioritylist > 0 then 
                 table.sort(spawns_sorting, sort_strictp_pl)
            elseif priority_count > 0 then
                table.sort(spawns_sorting, sort_priority_pl)
            else
                table.sort(spawns_sorting, sort_pl)
            end
            
            local conv_skip = 0
            for k = 1, #spawns_sorting do
                if CONVERGED_TEMP then
                    conv_skip = rand
                    CONVERGED_TEMP = false
                end
                if conv_skip > 0 then
                    conv_skip = conv_skip - 1
                elseif spawns_sorting[k] == nil then
                    debug('No targets found, waiting. k = %s, spawn count = %s',k,tostring(camp_count))
                    info('No targets found, waiting.')
                    mq.delay(delayed_cycle_time)
                    break
                else
                    npcID = spawns_sorting[k].ID
                    if npcID == nil or npcID == 0 then
                        debug('ID was nil or 0. k = %s',k)
                        break
                    end
                    local npcName = mq.TLO.Spawn(npcID).Name() or 'Unknown'
                    debug('checking spawnsort: %s, i: %s, k: %s, id: %s, PL: %s, dist: %s',npcName,i,k,npcID,spawns_sorting[k].PathL,spawns_sorting[k].dist)
                    if HUNT_ONLY_PRIORITIES and get_priority(spawns_sorting[k].spawn) <= #mobprioritylist then
                        debug('Priority Target Found: %s, k = %s',npcName,k)
                        info('Priority Target Found: %s',npcName)
                        hunted = npcID
                        hunt(hunted)
                        break
                    elseif HUNT_PRIORITIES_IN_ORDER and get_priority(spawns_sorting[k].spawn) <= #mobprioritylist then
                        debug('Priority Target Found: %s, k = %s',npcName,k)
                        info('Priority Target Found: %s',npcName)
                        hunted = npcID
                        hunt(hunted)
                        break
                    elseif not HUNT_ONLY_PRIORITIES and not HUNT_PRIORITIES_IN_ORDER then
                        debug('Target Found: %s, k=%s',npcName,k)
                        info('Target Found: %s',npcName)
                        hunted = npcID
                        hunt(hunted)
                        break
                    end
                end
            end
            debug('i = '..i)
            if ( i > camp_count ) then
                debug('No targets found, waiting. i = %s, spawn count = %s',i,tostring(mq.TLO.SpawnCount(search_str)()))
                debug('There are %s spawns with no path in camp envelope.',nopathcount)
                info('No targets found, waiting.')
                mq.delay(delayed_cycle_time)
            end
        end
        i = i + path_eval_size
        debug('i = '..i)
    end
    mq.delay(cycle_time)
end





local function set_camp()
    X = mq.TLO.Me.X()
    Y = mq.TLO.Me.Y()
    Z = mq.TLO.Me.Z()
    mq.cmd('/squelch /maploc remove 1')
    mq.cmd('/squelch /maploc remove 1')
    search_str = string.format('npc targetable nopet loc %d %d %d radius %d', X, Y, Z, camp_radius)
    --search_str = string.format('npc targetable nopet loc %d %d %d radius %d zradius %d', X, Y, Z, camp_radius, camp_Z)
    CAMPSET = true
    print(string.format('Camp set to : %.2f, %.2f, %.2f  (X,Y,Z)',X,Y,Z))
    mq.cmdf('/squelch /maploc size 10 width 1 radius %d %s %s',camp_radius, Y, X)
end

local function update_camp()
    if not CAMPSET then 
        print('Set Camp first.')
    else
        mq.cmd('/squelch /maploc remove 1')
        mq.cmd('/squelch /maploc remove 1')
        print('MultiHunter: Camp Ranges Updated.')
        --search_str = string.format('npc targetable nopet loc %d %d %d radius %d zradius %d', X, Y, Z, camp_radius, camp_Z)
        search_str = string.format('npc targetable nopet loc %d %d %d radius %d', X, Y, Z, camp_radius)
        mq.cmdf('/squelch /maploc size 10 width 1 radius %d %s %s',camp_radius, Y, X)
    end
end

local function set_radius(arg)
    camp_radius = arg
    print('Hunt Camp Radius set to: '..arg)
    update_camp()
    --mq.cmdf('/mapfilter campradius %d',camp_radius)
end

local function bind_hunt(...)
    local args = {...}
    local key = args[1]
    local value = args[2]
    if key == 'camp' then
        set_camp()
    elseif key == 'start' or key == 'resume' then
        if CAMPSET then PAUSED = false
        else print('Set camp first') end
    elseif key == 'pause' then
        PAUSED = true
    elseif key == 'convergence' then
        if value == 'on' then DO_CONVERGENCE = true
        elseif value == 'off' then DO_CONVERGENCE = false
        else 
            DO_CONVERGENCE = DO_CONVERGENCE==false
        end
        print('Check Convergence set to: '..tostring(DO_CONVERGENCE))
    elseif key == 'radius' then
        set_radius(tonumber(value))
    elseif key == 'zlow' then
        camp_ZLow = tonumber(value)
    elseif key == 'zhigh' then
        camp_ZHigh = tonumber(value)
    elseif key == 'debug' then
        if(DEBUG) then DEBUG = false
        elseif(not DEBUG) then DEBUG = true
        end
    elseif key =='addignore' then
        add_type(ignores, 'ignores', zone_short_name, value)
    elseif key =='removeignore' then
        remove_type(ignores, 'ignores', zone_short_name, value)
    elseif key =='load' then
        load_set(ignores, 'ignores')
    elseif key == 'ban' then
        if type(tonumber(value)) == 'number' then
            table.insert(banlist, tonumber(value))
            table.insert(banlist_disp, string.format('%d  (%s)',mq.TLO.Spawn(tonumber(value)).ID(),mq.TLO.Spawn(tonumber(value)).Name()))
        else
            print('/hunt ban #')
        end
	elseif key == 'prioritize' then
		table.insert(mobprioritylist, value)
		print('Priority added: '..tostring(value))
    end
end

local function event_zoned()
    print('Zone Changed -- Multihunter.lua paused and reset.')
    PAUSED = true
    zone_short_name = mq.TLO.Zone.ShortName()
    hunt_clear()
    ignores = {}
    banlist = {}
    banlist_disp = { }
	mobprioritylist = { }
    spawns_lostpath = { }
    load_set(ignores, 'ignores')
end


local function Init()
    if ( not mq.TLO.Plugin('mq2spawnsort').IsLoaded() ) then mq.cmd.plugin('mq2spawnsort') end
    --if ( not mq.TLO.Plugin('mq2xassist').IsLoaded() ) then mq.cmd.plugin('mq2xassist') end
    mq.bind('/hunt', bind_hunt)
    mq.event('zoned1','#*#LOADING, PLEASE WAIT...#*#',event_zoned)
    mq.delay(math.random(1500))
    load_set(ignores, 'ignores')
    -- Update stored_zonecount to current zone count for proper monitoring
    stored_zonecount = mq.TLO.SpawnCount('pc')()
    if zonecount > raidcount and NOTIFY_POPULATION then 
        mq.cmd('/popup Someone Else is in Zone. Are you sure you want to Hunt it?')
    end

end
--is target aggro on me?
--is target a corpse?
--is pathlength ok?  use spawnsort
local function Main()
    while true do
        if ( not PAUSED and not HUNTING and CAMPSET) then
            debug_loop('Calling Radar from Main')
            radar()
            get_spawn()
        end
        if not PAUSED and HUNTING then
            radar()
            debug_loop('Calling verify_spawn from Main.  Hunted = '..hunted)
            verify_spawn(hunted)
            nav_check(hunted)
            stuck_check()
            engage_check(hunted)
        end
        zonecount = mq.TLO.SpawnCount('pc')()
        if not PAUSED and zonecount > stored_zonecount and NOTIFY_POPULATION then 
            mq.cmd('/popup Zone Population changed!')
            print('Zone Population changed! ')
            playSound('panic.wav')
        end
        if not PAUSED and zonecount > stored_zonecount and POP_STOP then 
            PAUSED = true
            mq.cmd('/popup Someone else zoned in. Stopping Hunt')
            print('Someone else zoned in. Stopping Hunt')
            hunt_clear()
        end
        stored_zonecount = zonecount
        mq.doevents()
        mq.delay(cycle_time)
    end
end

----------------------------------UI-----------------------------------

local function select(array)
    local result = {}
    for k,v in pairs(array) do
        table.insert(result,{array[v], format('%s = 1', array[v])})
    end
    return result
end
        

local function draw_combo_box(label, resultvar, options, bykey)
    if ImGui.BeginCombo(string.format('##%s',label), resultvar) then
        for i,j in pairs(options) do
            if bykey then
                if ImGui.Selectable(i, i == resultvar) then
                    resultvar = i
                end
            else
                if ImGui.Selectable(j, j == resultvar) then
                    resultvar = j
                end
            end
        end
        ImGui.EndCombo()
    end
    return resultvar
end

local function HelpMarker(desc)
    if ImGui.IsItemHovered() then
        ImGui.BeginTooltip()
        ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35.0)
        ImGui.Text(desc)
        ImGui.PopTextWrapPos()
        ImGui.EndTooltip()
    end
end

local function hunt_ui()
    if not OPENGUI or mq.TLO.MacroQuest.GameState() ~= 'INGAME' then 
        info('UI Closed, Exiting script.')
        mq.exit() 
    end
    OPENGUI, DRAWGUI = ImGui.Begin('MultiHunter', OPENGUI)
    if DRAWGUI then
        ImGui.PushItemWidth(140)
        --ImGui.SetWindowFontScale(1)
        ImGui.BeginTabBar('Tabs') 
        if ImGui.BeginTabItem("Main") then
            if ImGui.Button('Set Camp') then
                set_camp()
            end
            ImGui.SameLine()
            if PAUSED then
                if ImGui.Button('Start') then
                    if CAMPSET then
                        PAUSED = false
                    else print('Set camp first.')
                    end
                end
                if ImGui.IsItemClicked(1) then
                    mq.cmd('/dga /docommand /hunt start')
                end
                if ImGui.IsItemHovered() then
                    ImGui.SetTooltip('Left Click: Start on self only\nRight Click: Start on all toons running script')
                end
            else
                if ImGui.Button('Pause') then
					mq.cmd('/nav pause')
                    PAUSED = true
                end
                if ImGui.IsItemClicked(1) then
                    mq.cmd('/dga /docommand /hunt pause')
                end
                if ImGui.IsItemHovered() then
                    ImGui.SetTooltip('Left Click: Pause on self only\nRight Click: Pause on all toons running script')
                end
            end
            ImGui.SameLine()
            if HIDECORPSES then
                if ImGui.Button('Show the Carnage') then
                    HIDECORPSES = false
                    mq.cmd('/hidec none')
                end
            else
                if ImGui.Button('Hide the Bodies') then
                    HIDECORPSES = true
                    mq.cmd("/hidec all")
                end
            end

            ImGui.SameLine()
            if ImGui.Button('Reset') then
                hunt_clear()
            end

            if ImGui.Button('Ban Target') then
                if mq.TLO.Target() then
                    table.insert(banlist, mq.TLO.Target.ID())
                    table.insert(banlist_disp, string.format('%d  (%s)',mq.TLO.Target.ID(),mq.TLO.Target.Name()))
                else
                    print('Target a mob first.')
                end
            end
            ImGui.SameLine()
            if ImGui.Button('Ignore Target') then
                if mq.TLO.Target() then
                    add_type(ignores, 'ignores', zone_short_name, mq.TLO.Target.CleanName())
                else
                    print('Target a mob first.')
                end
            end
            if ImGui.IsItemClicked(1) then
                if mq.TLO.Target() then
                    mq.cmd('/dga /docommand /hunt addignore ' .. mq.TLO.Target.CleanName())
                else
                    print('Target a mob first.')
                end
            end
            if ImGui.IsItemHovered() then
                ImGui.SetTooltip('Left Click: Ignore on this toon only\nRight Click: Ignore on all toons running script')
            end
            ImGui.SameLine()
            if ImGui.Button('All: Reload Ignores') then
                mq.cmd('/dgex /hunt load')
            end
            --camp_radius = ImGui.SliderInt("Camp Radius", camp_radius, 250,6000)
            --camp_Z = ImGui.SliderInt("Camp Z Radius", camp_Z, 10,3000)
            
            camp_radius = ImGui.DragInt("Camp Radius", camp_radius, 25,250,9999)
            HelpMarker("Drag or Ctrl-Click to change then click Update") 

            ImGui.PushItemWidth(80) 
            camp_ZHigh = ImGui.DragInt("ZHigh", camp_ZHigh, 10,10,3000)
            ImGui.SameLine()
            camp_ZLow = ImGui.DragInt("ZLow   ", camp_ZLow, 10,10,3000)
            ImGui.SameLine()
            if ImGui.Button('Update') then
                update_camp()
            end   

            local hunted_disp = hunted or 'none'
            local display = mq.TLO.Spawn(hunted_disp)
            local display1 = display.Name() or 'None'
            local display2 = display.Distance() or 0.0
            local display2a = mq.TLO.Navigation.PathLength('id '..hunted_disp)() or 0
            local display3 = mq.TLO.SpawnCount('pc')() or 'Error'
            local display4 = mq.TLO.SpawnCount('corpse') or 'Error'
            local near = mq.TLO.NearestSpawn('npc targetable nopet')
            local near1 = near.Name() or '-'
            local near2 = near.Distance() or 0.0
            local near2a = mq.TLO.Navigation.PathLength('id '..tostring(near.ID()))() or 0

            ImGui.Text('Hunting : ')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(1,1,0,1),string.format('%s (%4.1f) PL(%4.1f)', display1, tonumber(display2),tonumber(display2a)))
            ImGui.Text('Nearest : ')
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(1,1,0,1),string.format('%s (%4.1f) PL(%4.1f)', near1, tonumber(near2),tonumber(near2a)))
            ImGui.Text('')
            ImGui.Text(string.format('Zone PC Count :  %s   ', display3))
            ImGui.SameLine()
            
            NOTIFY_POPULATION = ImGui.Checkbox('Notify ',NOTIFY_POPULATION )
            HelpMarker("Notify if Population changes") 
            ImGui.SameLine()
            POP_STOP = ImGui.Checkbox('Stop ',POP_STOP)
            HelpMarker("Stop if Population changes") 
            ImGui.Text(string.format('Corpse Count    :  %s ', display4))
            ImGui.PopItemWidth()
			HUNT_ONLY_PRIORITIES = ImGui.Checkbox('Hunt only Priorities ', HUNT_ONLY_PRIORITIES )
			HelpMarker("Only hunt mobs in priority list")
			HUNT_PRIORITIES_IN_ORDER = ImGui.Checkbox('Hunt Priorities in Strict Order', HUNT_PRIORITIES_IN_ORDER )
			HelpMarker("Hunt all top priority mobs, then second, etc., regardless of distance")

            ImGui.EndTabItem()
        end 

        if ImGui.BeginTabItem("Bans") then
            if ImGui.Button('Remove List Item') then
                if item_current_idx > 0 then
                    print('Removing Ban: #'..item_current_idx..' | ID# '..banlist[item_current_idx])
                    table.remove(banlist, item_current_idx)
                    table.remove(banlist_disp, item_current_idx)
                else
                    print('Select a list item to remove') 
                end
            end
            ImGui.SameLine() 
            
            if ImGui.Button('Ban Target') then
                if mq.TLO.Target() then
                    table.insert(banlist, mq.TLO.Target.ID())
                    table.insert(banlist_disp, string.format('%d  (%s)',mq.TLO.Target.ID(),mq.TLO.Target.Name()))
                else
                    print('Target a mob first.')
                end
            end
            HelpMarker("Note: Bans are not saved, and are purged when zoning.") 
            ImGui.SameLine() 
            if ImGui.Button('All: Ban Target') then
                if mq.TLO.Target() then
                    table.insert(banlist, mq.TLO.Target.ID())
                    table.insert(banlist_disp, string.format('%d  (%s)',mq.TLO.Target.ID(),mq.TLO.Target.Name()))
                    mq.cmd('/dgex /hunt ban '..mq.TLO.Target.ID())
                else
                    print('Target a mob first.')
                end
            end
            HelpMarker("/dgex /hunt ban <ID>") 

            ImGui.Text("Hunt Banned IDs (Temporary):")
            if (ImGui.BeginListBox("##Ban List",ImVec2(-.9,0))) then
            
                if banlist_disp ~= nil then
                    for n = 1, #banlist_disp do
                        is_selected = (item_current_idx == n)
                        if ( ImGui.Selectable(tostring(banlist_disp[n]), is_selected) ) then
                            item_current_idx = n
                            debug_UI('item_current_idx = '..item_current_idx..' n = '..n)
                            is_selected = (item_current_idx == n)
                            debug_UI('is_selected = '..tostring(is_selected))
                        end
                        if (is_selected) then
                            ImGui.SetItemDefaultFocus(item_current_idx)
                        end
                    end
                end
                ImGui.EndListBox()
            end
            ImGui.EndTabItem() 
        end
		
		if ImGui.BeginTabItem("Priority") then
            if ImGui.Button('Remove List Item') then
                if item_current_idx > 0 then
                    print('Removing Priority: #'..mobprioritylist[item_current_idx])
                    table.remove(mobprioritylist, item_current_idx)
                else
                    print('Select a list item to remove') 
                end
            end
            ImGui.SameLine() 
			if ImGui.Button('Clear Priority List') then
				mobprioritylist = {}
			end
            
            if ImGui.Button('Prioritize Target') then
                if mq.TLO.Target() then
					tmp = string.gsub(mq.TLO.Target.Name(), "%d*$", "")
                    table.insert(mobprioritylist, tmp)
                else
                    print('Target a mob first.')
                end
            end
            HelpMarker("Note: Priorities are not saved, and are purged when zoning.") 
            ImGui.SameLine() 
            if ImGui.Button('All: Prioritize Target') then
                if mq.TLO.Target() then
                    table.insert(mobprioritylist, mq.TLO.Target.Name())
                    mq.cmd('/dgex /hunt prioritize '..mq.TLO.Target.Name())
                else
                    print('Target a mob first.')
                end
            end
			PARTIAL_PRIORITY = ImGui.Checkbox('Partial Name Match', PARTIAL_PRIORITY)
			HelpMarker("Match partial names and surnames (case insensitive). When off, requires exact name match.")
			
            mobprioritytext_input, _ = ImGui.InputText("##priorityinput##edit", mobprioritytext_input)
			ImGui.SameLine()
			if ImGui.Button('Add to Priority List') then
                if mobprioritytext_input ~= '' then
                    table.insert(mobprioritylist, mobprioritytext_input)
                else
                    print('Input a mob name to add it to the list.')
                end
            end
            
            ImGui.Text("Prioritized Mobs (Temporary and in Priority Order):")
            if (ImGui.BeginListBox("##Priority List",ImVec2(-.9,0))) then
            
                if mobprioritylist ~= nil then
                    for n = 1, #mobprioritylist do
                        is_selected = (item_current_idx == n)
                        if ( ImGui.Selectable(tostring(mobprioritylist[n]), is_selected) ) then
                            item_current_idx = n
                            debug_UI('item_current_idx = '..item_current_idx..' n = '..n)
                            is_selected = (item_current_idx == n)
                            debug_UI('is_selected = '..tostring(is_selected))
                        end
                        if (is_selected) then
                            ImGui.SetItemDefaultFocus(item_current_idx)
                        end
                    end
                end
                ImGui.EndListBox()
            end
            
			if ImGui.Button('Increase Priority') then
                if item_current_idx > 1 then
                    print('Increasing Priority: # '..mobprioritylist[item_current_idx])
                    table.insert(mobprioritylist, item_current_idx - 1, mobprioritylist[item_current_idx])
					table.remove(mobprioritylist, item_current_idx + 1)
					item_current_idx = item_current_idx - 1
                else
                    print('Select a list item to increase.') 
                end
            end
            ImGui.SameLine() 
            if ImGui.Button('Decrease Priority') then
                if item_current_idx > 0 and item_current_idx < #mobprioritylist then
                    table.insert(mobprioritylist, item_current_idx + 2, mobprioritylist[item_current_idx])
					table.remove(mobprioritylist, item_current_idx)
					item_current_idx = item_current_idx + 1
                else
                    print('Select a list item to decrease.')
                end
            end
			

			
            ImGui.EndTabItem() 
        end

        if ImGui.BeginTabItem("Ignores") then
            if ImGui.Button('Remove List Item') then
                if item_current_idx > 0 then
                    print('remove_type'..zone_short_name..', '..tostring(ignores[zone_short_name][item_current_idx])..')')
                    remove_type(ignores, 'ignores', zone_short_name, ignores[zone_short_name][item_current_idx])
                else
                    print('Select a list item to remove') -- index='..item_current_idx)
                end
            end
            if ImGui.IsItemClicked(1) then
                if item_current_idx > 0 then
                    mq.cmd('/dga /docommand /hunt removeignore ' .. ignores[zone_short_name][item_current_idx])
                else
                    print('Select a list item to remove')
                end
            end
            if ImGui.IsItemHovered() then
                ImGui.SetTooltip('Left Click: Remove on this toon only\nRight Click: Remove on all toons running script')
            end
            ImGui.SameLine() 
            if ImGui.Button('Ignore Target') then
                if mq.TLO.Target() then
                    add_type(ignores, 'ignores', zone_short_name, mq.TLO.Target.CleanName())
                else
                    print('Target a mob first.')
                end
            end
            ImGui.SameLine() 
            if ImGui.Button('Reload .ini') then
                load_set(ignores, 'ignores')
            end
            if ImGui.Button('All: Reload Ignores') then
                mq.cmd('/dgex /hunt load')
            end
            PARTIAL_IGNORE = ImGui.Checkbox('Partial Name Match', PARTIAL_IGNORE)
            HelpMarker("Match partial names (case insensitive). When off, requires exact name match.")
            ignoretext_input, _ = ImGui.InputText("##ignoreinput##edit", ignoretext_input)
            ImGui.SameLine() 
            if ImGui.Button('Add to Ignore List') then
                if ignoretext_input ~= '' then
                    add_type(ignores, 'ignores', zone_short_name, ignoretext_input)
                    ignoretext_input = ""
                else
                    print('Input a mob name to add it to the list.')
                end
            end
            ImGui.Text("Hunter Ignores:")
            if (ImGui.BeginListBox("##Hunter Ignores",ImVec2(-.9,0))) then
            
                if ignores[zone_short_name] ~= nil then
                    for n = 1, #ignores[zone_short_name] do
                        is_selected = (item_current_idx == n)
                        if (ImGui.Selectable(ignores[zone_short_name][n], is_selected)) then
                            item_current_idx = n
                            debug_UI('item_current_idx = '..item_current_idx..' n = '..n)
                            is_selected = (item_current_idx == n)
                            debug_UI('is_selected = '..tostring(is_selected))
                        end
                        -- Set the initial focus when opening the combo (scrolling + keyboard navigation focus)
                        if (is_selected) then
                            ImGui.SetItemDefaultFocus(item_current_idx)
                        end
                    end
                end
                ImGui.EndListBox()
            end

            ImGui.EndTabItem() 
        end

        if ImGui.BeginTabItem("Misc") then
            cycle_time=ImGui.DragInt("Cycle Time, ms", cycle_time, 250,250,5000)
            engage_radius=ImGui.DragInt("XTar Engage Radius", engage_radius, 25,5,500)
            HelpMarker("How close should an xtarget be for us to chase after it.") 
            melee_dist=ImGui.DragInt("Melee Distance", melee_dist, 1,1,25)
            HelpMarker("Maintain this distance when engaged.") 
            path_eval_size=ImGui.SliderInt("Path Eval Size", path_eval_size, 5,50)
            HelpMarker("How many spawns to evaluate path length per pass")
            z_penalty =ImGui.SliderInt("Z Sort Penalty", z_penalty, 0,50)
            HelpMarker("Sorting Penalty for Z axis.")
            convergence_count =ImGui.SliderInt("Convergence Count", convergence_count, 1,6)
            HelpMarker("Trigger nearby pc count for de-convergence. Adjust if you are using group on chase") 
            USEPET = ImGui.Checkbox('Use Pet',USEPET)
            HelpMarker("Pet attack when in range") 
            ImGui.SameLine()   
            USEFELLOWSHIP = ImGui.Checkbox('Use Fellowship',USEFELLOWSHIP)
            HelpMarker("Use fellowship insignia as last resort for stuck") 
            DO_CONVERGENCE = ImGui.Checkbox('Check Convergence',DO_CONVERGENCE)
            INFO = ImGui.Checkbox('Basic Hunt Info',INFO)
            HelpMarker("See what's going on") 
            DEBUG = ImGui.Checkbox('DEBUG',DEBUG)
            HelpMarker("Turn on spam") 
            ImGui.SameLine()            
            DEBUG_UI = ImGui.Checkbox('DEBUG_UI',DEBUG_UI)
            DEBUG_SPAWNS = ImGui.Checkbox('DEBUG_SPAWNS',DEBUG_SPAWNS)
            ImGui.SameLine()  
            DEBUG_MISC = ImGui.Checkbox('DEBUG_MISC',DEBUG_MISC)
            DEBUG_STUCK = ImGui.Checkbox('DEBUG_STUCK',DEBUG_STUCK)
            ImGui.SameLine()  
            DEBUG_LOOP = ImGui.Checkbox('DEBUG_LOOP',DEBUG_LOOP)
            ImGui.EndTabItem() 
        end

        ImGui.EndTabBar()
        
    end
    ImGui.End()
end

mq.imgui.init('MultiHunter', hunt_ui)


Init()
Main()