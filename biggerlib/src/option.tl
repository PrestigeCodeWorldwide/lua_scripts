
local record SerializedOptionValue<T>
    ClassName: string
    Value: T
end

local record MatchFunctions<T, R1, R2>
    Some: function(T): R1
    None: function(): R2
end

---@class Option A type based on Rust option for handling either a value or nil
---@field ClassName string The name of the class. (Option)
---@field protected _v any The value contained in the Option, if any.
---@field protected _s boolean A boolean indicating whether the Option contains a value (true) or is None (false).
---@field protected __index table A table containing the Option methods.
---@field protected _new fun(value:any):Option A constructor for an Option containing a value.
---@field None Option A static representation of an empty Option.
---@field Some fun(value:any):Option A constructor for an Option containing a value.
---@field Wrap fun(value:any):Option A constructor that wraps a value in an Option, or returns None if the value is nil.
---@field Is fun(obj:any):boolean A method to check if an object is an Option.
---@field Assert fun(obj:any) A method to assert that an object is an Option.
---@field Deserialize fun(data:table):Option A method to deserialize an Option from a table.
---@field Serialize fun(self:Option):table A method to serialize an Option to a table.
---@field Match fun(self:Option, matches:table):any A method to handle the contents of an Option based on provided functions for Some and None.
---@field IsSome fun(self:Option):boolean A method to check if the Option contains a value.
---@field IsNone fun(self:Option):boolean A method to check if the Option is empty (None).
---@field Expect fun(self:Option, msg:string):any A method to return the contained value or raise an error with the provided message if the Option is None.
---@field ExpectNone fun(self:Option, msg:string) A method to assert that the Option is None or raise an error with the provided message.
---@field Unwrap fun(self:Option):any A method to return the contained value or raise an error if the Option is None.
---@field UnwrapOr fun(self:Option, default:any):any A method to return the contained value or a default value if the Option is None.
---@field UnwrapOrElse fun(self:Option, defaultFunc:function):any A method to return the contained value or the result of a function if the Option is None.
---@field And fun(self:Option, optB:Option):Option A method to return the second Option if the first is Some, otherwise None.
---@field AndThen fun(self:Option, andThenFunc:function):Option A method to transform the contained value with a function if the Option is Some, otherwise None.
---@field Or fun(self:Option, optB:Option):Option A method to return the first Option if it is Some, otherwise the second.
---@field OrElse fun(self:Option, orElseFunc:function):Option A method to return the first Option if it is Some, otherwise the result of a function.
---@field XOr fun(self:Option, optB:Option):Option A method to return the first Option if only one of the two Options is Some, otherwise None.
---@field Filter fun(self:Option, predicate:function):Option A method to return the Option if it is Some and the predicate returns true, otherwise None.
---@field Contains fun(self:Option, value:any):boolean A method to check if the Option is Some and contains the specified value.
---@field protected __tostring fun(self:Option):string A metamethod to get a string representation of the Option.
---@field protected __eq fun(self:Option, opt:Option):boolean A metamethod to check equality between two Options.
global record Option<T>
    ClassName: string -- The name of the class. (Option)
    _v: T | nil -- The value contained in the Option, if any.
    _s: boolean -- A boolean indicating whether the Option contains a value (true) or is None (false).
    __index: table -- A table containing the Option methods.
    _new: function(value: T): Option<T> -- A constructor for an Option containing a value.
    None: Option<nil> -- A static representation of an empty Option.   
    Some: function(value: T): Option<T> -- A constructor for an Option containing a value.
    Wrap: function(value: T|nil): Option<T> -- A constructor that wraps a value in an Option, or returns None if the value is nil.
    Is: function(obj: any): boolean -- A method to check if an object is an Option.
    Assert: function(obj: any) -- A method to assert that an object is an Option.
    Deserialize: function(data: SerializedOptionValue<T>): Option<T> -- A method to deserialize an Option from a table.
    Serialize: function(self: Option<T>): SerializedOptionValue<T> -- A method to serialize an Option to a table.    	
    Match: function<T, R1, R2>(self: Option<T>, matches: MatchFunctions<R1, R2>): R1 | R2 --A method to handle the contents of an Option based on provided functions for Some and None.
    IsSome: function(self: Option<T>): boolean -- A method to check if the Option contains a value.
    IsNone: function(self: Option<T>): boolean -- A method to check if the Option is empty (None).
    Expect: function(self: Option<T>, msg: string): T -- A method to return the contained value or raise an error with the provided message if the Option is None.
    ExpectNone: function(self: Option, msg: string) -- A method to assert that the Option is None or raise an error with the provided message.
    Unwrap: function(self: Option<T>): T -- A method to return the contained value or raise an error if the Option is None.
    UnwrapOr: function(self: Option<T>, default: T): T -- A method to return the contained value or a default value if the Option is None.
    UnwrapOrElse: function(self: Option<T>, defaultFunc: function(): T): T -- A method to return the contained value or the result of a function if the Option is None.
    And: function(self: Option<T>, optB: Option<T>): Option<T> -- A method to return the second Option if the first is Some, otherwise None.
    AndThen: function<T, U>(self: Option<T>, andThenFunc: function(value: T): Option<U>): Option<U> -- A method to transform the contained value with a function if the Option is Some, otherwise None.
    Or: function(self: Option<T>, optB: Option<T>): Option<T> -- A method to return the first Option if it is Some, otherwise the second.
    OrElse: function(self: Option<T>, orElseFunc: function(): Option<T>): Option<T> -- A method to return the first Option if it is Some, otherwise the result of a function.
    XOr: function(self: Option<T>, optB: Option<T>): Option<T> -- A method to return the first Option if only one of the two Options is Some, otherwise None.
    Filter: function(self: Option<T>, predicate: function(value: T): boolean): Option<T> -- A method to return the Option if it is Some and the predicate returns true, otherwise None.
    Contains: function(self: Option<T>, value: T): boolean -- A method to check if the Option is Some and contains the specified value.
    metamethod __tostring: function(self: Option<T>): string -- A metamethod to get a string representation of the Option.
    metamethod __eq: function(self: Option<T>, opt: Option<T>): boolean -- A metamethod to check equality between two Options.
	metamethod __call: function(T | nil) : Option<T>
