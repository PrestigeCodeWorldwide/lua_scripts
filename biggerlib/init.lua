---@type Mq
local mq = require("mq")
local Log = require("biggerlib.log")
local Enum = require("biggerlib.enum")

---@class BL
---BiggerLib (BL) is a utility library providing a collection of functions and submodules to enhance Lua scripting capabilities within MacroQuest.
---
---@field log BL.Log Provides logging functions with different levels such as info, warn, error, and dump.
---@field Enum table A utility for creating enumerations.
---@field UI table Contains functions related to user interface utilities.
---@field Lume table A submodule providing a set of helper functions for table manipulation, math calculations, string manipulation, and more.
---@field ZenArray table A submodule offering functional array utilities to work with tables as arrays.
---@field GroupCmd fun(cmd: string) Executes a command on the entire group.
---@field IsNil fun(thingToCheckForNilly: any):boolean Checks if a value is nil or a string representation of nil.
---@field NotNil fun(thingToCheckForNilly: any):boolean Checks if a value is not nil or a string representation of nil.
---@field parseAllNames fun(names: string):table Parses a string of names separated by commas and/or 'and'.
---@field nameListIncludesMe fun(namesString: string):boolean Determines if the current character's name is included in a given list of names.
---@field searchForAliveSpawnByName fun(name: string, optionalRadius: number|nil):any Searches for a spawn by name within an optional radius.
---@field TargetAndNavTo fun(targetName: string, optionalRadius: number|nil) Targets a spawn by name and navigates to it.
---@field getRandomPointOnCircle fun():number, number Generates a random point on a circle centered around the player's position.
---@field cmd.pauseAutomation fun() Pauses automation scripts and stops various character actions.
---@field cmd.resumeAutomation fun() Resumes paused automation scripts.
---@field cmd.runToAfterDelay fun(x: number, y: number, z: number, delay: number)Waits for a delay then navigates to a location.
---@field cmd.setRngSeedFromPlayerPosition fun()Sets the RNG seed based on the player's position.
---@field cmd.returnToRaidMainAssist fun() Navigates to the raid main assist if one is set.
---@field cmd.removeZerkerRootDisc fun() Removes the Berserker root discipline if it is active.
---@field cmd.sendRaidChannelMessage fun(messageToSend: string) Sends a message to the raid channel.
---@field cmd.sendGroupChatMessage fun(messageToSend: string) Sends a message to the group chat.
---@field cmd.sendFellowshipChannelMessage fun(messageToSend: string) Sends a message to the fellowship chat channel.
---@field IHaveBuff fun(buffName: string):boolean Returns true if the current character has the specified buff.
---@field WaitForNav fun() Waits until navigation is complete before continuing.
---@field UI.GetOnOffColor fun(val: string):string Utility function for on/off text coloring.
---@field MakeGroupVisible fun() Makes the entire group visible.
local BL = {}

---@class BL.Log
---@field info fun(message: string)|nil @Logs an informational message.
---@field warn fun(message: string)|nil @Logs a warning message.
---@field error fun(message: string)|nil @Logs an error message.
---@field dump fun(value: any)|nil @Dumps a value for debugging purposes.

BL.cmd = {}
---@type BL.Log
BL.log = {}
BL.Enum = Enum
BL.UI = {}

-- #region Oneoffs


--- Runs /dgga "cmd", so your whole group will each execute whatever command
---@param cmd string @The command to be executed on the group.
function BL.GroupCmd(cmd)
	mq.cmd("/dgga " .. cmd)
end

--- Checks if the given value is neither nil nor a string representation of nil.
-- ---@alias MQSpawn spawn | fun(): string|nil -- reminder that all the MQ userdatas can be a function or a spawn
---@param thingToCheckForNilly any @The value to check for nil or "nil" representations.
---@return boolean @Returns true if the value is nil or "nil", false otherwise.
function IsNil(thingToCheckForNilly)
	if type(thingToCheckForNilly) == "function" then
		thingToCheckForNilly = thingToCheckForNilly()
	end
	return thingToCheckForNilly == nil
		or thingToCheckForNilly == "NULL"
		or thingToCheckForNilly == "nil"
		or thingToCheckForNilly == {}
		or thingToCheckForNilly == ""
