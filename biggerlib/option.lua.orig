local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local assert = _tl_compat and _tl_compat.assert or assert











































































































































Option = {}



































function Option._new(value)
   local optionInstance = {
      ClassName = "Option",
      _v = value,
      _s = value ~= nil,

   }

   setmetatable(optionInstance, {
      __call = function(_self, optionValue)
         local newOption = Option._new(optionValue)
         return newOption
      end,
   })
   return optionInstance
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

local None = Option._new(nil)




function Option.Some(value)
   assert(value ~= nil, "Option.Some() value cannot be nil")
   return Option._new(value)
end




function Option.Wrap(value)
   if value == nil then
      return None
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
      return None
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




function Option.IsSome(self)
   return self._s
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
      return None
   end
end






function Option.AndThen(self, andThenFunc)
   if self:IsSome() then
      return andThenFunc(self:Unwrap())
   else
      return None
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
      return None
   elseif someOptA then
      return self
   else
      return optB
   end
end






function Option.Filter(self, predicate)
   if self:IsNone() or not predicate(self._v) then
      return None
   else
      return self
   end
end






function Option.Contains(self, value)
   return self:IsSome() and self._v == value
end





function Option.__tostring(self)
   if self:IsSome() then
      return "Option<" .. type(self._v) .. ">"
   else
      return "Option<None>"
   end
end






function Option.__eq(self, opt)
   if Option.Is(opt) then
      if self:IsSome() and opt:IsSome() then
         return self:Unwrap() == opt:Unwrap()
      elseif self:IsNone() and opt:IsNone() then
         return true
      end
   end
   return false
end

Option.None = None
