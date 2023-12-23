--- @type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")

local config = require("interface.configuration")
local camp = require("routines.camp")
local helpers = require("utils.helpers")
local logger = require("utils.logger")
local constants = require("constants")
local mode = require("mode")
local state = require("state")

-- UI Control variables
local openGUI = true
local shouldDrawGUI = true
local uiTheme = "TEAL"

local abilityGUIOpen = false
local shouldDrawAbilityGUI = false

local helpGUIOpen = false
local shouldDrawHelpGUI = false

-- UI constants
local MINIMUM_WIDTH = 372
local HALF_BUTTON_WIDTH = 173
local BUTTON_HEIGHT = 22
local mid_x = 140
local item_width = 115
local X_COLUMN_OFFSET = 265
local Y_COLUMN_OFFSET = 30

local WHITE = ImVec4(1, 1, 1, 1)
local GREEN = ImVec4(0, 1, 0, 1)
local YELLOW = ImVec4(1, 1, 0, 1)
local RED = ImVec4(1, 0, 0, 1)
local LIGHT_BLUE = ImVec4(0.6, 0.8, 1, 1)
local ORANGE = ImVec4(1, 0.65, 0, 1)
local BL = require("biggerlib")
local zen
local ui = {}

function ui.init(_zen)
	zen = _zen
	mq.imgui.init("ZEN Bot 1.0", ui.main)
	ui.isDirty = false
end

function ui.toggleGUI(open)
	openGUI = open
end

local function helpMarker(desc)
	if ImGui.IsItemHovered() then
		ImGui.BeginTooltip()
		ImGui.PushTextWrapPos(ImGui.GetFontSize() * 35.0)
		ImGui.Text(desc)
		ImGui.PopTextWrapPos()
		ImGui.EndTooltip()
	end
end

function ui.drawComboBox(label, resultvar, options, bykey, helpText, xOffset, yOffset)
	if not yOffset and not xOffset then
		xOffset, yOffset = ImGui.GetCursorPos()
	end
	ImGui.SetCursorPosX(xOffset)
	ImGui.SetCursorPosY(yOffset + 5)
	ImGui.Text(label)
	ImGui.SameLine()
	helpMarker(helpText)
	ImGui.SameLine()
	ImGui.SetCursorPosX(mid_x + xOffset)
	local _, y = ImGui.GetCursorPos()
	ImGui.SetCursorPosY(y - 3)
	if ImGui.BeginCombo("##" .. label, resultvar) then
		for i, j in pairs(options) do
			if bykey then
				if ImGui.Selectable(i, i == resultvar) then
					resultvar = i
				end
			else
				if ImGui.Selectable(j, j == resultvar) then
					resultvar = j
				end
			end
		end
		ImGui.EndCombo()
	end
	--[[if ImGui.BeginCombo(label, resultvar) then
		for i,j in pairs(options) do
			if bykey then
				if ImGui.Selectable(i, i == resultvar) then
					resultvar = i
				end
			else
				if ImGui.Selectable(j, j == resultvar) then
					resultvar = j
				end
			end
		end
		ImGui.EndCombo()
	end
	helpMarker(helpText)]]
	return resultvar
end

function ui.drawCheckBox(labelText, idText, resultVar, helpText, xOffset, yOffset)
	if not yOffset and not xOffset then
		xOffset, yOffset = ImGui.GetCursorPos()
	end
	ImGui.SetCursorPosX(xOffset)
	ImGui.SetCursorPosY(yOffset + 5)
	if resultVar then
		ImGui.TextColored(GREEN, labelText)
	else
		ImGui.TextColored(RED, labelText)
	end
	ImGui.SameLine()
	helpMarker(helpText)
	ImGui.SameLine()
	local x, y = ImGui.GetCursorPos()
	ImGui.SetCursorPosY(y - 3)
	ImGui.SetCursorPosX(mid_x + xOffset)
	resultVar, _ = ImGui.Checkbox(idText, resultVar)
	--[[if resultVar then ImGui.PushStyleColor(ImGuiCol.Text, GREEN) else ImGui.PushStyleColor(ImGuiCol.Text, RED) end
	resultVar,_ = ImGui.Checkbox(labelText, resultVar)
	ImGui.PopStyleColor(1)
	helpMarker(helpText)]]
	if resultVar then
		--logger.info("ResultVar for checkbox %s is %s", labelText, tostring(resultVar))
	end
	return resultVar