end

BL.IsNil = IsNil

--- Checks if the given value is neither nil nor a string representation of nil.
---@param thingToCheckForNilly any @The value to check for nil or "nil" representations.
---@return boolean @Returns true if the value is not nil or "nil", false otherwise.
function NotNil(thingToCheckForNilly)
	return IsNil(thingToCheckForNilly) == false
end

BL.NotNil = NotNil

--- For use in MQ events from the parser, meant to be the "line" that the event handler accepts.
--- Parses a string of names separated by commas and/or the word 'and', and returns a list of names.
--- Usually followed by nameListIncludesMe()
---@seealso BL.nameListIncludesMe
---@param names string @The string containing names to parse.
---@return table @Returns a table of parsed names.
function BL.parseAllNames(names)
	local withoutAnd = names:gsub(", and", ",")

	-- Handle case where only "and" is used without a comma (e.g., "personA and personB")
	withoutAnd = withoutAnd:gsub(" and ", ",")

	-- Split string by comma
	local nameList = {}
	for name in withoutAnd:gmatch("[^,]+") do
		-- Trim whitespace and insert into list
		table.insert(nameList, name:match("^%s*(.-)%s*$"))
	end

	return nameList
end

--- Determines if the current character's name is included in a given list of names. Usually preceded by parseAllNames()
---@param namesString string @A string representing a list of names, separated by commas and/or 'and'.
---@return boolean @Returns true if the character's name is in the list, false otherwise.
function BL.nameListIncludesMe(namesString)
	local names = BL.parseAllNames(namesString)
	local myname = mq.TLO.Me.CleanName()

	for _, name in ipairs(names) do
		if name == myname then
			return true
		end
	end

	return false
end

--- Searches for a spawn by name within an optional radius and returns it if found.
--- This is intended to be used like `BL.searchForAliveSpawnByName("npc targetable egg", 300)`
---@param name string @The name of the spawn to search for.
---@param optionalRadius number|nil @The optional radius within which to search for the spawn.
---@return nil|string|spawn|function():spawn|nil|string @Returns the spawn userdata if found, nil otherwise.
function BL.searchForAliveSpawnByName(name, optionalRadius)
	local searchString = name
	if optionalRadius then
		searchString = searchString .. " radius " .. optionalRadius
	end
	local spawnFound = mq.TLO.Spawn(searchString)

	if BL.NotNil(spawnFound) then
		return spawnFound
	end
	return nil
end

--- Targets a spawn by name.  After targeting, navigates to it, with an optional search radius.
---@param targetName string @The name of the target spawn.
---@param optionalRadius number|nil @The optional radius within which to search for the target spawn.
function BL.TargetAndNavTo(targetName, optionalRadius)
	while not targetSpawned do
		local targetSpawn = mq.TLO.Spawn(targetName)
		mq.delay(1000)
		if BL.NotNil(targetSpawn) then
			targetSpawned = true
		end
	end

	local targetSpawn = mq.TLO.Spawn("targetable " .. targetName)
	if targetSpawn() then
		targetSpawn.DoTarget()
	else
		BL.warn("WARNING: Could not find targetable spawn: " .. targetName)
	end

	mq.cmd("/nav target")
	BL.WaitForNav()
end

--- Generates a random point on a circle centered around the player's current position.
---@return number, number @Returns the X and Y coordinates of the random point on the circle.
function BL.getRandomPointOnCircle()
	local h, k = mq.TLO.Me.X(), mq.TLO.Me.Y()
	local r = 160
	local z = -46
	-- Generate a random angle between 0 and 2*pi
	local theta = math.random() * 2 * math.pi

	-- Calculate the X and Y coordinates based on the random angle
	local X = h + r * math.cos(theta)
	local Y = k + r * math.sin(theta)

	return X, Y
end

--- Pauses automation scripts and stops various character actions.
function BL.cmd.pauseAutomation()
	mq.cmd("/boxr Pause")
	mq.delay(50)
	mq.cmd("/afollow off")
	mq.cmd("/nav stop")
	mq.cmd("/stopsong")
	mq.cmd("/attack off")
	mq.delay(50)
