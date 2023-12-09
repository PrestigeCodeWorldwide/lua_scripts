local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local package = _tl_compat and _tl_compat.package or package; local table = _tl_compat and _tl_compat.table or table; package.path = package.path .. ';../vendor/?.lua'
local lume = require("lume")

ZenArray = {}


















function newArray(baseMetatable, ...)
   local data = { ... }

   local instance = {

      _data = data,


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

   local arrayWithMetatable = setmetatable(instance, baseMetatable)

   return arrayWithMetatable
end


function ZenArray.map(self, fn)
   local mappedData = lume.map(self._data, fn)
   local newZenArray = newArray()
   newZenArray._data = mappedData
   return newZenArray
end




function ZenArray.forEach(self, fn, ...)
   for _, value in ipairs(self._data) do
      fn(value, ...)
   end
   return self
end

function ZenArray.count(self, predicate)
   return lume.count(self._data, predicate)
end

function ZenArray.keys(self)
   return lume.keys(self._data)
end

function ZenArray.clone(self)
   return lume.clone(self)
end

function ZenArray.match(self, func)
   return lume.match(self._data, func)
end

function ZenArray.insert(self, value)
   table.insert(self._data, value)
   return self
end

function ZenArray.push(self, value)
   self:insert(value)
   return self
end

function ZenArray.contains(self, value)
   return lume.find(self._data, value) ~= nil
end

function ZenArray.remove(self, value)
   local index = lume.find(self._data, value)
   if index then
      table.remove(self._data, index)
      return true
   end
   return false
end

function ZenArray.isarray(self)
   return lume.isarray(self._data)
end

function ZenArray.clear(self)
   lume.clear(self._data)
end

function ZenArray.filter(self, func, retainkeys)
   local filteredData = lume.filter(self._data, func, retainkeys)
   local newZenArray = newArray()
   newZenArray._data = filteredData
   return newZenArray
end

function ZenArray.find(self, value)
   return lume.find(self._data, value)
end

return ZenArray
