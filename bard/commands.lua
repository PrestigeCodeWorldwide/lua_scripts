--- @type Mq
local mq = require('mq')
local lists = require('data.lists')
local logger = require('utils.logger')
local timer = require('utils.timer')
local config = require('configuration')
local state = require('state')

local zen
local commands = {
	help = {
		{ command = 'help', tip = 'Output the help text' },
		{ command = 'burnnow', tip = 'Activate burn abilities' },
		{ command = 'pause [on|1|off|0]', tip = 'Pause or resume the script' },
		{ command = 'show', tip = 'Display the UI window' },
		{ command = 'hide', tip = 'Hide the UI window' },
		{ command = 'mode [mode]', tip = 'Set the current mode of the script. Valid Modes:\n0|manual|1|assist|2|chase|3|vorpal|4|tank|5|pullertank|6|puller|7|huntertank' },
		{ command = 'resetcamp', tip = 'Reset the centerpoint of the camp to your current X,Y,Z coordinates' },
		{ command = 'addclicky <mash|burn|buff|heal>', tip = 'Adds the currently held item to the clicky group specified' },
		{ command = 'removeclicky', tip = 'Removes the currently held item from clickies' },
		{ command = 'listclickies', tip = 'Displays the list of added clickies' },
		{ command = 'door', tip = 'Click the nearest door' },
		{ command = 'ignore', tip = 'Adds the targeted mob to the ignore list for the current zone' },
		{ command = 'unignore', tip = 'Removes the targeted mob from the ignore list for the current zone' },
		{ command = 'switchwithma', tip = 'Toggle switching target with MA' },
		{ command = 'assistat', tip = 'Sets mob hp for assist to start (0-100)' },
	}
}

function commands.init(_aqo)
	zen = _aqo
	
	--void CwtnControl::Pause() {
	--	boxrRunCommandf("/{} pause on", GetClassCommand());
	--}
	--
	--void CwtnControl::Unpause() {
	--	boxrRunCommandf("/{} pause off", GetClassCommand());
	--}
	--
	--void CwtnControl::Chase() {
	--	boxrRunCommandf("/{} mode chase", GetClassCommand());
	--}
	--
	--void CwtnControl::Camp() {
	--	boxrRunCommandf("/{} mode assist", GetClassCommand());
	--	boxrRunCommandf("/{} resetcamp", GetClassCommand());
	--}
	--
	--void CwtnControl::Manual() {
	--	boxrRunCommandf("/{} mode manual", GetClassCommand());
	--}
	--
	--void CwtnControl::BurnNow() {
	--	boxrRunCommandf("/{} BurnNow", GetClassCommand());
	--}
	
	mq.bind('/zen', commands.commandHandler)
	mq.bind('/brd', commands.commandHandler)
	--mq.bind('/cwtn', commands.commandHandler)
	--mq.bind(('/%s'):format(zen.state.class), commands.commandHandler)
	mq.bind('/nowcast', commands.nowcastHandler)
	
	
end

---Display help information for the script.
local function showHelp()
	local myClass = mq.TLO.Me.Class.ShortName():lower()
	local prefix = '\n- /' .. zen.state.class .. ' '
	local output = logger.logLine('ZEN Bot 1.0\n')
	output = output .. '\ayCommands:\aw'
	for _, command in ipairs(commands.help) do
		output = output .. prefix .. command.command .. ' -- ' .. command.tip
	end
	for _, category in ipairs(config.categories()) do
		output = output .. '\n\ay' .. category .. ' configuration:\aw'
		for _, key in ipairs(config.getByCategory(category)) do
			local cfg = config[key]
			if type(cfg) == 'table' and (not cfg.classes or cfg.classes[myClass]) then
				output = output .. prefix .. key .. ' <' .. type(cfg.value) .. '> -- ' .. cfg.tip
			end
		end
	end
	output = output .. '\n\ayClass Configuration\aw'
	for key, value in pairs(zen.class.OPTS) do
		local valueType = type(value.value)
		if valueType == 'string' or valueType == 'number' or valueType == 'boolean' then
			output = output .. prefix .. key .. ' <' .. valueType .. '>'
			if value.tip then
				output = output .. ' -- ' .. value.tip
			end
		end
	end
	output = output .. '\n\ayGear Check:\aw /tell <name> gear <slotname> -- Slot Names: ' .. lists.slotList
	output = output .. '\n\ayBuff Begging:\aw /tell <name> <alias> -- Aliases: '
	for alias, _ in pairs(zen.class.requestAliases) do
		output = output .. alias .. ', '
	end
	output = (output .. '\ax'):gsub('cls', zen.state.class)
	-- output is too long for the boring old chat window
	if not mq.TLO.Plugin.IsLoaded('MQ2ChatWnd')() then
		print(output)
	end
