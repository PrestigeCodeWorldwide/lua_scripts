---@type Mq
local mq = require 'mq'

local utils = {}

---Recursively dumps a data structure
---@param data table|string|number to dump
---@param printPrefix string|nil This string, if any, is printed before the dump
---@param indent number|nil The number of spaces to indent the dumps
function utils.dump(data, printPrefix, indent)
	assert(data ~= nil, "data cannot be nil")
	local indent = indent or 2
	local indentStr = string.rep(" ", indent)

	if printPrefix then print(printPrefix) end

	if type(data) == "table" then
		for k, v in pairs(data) do
			print(indentStr .. tostring(k) .. ": ")
			utils.dump(v, nil, indent + 2)
		end
	else
		print(tostring(data) .. "\n")
	end
end

function utils.color(val)
	if val == 'on' then
		val = '\agon'
	elseif val == 'off' then
		val = '\aroff'
	end
	return val
end

function utils.notNil(arg)
	if arg ~= nil then
		return arg
	else
		return 0
	end
end

return utils
