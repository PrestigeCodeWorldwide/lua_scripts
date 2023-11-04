---@type Mq
local mq = require 'mq'
local utils = require 'utils'
local settings = require 'settings'
local ui = require 'ui'
local terminate = false
local Commands = {
	reload = "reload",
	pcs = "pcs",
	drive = "drive",
}

local ClassInZone = {}

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

local function refreshClassList()
	for key, value in pairs(Classes) do
		print("Getting class in zone for " .. value)
		ClassInZone[key] = utils.getClassInZone(value)
	end
	print("Dumping Final array")
	utils.dump(ClassInZone)

	print("Printing all shaman")
	utils.dump(ClassInZone.shaman)
end

local function cmd_handler(...)
	local args = { ... }
	if #args < 1 then
		print("Not enough arguments to command")
		return
	end

	local command = args[1]

	if command == Commands.reload then
		-- for reload
		local myScriptName = "zen/burninator"
		mq.cmd('/timed 10 /lua run ' .. myScriptName)
		terminate = true
	elseif command == Commands.pcs then
		refreshClassList()
	elseif command == Commands.drive then
		local opt = args[2]
		if opt == nil then
			local currentDriver = settings.getSettingByName("isDriver")
			print("Current driver is " .. currentDriver)
			settings.updateSettings("isDriver", "on")
		elseif opt == "off" then
			settings.updateSettings("isDriver", "off")
		elseif opt == "on" then
			settings.updateSettings("isDriver", "on")
		end
	end
end


--- Called when you click the burninate button
---comment
---@param line string
---@param spellToCast string
---@param toonToCast string
---@param target MQSpawn|string
local function burninateEventHandler(line, spellToCast, toonToCast, target)
	print("Burninate Event Handler")
	print("Spell to cast: " .. spellToCast)
	print("Toon to cast: " .. toonToCast)
end

local uiEventHandlers = {
	-- Callback triggered on refresh button click
	refresh = refreshClassList,
	burninate = burninateEventHandler,
}


local function main()
	mq.bind("/burn", cmd_handler)
	settings.init()
	-- Meant for "/rs Burninate - Funeral Dirge - Robothaus - test_dummy_01 - false"
	-- or "/rs Burninate - Perseverance - Caelinaex - raid - true" so it casts MGB first
	-- #3# should also allow "raid" as a target
	mq.event('burninate', 'Burninate - #1# - #2# - #3# - #4#', burninateEventHandler)

	ui.init(uiEventHandlers)

	while not terminate do
		mq.doevents()
		mq.delay(50)
	end

	--ui.destroy()
end

main()
