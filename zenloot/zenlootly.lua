local mq         = require("mq")
local Write      = require("lib/Write")
local LIP        = require("lib/LIP")
local utils      = require("lib/ed/utils")
local dannet     = require("lib/dannet/helpers")

local Database   = require("lib.database") -- used for checking collectible/ts status
-- something here does something, don't unrequire them
local PackageMan = require("mq/PackageMan")
local Utils      = require("mq/Utils")
require("yalm.lib.database")

local BL              = require("biggerlib")
-- Configure Knightly Write...ly
Write.prefix          = function()
	return "\ax[" .. mq.TLO.Time() .. "] [\agZenLoot\ax] "
end
Write.loglevel        = "info"
Write.usecolors       = false

-- globals
local enabled         = true

-- used in the handle_master_looting function
local loot            = true

-- lookup tables
local MAX_BAG_SLOTS   = 12

local tLoot           = { keep = "Keep", sell = "Sell", class = "Class" }
local tLeave          = { destroy = "Destroy", ignore = "Ignore" }
local tValidOptions   = { keep = "Keep", sell = "Sell", class = "Class", destroy = "Destroy", ignore = "Ignore" }
local tValidSettings  = {
	distributedelay  = "DistributeDelay",
	newitemdelay     = "NewItemDelay",
	saveslots        = "SaveSlots",
	dannetdelay      = "DanNetDelay",
	tradeskillLooter = "tradeskillLooter",
}
local tValidLogLevels = { info = true, debug = true, warn = true, error = true, fatal = true }
local tValidClasses   = {
	BER = true,
	BST = true,
	BRD = true,
	CLR = true,
	DRU = true,
	ENC = true,
	MAG = true,
	MNK = true,
	NEC = true,
	PAL = true,
	RNG = true,
	ROG = true,
	SHD = true,
	SHM = true,
	WIZ = true,
	WAR = true,
}

--------------------------- LOOT ITSELF
local ZenLoot         = {
	enabled          = enabled,
	---- SET TO "NONE" TO DISABLE LOOTING TS MATS
	tradeskillLooter = "NONE",
	---- SET TO "NONE" TO DISABLE LOOTING COLLECTIONS
	collectionLooter = "NONE",
}

-- events
local function event_lore_item()
	loot = false
	Write.Debug(string.format("\a-yevent_lore_item: Loot = %s", loot))
end
mq.event("LoreLeave", "#*# already has #1# and it is lore#*#", event_lore_item)
mq.event(
	"LoreLeave",
	"#*#does not want #1#. It is either on their never list or they have selected No#*#",
	event_lore_item
)

-- script functions
local function print_usage()
	Write.Info("\agAvailable Commands - ")
	Write.Info("\a-g/zenloot on|off\a-t - Toggle ZenLoot on/off.")
	Write.Info("\a-g/zenloot sell [dry]\a-t - Sells designated items to the targeted merchant.")
	Write.Info("\a-g/zenloot cleanup [dry]\a-t - Destroy any marked items in your bags.")
	Write.Info(
		"\a-g/zenloot set <setting> <#>\a-t - Update ZenLoot settings; DistributeDelay (1-60), NewItemDelay (1-60), SaveSlots (>=1)"
	)
	Write.Info("\a-g/zenloot ini <file>\a-t - Set lootini (all characters).  Creates ini if it does not exist.")
	Write.Info("\a-g/zenloot convert <file>\a-t - Converts autoloot entries to ZenLoot format.")
	Write.Info("\a-g/zenloot log <level>\a-t - Configure log level (info, debug, warn, error, fatal).")
	Write.Info("\a-g/zenloot status\a-t - Show current ZenLoot configuration/settings.")
	Write.Info("\a-g/zenloot sort\a-t - Sort the loot file.")
	Write.Info("\a-g/zenloot reload\a-t - Reload ZenLoot settings from ZenLoot ini.")
	Write.Info(
		"\ao/setitem <preference> [name]\a-t - Set loot preference for item on cursor or by name (use quotes if there are spaces)."
	)
end

-- [string -> string preference, number quantity, string classes, table tClasses]
local function parse_item_settings(setting)
	local parts = split(setting, "|")
	local preference, quantity, classes
	preference  = parts[1]
	quantity    = tonumber(parts[2])
	classes     = parts[3]
	-- make a "valid" class set
	tClasses    = {}
	for k, v in pairs(split(parts[3], ",")) do
		tClasses[v] = true
	end
	return preference, quantity, classes, tClasses
end

local function check_lore_equip_prompt()
	local ConfirmationDialogBox     = "ConfirmationDialogBox"
	local ConfirmationDialogBoxText = ConfirmationDialogBox .. "/CD_TextOutput"
	if mq.TLO.Window(ConfirmationDialogBox).Open() then
		if mq.TLO.Window(ConfirmationDialogBoxText).Text():find("LORE-EQUIP", 1, true) then
			mq.cmd("/yes")
			mq.delay(1000)
		end
	end
end

local function calculate_reserved_slots()
	local reserved_slots = 0
	if settings["Excluded Bags"] ~= nil then
		for _, v in ipairs(settings["Excluded Bags"]) do
			if mq.TLO.FindItemCount(v)() > 0 then
				reserved_slots = reserved_slots + mq.TLO.FindItem(v).Container()
			end
		end
	end
	return reserved_slots
end