end

function ui.drawInputInt(labelText, idText, resultVar, helpText, xOffset, yOffset)
	if not yOffset and not xOffset then
		xOffset, yOffset = ImGui.GetCursorPos()
	end
	ImGui.SetCursorPosX(xOffset)
	ImGui.SetCursorPosY(yOffset + 5)
	ImGui.Text(labelText)
	ImGui.SameLine()
	helpMarker(helpText)
	ImGui.SameLine()
	local _, y = ImGui.GetCursorPos()
	ImGui.SetCursorPosY(y - 3)
	ImGui.SetCursorPosX(mid_x + xOffset)
	resultVar = ImGui.InputInt(idText, resultVar)
	--[[resultVar = ImGui.InputInt(labelText, resultVar)
	helpMarker(helpText)]]
	return resultVar
end

function ui.drawInputText(labelText, idText, resultVar, helpText, xOffset, yOffset)
	if not yOffset and not xOffset then
		xOffset, yOffset = ImGui.GetCursorPos()
	end
	ImGui.SetCursorPosX(xOffset)
	ImGui.SetCursorPosY(yOffset + 5)
	ImGui.Text(labelText)
	ImGui.SameLine()
	helpMarker(helpText)
	ImGui.SameLine()
	local _, y = ImGui.GetCursorPos()
	ImGui.SetCursorPosY(y - 3)
	ImGui.SetCursorPosX(mid_x + xOffset)
	resultVar = ImGui.InputText(idText, resultVar)
	--[[resultVar = ImGui.InputText(labelText, resultVar)
	helpMarker(helpText)]]
	return resultVar
end

function ui.getNextXY(startY, yAvail, xOffset, yOffset, maxY)
	yOffset = yOffset + Y_COLUMN_OFFSET
	if yOffset > maxY then
		maxY = yOffset
	end
	if yAvail - yOffset + startY < 25 then
		xOffset = xOffset + X_COLUMN_OFFSET
		yOffset = startY
	end
	return xOffset, yOffset, maxY
end

local function drawConfigurationForCategory(configs)
	local x, y = ImGui.GetCursorPos()
	local xOffset = x
	local yOffset = y
	local maxY = yOffset
	local _, yAvail = ImGui.GetContentRegionAvail()

	for _, cfgKey in ipairs(configs) do
		local cfg = config[cfgKey]

		if cfg.type == "checkbox" then
			config.set(cfgKey, ui.drawCheckBox(cfg.label, "##" .. cfgKey, cfg.value, cfg.tip, xOffset, yOffset))
		elseif cfg.type == "combobox" then
			config.set(cfgKey, ui.drawComboBox(cfg.label, cfg.value, cfg.options, true, cfg.tip, xOffset, yOffset))
		elseif cfg.type == "inputint" then
			config.set(cfgKey, ui.drawInputInt(cfg.label, "##" .. cfgKey, cfg.value, cfg.tip, xOffset, yOffset))
		elseif cfg.type == "inputtext" then
			config.set(cfgKey, ui.drawInputText(cfg.label, "##" .. cfgKey, cfg.value, cfg.tip, xOffset, yOffset))
		end
		xOffset, yOffset, maxY = ui.getNextXY(y, yAvail, xOffset, yOffset, maxY)
	end
end

