package.path = package.path .. ';../dist/?.lua'
package.path = package.path .. ';../vendor/?.lua'
lu = require('luaunit')
local Option = require('option')
local logger = require('logger')

function testOptionNone()
    local o = Option.Some(5)
    --dump(o, "Option.Some(5)")
	--lu.assertEquals(o:isSome(), true)
    
	
	
	--local o = Option.None
	--lu.assertEquals(o:isSome(), false)
    --lu.assertEquals(o:isNone(), true)
    --lu.assertEquals(o:unwrapOr(5), 5)
    --lu.assertEquals(o:unwrapOrElse(function() return 5 end), 5)
    --lu.assertEquals(o:unwrapOrError('Error'), nil)
    --lu.assertEquals(o:map(function(v) return v + 1 end), Option.none())
    --lu.assertEquals(o:mapOr(5, function(v) return v + 1 end), 5)
    --lu.assertEquals(o:mapOrElse(function() return 5 end, function(v) return v + 1 end), 5)
    --lu.assertEquals(o:andThen(function(v) return Option.some(v + 1) end), Option.none())
    --lu.assertEquals(o:filter(function(v) return v > 0 end), Option.none())
    --lu.assertEquals(o:orSome(5), 5)
    --lu.assertEquals(o:orNone(), Option.none())
    --lu.assertEquals(o:orError('Error'), nil)
    --lu.assertEquals(o:contains(5), false)
    --lu.assertEquals(o:containsAll({ 5, 6 }), false)
    --lu.assertEquals(o:containsAny({ 5, 6 }), false)
    --lu.assertEquals(o:containsNone({ 5, 6 }), true)
    --lu.assertEquals(o:equals(Option.none()), true)
    --lu.assertEquals(o:equals(Option.some(5)), false)
    --lu.assertEquals(o:equals(Option.some(6)), false)
    --lu.assertEquals(o:equals(Option.some('5')), false)
    --lu.assertEquals(o:equals(Option.some(nil)), false)
    --lu.assertEquals(o:equals(Option.some({})), false)
    --lu.assertEquals(o:equals(Option.some(function() end)), false)
    --lu.assertEquals(o:equals(Option.some(Option.none())), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(5))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(6))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some('5'))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(nil))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some({}))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(function() end))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(Option.none()))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(5)))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(6)))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some('5')))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(nil)))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some({})))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(function() end)))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(Option.none())))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(Option.some(5))))), false)
    --lu.assertEquals(o:equals(Option.some(Option.some(Option.some(Option.some(6))))), false)
end


function add(v1, v2)
    -- add positive numbers
    -- return 0 if any of the numbers are 0
    -- error if any of the two numbers are negative
    if v1 < 0 or v2 < 0 then
        error('Can only add positive or null numbers, received ' .. v1 .. ' and ' .. v2)
    end
    if v1 == 0 or v2 == 0 then
        return 0
    end
    return v1 + v2
end

function testAddPositive()
    lu.assertEquals(add(1,1),2)
end

function testAddZero()
    lu.assertEquals(add(1, 0), 0)
    lu.assertEquals(add(0, 5), 0)
    lu.assertEquals(add(0, 0), 0)
end

os.exit( lu.LuaUnit.run() )