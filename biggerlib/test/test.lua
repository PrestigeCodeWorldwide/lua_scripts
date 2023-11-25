--package.path = package.path .. ';../src/?.tl'
package.path = package.path .. ';../dist/?.lua'
package.path = package.path .. ';../test/?.tl'
package.path = package.path .. ';../test/busted/?.lua'
package.path = package.path .. ';../vendor/?.tl'
package.path = package.path .. ';../vendor/?.lua'

--- @type function
local describe = require("busted").describe
--- @type function
local it = require("busted").it
--- @type table
local assert = require("busted").assert

require("option")

describe("Option Some tests", function()
    it("Should be able to construct an Option.Some from new", function()		
        local o = Option.new(5)
        assert.is_true(o:IsSome())
        assert.is_false(o:IsNone())
    end)
	
	it("Should be able to create a new Option.Some from Option.Some directly", function()		
		-- Some here is technically global but the LSP can't handle it from teal
		local o = Option.Some(5)
		assert.is_true(o:IsSome())
		assert.is_false(o:IsNone())
    end)
	
	it("Should be able to create a new Option.Some from global Some directly", function()		
		-- Some here is technically global but the LSP can't handle it from teal
		local o = Some(5)
		assert.is_true(o:IsSome())
		assert.is_false(o:IsNone())
	end)
end)

