---@type Mq
local mq = require("mq")
local BL = require("biggerlib")
local State = require("state")

local settings = { boolSettings = {} }

local toon = mq.TLO.Me.Name() or ""
local settingsPath = "BurninateConfig_" .. toon .. ".lua"

function settings.listCommands()
	print("\at[Burninate]\aw ---- \atAll available commands \aw----")
	print("\at[Burninate]\aw Type \ay/burn help \aw to repeat this list")
	print("\at[Burninate]\aw Type \ay/burn resetdefaults \aw to reset all settings")

	print("\at[Burninate]\ao Pausing the script:")
	print("\at[Burninate]\ay /burn pause \aw(toggles pause)")
	print("\at[Burninate]\ay /burn pause \agon\aw/\aroff\aw (turn pause on or off)")

	print("\at[Burninate]\ao /burn do <spell> \aw Starts next burn of type")
	print("\at[Burninate]\ao /burn refresh \aw Refreshes cached lists, run before starting fight")
end

function settings.saveSettings()
	mq.pickle(settingsPath, { settings = settings })
end

function settings.getSettingByName(name)
	return settings[name]
end

function settings.updateSettings(cmd, val)
	settings[cmd] = val
	print("\at[Burninate] \aoTurning \ay", cmd, " \ag ", BL.UI.GetOnOffColor(val))
	settings.saveSettings()
end

function settings.setDefaults(s)
	if s == "all" then
		print("\at[Burninate] \aw---- \at Setting toggles to default values \aw----")
	end
	if s == "all" then
		State.driver = "off"
	end
	for k, v in pairs(settings) do
		print("\at[Burninate]\ao ", k, ": \ay", BL.UI.GetOnOffColor(v))
	end
	settings.saveSettings()
end

function settings.boolizeSettings()
	for k, v in pairs(settings) do
		if v == "on" then
			settings.boolSettings[k] = true
		elseif v == "off" then
			settings.boolSettings[k] = false
		end
	end
end

local function mergeSettings(settings, newSettings)
	for key, value in pairs(newSettings) do
		-- If the key is a table and exists in both settings and newSettings, recursively merge
		if type(value) == "table" and type(settings[key]) == "table" then
			mergeSettings(settings[key], value)
		else
			settings[key] = value
		end
	end
end

function settings.init()
	local configData, error = loadfile(mq.configDir .. "/" .. settingsPath) -- read config file
	--utils.dump(configData, "Config Data from file")
	if error then -- failed to read the config file, create it using pickle
		print("\at[Burninate] \ay Creating config file...")
		settings.setDefaults("all")
		settings.listCommands()
	elseif configData then -- file loaded, put content into your config table
		print("Config data received no error")

		local conf = configData()
		BL.log.dump(conf, "Config Data from file")
		print("After configData called")
		-- instead of replacing settings, i want to merge them
		mergeSettings(settings, conf.settings)
		BL.log.dump(settings, "ConfSettings transferred")

		--settings.setDefaults() -- check for missing settings
		--settings.listCommands()
	end
	settings.boolizeSettings()
	State.paused = false
end

function settings.boolSync()
	for k, v in pairs(settings.boolSettings) do
		if settings.boolSettings[k] == true and settings[k] == "off" then
			settings.updateSettings(k, "on")
		elseif settings.boolSettings[k] == false and settings[k] == "on" then
			settings.updateSettings(k, "off")
		end
	end
end

return settings

-- /multiline ; /squelch /backoff ; /squelch /end ; /squelch /attack off ; /squelch /afollow off  ; /squelch /stick off ; /squelch /moveto off ; /squelch /nav stop ; /squelch /play off ; /echo BACKED OFF
