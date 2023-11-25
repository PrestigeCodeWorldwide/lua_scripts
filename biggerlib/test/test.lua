--package.path = package.path .. ';../src/?.tl'
package.path = package.path .. ';../dist/?.lua'
package.path = package.path .. ';../test/?.tl'
package.path = package.path .. ';../test/busted/?.lua'
package.path = package.path .. ';../vendor/?.tl'
package.path = package.path .. ';../vendor/?.lua'



require("option")
require("busted")

-- This is just a test file, so we don't really need ALL of teal, but some helper types for the various busted stuff is nice
--- @type function
local describe = require("busted").describe
--- @type function
local it = require("busted").it
--- @type table
local assert = require("busted").assert

describe("Busted verify and example block", function()
  describe("shows how to use busted", function()
    it("should have some nice features", function()
	  assert.truthy("Yup")
      assert.are.same({ table = "great"}, { table = "great" }) -- deep check comparisons      
      assert.are_not.equal({ table = "great"}, { table = "great"}) -- or check by reference     
      assert.truthy("this is a string") -- truthy: not false or nil
      
      assert.True(1 == 1)
      assert.is_true(1 == 1)

      assert.falsy(nil)
      assert.has_error(function() error("Wat") end, "Wat")
    end)
    
    it("should provide some shortcuts to common functions", function()
      assert.are.unique({{ thing = 1 }, { thing = 2 }, { thing = 3 }})
    end)
  end)
end)

describe("Option.Some ", function()
    it("should be able to construct an Option.Some from new", function()		
        local o = Option.new(5)
        assert.is_true(o:IsSome())
        assert.is_false(o:IsNone())
        local other = Option.new(5)
		assert.is_true(o == other)	
    end)
	
	it("Should be able to create a new Option.Some from Option.Some directly", function()		
		local o = Option.Some(5)
		assert.is_true(o:IsSome())
		assert.is_false(o:IsNone())
    end)
	
	it("Should be able to create a new Option.Some from global Some directly", function()		
		local o = Some(5)
		assert.is_true(o:IsSome())
		assert.is_false(o:IsNone())
	end)
end)

describe("Option.None ", function()       
    it("Should be able to construct an Option.None from singleton", function()		
        local o = Option.None
        assert.is_false(o:IsSome())
        assert.is_true(o:IsNone())
        local otwo = Option.None
		assert.is_true(o == otwo)
    end)
	
	it("Should return false for isSome", function()
        local p = None
        assert.is_false(p:IsSome())
    end)	 
	
	it("Should be able to construct an Option.None from Global", function()		
        local o = None
        assert.is_false(o:IsSome())
        assert.is_true(o:IsNone())
		assert.is_true(o == Option.None)
		assert.is_true(o == None)
    end)
	
	it("Should be able to construct an Option.None from new", function()		
		local o = Option.new(nil)
		assert.is_false(o:IsSome())
        assert.is_true(o:IsNone())      
        assert.is_true(o == Option.None)
		assert.is_true(o == None)	
    end)
end)

describe("Option Construction and Wrapping", function()
    it("Should be able to wrap a value into an Option", function()
        local o = Option.Wrap(5)
        assert.is_true(o:IsSome())
        assert.is_false(o:IsNone())
    end)

    it("Should be able to check if an Option is None", function()
        local o = Option.Wrap(nil)
        assert.is_true(o:IsNone())
    end)
end)



describe("Option Identification and Assertion", function()
    it("Should be able to identify an Option", function()
        local o = Option.Wrap(5)
        assert.is_true(Option.Is(o))
    end)

    it("Should be able to assert an Option", function()
        local o = Option.Wrap(5)
        Option.Assert(o)  -- Should not throw an error
    end)
end)

