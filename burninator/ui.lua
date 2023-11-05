---@type Mq
local mq = require 'mq'
--- @type ImGui
require 'ImGui'
local fun = require "fun"

local settings = require 'settings'
local utils = require 'utils'
local state = require 'state'
local ui = {
	events = {},
	internal = {},
}

local selectedListItem = { nil, 0 } -- {key, index}
local selectedClass = 'Cleric'      -- Left hand menu selected item

local somekvpair = "default"
function ui.buildWindow()
	local update
	ImGui.SetWindowSize(240, 500, ImGuiCond.Once)
	local x, y = ImGui.GetContentRegionAvail()
	local buttonHalfWidth = (x / 2) - 4
	local buttonThirdWidth = (x / 4) - 1

	local boolSettings = settings.boolSettings
	local boolSwitch = settings.boolSwitch

	if ImGui.Button('Pause') then settings.togglePause() end
	ImGui.SameLine()
	if settings.Pause == false then
		ImGui.TextColored(0, 0.75, 0, 1, 'Running')
	else
		ImGui.TextColored(0.75, 0, 0, 1,
			'Paused')
	end

	ImGui.Separator()

	boolSettings.isDriver, update = ImGui.Checkbox('Driver', boolSettings.combat)
	if update then boolSwitch() end

	if ImGui.Button('Refresh', buttonHalfWidth, 0) then ui.eventHandlers.refresh() end
	----ImGui.SameLine()
	----if ImGui.Button('Pause hide 60', buttonHalfWidth, 0) then pauseHide(60) end

	ImGui.Separator()
	--ui.drawSpell()
	--ImGui.Separator()
	--somekvpair = ui.drawKeyAndInputText('keytext', 'label', somekvpair)
	--ImGui.Separator()
	ui.drawWindowPanels()

	--if ImGui.Button('Burn now', buttonHalfWidth, 0) then burnNow = true end
	--ImGui.PopStyleColor()
end

function ui.CheckInputType(key, value, typestring, inputtype)
	if type(value) ~= typestring then
		printf('\arWARNING [%s]: %s value is not a %s: type=%s value=%s\a-x', key, inputtype, typestring,
			type(value), tostring(value))
	end
end

local leftPanelWidth = 150
local leftPanelDefaultWidth = 150
local TABLE_FLAGS = 0
function ui.LeftPaneWindow()
	local x, y = ImGui.GetContentRegionAvail()
	if ImGui.BeginChild("left", leftPanelWidth, y - 1, true) then
		if ImGui.BeginTable('SelectSectionTable', 1, TABLE_FLAGS, 0, 0, 0.0) then
			ImGui.TableSetupColumn('Class', 0, -1.0, 1)
			ImGui.TableSetupScrollFreeze(0, 1) -- Make row always visible
			ImGui.TableHeadersRow()

			for key, className in pairs(state.Classes) do
				ImGui.TableNextRow()
				ImGui.TableNextColumn()
				local popStyleColor = false
				ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
				popStyleColor = true

				local sel = ImGui.Selectable(className, selectedClass == className)
				if sel and selectedClass ~= className then
					selectedListItem = { nil, 0 }
					selectedClass = className
				end
				if popStyleColor then ImGui.PopStyleColor() end
			end
			ImGui.Separator()

			ImGui.EndTable()
		end
	end
	ImGui.EndChild()
end

function ui.RightPaneWindow()
	local x, y = ImGui.GetContentRegionAvail()
	if ImGui.BeginChild("right", x, y - 1, true) then
		ui.drawClassSection(selectedClass)
	end
	ImGui.EndChild()
end

function ui.drawSplitter(thickness, size0, min_size0)
	local x, y = ImGui.GetCursorPos()
	local delta = 0
	ImGui.SetCursorPosX(x + size0)

	ImGui.PushStyleColor(ImGuiCol.Button, 0, 0, 0, 0)
	ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0, 0, 0, 0)
	ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.6, 0.6, 0.6, 0.1)
	ImGui.Button('##splitter', thickness, -1)
	ImGui.PopStyleColor(3)

	ImGui.SetItemAllowOverlap()

	if ImGui.IsItemActive() then
		delta, _ = ImGui.GetMouseDragDelta()

		if delta < min_size0 - size0 then
			delta = min_size0 - size0
		end
		if delta > 200 - size0 then
			delta = 200 - size0
		end

		size0 = size0 + delta
		leftPanelWidth = size0
	else
		leftPanelDefaultWidth = leftPanelWidth
	end
	ImGui.SetCursorPosX(x)
	ImGui.SetCursorPosY(y)
end

local spellInput = ""

function ui.drawClassSection(className, sectionProperties)
	-- Draw main section control switches first
	if ImGui.BeginChild(className) then
		if ImGui.Button("Add Spell") then
			print("Adding new spell to " .. className)
			table.insert(SPELLS_BY_CLASS[className], spellInput)
		end
		ImGui.SameLine()

		spellInput = ImGui.InputText('', tostring(spellInput))


		ImGui.Separator()
		-- Draw spells for class
		for _, spell in ipairs(SPELLS_BY_CLASS[className]) do
			ui.drawSpell(spell)
			ImGui.SameLine()
			ImGui.Text(spell)
			ImGui.SameLine()
			local doSpell = ImGui.Button("Do Now")
			if doSpell then
				print("Doing spell " .. spell)
			end
		end
		ImGui.Separator()
		-- Draw characters of class with enable/disable checkbox
		--utils.dump(state.ClassInZone, "Dumping class by classname")
		for keyClassStr, valueListOfToons in pairs(state.ClassInZone) do
			--printf("Comparing %s to %s", value, className)
			--utils.dump(key, "Dumping key in classinzone")
			--utils.dump(value, "Dumping value in classinzone")
			if keyClassStr == className then
				-- Do something with the matching key
				for _, toon in ipairs(valueListOfToons) do
					--print("Found matching value: " .. toon.CleanName())
					ImGui.Checkbox(toon.CleanName(), true)
				end
			end
		end
	end

	ImGui.EndChild()
end

function ui.drawWindowPanels()
	ui.drawSplitter(8, leftPanelDefaultWidth, 75)
	ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 2, 2)
	ui.LeftPaneWindow()
	ImGui.SameLine()
	ui.RightPaneWindow()
	ImGui.PopStyleVar()
end

function ui.drawKeyAndInputText(keyText, label, value)
	ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 0, 1)
	ImGui.Text(keyText)
	ImGui.PopStyleColor()
	ImGui.SameLine()

	ImGui.SameLine()
	ImGui.SetCursorPosX(175)
	-- the first part, spell/item/disc name, /command, etc
	ui.CheckInputType(label, value, 'string', 'InputText')
	return ImGui.InputText(label, tostring(value))
end

function ui.drawSpell(spellName)
	-- Get the table of icons, which live in an animation texture
	local anim = mq.FindTextureAnimation('A_SpellIcons')
	-- get the spell icon
	local spell = mq.TLO.Spell(spellName)
	if not spell then
		return
	end
	-- once you know the index of the icon inside the texture, set the cell
	anim:SetTextureCell(spell.SpellIcon())
	-- render the texture at the cell
	ImGui.DrawTextureAnimation(anim)
end

function ui.mainWindowEvent()
	Open, ShowUI = ImGui.Begin('Burninator', true)
	if ShowUI then
		ui.buildWindow()
	end
	ImGui.End()
end

function ui.init(eventHandlers)
	ui.eventHandlers = eventHandlers
	mq.imgui.init('Burninator', ui.mainWindowEvent)
end

return ui
