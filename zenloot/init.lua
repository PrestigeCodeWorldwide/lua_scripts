-------- REMINDER this is basically Lootier
local mq = require("mq")
local lip = require("lib.LIP")
local Write = require("lib.Write")
local BL = require("biggerlib")
require("ImGui")

local ZenLoot = require("ZenLootly")

local Open, ShowUI = true, true

local DistributeLootNowFlag = false

local config_dir = mq.configDir:gsub("\\", "/") .. "/"
local config_file = "ZenLoot.ini"
local zenloot_config = lip.load(config_dir .. config_file)

local settings_file = zenloot_config.ZenLoot.Lootini
local settings_path = config_dir .. settings_file

local show_keep, show_class, show_ignore, show_sell, show_destroy = true, true, true, true, true
local show_keep_pressed, show_class_pressed, show_ignore_pressed, show_sell_pressed, show_destroy_pressed =
	false, false, false, false, false
local text_filter_selected = false
local text_filter = ""

local loot_table_flags = bit32.bor(
	ImGuiTableFlags.BordersV,
	ImGuiTableFlags.BordersOuterH,
	ImGuiTableFlags.Resizable,
	ImGuiTableFlags.RowBg,
	ImGuiTableFlags.BordersInner
)

local choices = { "Keep", "Class", "Sell", "Ignore", "Destroy", "Distribute" }
local looters = {
	tradeskill = "NONE",
	collection = "NONE",
}

-- Configure Knightly Write...ly
Write.prefix = function()
	return "\ax[" .. mq.TLO.Time() .. "] [\agZenLoot\ax] "
end
Write.loglevel = "info"
Write.usecolors = false

--- Data unaltered directly loaded from the Loot.ini.  This data is modified in the interface and used to write back to the .ini file.
local remoteData = {}

--- Data converted for use in our interface.
local localData = {}

--- Filtered data that is used in the ImGui DisplayStart
local displayData = {}

--- Placeholder Strings for Adding new items
local ad_hoc_name, ad_hoc_value = "", ""

--- func desc
---@param t table
---@param filterIter function
table.filter = function(t, filterIter)
	local out = {}
	for i, v in ipairs(t) do
		if filterIter(v) then
			table.insert(out, v)
		end
	end
	return out
end

--- Sets the first letter of the provide string to uppercase.
---@param str string
---@return string
local function firstToUpper(str)
	return (str:gsub("^%l", string.upper))
end

local function displayFilter(v)
	if text_filter ~= "" or text_filter ~= " " then
		if
			(text_filter ~= " " and string.find(string.lower(v.name), string.lower(text_filter)))
			and (
				(show_keep and v.action == "Keep")
				or (show_class and v.action == "Class")
				or (show_destroy and v.action == "Destroy")
				or (show_ignore and v.action == "Ignore")
				or (show_sell and v.action == "Sell")
			)
		then
			return v
		end
	elseif
		not text_filter_selected
		and (
			(show_keep and v.action == "Keep")
			or (show_class and v.action == "Class")
			or (show_destroy and v.action == "Destroy")
			or (show_ignore and v.action == "Ignore")
			or (show_sell and v.action == "Sell")
		)
	then
		return v
	end
end

--- Split function
---@param inputstr string
---@param sep string
---@return table
local function split(inputstr, sep)
	if type(inputstr) == "string" then
		sep = sep or "%s"
		local t = {}
		for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
			table.insert(t, field)
			if s == "" then
				return t
			end
		end
	else
		return {}
	end
end

local function sortByNameComp(a, b)
	return a.name < b.name
end

--- Converts an Lua table created from the ini library to a flat table for use with ListClipper
---@param remoteTbl table Lua table in original format from loot.ini conversion
local function convertToLocalFormat(remoteTbl)
	local temp = {}

	for _, v in pairs(remoteTbl) do
		if type(v) == "table" then
			for key, value in pairs(v) do
				local categories = split(value, "|")
				local selectedClasses = {}

				if categories[3] and string.len(categories[3]) > 0 then
					for _, class in ipairs(split(categories[3], ",")) do
						selectedClasses[class] = true
					end
				end

				table.insert(temp, {
					name = key,
					action = firstToUpper(categories[1]),
					number = categories[2] or 0,
					classes = selectedClasses or {},
				})
			end
		end
	end
	return temp
end

