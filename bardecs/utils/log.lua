local inspect = require('utils.inspect')

local log = {}

log.levels = {
	TRACE = 1,
	DEBUG = 2,
	INFO = 3,
	WARN = 4,
	ERROR = 5,
}

-- Default to debug for now
log.level = log.levels.DEBUG

local log_prefix = '\a-t[\ax\ayZenBot\ax\a-t]\ax \aw'

-- Utility function to handle the actual logging with level checking
function _G.output_log(level, ...)
	if level < log.level then return end -- If the level is too high, don't log
	local timestampPrefix = log.timestamps and '\a-w[' .. os.date('%X') .. ']\ax' or ''
	local levelColor = '\ag'          -- Default to green for all levels except WARN and ERROR

	if level == log.levels.ERROR then
		levelColor = '\ar' -- Red for ERROR
	elseif level == log.levels.WARN then
		levelColor = '\ay' -- Yellow for WARN
	end

	local message = string.format(...)
	local output = timestampPrefix .. log_prefix .. levelColor .. message .. '\ax'
	print(output)
end

-- Define the log functions for each level
function _G.trace(...)
	output_log(log.levels.TRACE, ...)
end

function _G.debug(...)
	output_log(log.levels.DEBUG, ...)
end

function _G.info(...)
	output_log(log.levels.INFO, ...)
end

function _G.warn(...)
	output_log(log.levels.WARN, ...)
end

function _G.error(...)
	output_log(log.levels.ERROR, ...)
end

function _G.inspect(...)
    local args = { ... }
    info(inspect.inspect(args))
end

-- Alias dump to inspect for convenience
_G.dump = _G.inspect

-- Function to set the current logging level
function log.set_level(level)
	if log.levels[level] then
		log.level = log.levels[level]
	else
		error("Invalid logging level: " .. tostring(level))
	end
end

-- Function to get the name of the current logging level
function log.get_level_name()
	for name, level in pairs(log.levels) do
		if level == log.level then
			return name
		end
	end
	return "UNKNOWN"
end

return log