-- [string -> bool isValid, string setting, string preference, number quantity, table classes]
local function validate_setitem_input(input)
	local fn_name = "validate_setitem_input"
	Write.Debug(string.format("\a-y%s - Enter", fn_name))
	-- is it a valid loot option? Preference|Quantity|Classes
	local parts = split(input, "|")
	local setting, preference, quantity, classes
	local valid = true
	
	-- check preference value
	Write.Debug(string.format("\a-y%s - Preference (parts[1]): %s", fn_name, tostring(parts[1])))
	preference = tValidOptions[(parts[1] or ""):lower()]
	Write.Debug(string.format("\a-y%s - Preference (tValidOptions): %s", fn_name, tostring(preference)))
	if preference == nil then
		Write.Error("\ar[Set Item] Invalid input: \aw'" .. tostring(parts[1]) .. "'.")
		Write.Error("\ar[Set Item] \atValid Options: Keep, Keep|#, Class|#|BRD,WAR, Sell, Destroy, Ignore\ax")
		valid = false
	else
		setting = preference
	end
	
	-- make sure quantity is numeric
	if parts[2] ~= nil and (preference == "Keep" or preference == "Class") then
		Write.Debug(string.format("\a-y%s - Quantity (parts[2]): %s", fn_name, tostring(parts[2])))
		quantity = tonumber(parts[2])
		Write.Debug(string.format("\a-y%s - Quantity (tonumber): %s", fn_name, tostring(quantity)))
		if quantity == nil then
			Write.Error("\ar[Set Item] Quantity value must be numeric.")
			valid = false
		else
			setting = string.format("%s|%d", preference, quantity)
		end
	end
	
	-- make sure the class list is valid
	local classlist = parts[3]
	if classlist ~= nil and preference == "Class" then
		Write.Debug(string.format("\a-y%s - Classes (parts[3]): %s", fn_name, tostring(parts[3])))
		classes = split(classlist, ",")
		if #classes > 0 then
			for k, v in pairs(classes) do
				Write.Debug(string.format("\a-y%s - Classes (loop): %s", fn_name, tostring(v)))
				if tValidClasses[v:upper()] == nil then
					Write.Error("\ar[Set Item] Class value must be a valid short name.")
					valid = false
				end
			end
			-- if we made it here, parts 1,2, and 3 are all valid
			setting = string.format("%s|%d|%s", preference, quantity, parts[3]:upper())
		end
	elseif classlist == nil and preference == "Class" then
		Write.Error("\ar[Set Item] Class list cannot be empty.")
		valid = false
	end
	
	if valid then
		Write.Debug(string.format("\a-y%s - Parsed Setting: %s", fn_name, tostring(setting)))
	else
		Write.Debug(string.format("\a-y%s - Invalid: %s", fn_name, tostring(valid)))
	end
	
	Write.Debug(string.format("\a-y%s - Exit", fn_name))
	return valid, setting, preference, quantity, classes
end

local function zenloot_sell(dry)
	local fn_name                   = "zenloot_sell"
	local MerchantWnd               = "MerchantWnd"
	local MerchantSellButton        = "MerchantWnd/MW_Sell_Button"
	local MerchantSelectedItemLabel = "MerchantWnd/MW_SelectedItemLabel"
	
	-- allow for "dry" runs, since this will execute destroy commands
	local dryrun                    = dry == "dry"
	local prefix                    = dryrun and "\ay[Sell Dry Run]\ag" or "[Sell]"
	
	-- open the merchant
	if not mq.TLO.Window(MerchantWnd).Open() then
		-- basic error checking
		if mq.TLO.Target.ID() == nil then
			Write.Info(string.format("\ar%s No Merchant selected for auto selling.", prefix))
			return
		end
		-- only use real merchants
		if mq.TLO.Target.Class() ~= "Merchant" then
			Write.Info(
				string.format("\ar%s Target is not a real merchant. Please keep your helmet on at all times.", prefix)
			)
			return
		end
		-- distance
		if mq.TLO.Target.Distance3D() > 15 then
			Write.Info(string.format("\ar%s Merchant is too far away. Move close you dingus.", prefix))
			return
		end
		
		mq.cmd("/click right target")
		local timer = 0
		while not mq.TLO.Window(MerchantWnd).Open() or timer < 5000 do
			mq.delay(1000)
			timer = timer + 5000
		end
		
		-- second round of error checks
		if not mq.TLO.Window(MerchantWnd).Open() then
			Write.Info(string.format("\ar%s Error opening merchant window. You dumb. Try again?", prefix))
			return
		end
	end
	
	-- open up our inventory if it isn't already
	mq.cmdf("/keypress OPEN_INV_BAGS")
	mq.delay(250)
	
	Write.Info(string.format("\ag%s ZenLoot selling your junk.", prefix))
	
	-- run through our bags and sell the things
	for i = 1, MAX_BAG_SLOTS do
		local slots = mq.TLO.InvSlot("pack" .. i).Item.Container()
		if slots ~= nil and slots ~= 0 then
			for j = 1, slots do
				local item    = mq.TLO.InvSlot("pack" .. i).Item.Item(j)
				local validId = item ~= nil and item.ID() ~= nil and item.SellPrice() > 0 and item.NoRent() == false
				Write.Debug(string.format("\a-ypack%s slots = %s, slot = %s; item = %s", i, slots, j, item.Name()))
				if validId then
					local name    = item.Name()
					local section = name:sub(1, 1):upper()
					Write.Debug(string.format("\a-yvalidId = %s", name))
					local ini_setting = mq.TLO.Ini(lootini, section, name)() or "Keep"
					Write.Debug(string.format("\a-yini_setting = %s", ini_setting))
					local preference = parse_item_settings(ini_setting)
					Write.Debug(
						string.format(
							"\a-y%s - dry = %s; name = %s; ini_setting = %s; preference = %s",
							fn_name,
							tostring(dryrun),
							name,
							ini_setting,
							preference
						)
					)
					
					if preference == "Sell" then
						Write.Debug(string.format("\a-y%s - Start Sell Loop - Item: %s", fn_name, name))
						-- keep trying until our selected item is actually selected
						while mq.TLO.Window(MerchantSelectedItemLabel).Text() ~= name do
							Write.Debug(string.format("\a-y%s - Waiting to select item...", fn_name))
							mq.cmdf("/itemnotify in pack%s %s leftmouseup", i, j)
							mq.delay(250)
						end
						Write.Debug(string.format("\a-y%s - Selected Item", fn_name))
						
						-- wait for the sell button
						while not mq.TLO.Window(MerchantSellButton).Enabled() do
							Write.Debug(string.format("\a-y%s - Waiting for sell button to be enabled...", fn_name))
							mq.delay(250)
						end
						Write.Debug(string.format("\a-y%s - Sell Button Active", fn_name))
						
						-- shift click sell, everything must go
						Write.Info(string.format("\ag%s Selling %s", prefix, name))
						while not dryrun and mq.TLO.InvSlot("pack" .. i).Item.Item(j) == item do
							Write.Debug(string.format("\a-y%s - Notifying sell button...", fn_name))
							mq.cmd("/shiftkey /notify MerchantWnd MW_Sell_Button leftmouseup")
							mq.delay(1000)
						end
						
						Write.Debug(string.format("\a-y%s - End Sell Loop", fn_name))
					end
				end
			end
		end
		mq.delay(250)
	end
	
	Write.Info(string.format("\ag%s Finished Selling. Closing merchant and cleaning up.", prefix))
	mq.cmd("/cleanup")
