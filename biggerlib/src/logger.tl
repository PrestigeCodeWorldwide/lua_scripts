--package.path = package.path .. ";../vendor/busted/?.lua"
--package.path = package.path .. ";../vendor/?.lua"

--local lume = require("lume")
--local MapFunction = lume.MapFunction

-- Region: Logging
local log_prefix = "\a-t[\ax\ayBL\ax\a-t]\ax \aw"
local timestamps = false
-- Logging

--- Simple output log formatted somewhat nicely
global function logInfo(...: string)
	local timestampPrefix = timestamps and "\a-w[" .. os.date("%X") .. "]\ax" or ""
	local output = string.format(timestampPrefix .. log_prefix .. string.format(...) .. "\ax")
	print(output)	
end

local function dumpRecurse(data: any, logPrefix: string|nil, depth: integer|nil): string
		if data == nil then
			return "NIL"
		end
		if type(data) == "table" then
			local tabledata = data as table
			local output = "{"
			for key, value in pairs(tabledata) do
				output = output
					.. string.format(
						"\n%s[%s] = %s",
						string.rep(" ", depth or 0),
						tostring(key),
						dumpRecurse(value, logPrefix, (depth or 0) + 4)
					)
			end
			return output .. "\n" .. string.rep(" ", (depth or 0) - 4) .. "}"
		else
			return tostring(data)
		end
	end

--- This function is used to recursively dump data, useful for debugging.
--- @param data any The data to be dumped. This can be of any type.
--- @param logPrefix string|nil A string that is prefixed to each line of the dump. This is optional.
--- @param depth integer|nil An integer representing the current depth of the recursion. This is optional and is used for indentation.
global function dump(data: any, logPrefix: string|nil, depth: integer|nil)
	if logPrefix == nil then
		logPrefix = "DUMP"
	end
	print(logPrefix .. " : " .. dumpRecurse(data, logPrefix, depth))
end

-- EndRegion: Logging



--local tabletest = newTable(1, 2, 3)
--tabletest:push(4) -- got integer, expected {integer}
--tabletest:forEach(print)
