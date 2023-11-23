---@type Mq
local mq = require("mq")
local lume = require("lume")
local BL = {}
BL.cmd = {}
BL.enum = {}

local log_prefix = "\a-t[\ax\ayBL\ax\a-t]\ax \aw"

-- Region: LEM/Oneoff Helpers

--- Takes a full line of text and extracts every player named into a list
---@param names string A string containing a list of names, separated by commas
function BL.parseAllNames(names)
	local withoutAnd = names:gsub(", and", ",")

	-- Split string by comma
	local nameList = {}
	for name in withoutAnd:gmatch("[^,]+") do
		-- Trim whitespace and insert into list
		table.insert(nameList, name:match("^%s*(.-)%s*$"))
	end

	return nameList
end

--- Returns true if the nameList passed in from event contains the name of the current character
---@param namesString string A string containing a list of names, separated by commas
function BL.nameListIncludesMe(namesString)
	print(namesString)
	local names = BL.parseAllNames(namesString)
	print("names is " .. tostring(names))

	local myname = mq.TLO.Me.CleanName()

	for _, name in ipairs(names) do
		if name == myname then
			return true
		end
	end

	return false
end

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

--- Stops all automations (Boxr pause, afollow off, nav stop, twist stop, attack off)
function BL.cmd.pauseAutomation()
	mq.cmd("/boxr Pause")
	mq.cmd("/timed 5 /afollow off")
	mq.cmd("/nav stop")
	mq.cmd("/twist stop")
	mq.cmd("/attack off")
end

--- Currently this function only unpauses via Boxr
function BL.cmd.resumeAutomation()
	mq.cmd("/boxr Unpause")
end

-- This function waits for 'delay' seconds, then navigates to a location.
-- It will not return until the destination is reached
function BL.cmd.runToAfterDelay(x, y, z, delay)
	mq.delay(delay .. "s")
	mq.cmdf("/nav locxyz %d %d %d", x, y, z)

	---@diagnostic disable-next-line: undefined-field
	while mq.TLO.Nav.Active() do -- wait till I get there before continuing next command
		--pause wait for nav
		mq.delay(100)
	end
	print(string.format("Navigation arrived at: " .. x .. y .. z))
end

--- Used in specific raids when bots need to NOT stand close to each other during a dot/aura
function BL.cmd.setRngSeedFromPlayerPosition()
	local h, k = mq.TLO.Me.X(), mq.TLO.Me.Y()
	math.randomseed(os.time() * h / k)
end

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

--- Easy oneshot function to turn off the zerker disc that holds them in place (in case of needing to run)
function BL.cmd.removeZerkerRootDisc()
	local my_class = mq.TLO.Me.Class.ShortName()
	if my_class == "BER" and mq.TLO.Me.ActiveDisc.Name() == mq.TLO.Spell("Frenzied Resolve Discipline").RankName() then
		mq.cmd("/stopdisc")
	end
end
-- EndRegion: LEM/Oneoff Helpers

-- Region: Logging

local timestamps = false
-- Logging
function logLine(...)
	local timestampPrefix = timestamps and "\a-w[" .. os.date("%X") .. "]\ax" or ""
	return string.format(timestampPrefix .. log_prefix .. string.format(...) .. "\ax")
end

--- Simple output log formatted somewhat nicely
function info(...)
	local timestampPrefix = timestamps and "\a-w[" .. os.date("%X") .. "]\ax" or ""
	local output = string.format(timestampPrefix .. log_prefix .. string.format(...) .. "\ax")
	print(output)
	return output
end

--- This function is used to recursively dump data, useful for debugging.
--- @param data any The data to be dumped. This can be of any type.
--- @param logPrefix string|nil A string that is prefixed to each line of the dump. This is optional.
--- @param depth integer|nil An integer representing the current depth of the recursion. This is optional and is used for indentation.
function dump(data, logPrefix, depth)
	local function dumpRecurse(data, logPrefix, depth)
		if data == nil then
			return "NIL"
		end
		if type(data) == "table" then
			local output = "{"
			for key, value in pairs(data) do
				output = output
					.. string.format(
						"\n%s[%s] = %s",
						string.rep(" ", depth or 0),
						tostring(key),
						dumpRecurse(value, logPrefix, (depth or 0) + 4)
					)
			end
			return output .. "\n" .. string.rep(" ", (depth or 0) - 4) .. "}"
		else
			return tostring(data)
		end
	end

	if logPrefix == nil then
		logPrefix = "DUMP"
	end
	print(logPrefix .. " : " .. dumpRecurse(data, logPrefix, depth))
