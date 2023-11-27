local _tl_compat; if (tonumber((_VERSION or ''):match('[%d.]*$')) or 0) < 5.3 then local p, m = pcall(require, 'compat53.module'); if p then _tl_compat = m end end; local os = _tl_compat and _tl_compat.os or os; local pairs = _tl_compat and _tl_compat.pairs or pairs; local string = _tl_compat and _tl_compat.string or string; local log_prefix = "\a-t[\ax\ayBL\ax\a-t]\ax \aw"
local timestamps = false


function logInfo(...)
   local timestampPrefix = timestamps and "\a-w[" .. os.date("%X") .. "]\ax" or ""
   local output = string.format(timestampPrefix .. log_prefix .. string.format(...) .. "\ax")
   print(output)
end

local function _dumpRecurse(data, logPrefix, depth)
   if data == nil then
      return "NIL"
   end
   if type(data) == "table" then
      local tabledata = data
      local output = "{"
      for key, value in pairs(tabledata) do
         output = output ..
         string.format(
         "\n%s[%s] = %s",
         string.rep(" ", depth or 0),
         tostring(key),
         _dumpRecurse(value, logPrefix, (depth or 0) + 4))

      end
      return output .. "\n" .. string.rep(" ", (depth or 0) - 4) .. "}"
   else
      return tostring(data)
   end
end





function dump(data, logPrefix, depth)
   if logPrefix == nil then
      logPrefix = "DUMP"
   end
   print(logPrefix .. " : " .. _dumpRecurse(data, logPrefix, depth))
end