-- Combine Assist and Camp categories
local assistTabConfigs = {
	"ASSIST",
	"AUTOASSISTAT",
	"ASSISTNAMES",
	"SWITCHWITHMA",
	"CAMPRADIUS",
	"CHASETARGET",
	"CHASEDISTANCE",
	"CHASEPAUSED",
	"RESISTSTOPCOUNT",
}
local function drawAssistTab()
	local x, _ = ImGui.GetContentRegionAvail()
	if ImGui.Button("Reset Camp", x, BUTTON_HEIGHT) then
		camp.setCamp(true)
	end
	local current_camp_radius = config.get("CAMPRADIUS")

	drawConfigurationForCategory(assistTabConfigs)

	if current_camp_radius ~= config.get("CAMPRADIUS") then
		camp.setCamp()
	end
	--uiTheme = ui.drawComboBox('Theme', uiTheme, constants.uiThemes, true, 'Pick a UI color scheme')
end

local function drawSkillsTab()
	local x, y = ImGui.GetCursorPos()
	local xOffset = x
	local yOffset = y
	local maxY = yOffset
	local _, yAvail = ImGui.GetContentRegionAvail()
	for _, key in ipairs(zen.class.OPTS) do
		if key ~= "USEGLYPH" and key ~= "USEINTENSITY" then
			local option = zen.class.OPTS[key]
			local oldValue = option.value
			if option.type == "checkbox" then
				option.value = ui.drawCheckBox(option.label, "##" .. key, option.value, option.tip, xOffset, yOffset)
				if option.value ~= oldValue and option.onChanged ~= nil then
					logger.info("Calling onChanged for %s", key)
					option.onChanged()
				end
				if option.value and option.exclusive then
					zen.class.OPTS[option.exclusive].value = false
				end
			elseif option.type == "combobox" then
				option.value =
					ui.drawComboBox(option.label, option.value, option.options, true, option.tip, xOffset, yOffset)
				if option.value ~= oldValue and option.onChanged ~= nil then
					logger.info("Calling onChanged for %s", key)
					option.onChanged()
				end
			elseif option.type == "inputint" then
				option.value = ui.drawInputInt(option.label, "##" .. key, option.value, option.tip, xOffset, yOffset)
				if option.value ~= oldValue and option.onChanged ~= nil then
					logger.info("Calling onChanged for %s", key)
					option.onChanged()
				end
			elseif option.type == "inputtext" then
				option.value = ui.drawInputText(option.label, "##" .. key, option.value, option.tip, xOffset, yOffset)
				if option.value ~= oldValue and option.onChanged ~= nil then
					logger.info("Calling onChanged for %s", key)
					option.onChanged()
				end
			end
			xOffset, yOffset, maxY = ui.getNextXY(y, yAvail, xOffset, yOffset, maxY)
		end
	end

	local xAvail = ImGui.GetContentRegionAvail()
	x, y = ImGui.GetWindowSize()
	if x < xOffset + X_COLUMN_OFFSET or xAvail > 20 then
		x = math.max(MINIMUM_WIDTH, xOffset + X_COLUMN_OFFSET)
		ImGui.SetWindowSize(x, y)
	end
	if y < maxY or y > maxY + 35 then
		ImGui.SetWindowSize(x, maxY + 35)
	end
end

local function drawHealTab()
	drawConfigurationForCategory(config.getByCategory("Heal"))
end

local function drawBurnTab()
	if ImGui.Button("Burn Now", 112, BUTTON_HEIGHT) then
		mq.cmdf("/%s burnnow", state.class)
	end
	ImGui.SameLine()
	if ImGui.Button("Quick Burn", 112, BUTTON_HEIGHT) then
		mq.cmdf("/%s burnnow quick", state.class)
	end
	ImGui.SameLine()
	if ImGui.Button("Long Burn", 112, BUTTON_HEIGHT) then
		mq.cmdf("/%s burnnow long", state.class)
	end
	drawConfigurationForCategory(config.getByCategory("Burn"))
	if zen.class.drawBurnTab then
		zen.class.drawBurnTab()
	end
end