describe("Option None tests", function()
    it("Should be able to construct an Option.None from singleton", function()		
        local o = Option.None
        assert.is_false(o:IsSome())
        assert.is_true(o:IsNone())
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

describe("Option Methods ", function()
    it("Should be able to wrap a value into an Option", function()
        local o = Option.Wrap(5)
        assert.is_true(o:IsSome())
        assert.is_false(o:IsNone())
    end)

    it("Should be able to identify an Option", function()
        local o = Option.Wrap(5)
        assert.is_true(Option.Is(o))
    end)

    it("Should be able to assert an Option", function()
        local o = Option.Wrap(5)
        Option.Assert(o)  -- Should not throw an error
    end)

    it("Should be able to deserialize an Option", function()
        local data = { ClassName = "Option", Value = 5 }
        local o = Option.Deserialize(data)
        assert.is_true(o:IsSome())
        assert.is_false(o:IsNone())
    end)

    it("Should be able to serialize an Option", function()
        local o = Option.Wrap(5)
        local data = o:Serialize()
        assert.are.same(data, { ClassName = "Option", Value = 5 })
    end)

    it("Should be able to check if an Option is None", function()
        local o = Option.Wrap(nil)
        assert.is_true(o:IsNone())
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

describe("Option unwrap tests", function()
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
end)

describe("Option logic tests", function()
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
	
	it("Should return true if the Option contains the value", function()
        local o = Option.Wrap(5)
        assert.is_true(o:Contains(5))
    end)

    it("Should return false if the Option does not contain the value", function()
        local o = Option.Wrap(5)
        assert.is_false(o:Contains(10))
    end)

    it("Should return false if the Option is None", function()
        local o = Option.Wrap(nil)
        assert.is_false(o:Contains(5))
    end)
end)

describe("Option.Filter tests", function()
    it("Should return the Option if it is 'Some' and the predicate returns true", function()
        local o = Option.Wrap(5)
        local result = o:Filter(function(value) return value > 0 end)
        assert.are.equal(result:Unwrap(), 5)
    end)

    it("Should return 'None' if the Option is 'Some' and the predicate returns false", function()
        local o = Option.Wrap(5)
        local result = o:Filter(function(value) return value < 0 end)
        assert.is_true(result:IsNone())
    end)

    it("Should return 'None' if the Option is 'None'", function()
        local o = Option.Wrap(nil)
        local result = o:Filter(function(value) return value > 0 end)
        assert.is_true(result:IsNone())
    end)
end)

describe("Option.Match tests", function()
    it("Should call the 'Some' function if the Option is 'Some'", function()
        local o = Option.Wrap(5)
        local result = o:Match({
            Some = function(value) return value * 2 end,
            None = function() return 0 end
        })
        assert.are.equal(result, 10)
    end)

    it("Should call the 'None' function if the Option is 'None'", function()
        local o = Option.Wrap(nil)
        local result = o:Match({
            Some = function(value) return value * 2 end,
            None = function() return 0 end
        })
        assert.are.equal(result, 0)
    end)

    it("Should raise an error if the 'Some' function is missing", function()
        local o = Option.Wrap(5)
        assert.has_error(function()
            o:Match({
                None = function() return 0 end
            })
        end, "Missing 'Some' match")
    end)

    it("Should raise an error if the 'None' function is missing", function()
        local o = Option.Wrap(5)
        assert.has_error(function()
            o:Match({
                Some = function(value) return value * 2 end
            })
        end, "Missing 'None' match")
    end)
end)

describe("Option.__tostring tests", function()
    it("Should return a string representation of the Option if it is 'Some'", function()
        local o = Option.Wrap(5)
        local optStr = tostring(o)
		print("Opt str is: " .. optStr)
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

describe("Basic unit testing framework test", function()
  describe("should be awesome", function()
    it("should have some nice features", function()
	  assert.truthy("Yup")
      -- deep check comparisons!
      assert.are.same({ table = "great"}, { table = "great" })

      -- or check by reference!
      assert.are_not.equal({ table = "great"}, { table = "great"})
      
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
 
--os.exit(lu.LuaUnit.run())
 
 
--global type lu

--local lu = require('luaunit')
--require('option')
----local logger = require('logger')

--local function testOptionNone()
--    --- @type Option
--    local o = Option.Some(5)
--    --dump(o, "Option.Some(5)")
--	lu.assertEquals(o:isSome(), true)
    
	
	
--	--local o = Option.None
--	--lu.assertEquals(o:isSome(), false)
--    --lu.assertEquals(o:isNone(), true)
--    --lu.assertEquals(o:unwrapOr(5), 5)
--    --lu.assertEquals(o:unwrapOrElse(function() return 5 end), 5)
--    --lu.assertEquals(o:unwrapOrError('Error'), nil)
--    --lu.assertEquals(o:map(function(v) return v + 1 end), Option.none())
--    --lu.assertEquals(o:mapOr(5, function(v) return v + 1 end), 5)
--    --lu.assertEquals(o:mapOrElse(function() return 5 end, function(v) return v + 1 end), 5)
--    --lu.assertEquals(o:andThen(function(v) return Option.some(v + 1) end), Option.none())
--    --lu.assertEquals(o:filter(function(v) return v > 0 end), Option.none())
--    --lu.assertEquals(o:orSome(5), 5)
--    --lu.assertEquals(o:orNone(), Option.none())
--    --lu.assertEquals(o:orError('Error'), nil)
--    --lu.assertEquals(o:contains(5), false)
--    --lu.assertEquals(o:containsAll({ 5, 6 }), false)
--    --lu.assertEquals(o:containsAny({ 5, 6 }), false)
--    --lu.assertEquals(o:containsNone({ 5, 6 }), true)
--    --lu.assertEquals(o:equals(Option.none()), true)
--    --lu.assertEquals(o:equals(Option.some(5)), false)
--    --lu.assertEquals(o:equals(Option.some(6)), false)
--    --lu.assertEquals(o:equals(Option.some('5')), false)
--    --lu.assertEquals(o:equals(Option.some(nil)), false)
--    --lu.assertEquals(o:equals(Option.some({})), false)
--    --lu.assertEquals(o:equals(Option.some(function() end)), false)
--    --lu.assertEquals(o:equals(Option.some(Option.none())), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(5))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(6))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some('5'))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(nil))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some({}))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(function() end))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(Option.none()))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(5)))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(6)))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some('5')))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(nil)))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some({})))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(function() end)))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(Option.none())))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(Option.some(5))))), false)
--    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(Option.some(6))))), false)
--end


--function add(v1, v2)
--    -- add positive numbers
--    -- return 0 if any of the numbers are 0
--    -- error if any of the two numbers are negative
--    if v1 < 0 or v2 < 0 then
--        error('Can only add positive or null numbers, received ' .. v1 .. ' and ' .. v2)
--    end
--    if v1 == 0 or v2 == 0 then
--        return 0
--    end
--    return v1 + v2
--end

--function testAddPositive()
--    lu.assertEquals(add(1,1),2)
--end

--function testAddZero()
--    lu.assertEquals(add(1, 0), 0)
--    lu.assertEquals(add(0, 5), 0)
--    lu.assertEquals(add(0, 0), 0)
--end

