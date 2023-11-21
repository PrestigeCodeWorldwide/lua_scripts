---@type Mq
local mq = require("mq")
local lume = require("lume")
local BL = {}
BL.cmd = {}
BL.enum = {}

local log_prefix = "\a-t[\ax\ayBL\ax\a-t]\ax \aw"

--[[
	CONSTRUCTORS:
		
		Option.Some(anyNonNilValue): Option<any>
		Option.Wrap(anyValue): Option<any>
		
		Option(): Option.Some(anyNonNilValue) or Option.None if value is nil


	STATIC FIELDS:

		Option.None: Option<None>


	STATIC METHODS:

		Option.Is(obj): boolean


	METHODS:

		opt:Match(): (matches: MatchTable) -> any
		opt:IsSome(): boolean
		opt:IsNone(): boolean
		opt:Unwrap(): any
		opt:Expect(errMsg: string): any
		opt:ExpectNone(errMsg: string): void
		opt:UnwrapOr(default: any): any
		opt:UnwrapOrElse(default: () -> any): any
		opt:And(opt2: Option<any>): Option<any>
		opt:AndThen(predicate: (unwrapped: any) -> Option<any>): Option<any>
		opt:Or(opt2: Option<any>): Option<any>
		opt:OrElse(orElseFunc: () -> Option<any>): Option<any>
		opt:XOr(opt2: Option<any>): Option<any>
		opt:Contains(value: any): boolean

	--------------------------------------------------------------------

	Options are useful for handling nil-value cases. Any time that an
	operation might return nil, it is useful to instead return an
	Option, which will indicate that the value might be nil, and should
	be explicitly checked before using the value. This will help
	prevent common bugs caused by nil values that can fail silently.


	Example:

	print(Option(nil))       --> None
	print(Option(nil):IsNone()) --> true
	print(Option(nil):IsSome()) --> false
	print(Option(1))         --> Some(1)
	print(Option(1):IsNone()) --> false
	print(Option(1):IsSome()) --> true
	
	local mySome = Option(1)
	Option.Assert(mySome) -- error if mySome isn't an Option
	mySome:Match({
		Some = function(value)
			print('MATCHED Some: ' .. value)
		end,
		None = function()
			print('MATCHED None')
		end,
	}) -- prints "MATCHED Some: 1"
	
	local myNone = Option(nil)
	Option.Assert(myNone)
	myNone:Match({
		Some = function(value)
			print('MATCHED Some: ' .. value)
		end,
		None = function()
			print('MATCHED None')
		end,
	}) -- prints "MATCHED None"
	
	local myExtractedValue = mySome:Match({
		Some = function(value)
			return value
		end,
		None = function()
			return nil
		end,
	})
	assert(myExtractedValue == 1) -- passes
		
	-- Raw check:
	if result2:IsSome() then
		local value = result2:Unwrap() -- Explicitly call Unwrap
		print("Value of result2:", value)
	end
	
	if result3:IsNone() then
		print("No result for result3")
	end
	
	-- Bad, will throw error bc result4 is none:
	local value = result4:Unwrap()

---]]
---@class Option
Option = {}
Option.__index = Option

---@return Option
function Option._new(value)
	local self = setmetatable({
		ClassName = "Option",
		_v = value,
		_s = value ~= nil,
	}, Option)
	return self
end

---@return Option
function Option.Some(value)
	assert(value ~= nil, "Option.Some() value cannot be nil")
	return Option._new(value)
end

---@return Option
function Option.Wrap(value)
	if value == nil then
		return Option.None
	else
		return Option.Some(value)
	end
end

-- Set the __call metamethod to forward calls to Option.Wrap
setmetatable(Option, {
	__call = function(self, value)
		---@type Option
		return Option.Wrap(value)
	end,
})

function Option.Is(obj)
	return type(obj) == "table" and getmetatable(obj) == Option
end

function Option.Assert(obj)
	assert(Option.Is(obj), "Result was not of type Option")
end

---@return Option
function Option.Deserialize(data) -- type data = {ClassName: string, Value: any}
	assert(type(data) == "table" and data.ClassName == "Option", "Invalid data for deserializing Option")
	return data.Value == nil and Option.None or Option.Some(data.Value)
