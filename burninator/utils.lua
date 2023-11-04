---@type Mq
local mq = require 'mq'

local function dump(data, indent)
	indent = indent or 2
	local indentStr = string.rep(" ", indent)

	if type(data) == "table" then
		for k, v in pairs(data) do
			print(indentStr .. tostring(k) .. ": ")
			dump(v, indent + 2)
		end
	else
		print(tostring(data) .. "\n")
	end
end

local function getClassInZone(class)
	return mq.getFilteredSpawns(function(spawn)
		local isPC = spawn.Type() == "PC"
		local spawnClass = spawn.Class()
		local inputClass = class
		local matchesClass = spawnClass == inputClass
		local matches = isPC and matchesClass

		return matches
	end)
end

local function color(val)
	if val == 'on' then
		val = '\agon'
	elseif val == 'off' then
		val = '\aroff'
	end
	return val
end

local function notNil(arg)
	if arg ~= nil then
		return arg
	else
		return 0
	end
end

local Classes = {
	cleric = "Cleric",
	warrior = "Warrior",
	paladin = "Paladin",
	ranger = "Ranger",
	shadowknight = "Shadow Knight",
	druid = "Druid",
	monk = "Monk",
	rogue = "Rogue",
	shaman = "Shaman",
	necromancer = "Necromancer",
	wizard = "Wizard",
	magician = "Magician",
	enchanter = "Enchanter",
	beastlord = "Beastlord",
	bard = "Bard",
}

return {
	dump = dump,
	getClassInZone = getClassInZone,
	color = color,
	notNil = notNil,
	Classes = Classes,
}
