local Log = {}
local function _printOutput(logPrefix, ...)
	logPrefix = logPrefix or ""
	local output = string.format(logPrefix .. string.format(...) .. "\ax")
	print(output)
end

--- Prints to MQ Console in green with prefix of INFO
function info(...)
	local logPrefix = "\ag[INFO] "
	return _printOutput(logPrefix, ...)
end

--- Prints to MQ Console in yellow with prefix of WARN
function warn(...)
	local logPrefix = "\ay[WARN] "
	return _printOutput(logPrefix, ...)
end

--- Prints to MQ Console in red with prefix of ERROR
local function logerror(...)
	local logPrefix = "\ar[ERROR] "
	_printOutput(logPrefix, ...)
	error(...)
end

local function _dumpRecurse(tabledata, logPrefix, depth)
	if tabledata == nil then
		return "NIL"
	end
	if type(tabledata) == "table" then
		local output = "{"
		for key, value in pairs(tabledata) do
			output = output
				.. string.format(
					"\n%s[%s] = %s",
					string.rep(" ", depth or 0),
					tostring(key),
					_dumpRecurse(value, logPrefix, (depth or 0) + 4)
				)
		end
		return output .. "\n" .. string.rep(" ", (depth or 0) - 4) .. "}"
	else
		return tostring(tabledata)
	end
end

--- Developer utility dump function.  Prints absolutely any lua variable in human-readable fashion to the MQ console
function dump(data, logPrefix, depth)
	if logPrefix == nil then
		logPrefix = "DUMP"
	end
	print(logPrefix .. " : " .. _dumpRecurse(data, logPrefix, depth))
end

Log = {
	info = info,
	warn = warn,
	logerror = logerror,
	dump = dump,
}

return Log
