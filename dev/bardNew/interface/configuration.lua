--- @type Mq
local mq = require("mq")
local constants = require("constants")
local logger = require("utils.logger")
local modes = require("mode")

local config = {
	SETTINGS_FILE = ("%s/zenbot_%s_%s.lua"):format(mq.configDir, mq.TLO.EverQuest.Server(), mq.TLO.Me.CleanName()),

	

function config.get(key)
	--print("Getting " .. key)
	return config[key].value
end

function config.set(key, value)
	config[key].value = value
end

function config.getAll()
	local configMap = {}
	for key, cfg in pairs(config) do
		if type(config[key]) == "table" then
			configMap[key] = cfg.value
		end
	end
	return configMap
end

local categories = { "General", "Assist", "Camp", "Burn", "Heal", "Pull", "Tank", "Rest", "Loot", "Debug" }
function config.categories()
	return categories
end

local configByCategory = {
	General = {
		"PAUSED",
	},
	Assist = {
		"ASSIST",
		"AUTOASSISTAT",
		"ASSISTNAMES",
		"SWITCHWITHMA",
		"STICKHOW",
		"RESISTSTOPCOUNT",
	},
	Camp = { "CAMPRADIUS", "CHASETARGET", "CHASEDISTANCE", "CHASEPAUSED" },
	Burn = { "BURNALWAYS", "BURNALLNAMED", "BURNCOUNT", "BURNPCT", "USEGLYPH", "USEINTENSITY" },
	Pull = {
		"PULLRADIUS",
		"PULLLOW",
		"PULLHIGH",
		"PULLMINLEVEL",
		"PULLMAXLEVEL",
		"PULLARC",
		"GROUPWATCHWHO",
		"PULLWITH",
	},
	Heal = {
		"HEALPCT",
		"PANICHEALPCT",
		"HOTHEALPCT",
		"GROUPHEALPCT",
		"GROUPHEALMIN",
		"XTARGETHEAL",
		"REZGROUP",
		"REZRAID",
		"REZINCOMBAT",
		"PRIORITYTARGET",
	},
	Rest = {
		"MEDCOMBAT",
		"RECOVERPCT",
		"MEDMANASTART",
		"MEDMANASTOP",
		"MEDENDSTART",
		"MEDENDSTOP",
		"MANASTONESTART",
		"MANASTONESTARTHP",
		"MANASTONESTOPHP",
		"MANASTONETIME",
	},
	--Loot = { 'LOOTMOBS', 'LOOTCOMBAT' },
	Debug = { "TIMESTAMPS" },
}
function config.getByCategory(category)
	return configByCategory[category]
end

---Get or set the specified configuration option. Currently applies to pull settings only.
---@param name string @The name of the setting.
---@param current_value any @The current value of the specified setting.
---@param new_value string @The new value for the setting.
---@param key string @The configuration key to be set.
function config.getOrSetOption(name, current_value, new_value, key)
	if config[key] == nil then
		return
	end
	if new_value then
		if config[key].options and not config[key].options[new_value] then
			print(logger.logLine("\arInvalid option for \ay%s\ax: \ay%s\ax", key, new_value))
			return
		end
		if type(current_value) == "number" then
			config[key].value = tonumber(new_value) or current_value
		elseif type(current_value) == "boolean" then
			if constants.booleans[new_value] == nil then
				return
			end
			config[key].value = constants.booleans[new_value]
		else
			config[key].value = new_value
		end
		print(logger.logLine("Setting %s to: %s", key, config[key].value))
	else
		print(logger.logLine("%s: %s", name, current_value))
	end
end

---Check whether the specified file exists or not.
---@param file_name string @The name of the file to check existence of.
---@return boolean @Returns true if the file exists, false otherwise.
function config.fileExists(file_name)
	local f = io.open(file_name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

---Load common settings from settings file
---@return table|nil @Returns a table containing the loaded settings file content.
function config.loadSettings()
	if not config.fileExists(config.SETTINGS_FILE) then
		return nil
	end
	local settings = assert(loadfile(config.SETTINGS_FILE))()
	if not settings or not settings.common then
		return settings
	end
	for setting, value in pairs(settings.common) do
		if config[setting] then
			config[setting].value = value
		end
	end
	modes.currentMode = modes.fromString(config.MODE.value)
	logger.timestamps = config.TIMESTAMPS and config.TIMESTAMPS.value or false
	return settings
end

local ignores = {}

---Load mob ignore lists file
function config.loadIgnores()
	local ignore_file = ("%s/%s"):format(mq.configDir, "zen_ignore.lua")
	if config.fileExists(ignore_file) then
		ignores = assert(loadfile(ignore_file))()
	end
end

function config.saveIgnores()
	local ignore_file = ("%s/%s"):format(mq.configDir, "zen_ignore.lua")
	persistence.store(ignore_file, ignores)
end

function config.getIgnores(zone_short_name)
	if not zone_short_name then
		return ignores
	else
		return ignores[zone_short_name:lower()]
	end
end

function config.addIgnore(zone_short_name, mob_name)
	if ignores[zone_short_name:lower()] and ignores[zone_short_name:lower()][mob_name] then
		print(logger.logLine("\at%s\ax already in ignore list for zone \ay%s\az, skipping", mob_name, zone_short_name))
		return
	end
	if not ignores[zone_short_name:lower()] then
		ignores[zone_short_name:lower()] = {}
	end
	ignores[zone_short_name:lower()][mob_name] = true
	print(logger.logLine("Added pull ignore \at%s\ax for zone \ay%s\ax", mob_name, zone_short_name))
	config.saveIgnores()
end

function config.removeIgnore(zone_short_name, mob_name)
	if not ignores[zone_short_name:lower()] or not ignores[zone_short_name:lower()][mob_name] then
		print(
			logger.logLine("\at%s\ax not found in ignore list for zone \ay%s\az, skipping", mob_name, zone_short_name)
		)
		return
	end
	ignores[zone_short_name:lower()][mob_name] = nil
	print(logger.logLine("Removed pull ignore \at%s\ax for zone \ay%s\ax", mob_name, zone_short_name))
	config.saveIgnores()
end

function config.ignoresContains(zone_short_name, mob_name)
	return ignores[zone_short_name:lower()] and ignores[zone_short_name:lower()][mob_name]
end

return config