end

---Process binding commands.
---@vararg string @The input given to the bind command.
function commands.commandHandler(...)
	local args = { ... }
	if not args[1] then
		showHelp()
		return
	end

	local opt = args[1]:lower()
	local new_value = args[2] and args[2]:lower()
	local configName = config.getNameForAlias(opt)
	if opt == 'help' then
		showHelp()
	elseif opt == 'restart' then
		mq.cmd('/multiline ; /lua stop zen ; /timed 5 /lua run zen')
	elseif opt == 'debug' then
		local section = args[2]
		local subsection = args[3]
		if logger.flags[section] and logger.flags[section][subsection] ~= nil then
			logger.flags[section][subsection] = not logger.flags[section][subsection]
		end
	elseif opt == 'sell' and not new_value then
		zen.loot.sellStuff()
	elseif opt == 'burnnow' then
		zen.state.burnNow = true
		if new_value == 'quick' or new_value == 'long' then
			zen.state.burn_type = new_value
		end
	elseif opt == 'preburn' then
		if zen.class.preburn then
			zen.class.preburn()
		end
	elseif opt == 'pause' then
		if not new_value then
			zen.state.paused = not zen.state.paused
			if zen.state.paused then
				zen.state.resetCombatState()
				mq.cmd('/stopcast')
				mq.cmd('/medley stop')
				mq.delay(5)
				mq.cmd('/medley stop')
			end
		else
			if lists.booleans[new_value] == nil then
				return
			end
			zen.state.paused = lists.booleans[new_value]
			if zen.state.paused then
				zen.state.resetCombatState()
				mq.cmd('/stopcast')
			else
				zen.camp.setCamp()
			end
		end
	elseif opt == 'show' then
		zen.ui.toggleGUI(true)
	elseif opt == 'hide' then
		zen.ui.toggleGUI(false)
	elseif opt == 'mode' then
		if new_value then
			config.set('MODE', zen.mode.fromString(new_value) or config.get('MODE'))
			zen.state.resetCombatState()
		else
			print(logger.logLine('Mode: %s', config.get('MODE'):getName()))
		end
		zen.camp.setCamp()
	elseif opt == 'resetcamp' then
		zen.camp.setCamp(true)
	elseif opt == 'campradius' or opt == 'radius' or opt == 'pullarc' then
		config.getOrSetOption(opt, config.get(configName), new_value, configName)
		zen.camp.setCamp()
	elseif opt == 'timestamps' then
		config.getOrSetOption(opt, config.get(configName), new_value, configName)
		logger.timestamps = config.get(configName)
	elseif configName then
		config.getOrSetOption(opt, config.get(configName), new_value, configName)
	elseif opt == 'groupwatch' and lists.groupWatchOptions[new_value] then
		config.getOrSetOption(opt, config.get(configName), new_value, configName)
	elseif opt == 'assist' then
		if new_value and lists.assists[new_value] then
			config.set('ASSIST', new_value)
		end
		print(logger.logLine('assist: %s', config.get('ASSIST')))
	elseif opt == 'ignore' then
		local zone = mq.TLO.Zone.ShortName()
		if new_value then
			config.addIgnore(zone, args[2]) -- use not lowercased value
		else
			local target_name = mq.TLO.Target.CleanName()
			if target_name then
				config.addIgnore(zone, target_name)
			end
		end
	elseif opt == 'unignore' then
		local zone = mq.TLO.Zone.ShortName()
		if new_value then
			config.removeIgnore(zone, args[2]) -- use not lowercased value
		else
			local target_name = mq.TLO.Target.CleanName()
			if target_name then
				config.removeIgnore(zone, target_name)
			end
		end
	elseif opt == 'addclicky' then
		local clickyType = new_value
		local itemName = mq.TLO.Cursor()
		if itemName then
			local clicky = { name = itemName, clickyType = clickyType }
			zen.class.addClicky(clicky)
			zen.class.saveSettings()
		else
			print(logger.logLine('addclicky Usage:\n\tPlace clicky item on cursor\n\t/%s addclicky category\n\tCategories: burn, mash, heal, buff', zen.state.class))
		end
	elseif opt == 'removeclicky' then
		local itemName = mq.TLO.Cursor()
		if itemName then
			zen.class.removeClicky(itemName)
			zen.class.saveSettings()
		else
			print(logger.logLine('removeclicky Usage:\n\tPlace clicky item on cursor\n\t/%s removeclicky', zen.state.class))
		end
	elseif opt == 'listclickies' then
		local clickies = ''
		for clickyName, clickyType in pairs(zen.class.clickies) do
			clickies = clickies .. '\n- ' .. clickyName .. ' (' .. clickyType .. ')'
		end
		print(logger.logLine('Clickies: %s', clickies))
	elseif opt == 'invis' then
		if zen.class.invis then
			zen.class.invis()
		end
	elseif opt == 'tribute' then
		zen.common.toggleTribute()
	elseif opt == 'bark' then
		local repeatstring = ''
		for i = 2, #args do
			repeatstring = repeatstring .. ' ' .. args[i]
		end
		mq.cmdf('/dgga /say %s', repeatstring)
	elseif opt == 'force' then
		zen.assist.forceAssist(new_value)
	elseif opt == 'door' then
		mq.cmd('/doortarget')
		mq.delay(50)
		mq.cmd('/click left door')
	elseif opt == 'manastone' then
		local manastone = mq.TLO.FindItem('Manastone')
		if not manastone() then
			return
		end
		local manastoneTimer = zen.timer:new(5000)
		while mq.TLO.Me.PctHPs() > 50 and mq.TLO.Me.PctMana() < 90 do
			mq.cmd('/useitem Manastone')
			if manastoneTimer:timerExpired() then
				break
			end
		end
	elseif opt == 'bufflist' then
		--local buffList = zen.common.split(args[4])
		local buffSet = zen.common.splitSet(args[4])
		zen.state.buffs[new_value] = { class = args[3], buffs = buffSet }
	elseif opt == 'sicklist' then
		local sickList = zen.common.split(args[3])
		zen.state.sick[new_value] = sickList
	elseif opt == 'pauseforbuffs' then
		if config.get('MODE'):getName() == 'huntertank' then
			zen.movement.stop()
			state.holdForBuffs = timer:new(15000)
			print(logger.logLine('Holding pulls for 15 seconds for buffing'))
		end
	elseif opt == 'resumeforbuffs' then
		if config.get('MODE'):getName() == 'huntertank' then
			state.holdForBuffs = nil
		end
	elseif opt == 'armpets' then
		zen.class.armPets()
	elseif opt == 'switchwithma' then
		state.switchWithMA = not state.switchWithMA
	elseif opt == 'assistat' then

	else
		commands.classSettingsHandler(opt:upper(), new_value)
	end
