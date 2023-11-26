local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local assert = _tl_compat and _tl_compat.assert or assert; local tl = require("tl")
tl.loader()

require('logger')











































Option = {}





























function Option:__eq(opt)
   if self == nil and opt == nil then
      return true
   end

   if self:IsNone() and opt:IsNone() then
      return true
   elseif self:IsSome() and opt:IsSome() then
      return self.value == opt.value
   else
      return false
   end
end







function Option:__tostring()
   if self == nil then return "nil" end

   if self:IsSome() then
      return "Some(" .. tostring(self.value) .. ")"
   else
      return "None"
   end
end



None = setmetatable({ value = nil, ClassName = "Option" }, { __index = Option, __tostring = Option.__tostring, __eq = Option.__eq })
Option.None = setmetatable({ value = nil, ClassName = "Option" }, { __index = Option, __tostring = Option.__tostring, __eq = Option.__eq })

function Option.new(value)
   if value == nil then return Option.None end

   return setmetatable({ value = value, ClassName = "Option" }, { __index = Option, __tostring = Option.__tostring, __eq = Option.__eq })
end










function Option:UnwrapOr(default)
   if self:IsSome() then
      return self:Unwrap()
   else
      return default
   end
end




function Option.Some(value)
   assert(value ~= nil, "Option.Some() value cannot be nil")
   return Option.new(value)
end




function Some(value)
   return Option.Some(value)
end




function Option:IsSome()
   return self.value ~= nil
end




function Option.Wrap(value)
   if value == nil then
      return Option.None
   else
      return Option.Some(value)
   end
end





function Option.Is(value)
   if type(value) == "table" then
      return true
   end
   return false
end



function Option.Assert(obj)
   assert(Option.Is(obj), "Result was not of type Option")
end




function Option.IsNone(self)
   return self.value == nil
end






function Option.Expect(self, msg)
   assert(self:IsSome(), msg)
   return self.value
end






function Option.ExpectNone(self, msg)
   assert(self:IsNone(), msg)
end





function Option.Unwrap(self)
   return self:Expect("Cannot unwrap an Option of None type")
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






function Option.Contains(self, value)
   return self:IsSome() and self.value == value
end






function Option.Filter(self, predicate)
   if self:IsNone() or not predicate(self.value) then
      return Option.None
   else
      return self
   end
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
      Value = self.value,
   }
end


return Option
