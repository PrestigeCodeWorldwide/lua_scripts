local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local assert = _tl_compat and _tl_compat.assert or assert; local tl = require("tl")
tl.loader()

require('logger')









































Option = {}






































function Option:IsSome()
   return self._s
end

function Option.new(value)
   local self = setmetatable({
      ClassName = "Option",
      _v = value,
      _s = value ~= nil,
   }, {
      __index = Option,
   })



   return self
end

function Some(value)
   assert(value ~= nil, "Option.Some() value cannot be nil")
   return Option.Some(value)
end
Option.None = Option.new(nil)

None = Option.None





function Option.Some(value)
   assert(value ~= nil, "Option.Some() value cannot be nil")
   return Option.new(value)
end






function Option.Match(self, matches)
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







function Option.Wrap(value)
   if value == nil then
      return Option.None
   else
      return Option.Some(value)
   end
end




function Option.Is(obj)
   return type(obj) == "table" and getmetatable(obj) == Option
end



function Option.Assert(obj)
   assert(Option.Is(obj), "Result was not of type Option")
end





function Option.Deserialize(data)
   assert(data.ClassName == "Option", "Invalid data for deserializing Option")
   if data.Value == nil then
      return Option.None
   else
      return Option.Some(data.Value)
   end
end





function Option.Serialize(self)
   return {
      ClassName = self.ClassName,
      Value = self._v,
   }
end






function Option.IsNone(self)
   return not self._s
end






function Option.Expect(self, msg)
   assert(self:IsSome(), msg)
   return self._v
end






function Option.ExpectNone(self, msg)
   assert(self:IsNone(), msg)
end





function Option.Unwrap(self)
   return self:Expect("Cannot unwrap an Option of None type")
end






function Option.UnwrapOr(self, default)
   if self:IsSome() then
      return self:Unwrap()
   else
      return default
   end
end






function Option.UnwrapOrElse(self, defaultFunc)
   if self:IsSome() then
      return self:Unwrap()
   else
      return defaultFunc()
   end
end






function Option.And(self, optB)
   if self:IsSome() then
      return optB
   else
      return Option.None
   end
end






function Option.AndThen(self, andThenFunc)
   if self:IsSome() then
      return andThenFunc(self:Unwrap())
   else
      return Option.None
   end
end






function Option.Or(self, optB)
   if self:IsSome() then
      return self
   else
      return optB
   end
end






function Option.OrElse(self, orElseFunc)
   if self:IsSome() then
      return self
   else
      local result = orElseFunc()
      Option.Assert(result)
      return result
   end
end






function Option.XOr(self, optB)
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






function Option.Filter(self, predicate)
   if self:IsNone() or not predicate(self._v) then
      return Option.None
   else
      return self
   end
end






function Option.Contains(self, value)
   return self:IsSome() and self._v == value
end





function Option.__tostring(self)
   if self == nil then return "nil" end
   print(self)
   if self:IsSome() then
      return "Option<" .. type(self._v) .. ">"
   else
      return "Option<None>"
   end
end






function Option.__eq(self, opt)
   print("Checking equality")
   if Option.Is(opt) then
      if self:IsSome() and opt:IsSome() then
         return self:Unwrap() == opt:Unwrap()
      elseif self:IsNone() and opt:IsNone() then
         return true
      end
   end
   return false
end






















return Option