describe("Option Expectation and Unwrapping", function()
    it("Should be able to unwrap a value from an Option", function()
        local o = Option.Wrap(5)
        assert.are.equal(o:Unwrap(), 5)
    end)

    it("Should raise an error when trying to unwrap None", function()
        local o = Option.Wrap(nil)
        assert.has_error(function() o:Unwrap() end, "Cannot unwrap an Option of None type")
    end)

    it("Should be able to unwrap a value or return a default", function()
        local o = Option.Wrap(5)
        assert.are.equal(o:UnwrapOr(10), 5)

        local oNone = Option.Wrap(nil)
        assert.are.equal(oNone:UnwrapOr(10), 10)
    end)

    it("Should be able to unwrap a value or return the result of a function", function()
        local o = Option.Wrap(5)
        assert.are.equal(o:UnwrapOrElse(function() return 10 end), 5)

        local oNone = Option.Wrap(nil)
        assert.are.equal(oNone:UnwrapOrElse(function() return 10 end), 10)
    end)
	
	it("Should be able to expect a value from an Option", function()
        local o = Option.Wrap(5)
        assert.are.equal(o:Expect("Expected a value"), 5)
    end)
    
    it("Should be able to expect None from an Option", function()
        local o = Option.Wrap(nil)
        o:ExpectNone("Expected None")  -- Should not throw an error
    end)
end)

describe("Option.Contains ", function()
    it("Should return true if the Option is 'Some' and contains the specified value", function()
        local o = Option.Some(5)
        assert.is_true(o:Contains(5))
    end)

    it("Should return false if the Option is 'Some' but does not contain the specified value", function()
        local o = Option.Some(5)
        assert.is_false(o:Contains(10))
    end)

    it("Should return false if the Option is 'None'", function()
        local o = Option.None
        assert.is_false(o:Contains(5))
    end)
end)

describe("Option.And ", function()
    it("Should return the second Option if the first is 'Some'", function()
        local o1 = Option.Some(5)
        local o2 = Option.Some(10)
        assert.are.same(o1:And(o2), o2)
    end)

    it("Should return 'None' if the first Option is 'None'", function()
        local o1 = Option.None
        local o2 = Option.Some(10)
        assert.are.same(o1:And(o2), Option.None)
    end)
end)

describe("Option.AndThen ", function()
    it("Should transform the contained value with a function if the Option is 'Some'", function()
        local o = Option.Some(5)
        local result = o:AndThen(function(v) return Option.Some(v + 1) end)
        assert.are.same(result, Option.Some(6))
    end)

    it("Should return 'None' if the Option is 'None'", function()
        local o = Option.None
        local result = o:AndThen(function(v) return Option.Some(v + 1) end)
        assert.are.same(result, Option.None)
    end)
end)

describe("Option.Or ", function()
    it("Should return the first Option if it is 'Some'", function()
        local o1 = Option.Some(5)
        local o2 = Option.Some(10)
        assert.are.same(o1:Or(o2), o1)
    end)

    it("Should return the second Option if the first is 'None'", function()
        local o1 = Option.None
        local o2 = Option.Some(10)
        assert.are.same(o1:Or(o2), o2)
    end)
end)

describe("Option.OrElse ", function()
    it("Should return the first Option if it is 'Some'", function()
        local o = Option.Some(5)
        local result = o:OrElse(function() return Option.Some(10) end)
        assert.are.same(result, o)
    end)

    it("Should return the result of the function if the Option is 'None'", function()
        local o = Option.None
        local result = o:OrElse(function() return Option.Some(10) end)
        assert.are.same(result, Option.Some(10))
    end)
end)

describe("Option.XOr ", function()
    it("Should return 'None' if both Options are 'Some'", function()
        local o1 = Option.Some(5)
        local o2 = Option.Some(10)
        assert.are.same(o1:XOr(o2), Option.None)
    end)

    it("Should return 'None' if both Options are 'None'", function()
        local o1 = Option.None
        local o2 = Option.None
        assert.are.same(o1:XOr(o2), Option.None)
    end)

    it("Should return the first Option if only it is 'Some'", function()
        local o1 = Option.Some(5)
        local o2 = Option.None
        assert.are.same(o1:XOr(o2), o1)
    end)

    it("Should return the second Option if only it is 'Some'", function()
        local o1 = Option.None
        local o2 = Option.Some(10)
        assert.are.same(o1:XOr(o2), o2)
    end)
end)