local function drawPullTab()
	if ImGui.Button("Add Ignore", HALF_BUTTON_WIDTH, BUTTON_HEIGHT) then
		mq.cmdf("/%s ignore", state.class)
	end
	ImGui.SameLine()
	if ImGui.Button("Remove Ignore", HALF_BUTTON_WIDTH, BUTTON_HEIGHT) then
		mq.cmdf("/%s unignore", state.class)
	end
	local current_radius = config.PULLRADIUS.value
	local current_pullarc = config.PULLARC.value

	drawConfigurationForCategory(config.getByCategory("Pull"))

	if current_radius ~= config.get("PULLRADIUS") or current_pullarc ~= config.get("PULLARC") then
		camp.setCamp()
	end
end

local function drawRestTab()
	drawConfigurationForCategory(config.getByCategory("Rest"))
end

local function drawDebugComboBox()
	ImGui.PushItemWidth(300)
	if ImGui.BeginCombo("##debugoptions", "debug options") then
		for category, subcategories in pairs(logger.flags) do
			for subcategory, enabled in pairs(subcategories) do
				logger.flags[category][subcategory] = ImGui.Checkbox(category .. " - " .. subcategory, enabled)
			end
		end
		ImGui.EndCombo()
	end
	ImGui.PopItemWidth()
end

local function drawDebugTab()
	local x, _ = ImGui.GetContentRegionAvail()
	local buttonWidth = (x / 2)
	if ImGui.Button("Restart ZEN", buttonWidth, BUTTON_HEIGHT) then
		mq.cmd("/multiline ; /lua stop zen ; /timed 10 /lua run zen")
	end
	ImGui.SameLine()
	if ImGui.Button("View Ability Lists", x, BUTTON_HEIGHT) then
		abilityGUIOpen = true
	end
	config.TIMESTAMPS.value =
		ui.drawCheckBox("Timestamps", "##timestamps", config.TIMESTAMPS.value, "Toggle timestamps on log messages")
	logger.timestamps = config.TIMESTAMPS.value
	drawDebugComboBox()
	ImGui.TextColored(YELLOW, "Mode:")
	ImGui.SameLine()
	ImGui.SetCursorPosX(150)
	ImGui.TextColored(WHITE, "%s", config.get("MODE"))

	ImGui.TextColored(YELLOW, "Camp:")
	ImGui.SameLine()
	ImGui.SetCursorPosX(150)
	if camp.Active then
		ImGui.TextColored(YELLOW, "X: %.02f  Y: %.02f  Z: %.02f", camp.X, camp.Y, camp.Z)
		ImGui.TextColored(YELLOW, "Radius:")
		ImGui.SameLine()
		ImGui.SetCursorPosX(150)
		ImGui.TextColored(YELLOW, "%d", config.CAMPRADIUS.value)
		ImGui.TextColored(YELLOW, "Distance from camp:")
		ImGui.SameLine()
		ImGui.SetCursorPosX(150)
		ImGui.TextColored(YELLOW, "%d", math.sqrt(helpers.distance(mq.TLO.Me.X(), mq.TLO.Me.Y(), camp.X, camp.Y)))
	else
		ImGui.TextColored(RED, "--")
	end

	for k, v in pairs(state) do
		if type(v) ~= "table" and type(v) ~= "function" then
			ImGui.TextColored(YELLOW, "%s:", k)
			ImGui.SameLine()
			ImGui.SetCursorPosX(150)
			ImGui.TextColored(RED, "%s", v)
		end
	end
end

local function drawHUD()
	--[[ImGui.TextColored(YELLOW, 'Assist Mob ID:')
	ImGui.SameLine()
	ImGui.SetCursorPosX(150)
	ImGui.TextColored(RED, '%s', state.assistMobID)
	ImGui.TextColored(YELLOW, 'Tank Mob ID:')
	ImGui.SameLine()
	ImGui.SetCursorPosX(150)
	ImGui.TextColored(RED, '%s', state.tankMobID)
	ImGui.TextColored(YELLOW, 'Pull Mob ID:')
	ImGui.SameLine()
	ImGui.SetCursorPosX(150)
	ImGui.TextColored(RED, '%s', state.pullMobID)]]