end

local function zenloot_cleanup(dry)
	local fn_name = "zenloot_cleanup"
	
	-- allow for "dry" runs, since this will execute destroy commands
	local dryrun  = dry == "dry"
	local prefix  = dryrun and "\ay[Cleanup Dry Run]\ag" or "[Cleanup]"
	
	-- open up our inventory if it isn't already
	mq.cmdf("/keypress OPEN_INV_BAGS")
	mq.delay(250)
	
	Write.Info(string.format("\ag%s Cleaning up your inventory - destroying marked items.", prefix))
	
	-- run through our bags and destroy the things
	for i = 1, MAX_BAG_SLOTS do
		local slots = mq.TLO.InvSlot("pack" .. i).Item.Container()
		if slots ~= nil and slots ~= 0 then
			for j = 1, slots do
				local item    = mq.TLO.InvSlot("pack" .. i).Item.Item(j)
				local validId = item ~= nil and item.ID() ~= nil
				if validId then
					local name        = item.Name()
					local section     = name:sub(1, 1):upper()
					local ini_setting = mq.TLO.Ini(lootini, section, name)() or "Keep"
					local preference  = parse_item_settings(ini_setting)
					Write.Debug(
						string.format(
							"\a-y%s - dry = %s; name = %s; ini_setting = %s; preference = %s",
							fn_name,
							tostring(dryrun),
							name,
							ini_setting,
							preference
						)
					)
					
					if preference == "Destroy" then
						Write.Debug(string.format("\a-y%s - Start Cleanup Loop - %s", fn_name, name))
						-- pick up the item
						while mq.TLO.Cursor.ID() ~= item.ID() do
							mq.cmdf("/shift /itemnotify in pack%s %s leftmouseup", i, j)
							mq.delay(500)
						end
						Write.Debug(
							string.format(
								"\a-y%s Picked up %s to destroy.  Cursor = %s",
								fn_name,
								name,
								tostring(mq.TLO.Cursor.Name())
							)
						)
						
						-- destroy item if the cursor matches what we expect
						if mq.TLO.Cursor.ID() == item.ID() then
							Write.Info(string.format("\ar%s Destroying %s", prefix, name))
							if dryrun then
								mq.cmdf("/itemnotify in pack%s %s leftmouseup", i, j)
							else
								mq.cmd("/destroy")
							end
						else
							Write.Info(
								string.format(
									"\ar%s Cursor doesn't match.  Expected: %s; Actual: %s",
									prefix,
									name,
									tostring(mq.TLO.Cursor.Name())
								)
							)
							-- if cursor doesn't match what we expect, put it back
							if mq.TLO.Cursor.ID() ~= nil then
								mq.cmd("/autoinventory")
							end
						end
						
						-- wait for the cursor to be clear before moving on
						Write.Debug(string.format("\ay%s - End Cleanup Loop - %s", fn_name, name))
						mq.delay(250)
					end
				end
			end
		end
		mq.delay(250)
	end
	
	Write.Info(string.format("\ag%s Finished Cleanup. Hopefully we didn't delete anything important.", prefix))
	mq.cmd("/cleanup")
end

local function print_status()
	Write.Info("\agZenLoot Status - " .. (enabled and "on" or "off"))
	Write.Info("\atZenLoot Config: " .. settings_file)
	Write.Info("\atLoot File: " .. lootini)
	Write.Info("\a-gNewItemDelay = " .. ZenLoot.new_item_delay .. "s")
	Write.Info("\a-gDistributeDelay = " .. ZenLoot.distribute_delay .. "s")
	Write.Info(
		string.format("\a-gSaveSlots = %s (%s excluded bag slots)", ZenLoot.save_slots, calculate_reserved_slots())
	)
end

-- setup functions
local function create_loot_ini()
	local loot_ini_file = config_dir .. "/" .. lootini
	if not file_exists(loot_ini_file) then
		local sections     = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
		local out_settings = {}
		for i = 1, #sections do
			out_settings[sections:sub(i, i)] = {}
		end
		Write.Info(string.format("\ayLoot File does not exist.  Creating %s", lootini))
		LIP.save(loot_ini_file, out_settings)
	end
end

local function reload_settings(showStatus)
	settings                 = LIP.load(settings_path)
	ZenLoot.dannet_delay     = settings["ZenLoot"]["DanNetDelay"] or 150
	lootini                  = settings["ZenLoot"]["Lootini"] or "ZenLoot_Loot.ini"
	ZenLoot.save_slots       = settings["ZenLoot"]["SaveSlots"] or 3
	ZenLoot.distribute_delay = settings["ZenLoot"]["DistributeDelay"] or 2
	ZenLoot.new_item_delay   = settings["ZenLoot"]["NewItemDelay"] or 3
	ZenLoot.tradeskillLooter = settings["ZenLoot"]["tradeskillLooter"] or "NONE"
	ZenLoot.collectionLooter = settings["ZenLoot"]["collectionLooter"] or "NONE"
	
	-- calculate ZenLoot.save_slots based on excluded bag counts
	ZenLoot.save_slots       = ZenLoot.save_slots + calculate_reserved_slots()
	
	if showStatus then
		Write.Info("\ayReloading ZenLoot settings.")
		print_status()
	end
end

local function load_settings()
	config_dir    = mq.configDir:gsub("\\", "/") .. "/"
	settings_file = "ZenLoot.ini"
	settings_path = config_dir .. settings_file
	
	if file_exists(settings_path) then
		settings         = LIP.load(settings_path)
		
		-- adding settings that didn't exist originally
		local force_save = false
		if settings["ZenLoot"]["DanNetDelay"] == nil then
			settings["ZenLoot"]["DanNetDelay"] = 150
			force_save                         = true
		end
		if settings["ZenLoot"]["tradeskillLooter"] == nil then
			settings["ZenLoot"]["tradeskillLooter"] = "NONE"
			force_save                              = true
		end
		if settings["ZenLoot"]["collectionLooter"] == nil then
			settings["ZenLoot"]["collectionLooter"] = "NONE"
			force_save                              = true
		end
		-- if we added anything, save it
		if force_save then
			LIP.save(settings_path, settings)
		end
	else
		settings = {
			ZenLoot           = {
				Lootini          = "ZenLoot_Loot.ini",
				DanNetDelay      = 150, -- ms
				DistributeDelay  = 1, -- seconds
				NewItemDelay     = 3, -- seconds
				SaveSlots        = 3,
				tradeskillLooter = "NONE",
				collectionLooter = "NONE",
			},
			["Excluded Bags"] = {},
		}
		LIP.save(settings_path, settings)
	end
	reload_settings(false)
	create_loot_ini()