end



local None: Option<nil> = Option._new(nil)

function Option._new<T>(value: T): Option<T>
    
    -- Create a new Option instance for non-nil values
    local optionInstance: Option<T> = {
        ClassName = "Option",
        _v = value,
        _s = value ~= nil,
    }
    
    setmetatable(optionInstance, {
        __call = function(_self, optionValue: T): Option<T>
            local newOption = Option._new(optionValue)
            return newOption
        end
    })

    return optionInstance
end

--- @generic T
--- @param value T | nil
--- @return Option<T>


--- @generic T, R1, R2
--- @param self Option<T>
--- @param matches MatchFunctions<R1, R2>
--- @return R1 | R2
function Option.Match<T, R1, R2>(self: Option<T>, matches: MatchFunctions<T, R1, R2>): R1 | R2
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



--- @generic T
--- @param value T
--- @return Option<T>
function Option.Some<T>(value: T): Option<T>
	assert(value ~= nil, "Option.Some() value cannot be nil")
	return Option._new(value)
end

--- @generic T
--- @param value T | nil
--- @return Option<T>
function Option.Wrap<T>(value: T | nil): Option<T>
    if value == nil then
        return None
    else
        return Option.Some(value)
    end
end

--- @generic T
--- @param obj T
--- @return boolean
function Option.Is<T>(obj: T): boolean
    return type(obj) == "table" and getmetatable(obj) == Option
end

---Asserts that a given object is an Option
---The Assert function doesn't need to be generic since it doesn't depend on the type of Option
function Option.Assert(obj: any)
    assert(Option.Is(obj), "Result was not of type Option")
end

--- Deserialize an Option from a Serialized value
--- @generic T
--- @param data SerializedOptionValue<T>
--- @return Option<T>
function Option.Deserialize<T>(data: SerializedOptionValue<T>): Option<T>
    assert(data.ClassName == "Option", "Invalid data for deserializing Option")
    if data.Value == nil then
        return None  -- Return the global None for empty Option
    else
        return Option.Some(data.Value)  -- Return Option with value
    end
end

--- Serialize an Option to a SerializedOptionValue
--- @generic T
--- @param self Option<T>
--- @return SerializedOptionValue<T>
function Option.Serialize(self: Option<T>): SerializedOptionValue<T>
    return {
        ClassName = self.ClassName,
        Value = self._v,
    }
end

--- @generic T
--- @param self Option<T>
--- @return boolean
function Option.IsSome<T>(self: Option<T>): boolean
    return self._s
end

--- @generic T
--- @param self Option<T>
--- @return boolean
function Option.IsNone<T>(self: Option<T>): boolean
    return not self._s
end

--- @generic T
--- @param self Option<T>
--- @param msg string
--- @return T
--- @raise Raises an error if the Option is None.
function Option.Expect<T>(self: Option<T>, msg: string): T
    assert(self:IsSome(), msg)
    return self._v
end

--- Asserts that the Option is None, or raises an error with the provided message.
--- @generic T
--- @param self Option<T>
--- @param msg string
--- @raise Raises an error if the Option is Some
function Option.ExpectNone<T>(self: Option<T>, msg: string)
    assert(self:IsNone(), msg)
