
local lume = require("lume")
local MapFunction = lume.MapFunction

-- Generates an iterator that increments from i to to by inc
-- @param i integer
-- @param to integer
-- @param inc integer
-- @return function
global function range(i: integer, to: integer, inc: integer): function
    if i == nil then
        return nil -- range(--[[ no args ]]) -> return "nothing" to fail the loop in the caller
    end
    
    if to == nil then
        to = i
        i = to == 0 and 0 or (to > 0 and 1 or -1)
    end
    
    -- 0 -> 0 with any inc would never iterate
    inc = inc or (i < to and 1 or -1)
    
    -- step back (once) before we start
    i = i - inc
    return function(): integer
        if i == to then
            return nil
        end
        i = i + inc
        return i
    end
end

global record ZenTable<T>
  -- Definitions of the methods
  _data: {T}
    
  contains: function(self: ZenTable<T>, value: T): boolean
  remove: function(self: ZenTable<T>, value: T): boolean
  isarray: function(self: ZenTable): boolean
  clear: function(self: ZenTable)  
  match: function(self: ZenTable<T>, func: function(T):boolean): (T, (number | string))
  find: function(self: ZenTable<T>, value: T): number | nil
  count: function(self: ZenTable<T>, predicate: (nil | function(x:T):boolean)): number 
  clone: function(self: ZenTable<T>): ZenTable<T>
  keys: function(self: ZenTable<T>): {number | string}
  forEach: function(self: ZenTable<T>, fn: function(T|any, ...: any), ...: any): ZenTable<T>
  map: function<T,R>(self: ZenTable<T>, fn: MapFunction<T, R>): ZenTable<R> 
  push: function(self: ZenTable<T>, ...: T): T...
  filter: function(self: ZenTable<T>, func: (function(T):boolean), retainkeys: (boolean | nil)): table
end

function ZenTable.forEach<T>(self: ZenTable<T>, fn: function(T|any, ...: any), ...: any): ZenTable<T>
  for _, value in ipairs(self._data) do
    fn(value, ...)
  end
  return self
end
 
function ZenTable.count<T>(self: ZenTable<T>, predicate: (nil | function(x:T):boolean)): number
  return lume.count(self._data, predicate)
end

function ZenTable.keys(self: ZenTable<T>): {number | string}
  return lume.keys(self._data)
end

function ZenTable.clone<T>(self: ZenTable<T>): ZenTable<T>
  return lume.clone(self as {T}) as ZenTable<T>
end

function ZenTable.match<T>(self: ZenTable<T>, func: function(T):boolean): (T, (number | string))
  return lume.match(self._data, func)
end

function ZenTable.insert<T>(self: ZenTable<T>, value: T)
  table.insert(self._data, value)
end

function ZenTable.contains<T>(self: ZenTable<T>, value: T): boolean
  return lume.find(self._data, value) ~= nil
end

function ZenTable.remove<T>(self: ZenTable<T>, value: T): boolean
  local index = lume.find(self._data, value)
  if index then
    table.remove(self._data, index)
    return true
  end
  return false
end 

function ZenTable.map<T, R>(self: ZenTable<T>, fn: MapFunction<T, R>): ZenTable<R>
  local result = {}
  for _, value in ipairs(self._data) do
    table.insert(result, fn(value))
  end
  return { _data = result }
end

function ZenTable.isarray(self: ZenTable<T>): boolean
  return lume.isarray(self._data)
end

function ZenTable.clear<T>(self: ZenTable<T>) 
  lume.clear(self._data)
end

function ZenTable.filter<T>(self: ZenTable<T>, func: (function(T): boolean), retainkeys: boolean|nil ): table  
  return lume.filter(self._data, func, retainkeys)
end

function ZenTable.find<T>(self: ZenTable<T>, value: T): number | nil
  return lume.find(self._data, value)
end

local function newTable<T>(...: T): ZenTable<T>
  local instance: ZenTable<T> = {
    _data = {...},
    
    -- Assigning the existing ZenTable methods to the new instance
    filter = ZenTable.filter,
    contains = ZenTable.contains,
    remove = ZenTable.remove,
    forEach = ZenTable.forEach,  -- Assuming `each` is the implementation of `forEach`
    isarray = ZenTable.isarray,
    clear = ZenTable.clear,
    match = ZenTable.match,
    find = ZenTable.find,
    count = ZenTable.count,
    clone = ZenTable.clone,
    keys = ZenTable.keys,
    map = ZenTable.map,
    push = ZenTable.push -- Assuming Lua's table.insert is used for push
  }
  
  return instance
end

local tabletest = newTable(1, 2, 3)
tabletest:push(4) -- got integer, expected {integer}
tabletest:forEach(print)