end

local function sort_loot_ini()
	local loot_ini_file = config_dir .. "/" .. lootini
	if file_exists(loot_ini_file) then
		Write.Info("\ayStarting loot file sort - " .. lootini)
		local in_settings = LIP.load(loot_ini_file)
		LIP.save(loot_ini_file, in_settings)
		Write.Info("\ayFinished loot file sort - " .. lootini)
	else
		Write.Error("Loot file doesn't exist.  Nothing to sort.")
	end
end

-- binds
local function bind_zenloot(cmd, val, val2)
	-- usage
	if cmd == nil then
		print_usage()
		return
	end
	
	-- on/off
	if cmd == "on" then
		enabled = true
		Write.Info("\ayZenLoot enabled.")
	elseif cmd == "off" then
		enabled = false
		Write.Info("\ayZenLoot disabled.")
	end
	
	if cmd == "reload" then
		reload_settings(true)
		return
	end
	
	if cmd == "status" then
		print_status()
		return
	end
	
	-- sell/cleanup
	if cmd == "sell" then
		zenloot_sell(val)
		return
	end
	if cmd == "cleanup" then
		zenloot_cleanup(val)
		return
	end
	
	-- log levels
	if cmd == "log" then
		if tValidLogLevels[val] ~= nil then
			Write.loglevel = val
			Write.Info("\ayLog Level = " .. Write.loglevel)
		else
			Write.Error(string.format("\arInvalid log level \aw'%s'\ax.", val))
		end
	end
	
	if cmd == "save" then
		BL.info("Saving ZenLoot settings")
		ZenLoot.save_settings()
		mq.delay(500)
		mq.cmd("/zenloot ini")
		mq.delay(500)
	end
	
	-- ZenLoot settings
	if cmd == "set" then
		local setting = tValidSettings[(tostring(val) or ""):lower()]
		if setting ~= nil then
			local num = tonumber(val2)
			
			if num == nil then
				Write.Error(string.format("\ar%s must be numeric.", setting))
				return
			end
			
			-- new item delay
			if setting == "NewItemDelay" then
				if num >= 1 and num <= 60 then
					ZenLoot.new_item_delay = num
				else
					Write.Error(string.format("\ar%s must be numeric (1-60).", setting))
					return
				end
			end
			
			-- distribute delay
			if setting == "DistributeDelay" then
				if num >= 1 and num <= 60 then
					ZenLoot.distribute_delay = num
				else
					Write.Error(string.format("\ar%s must be numeric (1-60).", setting))
					return
				end
			end
			
			-- save slots
			if setting == "SaveSlots" then
				if num >= 1 then
					ZenLoot.save_slots = num + calculate_reserved_slots()
				else
					Write.Error(string.format("\ar%s must be numeric (>=1).", setting))
					return
				end
			end
			
			-- dannet delay
			if setting == "DanNetDelay" then
				if num >= 1 and num <= 3000 then
					ZenLoot.dannet_delay = num
				else
					Write.Error(string.format("\ar%s must be numeric (1-3000).", setting))
					return
				end
			end
			
			-- if we made it here, save the setting
			mq.cmdf('/ini "%s" "%s" "%s" "%s"', settings_file, "ZenLoot", setting, num)
			Write.Info(string.format("\ay%s = %s", setting, num))
			mq.delay(1000)
		else
			Write.Error(string.format("\arInvalid setting \aw'%s'\ax. \atValid settings: ", val or ""))
			return
		end
	end
	
	-- loot ini
	if cmd == "ini" and val ~= nil then
		local newIniPath = config_dir .. tostring(val)
		-- check if the new ini exists, create if not
		if not file_exists(newIniPath) then
			Write.Info("\ayCreating " .. newIniPath)
			LIP.save(newIniPath, {})
		end
		-- update and save the zenloot config
		lootini = val
		mq.cmdf('/ini "%s" "%s" "%s" "%s"', settings_file, "ZenLoot", "Lootini", val)
		Write.Info(string.format("\ayUsing %s for loot file.", val))
	end
	
	-- sort loot ini
	if cmd == "sort" then
		sort_loot_ini()
		return
	end
end

local function bind_setitem(input, item)
	-- error checking
	if mq.TLO.Cursor.ID() == nil and item == nil then
		Write.Error(
			"\ar[Set Item] Nothing on the cursor.  How can we write the loot setting with nothing on your cursor?"
		)
		return
	end
	
	local name
	-- if we have an item on cursor, use that
	if mq.TLO.Cursor.ID() then
		name = mq.TLO.Cursor.Name()
	else
		-- if the first and last characters are quotes, strip them
		if item:sub(1, 1) == '"' and item:sub(item:len()) == '"' then
			name = item:sub(2, item:len() - 1)
		else
			name = item
		end
		Write.Debug(string.format("\a-ybind_setitem - item = %s; parsed name = %s", item, name))
	end
	local section = name:sub(1, 1):upper()
	
	-- show current ini value
	if input:lower() == "status" then
		local ini_setting = mq.TLO.Ini(lootini, section, name)()
		if ini_setting ~= nil then
			Write.Info(string.format("\ag[Set Item] %s is currently set to %s.", name, ini_setting))
			mq.cmdf("/autoinventory")
		else
			Write.Info(string.format("\a-g[Set Item] %s does not exist in the ini file.", name))
		end
		return
	end
	
	local valid, setting, preference, quantity, classes = validate_setitem_input(input)
	if not valid then
		return
	end
	
	-- all clear, let it rip
	local cmd = string.format('/ini "%s" "%s" "%s" "%s"', lootini, section, name, setting)
	Write.Debug("\a-ySetItem - " .. cmd)
	mq.cmdf(cmd)
	if mq.TLO.Ini(lootini, section, name)() == setting then
		Write.Info("\agSet " .. name .. " to " .. setting)
		-- destroy it or put it back
		if preference and preference:lower() == "destroy" and mq.TLO.Cursor.Name() == name then
			Write.Info("\arDestroying " .. name)
			mq.cmdf("/destroy")
		elseif mq.TLO.Cursor.ID() then
			Write.Info("\agPutting " .. name .. " into inventory.")
			mq.cmdf("/autoinventory")
		end
	else
		Write.Error("\ar[Set Item] Error setting " .. name .. " to " .. setting)
	end