end

local uiTabs = {
	--{label='HUD', draw=drawHUD},
	{ label = "General", draw = drawAssistTab },
	{ label = "Skills", draw = drawSkillsTab },
	--{label=constants.icons.FA_HEART..' Heal', draw=drawHealTab, color=LIGHT_BLUE},
	{ label = constants.icons.FA_FIRE .. " Burn", draw = drawBurnTab, color = ORANGE },
	{ label = "Pull", draw = drawPullTab },
	{ label = "Rest", draw = drawRestTab },
	{ label = "Debug", draw = drawDebugTab },
}
local function drawBody()
	if ImGui.BeginTabBar("##tabbar") then
		for _, tab in ipairs(uiTabs) do
			if tab.color then
				ImGui.PushStyleColor(ImGuiCol.Text, tab.color)
			end
			if ImGui.BeginTabItem(tab.label) then
				if tab.color then
					ImGui.PopStyleColor()
				end
				if ImGui.BeginChild(tab.label, -1, -1, false, ImGuiWindowFlags.HorizontalScrollbar) then
					ImGui.PushItemWidth(item_width)
					tab.draw()
					ImGui.PopItemWidth()
				end
				ImGui.EndChild()
				ImGui.EndTabItem()
			elseif tab.color then
				ImGui.PopStyleColor()
			end
		end
		ImGui.EndTabBar()
	end
end

local function drawHeader()
	local x, _ = ImGui.GetContentRegionAvail()
	local buttonWidth = (x / 2) - 22
	if state.paused then
		if ImGui.Button(constants.icons.FA_PLAY, buttonWidth, BUTTON_HEIGHT) then
			camp.setCamp()
			BL.warn("Changing PAUSED state to false")

			state.paused = false
		end
	else
		if ImGui.Button(constants.icons.FA_PAUSE, buttonWidth, BUTTON_HEIGHT) then
			BL.warn("Changing PAUSED state to TRUE")

			state.paused = true
			state.resetCombatState()
			mq.cmd("/stopcast")
		end
	end
	helpMarker("Pause/Resume")
	ImGui.SameLine()
	if ImGui.Button(constants.icons.FA_SAVE, buttonWidth, BUTTON_HEIGHT) then
		zen.class.saveSettings()
	end
	helpMarker("Save Settings")
	ImGui.SameLine()
	if ImGui.Button(constants.icons.MD_HELP, -1, BUTTON_HEIGHT) then
		helpGUIOpen = true
	end
	helpMarker("Help")
	ImGui.Text("Bot Status: ")
	ImGui.SameLine()
	ImGui.SetCursorPosX(buttonWidth + 16)
	if state.paused then
		ImGui.TextColored(RED, "PAUSED")
	else
		ImGui.TextColored(GREEN, "RUNNING")
	end
	local current_mode = config.get("MODE")
	ImGui.PushItemWidth(item_width)
	mid_x = buttonWidth + 8
	config.MODE.value = ui.drawComboBox("Mode", config.get("MODE"), mode.mode_names, false, config.MODE.tip)
	mode.currentMode = mode.fromString(config.get("MODE"))
	mid_x = 140
	ImGui.PopItemWidth()
	if ImGui.Button("Mem Songs", 100, BUTTON_HEIGHT) then
		zen.class.signalSpellsChanged()
	end
	ImGui.SameLine()
	local memCount = "Memmed now: " .. (zen.class.gemsInUse or "0")
	ImGui.LabelText("", memCount)
	if current_mode ~= config.get("MODE") and not state.paused then
		camp.setCamp()
	end
end