end

--- Plain boxr unpause
function BL.cmd.resumeAutomation()
	mq.cmd("/boxr Unpause")
end

-- This function waits for 'delay' seconds, then navigates to a location.
-- It will not return control until the destination is reached
---@param x number @The X coordinate of the destination.
---@param y number @The Y coordinate of the destination.
---@param z number @The Z coordinate of the destination.
---@param delay number @The delay in seconds before starting navigation.
function BL.cmd.runToAfterDelay(x, y, z, delay)
	mq.delay(delay .. "s")
	mq.cmdf("/nav locyxz %d %d %d", x, y, z)
	BL.WaitForNav()
	print(string.format("Navigation arrived at: " .. x .. y .. z))
end

function BL.cmd.setRngSeedFromPlayerPosition()
	local h, k = mq.TLO.Me.X(), mq.TLO.Me.Y()
	math.randomseed(os.time() * h / k)
end

--- Navigates to the raid main assist if one is set.
function BL.cmd.returnToRaidMainAssist()
	mq.delay(10)
	--Check to see if we have a raid assist, then return to him
	local mainAssistName = mq.TLO.Raid.MainAssist(1).Name()
	if mainAssistName then
		mq.cmd("/nav spawn pc =" .. mainAssistName)
	else
		print("WARNING: No raid main assist set")
	end
end

--- Removes the Berserker root discipline if it is active.
function BL.cmd.removeZerkerRootDisc()
	local my_class = mq.TLO.Me.Class.ShortName()
	if my_class == "BER" and mq.TLO.Me.ActiveDisc.Name() == mq.TLO.Spell("Frenzied Resolve Discipline").RankName() then
		mq.cmd("/stopdisc")
	end
end

--- Sends a message to the raid channel.
---@param messageToSend string @The message to send to the raid channel.
function BL.cmd.sendRaidChannelMessage(messageToSend)
	mq.cmdf("/rs %s", messageToSend)
	BL.info(messageToSend)
end

--- Sends a message to the group chat.
---@param messageToSend string @The message to send to the group chat.
function BL.cmd.sendGroupChatMessage(messageToSend)
	mq.cmdf("/g %s", messageToSend)
	BL.info(messageToSend)
end

--- Sends a message to the fellowship chat channel.
---@param messageToSend string @The message to send to the raid channel.
function BL.cmd.sendFellowshipChannelMessage(messageToSend)
	mq.cmdf("/fs %s", messageToSend)
	BL.info(messageToSend)
end

--- Returns true if the current character has the buff with the given name
---@param buffName string @The name of the buff to check for.
---@return boolean @Returns true if the character has the buff, false otherwise.
function BL.IHaveBuff(buffName)
    local buffID = mq.TLO.Me.Buff(buffName).ID()
    if buffID ~= nil and buffID > 0 then
        return true
    end
    return false
end

-- Runs to locx,locy any time toon has debuff applied to them.
function BL.RunToWhileDebuffed(debuffName, locX, locY)
	if BL.IHaveBuff(debuffName) then
		-- we have the debuff, run to safe spot
		mq.cmd('/g I have the AOE debuff, running to safe spot')
		BL.cmd.pauseAutomation()
		mq.delay(500)
		mq.cmdf('/nav locyx %s %s', locX, locY)
		
		while BL.IHaveBuff(debuffName) do
			mq.delay(1000)
		end
		mq.cmd('/g AOE debuff is gone, resuming')
		BL.cmd.resumeAutomation()
	end
end

--- Waits until navigation is complete before continuing.
--- Intended to be used as a Coroutine yield spin
function BL.WaitForNav()
	-- Nav doesn't seem to report Active immediately, force a yield
	mq.delay(100, function()
		return mq.TLO.Navigation.Active()
	end)
	mq.delay(1000, function()
		return not mq.TLO.Navigation.Active()
	end)
end

--- Utility function for on/off text coloring
function BL.UI.GetOnOffColor(val)
	if val == "on" then
		return "\agon"
	elseif val == "off" then
		return "\aroff"
	end
	return val