end

function commands.classSettingsHandler(opt, new_value)
	if new_value then
		if opt == 'SPELLSET' and zen.class.OPTS.SPELLSET ~= nil then
			if zen.class.spellRotations[new_value] then
				print(logger.logLine('Setting %s to: %s', opt, new_value))
				zen.class.OPTS.SPELLSET.value = new_value
			end
		elseif opt == 'USEEPIC' and zen.class.OPTS.USEEPIC ~= nil then
			if zen.class.EPIC_OPTS[new_value] then
				print(logger.logLine('Setting %s to: %s', opt, new_value))
				zen.class.OPTS.USEEPIC.value = new_value
			end
		elseif opt == 'AURA1' and zen.class.OPTS.AURA1 ~= nil then
			if zen.class.AURAS[new_value] then
				print(logger.logLine('Setting %s to: %s', opt, new_value))
				zen.class.OPTS.AURA1.value = new_value
			end
		elseif opt == 'AURA2' and zen.class.OPTS.AURA2 ~= nil then
			if zen.class.AURAS[new_value] then
				print(logger.logLine('Setting %s to: %s', opt, new_value))
				zen.class.OPTS.AURA2.value = new_value
			end
		elseif zen.class.OPTS[opt] and type(zen.class.OPTS[opt].value) == 'boolean' then
			if lists.booleans[new_value] == nil then
				return
			end
			zen.class.OPTS[opt].value = lists.booleans[new_value]
			print(logger.logLine('Setting %s to: %s', opt, lists.booleans[new_value]))
		elseif zen.class.OPTS[opt] and type(zen.class.OPTS[opt].value) == 'number' then
			if tonumber(new_value) then
				print(logger.logLine('Setting %s to: %s', opt, tonumber(new_value)))
				if zen.class.OPTS[opt].value ~= nil then
					zen.class.OPTS[opt].value = tonumber(new_value)
				end
			end
		else
			print(logger.logLine('Unsupported command line option: %s %s', opt, new_value))
		end
	else
		if zen.class.OPTS[opt] ~= nil then
			print(logger.logLine('%s: %s', opt:lower(), zen.class.OPTS[opt].value))
		else
			print(logger.logLine('Unrecognized option: %s', opt))
		end
	end
end

function commands.nowcastHandler(...)
	print("In nowcast")
	zen.class.nowCast({ ... })
end

return commands