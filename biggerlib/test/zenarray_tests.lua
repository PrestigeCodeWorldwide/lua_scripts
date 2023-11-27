package.path = package.path .. ';../dist/?.lua'

require("option")
require("busted")
require("zenarray")
-- This is just a test file, so we don't really need ALL of teal, but some helper types for the various busted stuff is nice
--- @type function
local describe = require("busted").describe
--- @type function
local it = require("busted").it
--- @type table
local assert = require("busted").assert

describe("ZenTable Creation and Basic Functionality", function()
    it("Should be able to create a new ZenTable", function()
        local zt = newArray(1, 2, 3)
        assert.is_true(zt:isarray())
    end)

    it("Should be able to check if ZenTable contains a value", function()
        local zt = newArray(1, 2, 3)
        assert.is_true(zt:contains(2))
        assert.is_false(zt:contains(4))
    end)
end)

describe("ZenTable Modification Methods", function()
    it("Should be able to remove a value from ZenTable", function()
        local zt = newArray(1, 2, 3)
        assert.is_true(zt:remove(2))
        assert.is_false(zt:contains(2))
    end)
    
    it("Should be able to clear all values in ZenTable", function()
        local zt = newArray(1, 2, 3)
        zt:clear()
        assert.is_false(zt:contains(1))
        assert.is_false(zt:contains(2))
        assert.is_false(zt:contains(3))
    end)
end)

describe("ZenTable Iteration and Transformation", function()
    it("Should be able to apply a function to each element with forEach", function()
        local zt = newArray(1, 2, 3)
        local sum = 0
        zt:forEach(function(value) sum = sum + value end)
        assert.are.equal(sum, 6)
    end)

    it("Should be able to transform elements with map", function()
        local zt = newArray(1, 2, 3)
        local doubled = zt:map(function(x) return x * 2 end)
        assert.is_true(doubled:contains(2))
        assert.is_true(doubled:contains(4))
        assert.is_true(doubled:contains(6))
    end)
end)

describe("ZenTable Utility Methods", function()
    it("Should be able to find an element's index", function()
        local zt = newArray(1, 2, 3)
        assert.are.equal(zt:find(2), 2)
    end)

    it("Should be able to count elements based on a predicate", function()
        local zt = newArray(1, 2, 3, 4)
        local count = zt:count(function(x) return x % 2 == 0 end)
        assert.are.equal(count, 2)
    end)

    it("Should be able to clone the ZenTable", function()
        local zt = newArray(1, 2, 3)
        local cloned = zt:clone()
        assert.is_true(cloned:contains(1))
        assert.is_true(cloned:contains(2))
        assert.is_true(cloned:contains(3))
    end)

    it("Should be able to filter elements based on a predicate", function()
        local zt = newArray(1, 2, 3, 4)
        local filtered = zt:filter(function(x) return x % 2 == 0 end)
        assert.is_true(filtered:contains(2))
        assert.is_true(filtered:contains(4))
        assert.is_false(filtered:contains(1))
        assert.is_false(filtered:contains(3))
    end)
end)

describe("ZenTable Match and Keys Methods", function()
    it("Should be able to match an element based on a predicate", function()
        local zt = newArray(1, 2, 3)
        local value, key = zt:match(function(x) return x == 2 end)
        assert.are.equal(value, 2)
        assert.are.equal(key, 2)
    end)

    it("Should be able to retrieve all keys", function()
        local zt = newArray('a', 'b', 'c')
        local keys = zt:keys()
        assert.are.same(keys, {1, 2, 3})
    end)
end)

describe("ZenArray Advanced Functionality", function()
    it("Should correctly add elements using push", function()
        local zt = newArray(1, 2)
        zt:push(3)
		zt:push(4)
        assert.are.same(zt._data, {1, 2, 3, 4})
    end)

    it("Should handle edge cases gracefully", function()
        local zt = newArray()
        assert.is_false(zt:remove(1))  -- Removing from empty array
        assert.is_nil(zt:find(1))      -- Finding in empty array
    end)

    it("Should correctly insert an element", function()
        local zt = newArray(1, 2)
        zt:insert(3) -- Assuming insert method takes (value, position)
        assert.are.same(zt._data, {1, 2, 3})
    end)
end)

describe("ZenArray Error Handling", function()
    it("Should handle invalid input for map function", function()
        local zt = newArray(1, 2, 3)
        local status, err = pcall(function() zt:map("not a function") end)
        assert.is_false(status)  -- pcall returns false if there's an error
        assert.is_not_nil(err)   -- err should contain error information
    end)

    it("Should handle invalid input for forEach function", function()
        local zt = newArray(1, 2, 3)
        local status, err = pcall(function() zt:forEach("not a function") end)
        assert.is_false(status)
        assert.is_not_nil(err)
    end)

    it("Should handle invalid input for filter function", function()
        local zt = newArray(1, 2, 3)
        local status, err = pcall(function() zt:filter("not a function") end)
        assert.is_false(status)
        assert.is_not_nil(err)
    end)

    it("Should handle invalid input for count function", function()
        local zt = newArray(1, 2, 3)
        local status, err = pcall(function() zt:count("not a function") end)
        assert.is_false(status)
        assert.is_not_nil(err)
    end)

    it("Should handle invalid input for match function", function()
        local zt = newArray(1, 2, 3)
        local status, err = pcall(function() zt:match("not a function") end)
        assert.is_false(status)
        assert.is_not_nil(err)
    end)
end)