end

--- Utility function for making your whole group visible
function BL.MakeGroupVisible()
	BL.GroupCmd("/makemevisible")
end

-- #endregion oneoffs

-- #region CLIBinds

-- #endregion CLIBinds

-- #region Enum Library

-- #endregion Enum Library

-- #region Logging Utils

--- Prints to MQ Console in green with prefix of INFO
BL.info = Log.info
--- Prints to MQ Console in yellow with prefix of WARN
BL.warn = Log.warn
--- Prints to MQ Console in red with prefix of ERROR
BL.error = Log.logerror
--- Developer utility dump function.  Prints absolutely any lua variable in human-readable fashion to the MQ console
BL.dump = Log.dump

BL.log = {
	info = Log.info,
	warn = Log.warn,
	error = Log.logerror,
	dump = Log.dump,
}

-------------------------------  END LOGGING UTILS ---------------------------------
-- #endregion Logging Utils

-- #region Lume
------------------------------- LUME LIBRARY --------------------------------------

local lume = { _version = "2.3.0" }

local pairs, ipairs = pairs, ipairs
local type, assert, unpack = type, assert, unpack or table.unpack
local tostring, tonumber = tostring, tonumber
local math_floor = math.floor
local math_ceil = math.ceil
local math_atan2 = math.atan2 or math.atan
local math_sqrt = math.sqrt
local math_abs = math.abs

local noop = function() end

local identity = function(x)
	return x
end