local function isEmpty(something)
	local val = true
	if something then
		if type(something) == "string" or type(something) == "table" then
			if something and #something > 0 then
				val = false
			end
		else
			val = false
		end
	end
	return val
end

local function convertToRemoteFormat(localTbl)
	local temp = {
		["A"] = {},
		["B"] = {},
		["C"] = {},
		["D"] = {},
		["E"] = {},
		["F"] = {},
		["G"] = {},
		["H"] = {},
		["I"] = {},
		["J"] = {},
		["K"] = {},
		["L"] = {},
		["M"] = {},
		["N"] = {},
		["O"] = {},
		["P"] = {},
		["Q"] = {},
		["R"] = {},
		["S"] = {},
		["T"] = {},
		["U"] = {},
		["V"] = {},
		["W"] = {},
		["X"] = {},
		["Y"] = {},
		["Z"] = {},
	}

	for i, value in ipairs(localTbl) do
		local section = string.upper(string.sub(value.name, 1, 1))
		local selectedClassesStr = ""
		if section then
			if value.action == "Class" then
				value.selectedClasses = {}
				for classname, selected in pairs(value.classes) do
					if selected == true then
						table.insert(value.selectedClasses, classname)
						selectedClassesStr = selectedClassesStr .. "," .. classname
					end
				end
			end
			if
				not isEmpty(value.action)
				and not isEmpty(value.number)
				and not isEmpty(value.selectedClasses)
				and tonumber(value.number) > 0
				and #value.selectedClasses
			then
				temp[section][value.name] = value.action
					.. "|"
					.. value.number
					.. "|"
					.. string.sub(selectedClassesStr, 2, string.len(selectedClassesStr))
			elseif
				not isEmpty(value.action)
				and (value.action == "Keep")
				and not isEmpty(value.number)
				and tonumber(value.number) > 0
			then
				temp[section][value.name] = value.action .. "|" .. value.number
			elseif not isEmpty(value.action) then
				if value.action == "Class" then
					Write.Warn(
						string.format(
							'Action found - Class without number of items or classes selected on item "%s".  Saving as "Keep"  Make sure to use the context menu on the item to set amounts and classes.',
							value.name
						)
					)
					temp[section][value.name] = "Keep"
					localTbl[i].action = "Keep"
				else
					temp[section][value.name] = value.action
				end
			else
				Write.Error(string.format("Problem converting item %s to remote format, skipping . . .", value.name))
				return nil
			end
		else
			Write.Error(string.format("Problem attempting to convert item %s", value.name))
		end
	end
	return temp
end