end

--- Returns the value contained in the Option, or raises an error if the Option is None
--- @generic T
--- @param self Option<T>
--- @return T
function Option.Unwrap<T>(self: Option<T>): T
    return self:Expect("Cannot unwrap an Option of None type")
end

--- Returns the value contained in the Option, or a default value if the Option is None
--- @generic T
--- @param self Option<T>
--- @param default T
--- @return T
function Option.UnwrapOr<T>(self: Option<T>, default: T): T
    if self:IsSome() then
        return self:Unwrap()
    else
        return default
    end
end

--- Returns the contained value if the Option is Some, otherwise the result of the defaultFunc
--- @generic T
--- @param self Option<T>
--- @param defaultFunc fun():T
--- @return T
function Option.UnwrapOrElse<T>(self: Option<T>, defaultFunc: function(): T): T
    if self:IsSome() then
        return self:Unwrap()
    else
        return defaultFunc()
    end
end

--- Returns the second Option if the first is 'Some', otherwise returns 'None'.
--- @generic T
--- @param self Option<T>
--- @param optB Option<T>
--- @return Option<T>
function Option.And<T>(self: Option<T>, optB: Option<T>): Option<T>
    if self:IsSome() then
        return optB
    else
        return None
    end
end

--- Transforms the contained value with a function if the Option is 'Some', otherwise returns 'None'.
--- @generic T, U
--- @param self Option<T>
--- @param andThenFunc fun(value: T): Option<U>
--- @return Option<U>
function Option.AndThen<T, U>(self: Option<T>, andThenFunc: function(value: T): Option<U>): Option<U>
    if self:IsSome() then
        return andThenFunc(self:Unwrap())
    else
        return None
    end
end

--- Returns the first Option if it is 'Some', otherwise returns the second Option.
--- @generic T
--- @param self Option<T>
--- @param optB Option<T>
--- @return Option<T>
function Option.Or<T>(self: Option<T>, optB: Option<T>): Option<T>
    if self:IsSome() then
        return self
    else
        return optB
    end
end

--- Returns the first Option if it is 'Some', otherwise the result of the function.
--- @generic T
--- @param self Option<T>
--- @param orElseFunc fun(): Option<T>
--- @return Option<T>
function Option.OrElse<T>(self: Option<T>, orElseFunc: function(): Option<T>): Option<T>
    if self:IsSome() then
        return self
    else
        local result = orElseFunc()
        Option.Assert(result)
        return result
    end
end

--- Returns the first Option if only one of the two Options is 'Some', otherwise 'None'.
--- @generic T
--- @param self Option<T>
--- @param optB Option<T>
--- @return Option<T>
function Option.XOr<T>(self: Option<T>, optB: Option<T>): Option<T>
    local someOptA = self:IsSome()
    local someOptB = optB:IsSome()

    if someOptA == someOptB then
        return None
    elseif someOptA then
        return self
    else
        return optB
    end
end

--- Returns the Option if it is 'Some' and the predicate returns true, otherwise 'None'.
--- @generic T
--- @param self Option<T>
--- @param predicate fun(value: T): boolean
--- @return Option<T>
function Option.Filter<T>(self: Option<T>, predicate: function(value: T): boolean): Option<T>
    if self:IsNone() or not predicate(self._v) then
        return None
    else
        return self
    end
end

--- Checks if the Option is 'Some' and contains the specified value.
--- @generic T
--- @param self Option<T>
--- @param value T
--- @return boolean
function Option.Contains<T>(self: Option<T>, value: T): boolean
    return self:IsSome() and self._v == value
end

--- Gets a string representation of the Option.
--- @generic T
--- @param self Option<T>
--- @return string
function Option.__tostring<T>(self: Option<T>): string
    if self:IsSome() then
        return "Option<" .. type(self._v) .. ">"
    else
        return "Option<None>"
    end
end

--- Checks equality between two Options.
--- @generic T
--- @param self Option<T>
--- @param opt Option<T>
--- @return boolean
function Option.__eq<T>(self: Option<T>, opt: Option<T>): boolean
    if Option.Is(opt) then
        if self:IsSome() and opt:IsSome() then
            return self:Unwrap() == opt:Unwrap()
        elseif self:IsNone() and opt:IsNone() then
            return true
        end
    end
    return false
end



--Option.None = Option._new(nil)

Option.None = None


return Option
--[[]]





--[[CONSTRUCTORS:
		
		Option.Some(anyNonNilValue): Option<any>
		Option.Wrap(anyValue): Option<any>
		
		Option(): Option.Some(anyNonNilValue) or None if value is nil

	
	STATIC FIELDS:

		None: Option<None>


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