end

local function check_plugins()
	if mq.TLO.Plugin("mq2autoloot")() ~= nil then
		mq.cmdf("/plugin mq2autoloot unload noauto")
		Write.Info("\agUnloading mq2autoloot, as I replace it.")
	end
	-- bitch about dannet
	if mq.TLO.Plugin("mq2dannet")() == nil then
		Write.Info("\arZenLoot requireds mq2dannet. Exiting.")
		mq.exit()
	end
end

function ZenLoot.save_settings()
	BL.info("Saving settings!")
	settings.ZenLoot.tradeskillLooter = ZenLoot.tradeskillLooter
	settings.ZenLoot.collectionLooter = ZenLoot.collectionLooter
	config_dir                        = mq.configDir:gsub("\\", "/") .. "/"
	settings_file                     = "ZenLoot.ini"
	settings_path                     = config_dir .. settings_file
	LIP.save(settings_path, settings)
	mq.delay(1000)
	reload_settings()
end

function ZenLoot.handle_master_looting(tradeskillLooter, collectionLooter)
	local fn_name = "handle_master_looting"
	
	-- No raid execution at all!
	if mq.TLO.Raid.Members() > 0 then
		return
	end
	
	-- if you're solo looting, use personal list instead of shared list
	local solo_looter  = mq.TLO.Group.Members() == nil or (mq.TLO.Group.Members() == 1 and mq.TLO.Me.Mercenary.ID())
	local prefix       = solo_looter and "Personal" or "Shared"
	local LootCountTLO = solo_looter and "PCount" or "SCount"
	local LootListTLO  = solo_looter and "PList" or "SList"
	
	-- use the advloot window value because it doesn't suck
	if mq.TLO.Me.CleanName() == mq.TLO.Window("AdvancedLootWnd/ADLW_FiltersWnd/ADLW_CalculatedMasterLooter").Text() then
		-- ok, let's check the shared loot against the loot ini
		if mq.TLO.AdvLoot[LootCountTLO]() > 0 and not mq.TLO.AdvLoot.LootInProgress() then
			local item     = mq.TLO.AdvLoot[LootListTLO](1)
			local itemName = item.Name()
			local item_id  = item.ID()
			
			if itemName ~= nil then
				local section     = itemName:sub(1, 1):upper()
				local ini_setting = mq.TLO.Ini(lootini, section, itemName)()
				
				-- if we've never seen it before, set it to keep and let the user sort it out later
				if ini_setting == nil or ini_setting == "" then
					mq.delay(ZenLoot.new_item_delay .. "s")
					
					if itemName == mq.TLO.AdvLoot[LootListTLO](1).Name() then
						BL.info("about to query database for itemid: " .. item_id)
						local dbItem = Database.QueryDatabaseForItemId(item_id)
						
						if dbItem == nil then
							BL.info("Couldn't find db item ")
							return
						end
						
						if dbItem.collectible == 1 then
							if collectionLooter == "NONE" then
								local theItem = mq.TLO.AdvLoot.SList(1)
								if
								theItem.Greed()
									or theItem.AlwaysGreed()
									or theItem.Need()
									or theItem.AlwaysNeed()
								then
									mq.cmdf("/advloot shared 1 giveto %s 1", mq.TLO.Me.CleanName())
									mq.delay(100)
									return
								end
								
								mq.cmd("/advloot shared 1 leave")
								mq.delay(100)
								return
							else
								BL.info("Collectible identified, giving to " .. collectionLooter)
								mq.cmdf("/advloot shared 1 giveto %s", collectionLooter)
								
								mq.delay(100)
								return
							end
						elseif dbItem.tradeskills == 1 then
							if ZenLoot.tradeskillLooter == "NONE" then
								local theItem = mq.TLO.AdvLoot.SList(1)
								if
								theItem.Greed()
									or theItem.AlwaysGreed()
									or theItem.Need()
									or theItem.AlwaysNeed()
								then
									mq.cmdf("/advloot shared 1 giveto %s 1", mq.TLO.Me.CleanName())
									mq.delay(100)
									return
								end
								
								mq.cmd("/advloot shared 1 leave")
								mq.delay(100)
								return
							else
								BL.info("Tradeskill item identified, giving to " .. ZenLoot.tradeskillLooter)
								mq.cmdf("/advloot shared 1 giveto %s", ZenLoot.tradeskillLooter)
								mq.delay(100)
								return
							end
						else
							BL.info("Setting to ignore for " .. itemName)
							ini_setting = "Ignore"
						end
					else
						Write.Info(
							string.format(
								"\a-g[%s] %s no longer in shared loot window. Assuming this was handled manually and moving on to the next item.",
								prefix,
								itemName
							)
						)
						return
					end
				end
				
				-- parse out the ini setting for preference, quantity and classlist
				local preference, quantity, classes, tClasses = parse_item_settings(ini_setting)
				
				local valid                                   = true
				if tValidOptions[preference:lower()] == nil then
					Write.Error(
						string.format("\ar[%s] Invalid loot preference for %s - %s.", prefix, itemName, preference)
					)
					valid = false
				end
				
				-- if everything looks good, lets start checking if we should hand this thing out
				if valid then
					Write.Debug(
						string.format(
							"\a-y%s - %s - setting: %s; preference = %s; quantity = %s; classes = %s",
							fn_name,
							itemName,
							ini_setting,
							tostring(preference),
							tostring(quantity),
							tostring(classes)
						)
					)
					
					-- handle our keep cases
					if tLoot[preference:lower()] ~= nil then
						local count = mq.TLO["Group"].Members() or 0
						
						for i = 0, count do
							-- check this each time through incase ZenLoot was turned off and break out
							if not enabled then
								return
							end
							
							-- reset this for each group member, assume we'll start with the intention of looting
							-- let the conditions below say otherwise and handle appropriately at the end
							loot = true
							
							local member
							
							-- always consider the master looter first, then work down the group list
							if i == 0 or mq.TLO["Group"].Member(i).Name() == mq.TLO.Me.CleanName() then
								member = mq.TLO.Me
							else
								member = mq.TLO["Group"].Member(i)
							end
							
							-- if this group member is in the zone
							if member.ID() ~= 0 then
								local name  = member.Name()
								local class = member.Class.ShortName()
								
								-- if we have a class list, check against it
								if classes ~= nil and tClasses[class] == nil then
									loot = false
									Write.Debug(
										string.format(
											"\a-y%s - %s is not on the class list.  Skipping %s.",
											fn_name,
											class,
											name
										)
									)
								end
								
								-- free inventory check
								-- if loot then loot = check_free_inventory(name, item) end
								if loot then
									local slots, count, stacksize
									if name == mq.TLO.Me.DisplayName() then
										slots     = mq.TLO.Me.FreeInventory()
										count     = mq.TLO.FindItemCount(item_id)() or 0
										stacksize = mq.TLO.FindItem(item_id).StackSize() or 0
										Write.Debug(
											string.format(
												"\a-y%s - %s - Free Inventory - Slots = %s; Count = %s; Stack Size = %s",
												fn_name,
												name,
												slots,
												count,
												stacksize
											)
										)
									else
										-- use dannet
										Write.Debug(
											string.format(
												"\a-y%s - %s - Free Inventory - %s - Save Slots = %s",
												fn_name,
												name,
												itemName,
												ZenLoot.save_slots
											)
										)
										slots     = tonumber(dannet.query(name, "Me.FreeInventory", ZenLoot.dannet_delay))
											or 0
										count     = tonumber(
											dannet.query(
												name,
												string.format("FindItemCount[%s]", item_id),
												ZenLoot.dannet_delay
											)
										) or 0
										stacksize = tonumber(
											dannet.query(
												name,
												string.format("FindItem[%s].StackSize", item_id),
												ZenLoot.dannet_delay
											)
										) or 0
									end
									
									if
									(count == 0 or (count > 0 and count + 1 > stacksize))
										and slots <= ZenLoot.save_slots
									then
										loot = false
										Write.Debug(
											string.format(
												"\a-y%s - %s looting %s would put them over the configured save slots value.",
												fn_name,
												name,
												itemName
											)
										)
									end
								end
								
								-- if we have a quantity, query the member to make sure it wouldn't put them over
								-- if loot then loot = check_quantity(name, item) end
								if loot then
									if quantity ~= nil then
										local count, bankcount
										-- if it's me, do this locally
										if name == mq.TLO.Me.DisplayName() then
											count     = math.max(
												mq.TLO.FindItemCount(item_id)(),
												mq.TLO.FindItemCount(itemName)()
											)
											bankcount = math.max(
												mq.TLO.FindItemBankCount(item_id)(),
												mq.TLO.FindItemBankCount(itemName)()
											)
											Write.Debug(
												string.format(
													"\a-y%s - %s - Item Counts - Count = %s; Bank Count: %s;",
													fn_name,
													name,
													count,
													bankcount
												)
											)
										else
											-- use dannet
											Write.Debug(
												string.format(
													"\a-y%s - %s - DanNet (Counts) - %s",
													fn_name,
													name,
													itemName
												)
											)
											count     = math.max(
												tonumber(
													dannet.query(
														name,
														string.format("FindItemCount[%s]", item_id),
														ZenLoot.dannet_delay
													)
												) or 0,
												tonumber(
													dannet.query(
														name,
														string.format("FindItemCount[%s]", itemName),
														ZenLoot.dannet_delay
													)
												) or 0
											)
											bankcount = math.max(
												tonumber(
													dannet.query(
														name,
														string.format("FindItemBankCount[%s]", item_id),
														ZenLoot.dannet_delay
													)
												) or 0,
												tonumber(
													dannet.query(
														name,
														string.format("FindItemBankCount[%s]", itemName),
														ZenLoot.dannet_delay
													)
												) or 0
											)
										end
										if (count + bankcount) >= quantity then
											loot = false
											Write.Debug(
												string.format(
													"\a-y%s - %s looting %s would put them over the specific quantity (%s). Inventory = %s; Bank = %s;",
													fn_name,
													name,
													itemName,
													quantity,
													count,
													bankcount
												)
											)
										end
									end
								end
								
								-- if we're still going to loot this, do the lore checks
								-- if loot then loot = check_lore(name, item) end
								if loot then
									local lore, banklore
									-- if it's me, do this locally
									if name == mq.TLO.Me.DisplayName() then
										lore     = mq.TLO.FindItem(item_id).Lore()
										banklore = mq.TLO.FindItemBank(item_id).Lore()
										Write.Debug(
											string.format(
												"\a-y%s - %s - Item Lore - Inventory = %s; Bank: %s;",
												fn_name,
												name,
												lore,
												banklore
											)
										)
									else
										-- use dannet
										Write.Debug(
											string.format("\a-y%s - %s - DanNet (Lore) - %s", fn_name, name, itemName)
										)
										lore     = tostring(
											dannet.query(
												name,
												string.format("FindItem[%s].Lore", item_id),
												ZenLoot.dannet_delay
											)
										) == "TRUE"
										banklore = tostring(
											dannet.query(
												name,
												string.format("FindItemBank[%s].Lore", item_id),
												ZenLoot.dannet_delay
											)
										) == "TRUE"
									end
									if lore == true or banklore == true then
										loot = false
										Write.Debug(
											string.format(
												"\a-y%s - %s has %s already. Inventory = %s; Bank = %s;",
												fn_name,
												name,
												itemName,
												lore,
												banklore
											)
										)
									end
								end
								
								Write.Debug(
									string.format("\a-y%s - loot = %s; item = %s", fn_name, tostring(loot), itemName)
								)
								
								if loot and itemName == mq.TLO.AdvLoot[LootListTLO](1).Name() then
									-- if single looting
									if solo_looter then
										Write.Info(
											string.format("\ag[%s] SOLO LOOTER Looting %s.", prefix, itemName, name)
										)
										mq.cmdf("/advloot personal 1 loot")
									else
										Write.Info(string.format("\a-g[%s] Giving %s to %s.", prefix, itemName, name))
										mq.cmdf("/advloot shared 1 giveto %s 1", name)
									end
									mq.doevents()
									mq.delay(ZenLoot.distribute_delay .. "s")
									-- if there was no lore message after trying to hand it out, loot is still true, break the loop
									if loot then
										break
									end
									Write.Debug(
										string.format(
											"\a-y%s has the %s already (probably in parcel).  Loot = %s",
											name,
											itemName,
											tostring(loot)
										)
									)
								end
							end
							
							-- if we made it here, no one can loot the item. drop it.
							if i == count then
								loot = false
								Write.Debug(
									string.format(
										"\ar[%s] No one was able to loot/wanted %s.  Leaving.",
										prefix,
										itemName
									)
								)
							end
						end
					else
						-- handle our leave cases
						local item = mq.TLO.AdvLoot.SList(1)
						if item.Never() then
							loot = false
							Write.Debug(string.format("\ar[%s] %s is set to Never.  Leaving.", prefix, itemName))
						elseif item.AlwaysNeed() or item.AlwaysGreed() or item.Greed() or item.Need() then
							loot = true
							Write.Debug(
								string.format(
									"\ag[%s] %s is set to AlwaysNeed, AlwaysGreed, Greed, or Need.  Keeping.",
									prefix,
									itemName
								)
							)
							mq.cmd("/advloot personal 1 loot")
						else
							loot = false
							Write.Debug(string.format("\ar[%s] %s is UNSET.  Leaving.", prefix, itemName))
						end
					end
					
					-- we made it. leave the stupid item.
					if loot == false then
						mq.cmdf("/advloot %s 1 leave", prefix:lower())
					end
				end
			end
		end
	end
