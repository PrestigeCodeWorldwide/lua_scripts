local inspect = require('utils.inspect')

local logger = {
	flags = {
		routines = {
			assist = false,
			buff = false,
			camp = false,
			cure = false,
			debuff = false,
			events = false,
			heal = false,
			mez = false,
			movement = false,
			pull = false,
			tank = false
		},
		class = {
			ae = false,
			aggro = false,
			burn = false,
			cast = false,
			findspell = false,
			managepet = false,
			mash = false,
			ohshit = false,
			recover = false,
			rest = false
		},
		ability = { validation = false, all = false, spell = false, aa = false, disc = false, item = false, skill = false },
		common = { chase = false, cast = false, memspell = false, misc = false, loot = false },
		zen = { main = false, commands = false, configuration = false },
		announce = { spell = true, aa = true, disc = true, item = true, skill = true },
	},
	timestamps = false,
}

local log_prefix = '\a-t[\ax\ayZenBot\ax\a-t]\ax \aw'

function logger.logLine(...)
	local timestampPrefix = logger.timestamps and '\a-w[' .. os.date('%X') .. ']\ax' or ''
	return string.format(timestampPrefix .. log_prefix .. string.format(...) .. '\ax')
end

function logger.info(...)
	local timestampPrefix = logger.timestamps and '\a-w[' .. os.date('%X') .. ']\ax' or ''
	local output = string.format(timestampPrefix .. log_prefix .. string.format(...) .. '\ax')
	print(output)
	return output
end

function logger.dump(data, depth)
	if type(data) == 'table' then
		local output = '{'
		for key, value in pairs(data) do
			output = output ..
				string.format('\n%s%s = %s', string.rep(' ', depth or 4), key, logger.dump(value, (depth or 4) + 4))
		end
		return output .. '\n' .. string.rep(' ', depth or 4) .. '}'
	else
		return tostring(data)
	end
end

function logger.inspect(...)
	local args = { ... }
	logger.info(inspect.inspect(args))
end

function logger.putLogData(message, key, value, separator)
	return string.format('%s%s%s=%s', message, separator or ' ', key, value)
end

function logger.putAllLogData(message, data, separator)
	for key, value in pairs(data) do
		message = message .. string.format('%s%s=%s', separator or ' ', key, value)
	end
	return message
end

---The formatted string and zero or more replacement variables for the formatted string.
---@vararg string
function logger.debug(debug_flag, ...)
	if debug_flag then print(logger.logLine(...)) end
end

--[[
local msg = logger.logLine('testing %s', '123')
msg = logger.putLogData(msg, 'a', 'b')
print(msg)
local data = {c='d',e=1}
msg = logger.putAllLogData(msg, data, '\n')
print(msg)
]]

return logger
