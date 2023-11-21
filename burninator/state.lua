---@type Mq
local mq = require('mq')
local utils = require('utils')

local State = {}

State.ClassInZone = {}

State.Classes = {
	cleric = 'Cleric',
	warrior = 'Warrior',
	paladin = 'Paladin',
	ranger = 'Ranger',
	shadowknight = 'Shadow Knight',
	druid = 'Druid',
	monk = 'Monk',
	rogue = 'Rogue',
	shaman = 'Shaman',
	necromancer = 'Necromancer',
	wizard = 'Wizard',
	magician = 'Magician',
	enchanter = 'Enchanter',
	beastlord = 'Beastlord',
	bard = 'Bard',
}

function State.refreshClassList()
	for key, value in pairs(State.Classes) do
		print('Getting class in zone for ' .. value)
		State.ClassInZone[value] = State.getClassInZone(value)
	end
	print('Dumping Final array')
	utils.dump(State.ClassInZone)

	--print("Printing all shaman")
	--utils.dump(State.ClassInZone.shaman)
end

function State.getClassInZone(class)
	return mq.getFilteredSpawns(function(spawn)
		local isPC = spawn.Type() == 'PC'
		local spawnClass = spawn.Class()
		local inputClass = class
		local matchesClass = spawnClass == inputClass
		local matches = isPC and matchesClass

		return matches
	end)
end

return State