end

-- EndRegion: Logging

-- Region: Metaprogramming

--- utility method to combine two metatables into one, like multiple inheritance.
--- Used because doing so provides an ocean of increased typechecking support
function mergeMetatables(metatable1, metatable2)
	local merged = {}
	for k, v in pairs(metatable1) do
		merged[k] = v
	end
	for k, v in pairs(metatable2) do
		if merged[k] == nil then
			merged[k] = v
		else
			error("Conflicting keys when merging metatables: " .. k)
		end
	end
	return merged
end

-- EndRegion: Metaprogramming

-- Region: ZenTable
--- Convenience table with custom metatable of utility methods
--- @class ZenTable
--- @field insert fun(self:ZenTable, value:any)
--- @field contains fun(self:ZenTable, value:any):boolean
--- @field remove fun(self:ZenTable, value:any):boolean
--- @field map fun(self:ZenTable, func:function):table
--- @field forEach fun(self:ZenTable, func:function)
--- @field isarray fun(self:ZenTable):boolean
--- @field push fun(self:ZenTable, ...)
--- @field clear fun(self:ZenTable)
--- @field filter fun(self:ZenTable, func:function, retainkeys:boolean|nil):table
--- @field match fun(self:ZenTable, func:function):any
--- @field concat fun(self:ZenTable, sep:string|nil, i:number|nil, j:number|nil):string
--- @field find fun(self:ZenTable, value:any):number|nil
--- @field count fun(self:ZenTable, value:any):number
--- @field keys fun(self:ZenTable):table
--- @field clone fun(self:ZenTable):ZenTable

--- Define a metatable with utility methods for tables.
--- Any custom metatable WILL be merged with this one.
local zentable_metatable = {
	insert = function(self, value)
		table.insert(self, value)
	end,
	contains = function(self, value)
		return lume.find(self, value) ~= nil
	end,
	remove = function(self, value)
		local index = lume.find(self, value)
		if index then
			table.remove(self, index)
			return true
		end
		return false
	end,
	map = function(self, func)
		return lume.map(self, func)
	end,
	forEach = function(self, func)
		lume.each(self, func)
	end,
	isarray = function(self)
		return lume.isarray(self)
	end,
	push = function(self, ...)
		lume.push(self, ...)
	end,
	clear = function(self)
		lume.clear(self)
	end,
	filter = function(self, func, retainkeys)
		return lume.filter(self, func, retainkeys)
	end,
	match = function(self, func)
		return lume.match(self, func)
	end,
	concat = function(self, sep, i, j)
		return lume.concat(self, sep, i, j)
	end,
	find = function(self, value)
		return lume.find(self, value)
	end,
	count = function(self, value)
		return lume.count(self, value)
	end,
	keys = function(self)
		return lume.keys(self)
	end,
	clone = function(self)
		return lume.clone(self)
	end,
}
--- Factory function to create a new table with the metatable set
--- Generic newTable function that accepts a metatable to set up the new table
--- ZenTable Enables fooTable:insert(value) syntax instead of ugly gross C table.insert(fooTable, value)
--- @generic T : ZenTable
--- @param initialValues table|nil Initial values to populate the table
--- @param metatable T|nil
--- @return T
function newTable(initialValues, metatable)
	initialValues = initialValues or {}
	local finalMetatable

	if not metatable then
		-- If metatable is nil, use the default zentable_metatable
		finalMetatable = zentable_metatable
	else
		-- If metatable is provided, merge it with zentable_metatable
		assert(type(metatable) == "table", "Expected a table for the metatable")
		finalMetatable = mergeMetatables(zentable_metatable, metatable)
	end

	-- Set the metatable for the initialValues table
	return setmetatable(initialValues, { __index = finalMetatable })
end

-- EndRegion: ZenTable

-- Region: Utilities

--- Generates an iterator that increments from i to to by inc
--- @param i any
--- @param to any
--- @param inc any
--- @return function|nil
function range(i, to, inc)
	if i == nil then
		return
	end -- range(--[[ no args ]]) -> return "nothing" to fail the loop in the caller

	if not to then
		to = i
		i = to == 0 and 0 or (to > 0 and 1 or -1)
	end

	-- we don't have to do the to == 0 check
	-- 0 -> 0 with any inc would never iterate
	inc = inc or (i < to and 1 or -1)

	-- step back (once) before we start
	i = i - inc
	return function()
		if i == to then
			return nil
		end
		i = i + inc
		return i, i
	end
end

-- EndRegion: Utilities

return BL
