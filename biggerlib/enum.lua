----------------------------------------- ENUM LIBRARY -----------------------------------------------------

--- USAGE:
---local BL = require("biggerlib")

---- construct enum from a multiline string (most convenient)
---- (can contain single line comments, and parentheses can be omitted)
---local days = BL.Enum([[
---    SUNDAY
---    MONDAY
---    TUESDAY
---    WEDNESDAY
---    THURSDAY
---    FRIDAY
---    SATURDAY
---]])

---print(days.TUESDAY) -- 2
---print(days.THURSDAY) -- 100
---print(days.count) -- 7 (number of fields in the enum)
----- usualy only for debugging purposes
---print(days) -- prints the entire enum
---print(days:pstr()) -- pretty-prints the enum in a more readable form

---- Get an Instance from a String (what macroquest provides)
--- local myDay = days:FromStr("SUNDAY")
--- Compare an instance
--- if myDay == days.SUNDAY then ...

local fmt = string.format
local remove = table.remove
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local type = type
local next = next
local select = select
local tonumber = tonumber
local setmetatable = setmetatable

local function _iterator(t, i)
	i = i + 1
	local val = t[i]
	if i > #t then
		return
	end
	return i, val
end

local _make_globals = false

local Enum = {}

local function FromStr(enum, str)
	return enum._reverseLookup[str]
end

local function ToStr(enum, value)
	for k, v in pairs(enum._reverseLookup) do
		if v == value then
			return k
		end
	end
	BL.error("ERROR: Unimplemented ToStr for enum! " .. tostring(value) .. " in enum: " .. tostring(enum))
	return nil -- Return nil if the value does not correspond to any key
end

local MT = {
	__type = "enum", -- for type checking
	__index = function(t, k)
		return t._fields[k] or Enum[k] or t._iterable_values[k] or error(fmt("field %s does not exist in enum", k), 2)
	end,
	-- enums are immutable for their actual values, but we allow associated functions such as FromStr/ToStr
	__newindex = function(t, k, v)
		if type(v) ~= "function" then
			error("cannot assign non-function values to an enum (enums are immutable for non-functions)", 2)
		else
			rawset(t, k, v) -- Allows the assignment of a function
		end
	end,
	__tostring = function(t)
		local str = "enum: "
		for i = 1, #t._ordered_fields do
			local k = t._ordered_fields[i]
			local v = t._fields[k]
			str = str .. fmt("%s = %d", k, v)
			if i < #t._ordered_fields then
				str = str .. ", "
			end
		end
		return str .. ""
	end,
	-- for lua 5.2+
	__ipairs = function(t)
		return _iterator, t._iterable_values, 0
	end,
	__pairs = function(t)
		return next, t._fields, nil
	end,
	FromStr = FromStr,
	_reverseLookup = {},
}

-- for lua 5.1
function Enum:ipairs()
	return _iterator, self._iterable_values, 0
end
function Enum:pairs()
	return next, self._fields, nil
end

-- for pretty printing - assembles the enum neatly over several lines and indented
function Enum:pstr()
	local str = "enum {\n"
	for i = 1, #self._ordered_fields do
		local k = self._ordered_fields[i]
		local v = self._fields[k]
		str = str .. fmt(fmt("    %%-%ds%%d\n", self._longest_field + 4), k, v)
	end
	return str .. "}"
end

function Enum.make_globals(enable)
	_make_globals = enable
end

local function _new_from_table(...)
	local t = {
		count = {},
		_fields = {},
		_iterable_values = {},
		_ordered_fields = {},
		_longest_field = 0, -- for pretty printing
		_reverseLookup = {},
		FromStr = function(self, str)
			return FromStr(self, str)
		end,
		ToStr = function(self, value)
			return ToStr(self, value)
		end,
	}

	local exp = false -- exponential stepping
	local step = 1 -- incremental step
	local elems = type(...) == "table" and ... or { ... }

	-- check format
	local str = elems[1]:match("^[-+*%d]+")
	if str then
		remove(elems, 1)

		if tonumber(str) then
			---@diagnostic disable-next-line: cast-local-type
			step = tonumber(str)
		else
			if #str == 1 then
				if str == "-" then
					step = -1
				elseif str == "+" then
					step = 1
				elseif str == "*" then
					step, exp = 2, true
				else
					error(fmt("invalid format '%s'", str))
				end
			else
				if str:sub(1, 1) ~= "*" then
					error(fmt("invalid format '%s'", str))
				end
				step, exp = 2, true
				local inc = tonumber(str:match("%-?%d$"))
				if not inc and str:sub(2, 2) == "-" then
					inc = -2
				end
				step = (inc and inc ~= 0) and inc or step
			end
		end
	end

	-- assemble the enum
	t.count = #elems
	local val = 0

	for i = 1, #elems do
		local words = {} -- try splitting the current entry into parts, if possible
		for word in elems[i]:gmatch("[%w_-]+") do
			words[#words + 1] = word
		end

		-- check for duplicates
		local k = words[1]
		if t._fields[k] then
			error(fmt("duplicate field '%s' in enum", k), 2)
		end

		-- keep track of longest for pretty printing
		if #k > t._longest_field then
			t._longest_field = #k
		end

		-- if a second element exists then current entry contains a custom value
		if words[2] then
			---@diagnostic disable-next-line: cast-local-type
			val = tonumber(words[2])
		end
		if not val then
			error(fmt("invalid value '%s' for enum field", words[2]), 2)
		end

		-- store the entries and respective values
		t._fields[k] = val
		t._ordered_fields[i] = k -- useful for printing
		t._iterable_values[i] = val -- useful for iterators

		if _make_globals then
			_G[k] = val -- not recommended
		end

		-- increase 'val' by increments or exponential growth
		if not exp then
			val = val + step
		else
			if val ~= 0 then
				if val > 0 and step < 0 then
					---@diagnostic disable-next-line: param-type-mismatch
					val = floor(val / abs(step))
				elseif val < 0 and step > 0 then
					---@diagnostic disable-next-line: param-type-mismatch
					val = ceil(val / abs(step))
				else
					---@diagnostic disable-next-line: param-type-mismatch
					val = val * abs(step)
				end
			else
				val = step > 0 and 1 or -1
			end
		end

		-- Populate reverse lookup table
		t._reverseLookup[k] = val
	end

	return setmetatable(t, MT)
end

local function _new_from_string(...)
	-- check if it's more than one string
	if select("#", ...) > 1 then
		return _new_from_table(...)
	end

	-- remove comments
	local s = (...):gsub("%-%-[^\n]+", "")

	-- remove whitespace and ',' or '=', join custom values to their fields
	-- and put everything in a table
	local elems = {}
	for word in s:gmatch("([^,\r\n\t =]+)") do
		if not tonumber(word) or #elems == 0 then -- if NAN or is format string
			elems[#elems + 1] = word
		else
			elems[#elems] = elems[#elems] .. " " .. tonumber(word)
		end
	end
	local t = _new_from_table(unpack(elems))

	t.FromStr = function(self, str)
		return FromStr(self, str)
	end
	t.ToStr = function(self, value)
		return ToStr(self, value)
	end

	return t
end

local _constructors = {
	string = _new_from_string,
	table = _new_from_table,
}

local function _newEnums(...)
	if not _constructors[type(...)] then
		error("invalid parameters for enum: must be a string, table or string varargs", 2)
	end
	return _constructors[type(...)](...)
end

local Enum = setmetatable(Enum, {
	__call = function(_, ...)
		return _newEnums(...)
	end,
})

return Enum
