local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local ipairs = _tl_compat and _tl_compat.ipairs or ipairs; local table = _tl_compat and _tl_compat.table or table
local lume = require("lume")
local MapFunction = lume.MapFunction






function range(i, to, inc)
   if i == nil then
      return nil
   end

   if to == nil then
      to = i
      i = to == 0 and 0 or (to > 0 and 1 or -1)
   end


   inc = inc or (i < to and 1 or -1)


   i = i - inc
   return function()
      if i == to then
         return nil
      end
      i = i + inc
      return i
   end
end


ZenTable = {}


















function ZenTable.forEach(self, fn, ...)
   for _, value in ipairs(self._data) do
      fn(value, ...)
   end
   return self
end

function ZenTable.count(self, predicate)
   return lume.count(self._data, predicate)
end

function ZenTable.keys(self)
   return lume.keys(self._data)
end

function ZenTable.clone(self)
   return lume.clone(self)
end

function ZenTable.match(self, func)
   return lume.match(self._data, func)
end

function ZenTable.insert(self, value)
   table.insert(self._data, value)
end

function ZenTable.contains(self, value)
   return lume.find(self._data, value) ~= nil
end

function ZenTable.remove(self, value)
   local index = lume.find(self._data, value)
   if index then
      table.remove(self._data, index)
      return true
   end
   return false
end

function ZenTable.map(self, fn)
   local result = {}
   for _, value in ipairs(self._data) do
      table.insert(result, fn(value))
   end
   return { _data = result }
end

function ZenTable.isarray(self)
   return lume.isarray(self._data)
end

function ZenTable.clear(self)
   lume.clear(self._data)
end

function ZenTable.filter(self, func, retainkeys)
   return lume.filter(self._data, func, retainkeys)
end

function ZenTable.find(self, value)
   return lume.find(self._data, value)
end

local function newTable(...)
   local instance = {
      _data = { ... },


      filter = ZenTable.filter,
      contains = ZenTable.contains,
      remove = ZenTable.remove,
      forEach = ZenTable.forEach,
      isarray = ZenTable.isarray,
      clear = ZenTable.clear,
      match = ZenTable.match,
      find = ZenTable.find,
      count = ZenTable.count,
      clone = ZenTable.clone,
      keys = ZenTable.keys,
      map = ZenTable.map,
      push = ZenTable.push,
   }

   return instance
end

local tabletest = newTable(1, 2, 3)
tabletest:push(4)
tabletest:forEach(print)
