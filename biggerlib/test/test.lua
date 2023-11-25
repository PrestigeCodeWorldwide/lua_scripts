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

local Option = require("option")



describe("Option Some tests", function()
    it("Should be able to construct an Option.Some", function()		
        local o = Option._new(5)
   
		
        assert.is_true(o:IsSome())
		assert.is_false(o:IsNone())
	end)	
end)

describe("Busted unit testing framework", function()
  describe("should be awesome", function()
    it("should be easy to use", function()
      assert.truthy("Yup.")
    end)

    it("should have lots of features", function()
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