end

local LootStartedTimestamp = 0

local function _handle_personal_loot_internal()
	local item     = mq.TLO.AdvLoot.PList(1)
	local itemName = item.Name()
	local item_id  = item.ID()
	
	if itemName == nil then return end
	
	local section     = itemName:sub(1, 1):upper()
	local ini_setting = mq.TLO.Ini(lootini, section, itemName)()
	
	-- if we've never seen it before, set it to keep and let the user sort it out later
	if ini_setting == nil or ini_setting == "" then
		mq.delay(ZenLoot.new_item_delay .. "s")
		
		if itemName == mq.TLO.AdvLoot.PList(1).Name() then
			BL.info("about to query database for itemid: " .. item_id)
			local dbItem = Database.QueryDatabaseForItemId(item_id)
			
			if dbItem == nil then
				BL.info("Couldn't find db item ")
				return
			end
			
			if dbItem.collectible == 1 then
				if ZenLoot.collectionLooter == "NONE" then
					local theItem = mq.TLO.AdvLoot.SList(1)
					if
					theItem.Greed()
						or theItem.AlwaysGreed()
						or theItem.Need()
						or theItem.AlwaysNeed()
					then
						mq.cmdf("/advloot personal 1 loot")
						mq.delay(100)
						return
					end
					
					mq.cmd("/advloot personal 1 leave")
					mq.delay(100)
					return
				elseif ZenLoot.collectionLooter == mq.TLO.Me.CleanName() then
					BL.info("Collectible identified and collections is enabled, looting!")
					mq.cmdf("/advloot personal 1 loot")
					
					mq.delay(100)
					return
				else
					mq.cmd("/advloot personal 1 leave")
					mq.delay(100)
					return
				end
			elseif dbItem.tradeskills == 1 then
				if ZenLoot.tradeskillLooter == "NONE" then
					local theItem = mq.TLO.AdvLoot.PList(1)
					if
					theItem.Greed()
						or theItem.AlwaysGreed()
						or theItem.Need()
						or theItem.AlwaysNeed()
					then
						mq.cmdf("/advloot personal 1 loot")
						mq.delay(100)
						return
					end
					
					mq.cmd("/advloot personal 1 leave")
					mq.delay(100)
					return
				elseif ZenLoot.tradeskillLooter == mq.TLO.Me.CleanName() then
					BL.info("Tradeskill item identified, looting")
					mq.cmdf("/advloot personal 1 loot")
					mq.delay(100)
					return
				else -- ts looter set to NOT ME
					mq.cmd("/advloot personal 1 leave")
					return
				end
			end
		--else
		--	Write.Info(
		--		string.format(
		--			"\a-g[Personal] %s no longer in shared loot window. Assuming this was handled manually and moving on to the next item.",
		--			itemName
		--		)
		--	)
		--	return
		end
	end
	-- this will be nil IFF we've never seen the item before, so we'll ignore it and let the user decide on his own
	if BL.IsNil(ini_setting) then ini_setting = "Ignore" end
	
	-- parse out the ini setting for preference, quantity and classlist
	local preference, quantity, classes, tClasses = parse_item_settings(ini_setting)
	
	local valid                                   = true
	if tValidOptions[preference:lower()] == nil then
		Write.Error(
			string.format("\ar[%s] Invalid loot preference for %s - %s.", prefix, itemName, preference)
		)
		valid = false
	end
	
	-- if everything looks good, lets start checking if we should hand this thing out
	if valid then
		Write.Debug(
			string.format(
				"\a-y%s - %s - setting: %s; preference = %s; quantity = %s; classes = %s",
				fn_name,
				itemName,
				ini_setting,
				tostring(preference),
				tostring(quantity),
				tostring(classes)
			)
		)
		
		-- handle our keep cases
		if tLoot[preference:lower()] ~= nil then
			local count = 1
			
			for i = 0, count do
				-- check this each time through incase ZenLoot was turned off and break out
				if not enabled then
					return
				end
				
				-- reset this for each group member, assume we'll start with the intention of looting
				-- let the conditions below say otherwise and handle appropriately at the end
				loot   = true
				
				local member
				
				member = mq.TLO.Me
				
				-- if this group member is in the zone
				if member.ID() ~= 0 then
					local name  = member.Name()
					local class = member.Class.ShortName()
					
					-- if we have a class list, check against it
					if classes ~= nil and tClasses[class] == nil then
						loot = false
						Write.Debug(
							string.format(
								"\a-y%s - %s is not on the class list.  Skipping %s.",
								fn_name,
								class,
								name
							)
						)
					end
					
					-- free inventory check
					-- if loot then loot = check_free_inventory(name, item) end
					if loot then
						local slots, count, stacksize
						slots     = mq.TLO.Me.FreeInventory()
						count     = mq.TLO.FindItemCount(item_id)() or 0
						stacksize = mq.TLO.FindItem(item_id).StackSize() or 0
						Write.Debug(
							string.format(
								"\a-y%s - %s - Free Inventory - Slots = %s; Count = %s; Stack Size = %s",
								fn_name,
								name,
								slots,
								count,
								stacksize
							)
						)
						
						if
						(count == 0 or (count > 0 and count + 1 > stacksize))
							and slots <= ZenLoot.save_slots
						then
							loot = false
							Write.Debug(
								string.format(
									"\a-y%s - %s looting %s would put them over the configured save slots value.",
									fn_name,
									name,
									itemName
								)
							)
						end
					end
					
					-- if we have a quantity, query the member to make sure it wouldn't put them over
					-- if loot then loot = check_quantity(name, item) end
					if loot then
						if quantity ~= nil then
							local count, bankcount
							-- if it's me, do this locally
								count     = math.max(
									mq.TLO.FindItemCount(item_id)(),
									mq.TLO.FindItemCount(itemName)()
								)
								bankcount = math.max(
									mq.TLO.FindItemBankCount(item_id)(),
									mq.TLO.FindItemBankCount(itemName)()
								)
								Write.Debug(
									string.format(
										"\a-y%s - %s - Item Counts - Count = %s; Bank Count: %s;",
										fn_name,
										name,
										count,
										bankcount
									)
								)
							
							if (count + bankcount) >= quantity then
								loot = false
								Write.Debug(
									string.format(
										"\a-y%s - %s looting %s would put them over the specific quantity (%s). Inventory = %s; Bank = %s;",
										fn_name,
										name,
										itemName,
										quantity,
										count,
										bankcount
									)
								)
							end
						end
					end
					
					-- if we're still going to loot this, do the lore checks
					-- if loot then loot = check_lore(name, item) end
					if loot then
						local lore, banklore
						-- if it's me, do this locally
							lore     = mq.TLO.FindItem(item_id).Lore()
							banklore = mq.TLO.FindItemBank(item_id).Lore()
							Write.Debug(
								string.format(
									"\a-y%s - %s - Item Lore - Inventory = %s; Bank: %s;",
									fn_name,
									name,
									lore,
									banklore
								)
							)
						if lore == true or banklore == true then
							loot = false
							Write.Debug(
								string.format(
									"\a-y%s - %s has %s already. Inventory = %s; Bank = %s;",
									fn_name,
									name,
									itemName,
									lore,
									banklore
								)
							)
						end
					end
					
					Write.Debug(
						string.format("\a-y%s - loot = %s; item = %s", fn_name, tostring(loot), itemName)
					)
					
					if loot and itemName == mq.TLO.AdvLoot[LootListTLO](1).Name() then
						-- if single looting
						if solo_looter then
							Write.Info(
								string.format("\ag[%s] SOLO LOOTER Looting %s.", prefix, itemName, name)
							)
							mq.cmdf("/advloot personal 1 loot")
						else
							Write.Info(string.format("\a-g[%s] Giving %s to %s.", prefix, itemName, name))
							mq.cmdf("/advloot shared 1 giveto %s 1", name)
						end
						mq.doevents()
						mq.delay(ZenLoot.distribute_delay .. "s")
						-- if there was no lore message after trying to hand it out, loot is still true, break the loop
						if loot then
							break
						end
						Write.Debug(
							string.format(
								"\a-y%s has the %s already (probably in parcel).  Loot = %s",
								name,
								itemName,
								tostring(loot)
							)
						)
					end
				end
				
				-- if we made it here, no one can loot the item. drop it.
				if i == count then
					loot = false
					Write.Debug(
						string.format(
							"\ar[%s] No one was able to loot/wanted %s.  Leaving.",
							prefix,
							itemName
						)
					)
				end
			end
		else
			-- handle our leave cases
			local item = mq.TLO.AdvLoot.SList(1)
			if item.Never() then
				loot = false
				Write.Debug(string.format("\ar[%s] %s is set to Never.  Leaving.", prefix, itemName))
			elseif item.AlwaysNeed() or item.AlwaysGreed() or item.Greed() or item.Need() then
				loot = true
				Write.Debug(
					string.format(
						"\ag[%s] %s is set to AlwaysNeed, AlwaysGreed, Greed, or Need.  Keeping.",
						prefix,
						itemName
					)
				)
				mq.cmd("/advloot personal 1 loot")
			else
				loot = false
				Write.Debug(string.format("\ar[%s] %s is UNSET.  Leaving.", prefix, itemName))
			end
		end
		
		-- we made it. leave the stupid item.
		if loot == false then
			mq.cmdf("/advloot personal 1 leave")
		end
	end