local function pushStyle(theme)
	local t = constants.uiThemes[theme]
	ImGui.PushStyleColor(ImGuiCol.WindowBg, t.windowbg)
	ImGui.PushStyleColor(ImGuiCol.TitleBg, t.bg)
	ImGui.PushStyleColor(ImGuiCol.TitleBgActive, t.active)
	ImGui.PushStyleColor(ImGuiCol.FrameBg, t.bg)
	ImGui.PushStyleColor(ImGuiCol.FrameBgHovered, t.hovered)
	ImGui.PushStyleColor(ImGuiCol.FrameBgActive, t.active)
	ImGui.PushStyleColor(ImGuiCol.Button, t.button)
	ImGui.PushStyleColor(ImGuiCol.ButtonHovered, t.hovered)
	ImGui.PushStyleColor(ImGuiCol.ButtonActive, t.active)
	ImGui.PushStyleColor(ImGuiCol.PopupBg, t.bg)
	ImGui.PushStyleColor(ImGuiCol.Tab, 0, 0, 0, 0)
	ImGui.PushStyleColor(ImGuiCol.TabActive, t.active)
	ImGui.PushStyleColor(ImGuiCol.TabHovered, t.hovered)
	ImGui.PushStyleColor(ImGuiCol.TabUnfocused, t.bg)
	ImGui.PushStyleColor(ImGuiCol.TabUnfocusedActive, t.hovered)
	ImGui.PushStyleColor(ImGuiCol.TextDisabled, t.text)
	ImGui.PushStyleColor(ImGuiCol.CheckMark, t.text)
	ImGui.PushStyleColor(ImGuiCol.Separator, t.hovered)

	ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 10)
end

local function popStyles()
	ImGui.PopStyleColor(18)

	ImGui.PopStyleVar(1)
end

local function drawAbilityInspector()
	if abilityGUIOpen then
		abilityGUIOpen, shouldDrawAbilityGUI = ImGui.Begin(
			("Ability Inspector##ZENBOTUI%s"):format(state.class),
			abilityGUIOpen,
			ImGuiWindowFlags.AlwaysAutoResize
		)
		if shouldDrawAbilityGUI then
			if ImGui.TreeNode("Class Order") then
				for _, routine in ipairs(zen.class.classOrder) do
					ImGui.Text(routine)
				end
				ImGui.TreePop()
			end
			if mq.TLO.Me.Class.CanCast() then
				if ImGui.TreeNode("Spells") then
					for alias, spell in pairs(zen.class.spells) do
						if ImGui.TreeNode(alias .. "##spellalias") then
							ImGui.Text("Name: %s", spell.Name)
							for opt, value in pairs(spell) do
								if
									opt ~= "Name"
									and (type(value) == "number" or type(value) == "string" or type(value) == "boolean")
								then
									ImGui.Text("%s: %s", opt, value)
								end
							end
							ImGui.TreePop()
						end
					end
					ImGui.TreePop()
				end
				if ImGui.TreeNode("Spell Sets") then
					for spellSetName, spellSet in pairs(zen.class.spellRotations) do
						if ImGui.TreeNode(spellSetName .. "##spellset") then
							for _, spell in ipairs(spellSet) do
								ImGui.Text(spell.Name)
							end
							ImGui.TreePop()
						end
					end
					ImGui.TreePop()
				end
			end
			if ImGui.TreeNode("Lists") then
				for i, list in ipairs(constants.classLists) do
					if #zen.class[list] > 0 then
						if ImGui.TreeNode(list .. "##lists" .. i) then
							for j, ability in ipairs(zen.class[list]) do
								if ImGui.TreeNode(ability.Name .. "##list" .. list .. i .. j) then
									for opt, value in pairs(ability) do
										if
											opt ~= "Name"
											and (
												type(value) == "number"
												or type(value) == "string"
												or type(value) == "boolean"
											)
										then
											local color = WHITE
											if opt == "opt" then
												if zen.class.isEnabled(value) then
													color = GREEN
												else
													color = RED
												end
											end
											ImGui.TextColored(color, "%s: %s", opt, value)
										end
									end
									ImGui.TreePop()
								end
							end
							ImGui.TreePop()
						end
					elseif list == "clickies" then
						if ImGui.TreeNode(list .. "##lists" .. i) then
							for clickyName, clicky in pairs(zen.class.clickies) do
								ImGui.Text("%s (%s)", clickyName, clicky.clickyType)
							end
							ImGui.TreePop()
						end
					end
				end
				if zen.class.rezAbility then
					if ImGui.TreeNode("rezAbility") then
						for opt, value in pairs(zen.class.rezAbility) do
							if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
								-- opt ~= 'Name' and
								local color = WHITE
								if opt == "opt" then
									if zen.class.isEnabled(value) then
										color = GREEN
									else
										color = RED
									end
								end
								ImGui.TextColored(color, "%s: %s", opt, value)
							end
						end
						ImGui.TreePop()
					end
				end
				ImGui.TreePop()
			end
		end
		ImGui.End()
	end