describe("Option logic ", function()
    it("Should return the second Option if the first is 'Some'", function()
        local o1 = Option.Wrap(5)
        local o2 = Option.Wrap(10)
        assert.are.equal(o1:And(o2):Unwrap(), 10)
    end)

    it("Should transform the contained value with a function if the Option is 'Some'", function()
        local o = Option.Wrap(5)
        local result = o:AndThen(function(value) return Option.Wrap(value * 2) end)
        assert.are.equal(result:Unwrap(), 10)
    end)

    it("Should return the first Option if it is 'Some', otherwise returns the second Option", function()
        local o1 = Option.Wrap(5)
        local o2 = Option.Wrap(10)
        assert.are.equal(o1:Or(o2):Unwrap(), 5)

        local oNone = Option.Wrap(nil)
        assert.are.equal(oNone:Or(o2):Unwrap(), 10)
    end)

    it("Should return the first Option if it is 'Some', otherwise the result of the function", function()
        local o = Option.Wrap(5)
        assert.are.equal(o:OrElse(function() return Option.Wrap(10) end):Unwrap(), 5)

        local oNone = Option.Wrap(nil)
        assert.are.equal(oNone:OrElse(function() return Option.Wrap(10) end):Unwrap(), 10)
    end)

    it("Should return the first Option if only one of the two Options is 'Some', otherwise 'None'", function()
        local o1 = Option.Wrap(5)
        local o2 = Option.Wrap(10)
        assert.is_true(o1:XOr(o2):IsNone())

        local oNone = Option.Wrap(nil)
        assert.are.equal(oNone:XOr(o2):Unwrap(), 10)
    end)
end)

describe("Option Serialization and Deserialization", function()
    it("Should be able to serialize an Option", function()
        local o = Option.Wrap(5)
        local data = o:Serialize()
        assert.are.same(data, { ClassName = "Option", Value = 5 })
    end)

    it("Should be able to deserialize an Option", function()
        local data = { ClassName = "Option", Value = 5 }
        local o = Option.Deserialize(data)
        assert.is_true(o:IsSome())
        assert.is_false(o:IsNone())
    end)
end)

describe("Option.__tostring ", function()
    it("Should return a string representation of the Option if it is 'Some'", function()
        local o = Option.Wrap(5)
        local optStr = tostring(o)
        assert.are.equal(optStr, "Some(5)")
    end)
    
    it("Should return 'Option<None>' if the Option is 'None'", function()
        local o = Option.Wrap(nil)
        assert.are.equal(tostring(o), "None")
    end)
    
    it("Should return 'nil' if the Option is nil", function()
        local o = nil
        assert.are.equal(tostring(o), "nil")
    end)
end)


































----package.path = package.path .. ';../src/?.tl'
--package.path = package.path .. ';../dist/?.lua'
--package.path = package.path .. ';../test/?.tl'
--package.path = package.path .. ';../test/busted/?.lua'
--package.path = package.path .. ';../vendor/?.tl'
--package.path = package.path .. ';../vendor/?.lua'

----- @type function
--local describe = require("busted").describe
----- @type function
--local it = require("busted").it
----- @type table
--local assert = require("busted").assert

--require("option")

--describe("Option Some ", function()
--    it("Should be able to construct an Option.Some from new", function()		
--        local o = Option.new(5)
--        assert.is_true(o:IsSome())
--        assert.is_false(o:IsNone())
--        local other = Option.new(5)
--		assert.is_true(o == other)	
--    end)
	
--	it("Should be able to create a new Option.Some from Option.Some directly", function()		
--		-- Some here is technically global but the LSP can't handle it from teal
--		local o = Option.Some(5)
--		assert.is_true(o:IsSome())
--		assert.is_false(o:IsNone())
--    end)
	
--	it("Should be able to create a new Option.Some from global Some directly", function()		
--		-- Some here is technically global but the LSP can't handle it from teal
--		local o = Some(5)
--		assert.is_true(o:IsSome())
--		assert.is_false(o:IsNone())
--	end)
--end)

--describe("Option.None ", function()           
--    it("Should be able to construct an Option.None from singleton", function()		
--        local o = Option.None
		
--        assert.is_false(o:IsSome())
--        assert.is_true(o:IsNone())
--        local otwo = Option.None
--		assert.is_true(o == otwo)
--    end)
	
--	it("Should return false for isSome", function()
--        local p = None
--        assert.is_false(p:IsSome())
--    end)	 
	
--	it("Should be able to construct an Option.None from Global", function()		
--        local o = None
--        assert.is_false(o:IsSome())
--        assert.is_true(o:IsNone())
--		assert.is_true(o == Option.None)
--		assert.is_true(o == None)
--    end)
	
--	it("Should be able to construct an Option.None from new", function()		
--		local o = Option.new(nil)
--		assert.is_false(o:IsSome())
--        assert.is_true(o:IsNone())      
--        assert.is_true(o == Option.None)
--		assert.is_true(o == None)	
--    end)
    
--     it("Should return true for isNone", function()
--        local o = Option.None
--		local isNone = o:IsNone()
--        assert.is_true(isNone)
--    end)    
    
--    it("Should return default value for unwrapOr", function()
--        local o = Option.None
--		local unwrapped = o:UnwrapOr(5)
--        assert.are.equal(unwrapped, 5)
--    end)
    
--    it("Should return result of function for unwrapOrElse", function()
--        local o = None
--        assert.are.equal(o:UnwrapOrElse(function() return 5 end), 5)
--    end)
--end)