--- Loads the ZenLoot loot .ini file into a Lua table
---@param file_path any
local function loadRemoteData(file_path)
	Write.Info(string.format("Loading data from %s", settings_file))
	remoteData = lip.load(file_path) or {}
	localData = convertToLocalFormat(remoteData) or {}
	table.sort(localData, sortByNameComp)
	Write.Info(string.format("Found %d items", #localData))
	looters.tradeskill = ZenLoot.tradeskillLooter
	looters.collection = ZenLoot.collectionLooter
end

--- Splits a string into table elements
---@param inputstr string
---@param sep string
local function split(inputstr, sep)
	if type(inputstr) == "string" then
		sep = sep or "%s"
		local t = {}
		for field, s in string.gmatch(inputstr, "([^" .. sep .. "]*)(" .. sep .. "?)") do
			table.insert(t, field)
			if s == "" then
				return t
			end
		end
	else
		return {}
	end
end

--- Saves our Lua table back to the ZenLoot Loot .ini file
---@param file_path any
local function saveRemoteData(file_path)
	Write.Info(string.format("Converting local data for storage."))
	local tempRemoteData = convertToRemoteFormat(localData)
	if tempRemoteData then
		Write.Info(string.format("Saving data to %s", settings_file))
		lip.save(file_path, tempRemoteData)
		remoteData = tempRemoteData

		-- Need to set the TS looter
		BL.info("Setting TS looter to %s", looters.tradeskill)
		ZenLoot.tradeskillLooter = looters.tradeskill
		BL.info("Setting Collection looter to %s", looters.tradeskill)
		ZenLoot.collectionLooter = looters.collection
		mq.cmd("/zenloot save")
	else
		Write.Error("Errors in converting to remote format.  Aborting save operation.")
	end
end

--- Renders a set of checkboxes for each of the classes
local function displayClassCheckboxes(row)
	local classList = {
		"SHM",
		"NEC",
		"MAG",
		"ENC",
		"WIZ",
		"DRU",
		"BRD",
		"CLR",
		"PAL",
		"RNG",
		"WAR",
		"ROG",
		"BST",
		"SHD",
		"MNK",
		"BER",
	}
	for _, v in ipairs(classList) do
		if not displayData[row].classes[v] then
			displayData[row].classes[v] = false
		end
	end

	ImGui.Columns(3, "mycolumn3", false)

	for _, value in ipairs(classList) do
		if ImGui.Checkbox(value, displayData[row].classes[value]) then
			displayData[row].classes[value] = true
		else
			displayData[row].classes[value] = false
		end
		ImGui.NextColumn()
	end
	ImGui.Columns(1)
end

--- Builds our context menu for Keep and Class options.
local function optionsContextMenu(row)
	local data = displayData[row]
	local name = data.name
	local actionToTake = data.action
	local numberToKeep = tonumber(data.number) or 0

	if actionToTake == "Class" or actionToTake == "Keep" then
		if ImGui.BeginPopupContextItem() then
			ImGui.Text(actionToTake .. ' Options for "' .. name .. '"')
			ImGui.PushItemWidth(125.0)
			displayData[row].number = ImGui.InputInt("# to Keep", numberToKeep)
			ImGui.PopItemWidth()

			if actionToTake == "Class" then
				displayClassCheckboxes(row)
			end

			ImGui.Separator()

			if ImGui.SmallButton("Save") then
				-- for index, value in ipairs(localData) do
				--     if value.name == displayData[row].name then
				--         localData[index] = displayData[row]
				--     end
				-- end
				saveRemoteData(settings_path)
				ImGui.CloseCurrentPopup()
			end
			ImGui.SameLine()
			if ImGui.SmallButton("Close") then
				ImGui.CloseCurrentPopup()
			end
			ImGui.EndPopup()
		end
	end
end

--- Renders the group of radio buttons.
---@param choices table List of available selections
---@param value string Consisting of one of our choices.  Keep, Ignore, Destroy, Sell, or a more complex string pipe delimited
local function renderRadioButtons(choices, row, value)
	for _, v in ipairs(choices) do
		local options = split(value, "|")
		if ImGui.RadioButton(v, options[1] == v) then
			displayData[row].action = v
			displayData[row].classes = {}
			displayData[row].number = ""
		end
		ImGui.SameLine()
		optionsContextMenu(row)
	end
end

--- Renders the Lua table into a list of selectable items.
---@param loot_data table A table representing the .ini file used in ZenLoot
local function renderData(loot_data)
	if ImGui.BeginTable("Loot", 2, loot_table_flags) then
		local clipper = ImGuiListClipper.new()
		clipper:Begin(#loot_data)
		while clipper:Step() do
			for row = clipper.DisplayStart + 1, clipper.DisplayEnd, 1 do
				local item = nil
				if loot_data[row] ~= nil then
					item = loot_data[row]
				end
				if item then
					ImGui.PushID(item.name)
					ImGui.TableNextRow()
					ImGui.TableNextColumn()
					ImGui.Text(item.name)
					ImGui.TableNextColumn()
					renderRadioButtons(choices, row, item.action)
					ImGui.PopID()
				end
			end
		end
		ImGui.EndTable()
	end
end

--- Buttons at the top of the display for various actions
local function drawButtons()
	if ImGui.Button("Distribute Loot##disloot_btn") then
        DistributeLootNowFlag = true
    end
    
    if ImGui.Button("Reload##reload_btn") then
		mq.cmd("/zenloot ini")
		loadRemoteData(settings_path)
		renderData(displayData)
	end
	ImGui.SameLine()
	if ImGui.Button("Save##save_btn") then
		saveRemoteData(settings_path)
	end
	ImGui.SameLine()
	if ImGui.Button("Sell##sell_btn") then
		mq.cmd("/zenloot sell")
	end
	ImGui.SameLine()
	if ImGui.Button("Cleanup##cleanup_btn") then
		mq.cmd("/zenloot cleanup")
	end
	ImGui.SameLine()
	ImGui.Text("Filters:")
	ImGui.SameLine()
	show_keep, show_keep_pressed = ImGui.Checkbox("Keep##keep_ckbx", show_keep)
	ImGui.SameLine()
	show_class, show_class_pressed = ImGui.Checkbox("Class##class_ckbx", show_class)
	ImGui.SameLine()
	show_sell, show_sell_pressed = ImGui.Checkbox("Sell##sell_ckbx", show_sell)
	ImGui.SameLine()
	show_ignore, show_ignore_pressed = ImGui.Checkbox("Ignore##ignore_ckbx", show_ignore)
	ImGui.SameLine()
	show_destroy, show_destroy_pressed = ImGui.Checkbox("Destroy##destroy_ckbx", show_destroy)

	-- Zen: add spot for TS class short name
	ImGui.PushItemWidth(100.0)
	looters.tradeskill, selected = ImGui.InputText("Tradeskill Looter##ts_looter", looters.tradeskill)

	ImGui.SameLine()
	looters.collection, _ = ImGui.InputText("Collection Looter##co_looter", looters.collection)
	ImGui.PopItemWidth()

	ImGui.Separator()

	ImGui.PushItemWidth(350.0)
	text_filter, text_filter_selected = ImGui.InputText("Text Filter##text_fltr", text_filter)
	ImGui.PopItemWidth()
	ImGui.SameLine()
	if ImGui.SmallButton("Clear##clr_text_fltr_btn") then
		text_filter = ""
		displayData = table.filter(localData, displayFilter)
	end

	ImGui.PushItemWidth(225.0)
	ad_hoc_name = ImGui.InputText("Name##ad_hoc_name", ad_hoc_name)
	ImGui.PopItemWidth()
	ImGui.SameLine()
	ImGui.PushItemWidth(225.0)
	ad_hoc_value = ImGui.InputText("Value##ad_hoc_value", ad_hoc_value)
	ImGui.PopItemWidth()
	ImGui.SameLine()
	if ImGui.SmallButton("Add New") then
		if ad_hoc_name and #ad_hoc_name > 1 and ad_hoc_value and #ad_hoc_value > 3 then
			remoteData[string.sub(ad_hoc_name, 1, 1)][ad_hoc_name] = ad_hoc_value
			lip.save(settings_path, remoteData)
			Write.Info("Added new entry " .. ad_hoc_name)
			Write.Info("Reloading ini file")
			mq.cmd("/zenloot ini")
			loadRemoteData(settings_path)
			displayData = table.filter(localData, displayFilter)
			ad_hoc_name = ""
			ad_hoc_value = ""
		end
	end

	if
		show_keep_pressed
		or show_class_pressed
		or show_ignore_pressed
		or show_sell_pressed
		or show_destroy_pressed
		or text_filter_selected
	then
		displayData = table.filter(localData, displayFilter)
		show_keep_pressed, show_class_pressed, show_ignore_pressed, show_sell_pressed, show_destroy_pressed =
			false, false, false, false, false
		text_filter_selected = false
	end
end

--- Layout
local function ManageLoot()
	if ShowUI then
		ImGui.PushStyleColor(ImGuiCol.WindowBg, 0.0, 0.0, 0.0, 0.95)
		ImGui.SetWindowSize(400, 400)
		Open, _ = ImGui.Begin("Manage Loot", Open)
		ImGui.PopStyleColor()
		ImGui.BeginChild("Data")
		drawButtons()
		renderData(displayData)
		ImGui.EndChild()
		ImGui.End()
	end
end

local function initLooters()
	looters.tradeskill = ZenLoot.tradeskillLooter
	looters.collection = ZenLoot.collectionLooter
end

--- Load up our data from the ZenLoot defined loot ini into a format we can use
--ZenLoot.setup()
loadRemoteData(settings_path)
initLooters()

--- Filter our data for displayData
displayData = table.filter(localData, displayFilter)

mq.imgui.init("manageloot", ManageLoot)

local function main()
	local last_time = os.time()
	while true do
		if ZenLoot.in_game() and ZenLoot.enabled then
			-- only run these every second, the loop is going
			-- to go faster to make the bind snappy
            if os.difftime(os.time(), last_time) >= 1 then
                if DistributeLootNowFlag then
				    ZenLoot.handle_master_looting(ZenLoot.tradeskillLooter, ZenLoot.collectionLooter)
				    ZenLoot.handle_personal_loot()
                    last_time = os.time()
                    DistributeLootNowFlag = false
                end
			end
			mq.doevents()
		end
		mq.delay(100)
	end
end
-------- REMINDER this is basically Lootier

main()
