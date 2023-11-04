---@type Mq
local mq = require 'mq'
local utils = require 'utils'

local settings = { Pause = false }
local boolSettings = {}

local toon = mq.TLO.Me.Name() or ''
local settingsPath = 'BurninateConfig_' .. toon .. '.lua'

SPELLS_BY_CLASS = {
    ['Cleric'] = {},
	['Shaman'] = {},
	['Druid'] = {},
	['Wizard'] = {},
	['Magician'] = {},
	['Enchanter'] = {},
	['Necromancer'] = {},
	['Warrior'] = {},
	['Paladin'] = {},
	['Ranger'] = {},
	['Shadow Knight'] = {},
	['Monk'] = {},
	['Rogue'] = {},
	['Bard'] = {},
	['Beastlord'] = {},	
}

local function listCommands()
	print('\at[Burninate]\aw ---- \atAll available commands \aw----')
	print('\at[Burninate]\aw Type \ay/burn help \aw to repeat this list')
	print('\at[Burninate]\aw Type \ay/burn resetdefaults \aw to reset all settings')

	print('\at[Burninate]\ao Pausing the script:')
	print('\at[Burninate]\ay /burn pause \aw(toggles pause)')
	print('\at[Burninate]\ay /burn pause \agon\aw/\aroff\aw (turn pause on or off)')

	print('\at[Burninate]\ao /burn do <spell> \aw Starts next burn of type')
	print('\at[Burninate]\ao /burn refresh \aw Refreshes cached lists, run before starting fight')
end

local function saveSettings()
	mq.pickle(settingsPath, { settings = settings })
end

local function getSettingByName(name)
	return settings[name]
end

local function updateSettings(cmd, val)
	settings[cmd] = val
	print('\at[Burninate] \aoTurning \ay', cmd, ' \ag ', utils.color(val))
	saveSettings()
end

local function setDefaults(s)
	if s == 'all' then print('\at[Burninate] \aw---- \at Setting toggles to default values \aw----') end
	if s == 'all' or settings.isDriver == nil then settings.isDriver = 'off' end
	for k, v in pairs(settings) do print('\at[Burninate]\ao ', k, ": \ay", utils.color(v)) end
	saveSettings()
end

local function boolizeSettings()
	for k, v in pairs(settings) do
		if v == 'on' then
			boolSettings[k] = true
		elseif v == 'off' then
			boolSettings[k] = false
		end
	end
end

local function init()
	local configData, error = loadfile(mq.configDir .. '/' .. settingsPath) -- read config file

	if error then                                                        -- failed to read the config file, create it using pickle	
		print('\at[Burninate] \ay Creating config file...')
		setDefaults('all')
		listCommands()
	elseif configData then -- file loaded, put content into your config table
		local conf = configData()
		settings = conf.settings

		setDefaults() -- check for missing settings
		listCommands()
	end
	boolizeSettings()
end

local function togglePause(val)
	if val == 'on' then
		settings.Pause = true
	elseif val == 'off' then
		settings.Pause = false
		print('\at[Burninate] \agUNPAUSED')
	else
		if settings.Pause == true then
			settings.Pause = false
			print('\at[Burninate] \agUNPAUSED')
		else
			print('\at[Burninate] \agPAUSED')
			settings.Pause = true
		end
	end
end

local function boolSwitch()
	for k, v in pairs(boolSettings) do
		if boolSettings[k] == true and settings[k] == 'off' then
			updateSettings(k, 'on')
		elseif boolSettings[k] == false and settings[k] == 'on' then
			updateSettings(k, 'off')
		end
	end
end


return {
	init = init,
	updateSettings = updateSettings,
	setDefaults = setDefaults,
	saveSettings = saveSettings,
	listCommands = listCommands,
	togglePause = togglePause,
	getSettingByName = getSettingByName,
	settings = settings,
	boolSettings = boolSettings,
	boolSwitch = boolSwitch,
}

-- /multiline ; /squelch /backoff ; /squelch /end ; /squelch /attack off ; /squelch /afollow off  ; /squelch /stick off ; /squelch /moveto off ; /squelch /nav stop ; /squelch /play off ; /echo BACKED OFF
