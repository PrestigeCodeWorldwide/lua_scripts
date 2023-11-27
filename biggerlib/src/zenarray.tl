package.path = package.path .. ';../vendor/?.lua'
local lume = require "lume"

global record ZenArray<T>
  _data: {T}
    
  contains: function(self: ZenArray<T>, value: T): boolean
  remove: function(self: ZenArray<T>, value: T): boolean
  isarray: function(self: ZenArray): boolean
  clear: function(self: ZenArray)  
  match: function(self: ZenArray<T>, func: function(T):boolean): (T, (number | string))
  find: function(self: ZenArray<T>, value: T): number | nil
  count: function(self: ZenArray<T>, predicate: (nil | function(x:T):boolean)): number 
  clone: function(self: ZenArray<T>): ZenArray<T>
  keys: function(self: ZenArray<T>): {number | string}
  forEach: function(self: ZenArray<T>, fn: function(T|any, ...: any), ...: any): ZenArray<T>
  map: function<T,R>(self: ZenArray<T>, fn: lume.MapFunction<T, R>): ZenArray<R> 
  push: function(self: ZenArray<T>, value: T): ZenArray<T>
  insert:  function(self: ZenArray<T>, value: T): ZenArray<T>
  filter: function(self: ZenArray<T>, func: (function(T):boolean), retainkeys: (boolean | nil)): ZenArray<T>
end
	
global function newArray<T>(...: T): ZenArray<T>    	
  	local data = {...} 
	
  	local instance : ZenArray<T> = {	
    -- underlying data
	_data = data,
    
    -- Assigning the existing ZenArray methods to the new instance
    filter = ZenArray.filter,
    contains = ZenArray.contains,
    remove = ZenArray.remove,
    forEach = ZenArray.forEach,
    isarray = ZenArray.isarray,
    clear = ZenArray.clear,
    match = ZenArray.match,
    find = ZenArray.find,
    count = ZenArray.count,
    clone = ZenArray.clone,
    keys = ZenArray.keys,
    map = ZenArray.map,
    push = ZenArray.push,
	insert = ZenArray.insert,
  }
  
  return instance
end
	
    
function ZenArray.map<T, R>(self: ZenArray<T>, fn: lume.MapFunction<T, R>): ZenArray<R>
  	local mappedData = lume.map(self._data, fn)
  	local newZenArray: ZenArray<R> = newArray()
  	newZenArray._data = mappedData as {R}
  	return newZenArray
end
    
    -- Iterates the table t and calls the function fn on each value followed by the supplied additional arguments. 
    -- If fn is a string the method of that name is called for each value. 
    -- The function returns t unmodified.
function ZenArray.forEach<T>(self: ZenArray<T>, fn: function(T|any, ...: any), ...: any): ZenArray<T>
  for _, value in ipairs(self._data) do
    fn(value, ...)
  end
  return self
end
 
function ZenArray.count<T>(self: ZenArray<T>, predicate: (nil | function(x:T):boolean)): number
  return lume.count(self._data, predicate)
end

function ZenArray.keys(self: ZenArray<T>): {number | string}
  return lume.keys(self._data)
end

function ZenArray.clone<T>(self: ZenArray<T>): ZenArray<T>
  return lume.clone(self as {T}) as ZenArray<T>
end

function ZenArray.match<T>(self: ZenArray<T>, func: function(T):boolean): (T, (number | string))
  return lume.match(self._data, func)
end

function ZenArray.insert<T>(self: ZenArray<T>, value: T): ZenArray<T>
  table.insert(self._data, value)
  return self
end

function ZenArray.push<T>(self: ZenArray<T>, value: T): ZenArray<T>
  self:insert(value)
  return self
end

function ZenArray.contains<T>(self: ZenArray<T>, value: T): boolean
  return lume.find(self._data, value) ~= nil
end

function ZenArray.remove<T>(self: ZenArray<T>, value: T): boolean
  local index = lume.find(self._data, value)
  if index then
    table.remove(self._data, index)
    return true
  end
  return false
end 

function ZenArray.isarray(self: ZenArray<T>): boolean
  return lume.isarray(self._data)
end

function ZenArray.clear<T>(self: ZenArray<T>) 
  lume.clear(self._data)
end

function ZenArray.filter<T>(self: ZenArray<T>, func: (function(T): boolean), retainkeys: boolean|nil ): ZenArray<T>  
  local filteredData = lume.filter(self._data, func, retainkeys)
  local newZenArray: ZenArray<T> = newArray()
  newZenArray._data = filteredData as {T}
  return newZenArray
end

function ZenArray.find<T>(self: ZenArray<T>, value: T): number | nil
  return lume.find(self._data, value)
end

return ZenArray