local patternescape = function(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

local absindex = function(len, i)
	return i < 0 and (len + i + 1) or i
end

local iscallable = function(x)
	if type(x) == "function" then
		return true
	end
	local mt = getmetatable(x)
	return mt and mt.__call ~= nil
end

local getiter = function(x)
	if lume.isarray(x) then
		return ipairs
	elseif type(x) == "table" then
		return pairs
	end
	BL.error("expected table", 3)
end

local iteratee = function(x)
	if x == nil then
		return identity
	end
	if iscallable(x) then
		return x
	end
	if type(x) == "table" then
		return function(z)
			for k, v in pairs(x) do
				if z[k] ~= v then
					return false
				end
			end
			return true
		end
	end
	return function(z)
		return z[x]
	end
end

function lume.clamp(x, min, max)
	return x < min and min or (x > max and max or x)
end

function lume.round(x, increment)
	if increment then
		return lume.round(x / increment) * increment
	end
	return x >= 0 and math_floor(x + 0.5) or math_ceil(x - 0.5)
end

function lume.sign(x)
	return x < 0 and -1 or 1
end

function lume.lerp(a, b, amount)
	return a + (b - a) * lume.clamp(amount, 0, 1)
end

function lume.smooth(a, b, amount)
	local t = lume.clamp(amount, 0, 1)
	local m = t * t * (3 - 2 * t)
	return a + (b - a) * m
end

function lume.pingpong(x)
	return 1 - math_abs(1 - x % 2)
end

function lume.distance(x1, y1, x2, y2, squared)
	local dx = x1 - x2
	local dy = y1 - y2
	local s = dx * dx + dy * dy
	return squared and s or math_sqrt(s)
end

function lume.angle(x1, y1, x2, y2)
	return math_atan2(y2 - y1, x2 - x1)
end

function lume.vector(angle, magnitude)
	return math.cos(angle) * magnitude, math.sin(angle) * magnitude
end

function lume.random(a, b)
	if not a then
		a, b = 0, 1
	end
	if not b then
		b = 0
	end
	return a + math.random() * (b - a)
end

function lume.randomchoice(t)
	return t[math.random(#t)]
end

function lume.weightedchoice(t)
	local sum = 0
	for _, v in pairs(t) do
		assert(v >= 0, "weight value less than zero")
		sum = sum + v
	end
	assert(sum ~= 0, "all weights are zero")
	local rnd = lume.random(sum)
	for k, v in pairs(t) do
		if rnd < v then
			return k
		end
		rnd = rnd - v
	end
end

function lume.isarray(x)
	return type(x) == "table" and x[1] ~= nil
end

function lume.push(t, ...)
	local n = select("#", ...)
	for i = 1, n do
		t[#t + 1] = select(i, ...)
	end
	return ...
end

function lume.remove(t, x)
	local iter = getiter(t)
	for i, v in iter(t) do
		if v == x then
			if lume.isarray(t) then
				table.remove(t, i)
				break
			else
				t[i] = nil
				break
			end
		end
	end
	return x
end

function lume.clear(t)
	local iter = getiter(t)
	for k in iter(t) do
		t[k] = nil
	end
	return t
end

function lume.extend(t, ...)
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if x then
			for k, v in pairs(x) do
				t[k] = v
			end
		end
	end
	return t
end

function lume.shuffle(t)
	local rtn = {}
	for i = 1, #t do
		local r = math.random(i)
		if r ~= i then
			rtn[i] = rtn[r]
		end
		rtn[r] = t[i]
	end
	return rtn
end

function lume.sort(t, comp)
	local rtn = lume.clone(t)
	if comp then
		if type(comp) == "string" then
			table.sort(rtn, function(a, b)
				return a[comp] < b[comp]
			end)
		else
			table.sort(rtn, comp)
		end
	else
		table.sort(rtn)
	end
	return rtn
end

function lume.array(...)
	local t = {}
	for x in ... do
		t[#t + 1] = x
	end
	return t
end

function lume.each(t, fn, ...)
	local iter = getiter(t)
	if type(fn) == "string" then
		for _, v in iter(t) do
			v[fn](v, ...)
		end
	else
		for _, v in iter(t) do
			fn(v, ...)
		end
	end
	return t
end

function lume.map(t, fn)
	fn = iteratee(fn)
	local iter = getiter(t)
	local rtn = {}
	for k, v in iter(t) do
		rtn[k] = fn(v)
	end
	return rtn
end

function lume.all(t, fn)
	fn = iteratee(fn)
	local iter = getiter(t)
	for _, v in iter(t) do
		if not fn(v) then
			return false
		end
	end
	return true
end

function lume.any(t, fn)
	fn = iteratee(fn)
	local iter = getiter(t)
	for _, v in iter(t) do
		if fn(v) then
			return true
		end
	end
	return false
end

function lume.reduce(t, fn, first)
	local started = first ~= nil
	local acc = first
	local iter = getiter(t)
	for _, v in iter(t) do
		if started then
			acc = fn(acc, v)
		else
			acc = v
			started = true
		end
	end
	assert(started, "reduce of an empty table with no first value")
	return acc
end

function lume.unique(t)
	local rtn = {}
	for k in pairs(lume.invert(t)) do
		rtn[#rtn + 1] = k
	end
	return rtn
end

function lume.filter(t, fn, retainkeys)
	fn = iteratee(fn)
	local iter = getiter(t)
	local rtn = {}
	if retainkeys then
		for k, v in iter(t) do
			if fn(v) then
				rtn[k] = v
			end
		end
	else
		for _, v in iter(t) do
			if fn(v) then
				rtn[#rtn + 1] = v
			end
		end
	end
	return rtn
end

function lume.reject(t, fn, retainkeys)
	fn = iteratee(fn)
	local iter = getiter(t)
	local rtn = {}
	if retainkeys then
		for k, v in iter(t) do
			if not fn(v) then
				rtn[k] = v
			end
		end
	else
		for _, v in iter(t) do
			if not fn(v) then
				rtn[#rtn + 1] = v
			end
		end
	end
	return rtn
end

function lume.merge(...)
	local rtn = {}
	for i = 1, select("#", ...) do
		local t = select(i, ...)
		local iter = getiter(t)
		for k, v in iter(t) do
			rtn[k] = v
		end
	end
	return rtn
end

function lume.concat(...)
	local rtn = {}
	for i = 1, select("#", ...) do
		local t = select(i, ...)
		if t ~= nil then
			local iter = getiter(t)
			for _, v in iter(t) do
				rtn[#rtn + 1] = v
			end
		end
	end
	return rtn
end

function lume.find(t, value)
	local iter = getiter(t)
	for k, v in iter(t) do
		if v == value then
			return k
		end
	end
	return nil
end

function lume.match(t, fn)
	fn = iteratee(fn)
	local iter = getiter(t)
	for k, v in iter(t) do
		if fn(v) then
			return v, k
		end
	end
	return nil
end

function lume.count(t, fn)
	local count = 0
	local iter = getiter(t)
	if fn then
		fn = iteratee(fn)
		for _, v in iter(t) do
			if fn(v) then
				count = count + 1
			end
		end
	else
		if lume.isarray(t) then
			return #t
		end
		for _ in iter(t) do
			count = count + 1
		end
	end
	return count
end

function lume.slice(t, i, j)
	i = i and absindex(#t, i) or 1
	j = j and absindex(#t, j) or #t
	local rtn = {}
	for x = i < 1 and 1 or i, j > #t and #t or j do
		rtn[#rtn + 1] = t[x]
	end
	return rtn
end

function lume.first(t, n)
	if not n then
		return t[1]
	end
	return lume.slice(t, 1, n)
end

function lume.last(t, n)
	if not n then
		return t[#t]
	end
	return lume.slice(t, -n, -1)
end

function lume.invert(t)
	local rtn = {}
	for k, v in pairs(t) do
		rtn[v] = k
	end
	return rtn
end

function lume.pick(t, ...)
	local rtn = {}
	for i = 1, select("#", ...) do
		local k = select(i, ...)
		rtn[k] = t[k]
	end
	return rtn
end

function lume.keys(t)
	local rtn = {}
	local iter = getiter(t)
	for k in iter(t) do
		rtn[#rtn + 1] = k
	end
	return rtn
end

function lume.clone(t)
	local rtn = {}
	for k, v in pairs(t) do
		rtn[k] = v
	end
	return rtn
end

function lume.fn(fn, ...)
	assert(iscallable(fn), "expected a function as the first argument")
	local args = { ... }
	return function(...)
		local a = lume.concat(args, { ... })
		return fn(unpack(a))
	end
end

function lume.once(fn, ...)
	local f = lume.fn(fn, ...)
	local done = false
	return function(...)
		if done then
			return
		end
		done = true
		return f(...)
	end
end

local memoize_fnkey = {}
local memoize_nil = {}

function lume.memoize(fn)
	local cache = {}
	return function(...)
		local c = cache
		for i = 1, select("#", ...) do
			local a = select(i, ...) or memoize_nil
			c[a] = c[a] or {}
			c = c[a]
		end
		c[memoize_fnkey] = c[memoize_fnkey] or { fn(...) }
		return unpack(c[memoize_fnkey])
	end
end

function lume.combine(...)
	local n = select("#", ...)
	if n == 0 then
		return noop
	end
	if n == 1 then
		local fn = select(1, ...)
		if not fn then
			return noop
		end
		assert(iscallable(fn), "expected a function or nil")
		return fn
	end
	local funcs = {}
	for i = 1, n do
		local fn = select(i, ...)
		if fn ~= nil then
			assert(iscallable(fn), "expected a function or nil")
			funcs[#funcs + 1] = fn
		end
	end
	return function(...)
		for _, f in ipairs(funcs) do
			f(...)
		end
	end
end

function lume.call(fn, ...)
	if fn then
		return fn(...)
	end
end

function lume.time(fn, ...)
	local start = os.clock()
	local rtn = { fn(...) }
	return (os.clock() - start), unpack(rtn)
end

local lambda_cache = {}

function lume.lambda(str)
	if not lambda_cache[str] then
		local args, body = str:match([[^([%w,_ ]-)%->(.-)$]])
		assert(args and body, "bad string lambda")
		local s = "return function(" .. args .. ")\nreturn " .. body .. "\nend"
		lambda_cache[str] = lume.dostring(s)
	end
	return lambda_cache[str]
end

local serialize

local serialize_map = {
	["boolean"] = tostring,
	["nil"] = tostring,
	["string"] = function(v)
		return string.format("%q", v)
	end,
	["number"] = function(v)
		if v ~= v then
			return "0/0" --  nan
		elseif v == 1 / 0 then
			return "1/0" --  inf
		elseif v == -1 / 0 then
			return "-1/0"
		end -- -inf
		return tostring(v)
	end,
	["table"] = function(t, stk)
		stk = stk or {}
		if stk[t] then
			BL.error("circular reference")
		end
		local rtn = {}
		stk[t] = true
		for k, v in pairs(t) do
			rtn[#rtn + 1] = "[" .. serialize(k, stk) .. "]=" .. serialize(v, stk)
		end
		stk[t] = nil
		return "{" .. table.concat(rtn, ",") .. "}"
	end,
}

setmetatable(serialize_map, {
	__index = function(_, k)
		BL.error("unsupported serialize type: " .. k)
	end,
})

serialize = function(x, stk)
	return serialize_map[type(x)](x, stk)
end

function lume.serialize(x)
	return serialize(x)
end

function lume.deserialize(str)
	return lume.dostring("return " .. str)
end

function lume.split(str, sep)
	if not sep then
		return lume.array(str:gmatch("([%S]+)"))
	else
		assert(sep ~= "", "empty separator")
		local psep = patternescape(sep)
		return lume.array((str .. sep):gmatch("(.-)(" .. psep .. ")"))
	end
end

function lume.trim(str, chars)
	if not chars then
		return str:match("^[%s]*(.-)[%s]*$")
	end
	chars = patternescape(chars)
	return str:match("^[" .. chars .. "]*(.-)[" .. chars .. "]*$")
end

function lume.wordwrap(str, limit)
	limit = limit or 72
	local check
	if type(limit) == "number" then
		check = function(s)
			return #s >= limit
		end
	else
		check = limit
	end
	local rtn = {}
	local line = ""
	for word, spaces in str:gmatch("(%S+)(%s*)") do
		local s = line .. word
		if check(s) then
			table.insert(rtn, line .. "\n")
			line = word
		else
			line = s
		end
		for c in spaces:gmatch(".") do
			if c == "\n" then
				table.insert(rtn, line .. "\n")
				line = ""
			else
				line = line .. c
			end
		end
	end
	table.insert(rtn, line)
	return table.concat(rtn)
end

function lume.format(str, vars)
	if not vars then
		return str
	end
	local f = function(x)
		return tostring(vars[x] or vars[tonumber(x)] or "{" .. x .. "}")
	end
	return (str:gsub("{(.-)}", f))
end

function lume.trace(...)
	local info = debug.getinfo(2, "Sl")
	local t = { info.short_src .. ":" .. info.currentline .. ":" }
	for i = 1, select("#", ...) do
		local x = select(i, ...)
		if type(x) == "number" then
			x = string.format("%g", lume.round(x, 0.01))
		end
		t[#t + 1] = tostring(x)
	end
	print(table.concat(t, " "))
end

function lume.dostring(str)
	return assert((loadstring or load)(str))()
end

function lume.uuid()
	local fn = function(x)
		local r = math.random(16) - 1
		r = (x == "x") and (r + 1) or (r % 4) + 9
		return ("0123456789abcdef"):sub(r, r)
	end
	return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function lume.hotswap(modname)
	local oldglobal = lume.clone(_G)
	local updated = {}
	local function update(old, new)
		if updated[old] then
			return
		end
		updated[old] = true
		local oldmt, newmt = getmetatable(old), getmetatable(new)
		if oldmt and newmt then
			update(oldmt, newmt)
		end
		for k, v in pairs(new) do
			if type(v) == "table" then
				update(old[k], v)
			else
				old[k] = v
			end
		end
	end
	local err = nil
	local function onerror(e)
		for k in pairs(_G) do
			_G[k] = oldglobal[k]
		end
		err = lume.trim(e)
	end
	local ok, oldmod = pcall(require, modname)
	oldmod = ok and oldmod or nil
	xpcall(function()
		package.loaded[modname] = nil
		local newmod = require(modname)
		if type(oldmod) == "table" then
			update(oldmod, newmod)
		end
		for k, v in pairs(oldglobal) do
			if v ~= _G[k] and type(v) == "table" then
				update(v, _G[k])
				_G[k] = v
			end
		end
	end, onerror)
	package.loaded[modname] = oldmod
	if err then
		return nil, err
	end
	return oldmod
end

local ripairs_iter = function(t, i)
	i = i - 1
	local v = t[i]
	if v ~= nil then
		return i, v
	end
end

function lume.ripairs(t)
	return ripairs_iter, t, (#t + 1)
end

function lume.color(str, mul)
	mul = mul or 1
	local r, g, b, a
	r, g, b = str:match("#(%x%x)(%x%x)(%x%x)")
	if r then
		r = tonumber(r, 16) / 0xff
		g = tonumber(g, 16) / 0xff
		b = tonumber(b, 16) / 0xff
		a = 1
	elseif str:match("rgba?%s*%([%d%s%.,]+%)") then
		local f = str:gmatch("[%d.]+")
		r = (f() or 0) / 0xff
		g = (f() or 0) / 0xff
		b = (f() or 0) / 0xff
		a = f() or 1
	else
		BL.error("bad color string %s", str)
	end
	return r * mul, g * mul, b * mul, a * mul
end

local chain_mt = {}
chain_mt.__index = lume.map(lume.filter(lume, iscallable, true), function(fn)
	return function(self, ...)
		self._value = fn(self._value, ...)
		return self
	end
end)
chain_mt.__index.result = function(x)
	return x._value
end

function lume.chain(value)
	return setmetatable({ _value = value }, chain_mt)
end

setmetatable(lume, {
	__call = function(_, ...)
		return lume.chain(...)
	end,
})

BL.Lume = lume
------------------------------- END LUME LIBRARY ----------------------------------
-- #endregion lume

-- #region ZenArray
------------------------------- FUNCTIONAL ARRAY UTILS ----------------------------
ZenArray = {}

function newArray(baseMetatable, ...)
	local data = { ... }

	local instance = {

		_data = data,

		filter = ZenArray.filter,
		contains = ZenArray.contains,
		remove = ZenArray.remove,
		forEach = ZenArray.forEach,
		isarray = ZenArray.isarray,
		clear = ZenArray.clear,
		match = ZenArray.match,
		find = ZenArray.find,
		count = ZenArray.count,
		clone = ZenArray.clone,
		keys = ZenArray.keys,
		map = ZenArray.map,
		push = ZenArray.push,
		insert = ZenArray.insert,
	}

	local arrayWithMetatable = setmetatable(instance, baseMetatable)

	return arrayWithMetatable
end

function ZenArray.map(self, fn)
	local mappedData = lume.map(self._data, fn)
	local newZenArray = newArray()
	newZenArray._data = mappedData
	return newZenArray
end

function ZenArray.forEach(self, fn, ...)
	for _, value in ipairs(self._data) do
		fn(value, ...)
	end
	return self
end

function ZenArray.count(self, predicate)
	return lume.count(self._data, predicate)
end

function ZenArray.keys(self)
	return lume.keys(self._data)
end

function ZenArray.clone(self)
	return lume.clone(self)
end

function ZenArray.match(self, func)
	return lume.match(self._data, func)
end

function ZenArray.insert(self, value)
	table.insert(self._data, value)
	return self
end

function ZenArray.push(self, value)
	self:insert(value)
	return self
end

function ZenArray.contains(self, value)
	return lume.find(self._data, value) ~= nil
end

function ZenArray.remove(self, value)
	local index = lume.find(self._data, value)
	if index then
		table.remove(self._data, index)
		return true
	end
	return false
end

function ZenArray.isarray(self)
	return lume.isarray(self._data)
end

function ZenArray.clear(self)
	lume.clear(self._data)
end

function ZenArray.filter(self, func, retainkeys)
	local filteredData = lume.filter(self._data, func, retainkeys)
	local newZenArray = newArray()
	newZenArray._data = filteredData
	return newZenArray
end

function ZenArray.find(self, value)
	return lume.find(self._data, value)
end

BL.ZenArray = ZenArray

-- #endregion ZenArray

--- Utility TODO marker
function BL.todo()
	BL.error("TODO")
	error("TODO")
	-- panic script
end

return BL