end

function Option:Serialize()
	return {
		ClassName = self.ClassName,
		Value = self._v,
	}
end

function Option:Match(matches)
	local onSome = matches.Some
	local onNone = matches.None
	assert(type(onSome) == "function", "Missing 'Some' match")
	assert(type(onNone) == "function", "Missing 'None' match")
	if self:IsSome() then
		return onSome(self:Unwrap())
	else
		return onNone()
	end
end

function Option:IsSome()
	return self._s
end

function Option:IsNone()
	return not self._s
end

function Option:Expect(msg)
	assert(self:IsSome(), msg)
	return self._v
end

function Option:ExpectNone(msg)
	assert(self:IsNone(), msg)
end

function Option:Unwrap()
	return self:Expect("Cannot unwrap option of None type")
end

function Option:UnwrapOr(default)
	if self:IsSome() then
		return self:Unwrap()
	else
		return default
	end
end

function Option:UnwrapOrElse(defaultFunc)
	if self:IsSome() then
		return self:Unwrap()
	else
		return defaultFunc()
	end
end

function Option:And(optB)
	if self:IsSome() then
		return optB
	else
		return Option.None
	end
end

function Option:AndThen(andThenFunc)
	if self:IsSome() then
		return andThenFunc(self:Unwrap())
	else
		return Option.None
	end
end

function Option:Or(optB)
	if self:IsSome() then
		return self
	else
		return optB
	end
end

function Option:OrElse(orElseFunc)
	if self:IsSome() then
		return self
	else
		local result = orElseFunc()
		Option.Assert(result)
		return result
	end
end

function Option:XOr(optB)
	local someOptA = self:IsSome()
	local someOptB = optB:IsSome()
	if someOptA == someOptB then
		return Option.None
	elseif someOptA then
		return self
	else
		return optB
	end
end

function Option:Filter(predicate)
	if self:IsNone() or not predicate(self._v) then
		return Option.None
	else
		return self
	end
end

function Option:Contains(value)
	return self:IsSome() and self._v == value
end

function Option:__tostring()
	if self:IsSome() then
		return "Option<" .. type(self._v) .. ">"
	else
		return "Option<None>"
	end
end

function Option:__eq(opt)
	if Option.Is(opt) then
		if self:IsSome() and opt:IsSome() then
			return self:Unwrap() == opt:Unwrap()
		elseif self:IsNone() and opt:IsNone() then
			return true
		end
	end
	return false
end

Option.None = Option._new()

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

-- Enums/matching
--- This is used to create a single variant of an enum, such as:
--- local MyEnum = {
---    VariantA = function(...) return createVariant("VariantA", ...) end,
---    VariantB = function(...) return createVariant("VariantB", ...) end,
---    -- Add more variants as needed
---}
function BL.enum.createVariant(name, ...)
	return { type = name, data = { ... } }
end

function BL.enum.match(enumValue, matchTable)
	local func = matchTable[enumValue.type]
	if func then
		return func(table.unpack(enumValue.data))
	end
end

-- Logging
function logLine(...)
	local timestampPrefix = timestamps and "\a-w[" .. os.date("%X") .. "]\ax" or ""
	return string.format(timestampPrefix .. log_prefix .. string.format(...) .. "\ax")
end

function info(...)
	local timestampPrefix = timestamps and "\a-w[" .. os.date("%X") .. "]\ax" or ""
	local output = string.format(timestampPrefix .. log_prefix .. string.format(...) .. "\ax")
	print(output)
	return output
end

--- This function is used to recursively dump data, useful for debugging.
--- @param data string The data to be dumped. This can be of any type.
--- @param logPrefix string A string that is prefixed to each line of the dump. This is optional.
--- @param depth integer An integer representing the current depth of the recursion. This is optional and is used for indentation.
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
--- Enables fooTable:insert(value) syntax instead of ugly gross C table.insert(fooTable, value)
--- @param initialValues table|nil Initial values to populate the table
--- @return ZenTable
function newTable(initialValues)
	local newTableInstance = setmetatable(initialValues or {}, { __index = zentable_metatable })
	return newTableInstance
end

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

--Option = {
--	Some = "un8qu3Some",
--	None = "un8qu3None",
--}

return BL