end

function ZenLoot.handle_personal_loot()
	-- No raid execution at all!
	if mq.TLO.Raid.Members() > 0 then
		return
	end
	
	local solo_looter = (
		mq.TLO.Raid.Members() == 0
			and (mq.TLO.Group.Members() == nil or (mq.TLO.Group.Members() == 1 and mq.TLO.Me.Mercenary.ID()))
	)
	
	-- early exit checks
	--if solo_looter then
	--	return
	--end
	
	-- added enabled check incase ZenLoot gets switched off mid loot cycle
	while enabled and mq.TLO.AdvLoot.PCount() > 0 do
		if not mq.TLO.AdvLoot.LootInProgress() then
			-- If we didn't start timer yet, start it now
			--if LootStartedTimestamp == 0 then
			--	LootStartedTimestamp = mq.gettime()
			--	return
			--end
			
			--local now = mq.gettime()
			---- we should go ahead and loot now
			--if now - LootStartedTimestamp < ZenLoot.new_item_delay then
			--	return
			--end
			
			LootStartedTimestamp = 0
			
			_handle_personal_loot_internal()
			-- OLD, loots everything by default instead of checking against list
			--Write.Info(string.format("\ag[Personal] Looting %s.", tostring(mq.TLO.AdvLoot.PList(1).Name())))
			--mq.cmd("/advloot personal 1 loot")
			--check_lore_equip_prompt()
			--mq.delay(500)
		end
	end
end

function ZenLoot.setup()
	check_plugins()
	load_settings()
	
	-- register binds
	mq.bind("/zenloot", bind_zenloot)
	mq.bind("/setitem", bind_setitem)
	
	Write.Info("\agZenLoot by (\a-to_O\ag) Special.Ed (\a-to_O\ag)")
	Write.Info("\atZenLoot Config: " .. settings_file)
	Write.Info("\atLoot File: " .. lootini)
	print_usage()
end

function ZenLoot.in_game()
	return mq.TLO.MacroQuest.GameState() == "INGAME"
end

ZenLoot.setup()

return ZenLoot