--describe("Option.And ", function()
--    it("Should return the second Option if the first is 'Some'", function()
--        local o1 = Option.Some(5)
--        local o2 = Option.Some(10)
--        assert.are.same(o1:And(o2), o2)
--    end)

--    it("Should return 'None' if the first Option is 'None'", function()
--        local o1 = Option.None
--        local o2 = Option.Some(10)
--        assert.are.same(o1:And(o2), Option.None)
--    end)
--end)

--describe("Option.AndThen ", function()
--    it("Should transform the contained value with a function if the Option is 'Some'", function()
--        local o = Option.Some(5)
--        local result = o:AndThen(function(v) return Option.Some(v + 1) end)
--        assert.are.same(result, Option.Some(6))
--    end)

--    it("Should return 'None' if the Option is 'None'", function()
--        local o = Option.None
--        local result = o:AndThen(function(v) return Option.Some(v + 1) end)
--        assert.are.same(result, Option.None)
--    end)
--end)

--describe("Option.Or ", function()
--    it("Should return the first Option if it is 'Some'", function()
--        local o1 = Option.Some(5)
--        local o2 = Option.Some(10)
--        assert.are.same(o1:Or(o2), o1)
--    end)

--    it("Should return the second Option if the first is 'None'", function()
--        local o1 = Option.None
--        local o2 = Option.Some(10)
--        assert.are.same(o1:Or(o2), o2)
--    end)
--end)

--describe("Option.OrElse ", function()
--    it("Should return the first Option if it is 'Some'", function()
--        local o = Option.Some(5)
--        local result = o:OrElse(function() return Option.Some(10) end)
--        assert.are.same(result, o)
--    end)

--    it("Should return the result of the function if the Option is 'None'", function()
--        local o = Option.None
--        local result = o:OrElse(function() return Option.Some(10) end)
--        assert.are.same(result, Option.Some(10))
--    end)
--end)

--describe("Option.XOr ", function()
--    it("Should return 'None' if both Options are 'Some'", function()
--        local o1 = Option.Some(5)
--        local o2 = Option.Some(10)
--        assert.are.same(o1:XOr(o2), Option.None)
--    end)

--    it("Should return 'None' if both Options are 'None'", function()
--        local o1 = Option.None
--        local o2 = Option.None
--        assert.are.same(o1:XOr(o2), Option.None)
--    end)

--    it("Should return the first Option if only it is 'Some'", function()
--        local o1 = Option.Some(5)
--        local o2 = Option.None
--        assert.are.same(o1:XOr(o2), o1)
--    end)

--    it("Should return the second Option if only it is 'Some'", function()
--        local o1 = Option.None
--        local o2 = Option.Some(10)
--        assert.are.same(o1:XOr(o2), o2)
--    end)
--end)

--describe("Option.Contains ", function()
--    it("Should return true if the Option is 'Some' and contains the specified value", function()
--        local o = Option.Some(5)
--        assert.is_true(o:Contains(5))
--    end)

--    it("Should return false if the Option is 'Some' but does not contain the specified value", function()
--        local o = Option.Some(5)
--        assert.is_false(o:Contains(10))
--    end)

--    it("Should return false if the Option is 'None'", function()
--        local o = Option.None
--        assert.is_false(o:Contains(5))
--    end)
--end)

--describe("Option.Filter ", function()
--    it("Should return the Option if it is 'Some' and the predicate returns true", function()
--        local o = Option.Some(5)
--        local result = o:Filter(function(v) return v > 0 end)
--        assert.are.same(result, o)
--    end)

--    it("Should return 'None' if the Option is 'Some' but the predicate returns false", function()
--        local o = Option.Some(5)
--        local result = o:Filter(function(v) return v < 0 end)
--        assert.are.same(result, Option.None)
--    end)

--    it("Should return 'None' if the Option is 'None'", function()
--        local o = Option.None
--        local result = o:Filter(function(v) return v > 0 end)
--        assert.are.same(result, Option.None)
--    end)
--end)

