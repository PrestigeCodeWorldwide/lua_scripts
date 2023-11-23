-- Region: Option
--[[CONSTRUCTORS:
		
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

Option = {}

--- @generic T
--- @param value T|nil
--- @return Option<T>
function Option._new(value)
	local self = setmetatable({
		ClassName = "Option",
		_v = value,
		_s = value ~= nil,
	}, Option)
	return self
end

--- @generic T
--- @param value T
--- @return Option<T>
function Option.Some(value)
	assert(value ~= nil, "Option.Some() value cannot be nil")
	return Option._new(value)
end

--- @generic T
--- @param value T|nil
--- @return Option<T>
function Option.Wrap(value)
	if value == nil then
		return Option.None
	else
		return Option.Some(value)
	end
end

---Determines if a given object is an Option
---@generic T
---@param obj T The object to check
---@return boolean Whether the object is an Option
function Option.Is(obj)
	return type(obj) == "table" and getmetatable(obj) == Option
end

---Asserts that a given object is an Option
function Option.Assert(obj)
	assert(Option.Is(obj), "Result was not of type Option")
end

--- Deserializes an Option from a table
--- @generic T
--- @param data table<string, any> A table with ClassName and Value keys
--- @return Option<T>
function Option.Deserialize(data) -- type data = {ClassName: string, Value: any}
	assert(type(data) == "table" and data.ClassName == "Option", "Invalid data for deserializing Option")
	return data.Value == nil and Option.None or Option.Some(data.Value)
end

--- Serializes an Option to a table
function Option:Serialize()
	return {
		ClassName = self.ClassName,
		Value = self._v,
	}
end

--- Matches the contents of the Option with provided functions for Some and None cases
--- @generic T, R1, R2
--- @param matches table<string, fun():R1|R2> A table with 'Some' and 'None' keys pointing to functions
--- @return R1|R2
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

--- Returns true if the Option contains a value
---@generic T : Option
---@return boolean Whether the option contains a value
function Option:IsSome()
	return self._s
end

--- Returns true if the Option is empty (None)
---@generic T : Option
---@return boolean Whether the option is empty
function Option:IsNone()
	return not self._s
end

--[[--- Returns the value contained in the Option, or raises an error if the Option is None
---@generic T
---@param msg string The message to print if the Option is None, before crashing
---@return T The value contained in the option
---@raise Raises an error if the Option is None.
function Option:Expect(msg)
	assert(self:IsSome(), msg)
	return self._v
end]]

--- Asserts that the Option is None, or raises an error if the Option is Some
---@generic T
function Option:ExpectNone(msg)
	assert(self:IsNone(), msg)
end

--- Returns the value contained in the Option, or raises an error if the Option is None
---@generic T
---@return T
function Option:Unwrap()
	return self:Expect("Cannot unwrap option of None type")
end

--- Returns the value contained in the Option, or a default value if the Option is None
---@generic T
---@param default T
---@return T
function Option:UnwrapOr(default)
	if self:IsSome() then
		return self:Unwrap()
	else
		return default
	end
end

--- Returns the contained value if the Option is Some, otherwise the result of the defaultFunc
--- @generic T
--- @param defaultFunc fun():T A function that returns a value of type T
--- @return T
function Option:UnwrapOrElse(defaultFunc)
	if self:IsSome() then
		return self:Unwrap()
	else
		return defaultFunc()
	end
end

--- Returns the second Option if the first is 'Some', otherwise returns 'None'.
--- @generic T
--- @param optB Option<T>
--- @return Option<T>
function Option:And(optB)
	if self:IsSome() then
		return optB
	else
		return Option.None
	end
end

--- Transforms the contained value with a function if the Option is 'Some', otherwise returns 'None'.
--- @generic T, U
--- @param andThenFunc fun(value: T):Option<U>
--- @return Option<U>
function Option:AndThen(andThenFunc)
	if self:IsSome() then
		return andThenFunc(self:Unwrap())
	else
		return Option.None
	end
end

--- Returns the first Option if it is 'Some', otherwise returns the second Option.
--- @generic T
--- @param optB Option<T>
--- @return Option<T>
function Option:Or(optB)
	if self:IsSome() then
		return self
	else
		return optB
	end
end

--- Returns the first Option if it is 'Some', otherwise the result of the function.
--- @generic T
--- @param orElseFunc fun():Option<T>
--- @return Option<T>
function Option:OrElse(orElseFunc)
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
--- @param optB Option
--- @return Option<T>
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

--- Returns the Option if it is 'Some' and the predicate returns true, otherwise 'None'.
--- @generic T
--- @param predicate fun(value: T):boolean
--- @return Option<T>
function Option:Filter(predicate)
	if self:IsNone() or not predicate(self._v) then
		return Option.None
	else
		return self
	end
end

--- Checks if the Option is 'Some' and contains the specified value.
--- @generic T
--- @param value T
--- @return boolean
function Option:Contains(value)
	return self:IsSome() and self._v == value
end

--- Gets a string representation of the Option.
--- @generic T
--- @return string
function Option:__tostring()
	if self:IsSome() then
		return "Option<" .. type(self._v) .. ">"
	else
		return "Option<None>"
	end
end

--- Checks equality between two Options.
--- @generic T : Option
--- @param opt `T`
--- @return boolean
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

--function Option:Expect(msg)
--	assert(self:IsSome(), msg)
--	return self._v
--end

-- Set the __call metamethod to forward calls to Option.Wrap
setmetatable(Option, {
	--- @generic T
	--- @param self Option
	--- @param value T|nil
	--- @return Option<T>
	__call = function(self, value)
		return Option.Wrap(value)
	end,
	__index = {
		Expect = function(self, msg)
			assert(self:IsSome(), msg)
			return self._v
		end,
	},
})

--Option.__index = Option

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

Option.None = Option._new()

-- EndRegion: Option