end

local function drawHelpWindow()
	if helpGUIOpen then
		helpGUIOpen, shouldDrawHelpGUI =
			ImGui.Begin(("ZEN Help##ZENBOTUI%s"):format(state.class), helpGUIOpen, ImGuiWindowFlags.AlwaysAutoResize)
		if shouldDrawHelpGUI then
			ImGui.PushTextWrapPos(750)
			if ImGui.TreeNode("General Commands") then
				for _, command in ipairs(constants.commandHelp) do
					ImGui.TextColored(YELLOW, "/zen " .. command.command)
					ImGui.SameLine()
					ImGui.Text(command.tip)
				end
				ImGui.TextColored(YELLOW, "/nowcast [name] alias <targetID>")
				ImGui.SameLine()
				ImGui.Text("Tells the named character or yourself to cast a spell on the specified target ID.")
				ImGui.TreePop()
			end
			for _, category in ipairs(config.categories()) do
				local categoryConfigs = config.getByCategory(category)
				if ImGui.TreeNode(category .. " Configuration") then
					for _, key in ipairs(categoryConfigs) do
						local cfg = config[key]
						if type(cfg) == "table" then
							ImGui.TextColored(YELLOW, "/zen %s <%s>", key, type(cfg.value))
							ImGui.SameLine()
							ImGui.Text(cfg.tip)
						end
					end
					ImGui.TreePop()
				end
			end
			if ImGui.TreeNode("Class Configuration") then
				for key, value in pairs(zen.class.OPTS) do
					local valueType = type(value.value)
					if valueType == "string" or valueType == "number" or valueType == "boolean" then
						ImGui.TextColored(YELLOW, "/zen %s <%s>", key, valueType)
						ImGui.SameLine()
						ImGui.Text("%s", value.tip)
					end
				end
				ImGui.TreePop()
			end
			if ImGui.TreeNode("Gear Check (WARNING*: Characters announce their gear to guild chat!") then
				ImGui.TextColored(YELLOW, "/tell <name> gear <slotname>")
				ImGui.TextColored(YELLOW, "Slot Names")
				ImGui.SameLine()
				ImGui.Text(constants.slotList)
				ImGui.TreePop()
			end
			if ImGui.TreeNode("Buff Begging  (WARNING*: Characters accounce requests to group or raid chat!") then
				ImGui.TextColored(YELLOW, "/tell <name> <alias>")
				ImGui.TextColored(YELLOW, "Aliases:")
				for alias, _ in pairs(zen.class.requestAliases) do
					ImGui.Text(alias)
				end
				ImGui.TreePop()
			end
			ImGui.PopTextWrapPos()
		end
		ImGui.End()
	end
end

-- ImGui main function for rendering the UI window
function ui.main()
	if not openGUI then
		return
	end
	pushStyle(uiTheme)
	openGUI, shouldDrawGUI =
		ImGui.Begin(string.format("ZEN Bot 1.0 - %s###ZENBOTUI%s", state.class, state.class), openGUI, 0)
	if shouldDrawGUI then
		drawHeader()
		drawBody()
	end
	ImGui.End()
	drawAbilityInspector()
	drawHelpWindow()
	popStyles()
end

return ui