--describe("Option.Match ", function()
--    it("Should return the result of the 'Some' function if the Option is 'Some'", function()
--        local o = Option.Some(5)
--        local result = o:Match({ Some = function(v) return v + 1 end, None = function() return 0 end })
--        assert.are.equal(result, 6)
--    end)

--    it("Should return the result of the 'None' function if the Option is 'None'", function()
--        local o = Option.None
--        local result = o:Match({ Some = function(v) return v + 1 end, None = function() return 0 end })
--        assert.are.equal(result, 0)
--    end)
--end)

--describe("Option Methods ", function()
--    it("Should be able to wrap a value into an Option", function()
--        local o = Option.Wrap(5)
--        assert.is_true(o:IsSome())
--        assert.is_false(o:IsNone())
--    end)

--    it("Should be able to identify an Option", function()
--        local o = Option.Wrap(5)
--        assert.is_true(Option.Is(o))
--    end)

--    it("Should be able to assert an Option", function()
--        local o = Option.Wrap(5)
--        Option.Assert(o)  -- Should not throw an error
--    end)

--    it("Should be able to deserialize an Option", function()
--        local data = { ClassName = "Option", Value = 5 }
--        local o = Option.Deserialize(data)
--        assert.is_true(o:IsSome())
--        assert.is_false(o:IsNone())
--    end)

--    it("Should be able to serialize an Option", function()
--        local o = Option.Wrap(5)
--        local data = o:Serialize()
--        assert.are.same(data, { ClassName = "Option", Value = 5 })
--    end)

--    it("Should be able to check if an Option is None", function()
--        local o = Option.Wrap(nil)
--        assert.is_true(o:IsNone())
--    end)

--    it("Should be able to expect a value from an Option", function()
--        local o = Option.Wrap(5)
--        assert.are.equal(o:Expect("Expected a value"), 5)
--    end)

--    it("Should be able to expect None from an Option", function()
--        local o = Option.Wrap(nil)
--        o:ExpectNone("Expected None")  -- Should not throw an error
--    end)
--end)

--describe("Option unwrap ", function()
--    it("Should be able to unwrap a value from an Option", function()
--        local o = Option.Wrap(5)
--        assert.are.equal(o:Unwrap(), 5)
--    end)

--    it("Should raise an error when trying to unwrap None", function()
--        local o = Option.Wrap(nil)
--        assert.has_error(function() o:Unwrap() end, "Cannot unwrap an Option of None type")
--    end)

--    it("Should be able to unwrap a value or return a default", function()
--        local o = Option.Wrap(5)
--        assert.are.equal(o:UnwrapOr(10), 5)

--        local oNone = Option.Wrap(nil)
--        assert.are.equal(oNone:UnwrapOr(10), 10)
--    end)

--    it("Should be able to unwrap a value or return the result of a function", function()
--        local o = Option.Wrap(5)
--        assert.are.equal(o:UnwrapOrElse(function() return 10 end), 5)

--        local oNone = Option.Wrap(nil)
--        assert.are.equal(oNone:UnwrapOrElse(function() return 10 end), 10)
--    end)
--end)

