--[[

	MatchTable {
		Some: (value: any) -> any
		None: () -> any
	}

	CONSTRUCTORS:

		Option.Some(anyNonNilValue): Option<any>
		Option.Wrap(anyValue): Option<any>
	

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

	local result1 = Option.Some(32)
	local result2 = Option.Some(nil)
	local result3 = Option.Some("Hi")
	local result4 = Option.Some(nil)
	local result5 = Option.None

	-- Use 'Match' to match if the value is Some or None:
	result1:Match {
		Some = function(value) print(value) end;
		None = function() print("No value") end;
	}

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

--]]

---@class MatchTable
---@field public Some fun(value: any): any # Function to handle Some case
---@field public None fun(): any # Function to handle None case

---@class Option
---@field ClassName string # The name of the class
---@field _v any # Value contained in the Option
---@field _s boolean # Status flag indicating whether the Option is Some (true) or None (false)
local Option = {}
Option.__index = Option
local _CLASSNAME = "Option"
function Option._new(value)
    local self = setmetatable({
    ClassName = _CLASSNAME,
        _v = value,
        _s = value ~= nil,
    }, Option)
    return self
end

---Creates a new Option with a non-nil value.
---@param value any
---@return Option
function Option.Some(value)
    assert(value ~= nil, "Option.Some() value cannot be nil")
    return Option._new(value)
end

---Creates a new Option with a non-nil value.
---@param value any
---@return Option
function Option.Wrap(value)
    if value == nil then
        return Option.None
    else
        return Option.Some(value)
    end
end

---Checks whether an object is an instance of Option.
---@param obj any
---@return boolean
function Option.Is(obj)
    return type(obj) == "table" and getmetatable(obj) == Option
end

---Asserts that an object is an instance of Option.
---@param obj any
function Option.Assert(obj)
    assert(Option.Is(obj), "Result was not of type Option")
end

---Deserializes an Option from a table with ClassName and Value fields.
---@param data table
---@return Option
function Option.Deserialize(data) -- type data = {ClassName: string, Value: any}
  assert(type(data) == "table" and data.ClassName == _CLASSNAME, "Invalid data for deserializing Option")
    return data.Value == nil and Option.None or Option.Some(data.Value)
end

---Serializes the Option into a table with ClassName and Value fields.
---@return table
function Option:Serialize()
    return {
        ClassName = self.ClassName,
        Value = self._v,
    }
end

---Matches the Option with the provided MatchTable functions.
---@param matches MatchTable
---@return any
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

---Returns true if the Option is Some.
---@return boolean
function Option:IsSome()
    return self._s
end

---Returns true if the Option is None.
---@return boolean
function Option:IsNone()
    return (not self._s)
end

---Returns the value if the Option is Some; otherwise, raises an error.
---@param msg string
---@return any
function Option:Expect(msg)
    assert(self:IsSome(), msg)
    return self._v
end

---Raises an error if the Option is not None.
---@param msg string
function Option:ExpectNone(msg)
    assert(self:IsNone(), msg)
end

---Unwraps the Option, returning the value if it is Some, otherwise raises an error.
---@return any
function Option:Unwrap()
    return self:Expect("Cannot unwrap option of None type")
end

---Returns the value if the Option is Some, otherwise returns the provided default.
---@param default any
---@return any
function Option:UnwrapOr(default)
    if self:IsSome() then
        return self:Unwrap()
    else
        return default
    end
end

---Returns the value if the Option is Some, otherwise calls the function and returns its result.
---@param defaultFunc function
---@return any
function Option:UnwrapOrElse(defaultFunc)
    if self:IsSome() then
        return self:Unwrap()
    else
        return defaultFunc()
    end
end

---Returns the provided Option if the current Option is Some, otherwise returns None.
---@param optB Option
---@return Option
function Option:And(optB)
    if self:IsSome() then
        return optB
    else
        return Option.None
    end
end

---Calls the predicate with the unwrapped value and returns its result if the Option is Some, otherwise returns None.
---@param andThenFunc function
---@return Option
function Option:AndThen(andThenFunc)
    if self:IsSome() then
        local result = andThenFunc(self:Unwrap())
        Option.Assert(result)
        return result
    else
        return Option.None
    end
end

---Returns the current Option if it is Some, otherwise returns the provided Option.
---@param optB Option
---@return Option
function Option:Or(optB)
    if self:IsSome() then
        return self
    else
        return optB
    end
end

---Returns the current Option if it is Some, otherwise calls the function and returns its result.
---@param orElseFunc function
---@return Option
function Option:OrElse(orElseFunc)
    if self:IsSome() then
        return self
    else
        local result = orElseFunc()
        Option.Assert(result)
        return result
    end
end

---Returns None if both Options are Some or None, otherwise returns the Option that is Some.
---@param optB Option
---@return Option
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

---Filters the Option using the provided predicate, returning None if the Option is None or the predicate returns false.
---@param predicate function
---@return Option
function Option:Filter(predicate)
    if self:IsNone() or not predicate(self._v) then
        return Option.None
    else
        return self
    end
end

---Checks if the Option contains the specified value.
---@param value any
---@return boolean
function Option:Contains(value)
    return self:IsSome() and self._v == value
end

---Converts the Option to a string representation.
---@return string
function Option:__tostring()
    if self:IsSome() then
        return "Option<" .. type(self._v) .. ">"
    else
        return "Option<None>"
    end
end

---Checks equality between two Options.
---@param opt Option
---@return boolean
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

---@type Option # A special instance of Option representing None
Option.None = Option._new()


return Option