--describe("Option logic ", function()
--    it("Should return the second Option if the first is 'Some'", function()
--        local o1 = Option.Wrap(5)
--        local o2 = Option.Wrap(10)
--        assert.are.equal(o1:And(o2):Unwrap(), 10)
--    end)

--    it("Should transform the contained value with a function if the Option is 'Some'", function()
--        local o = Option.Wrap(5)
--        local result = o:AndThen(function(value) return Option.Wrap(value * 2) end)
--        assert.are.equal(result:Unwrap(), 10)
--    end)

--    it("Should return the first Option if it is 'Some', otherwise returns the second Option", function()
--        local o1 = Option.Wrap(5)
--        local o2 = Option.Wrap(10)
--        assert.are.equal(o1:Or(o2):Unwrap(), 5)

--        local oNone = Option.Wrap(nil)
--        assert.are.equal(oNone:Or(o2):Unwrap(), 10)
--    end)

--    it("Should return the first Option if it is 'Some', otherwise the result of the function", function()
--        local o = Option.Wrap(5)
--        assert.are.equal(o:OrElse(function() return Option.Wrap(10) end):Unwrap(), 5)

--        local oNone = Option.Wrap(nil)
--        assert.are.equal(oNone:OrElse(function() return Option.Wrap(10) end):Unwrap(), 10)
--    end)

--    it("Should return the first Option if only one of the two Options is 'Some', otherwise 'None'", function()
--        local o1 = Option.Wrap(5)
--        local o2 = Option.Wrap(10)
--        assert.is_true(o1:XOr(o2):IsNone())

--        local oNone = Option.Wrap(nil)
--        assert.are.equal(oNone:XOr(o2):Unwrap(), 10)
--    end)
	
--	it("Should return true if the Option contains the value", function()
--        local o = Option.Wrap(5)
--        assert.is_true(o:Contains(5))
--    end)

--    it("Should return false if the Option does not contain the value", function()
--        local o = Option.Wrap(5)
--        assert.is_false(o:Contains(10))
--    end)

--    it("Should return false if the Option is None", function()
--        local o = Option.Wrap(nil)
--        assert.is_false(o:Contains(5))
--    end)
--end)

--describe("Option.Filter ", function()
--    it("Should return the Option if it is 'Some' and the predicate returns true", function()
--        local o = Option.Wrap(5)
--        local result = o:Filter(function(value) return value > 0 end)
--        assert.are.equal(result:Unwrap(), 5)
--    end)

--    it("Should return 'None' if the Option is 'Some' and the predicate returns false", function()
--        local o = Option.Wrap(5)
--        local result = o:Filter(function(value) return value < 0 end)
--        assert.is_true(result:IsNone())
--    end)

--    it("Should return 'None' if the Option is 'None'", function()
--        local o = Option.Wrap(nil)
--        local result = o:Filter(function(value) return value > 0 end)
--        assert.is_true(result:IsNone())
--    end)
--end)

--describe("Option.Match ", function()
--    it("Should call the 'Some' function if the Option is 'Some'", function()
--        local o = Option.Wrap(5)
--        local result = o:Match({
--            Some = function(value) return value * 2 end,
--            None = function() return 0 end
--        })
--        assert.are.equal(result, 10)
--    end)

--    it("Should call the 'None' function if the Option is 'None'", function()
--        local o = Option.Wrap(nil)
--        local result = o:Match({
--            Some = function(value) return value * 2 end,
--            None = function() return 0 end
--        })
--        assert.are.equal(result, 0)
--    end)

--    it("Should raise an error if the 'Some' function is missing", function()
--        local o = Option.Wrap(5)
--        assert.has_error(function()
--            o:Match({
--                None = function() return 0 end
--            })
--        end, "Missing 'Some' match")
--    end)

--    it("Should raise an error if the 'None' function is missing", function()
--        local o = Option.Wrap(5)
--        assert.has_error(function()
--            o:Match({
--                Some = function(value) return value * 2 end
--            })
--        end, "Missing 'None' match")
--    end)
--end)

--describe("Option.__tostring ", function()
--    it("Should return a string representation of the Option if it is 'Some'", function()
--        local o = Option.Wrap(5)
--        local optStr = tostring(o)
--        assert.are.equal(optStr, "Some(5)")
--    end)
    
--    it("Should return 'Option<None>' if the Option is 'None'", function()
--        local o = Option.Wrap(nil)
--        assert.are.equal(tostring(o), "None")
--    end)
    
--    it("Should return 'nil' if the Option is nil", function()
--        local o = nil
--        assert.are.equal(tostring(o), "nil")
--    end)
--end)

--describe("Basic unit testing framework test", function()
--  describe("should be awesome", function()
--    it("should have some nice features", function()
--	  assert.truthy("Yup")
--      -- deep check comparisons!
--      assert.are.same({ table = "great"}, { table = "great" })

--      -- or check by reference!
--      assert.are_not.equal({ table = "great"}, { table = "great"})
      
--      assert.truthy("this is a string") -- truthy: not false or nil

--      assert.True(1 == 1)
--      assert.is_true(1 == 1)

--      assert.falsy(nil)
--      assert.has_error(function() error("Wat") end, "Wat")
--    end)
    
--    it("should provide some shortcuts to common functions", function()
--      assert.are.unique({{ thing = 1 }, { thing = 2 }, { thing = 3 }})
--    end)
--  end)
--end)
 