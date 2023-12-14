---@type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")
local BL = require("biggerlib")
local Burn = require("burn")
local settings = require("settings")

local State = require("state")
local ui = {
	events = {},
	internal = {},
}

local selectedListItem = { nil, 0 } -- {key, index}
local selectedClass = "Cleric" -- Left hand menu selected item

local somekvpair = "default"
function ui.buildWindow()
	local update
	ImGui.SetWindowSize(240, 500, ImGuiCond.Once)
	local x, y = ImGui.GetContentRegionAvail()
	local buttonHalfWidth = (x / 2) - 4
	local buttonThirdWidth = (x / 4) - 1

	if ImGui.Button("Pause") then
		State.togglePause()
	end
	ImGui.SameLine()
	if State.paused == false then
		ImGui.TextColored(0, 0.75, 0, 1, "Running")
	else
		ImGui.TextColored(0.75, 0, 0, 1, "Paused")
	end

	ImGui.Separator()

	State.driver, update = ImGui.Checkbox("Driver", State.driver)
	if update then
		settings.boolSync()
	end

	if ImGui.Button("Refresh", buttonHalfWidth, 0) then
		ui.eventHandlers.refresh()
	end
	ImGui.Separator()
	if ImGui.Button("BURN NOW", buttonHalfWidth, 0) then
		Burn.triggerFullBurn()
	end
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
		printf(
			"\arWARNING [%s]: %s value is not a %s: type=%s value=%s\a-x",
			key,
			inputtype,
			typestring,
			type(value),
			tostring(value)
		)
	end
end

local leftPanelWidth = 150
local leftPanelDefaultWidth = 150
local TABLE_FLAGS = 0
function ui.LeftPaneWindow()
	local x, y = ImGui.GetContentRegionAvail()
	if ImGui.BeginChild("left", leftPanelWidth, y - 1, true) then
		if ImGui.BeginTable("SelectSectionTable", 1, TABLE_FLAGS, 0, 0, 0.0) then
			ImGui.TableSetupColumn("Class", 0, -1.0, 1)
			ImGui.TableSetupScrollFreeze(0, 1) -- Make row always visible
			ImGui.TableHeadersRow()

			for key, className in pairs(State.Classes) do
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
				if popStyleColor then
					ImGui.PopStyleColor()
				end
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
	ImGui.Button("##splitter", thickness, -1)
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

		spellInput = ImGui.InputText("", tostring(spellInput))

		ImGui.Separator()
		-- Draw spells for class
		for _, spell in ipairs(SPELLS_BY_CLASS[className]) do
			ui.drawSpell(spell)
			ImGui.SameLine()
			ImGui.Text(spell)
			ImGui.SameLine()
			local doSpell = ImGui.Button("Do Now")
			if doSpell then
				BL.log.info("Doing spell stub: " .. spell)
				Burn.emitSpellEvent(className, spell)
			end
		end
		ImGui.Separator()

		-- Draw characters of class with enable/disable checkbox
		ImGui.TextColored(0, 0, 1, 1, "Toon List")
		--utils.dump(state.ClassInZone, "Dumping class by classname")
		for keyClassStr, valueListOfToons in pairs(State.ClassInZone) do
			--printf("Comparing %s to %s", value, className)
			--utils.dump(key, "Dumping key in classinzone")
			--utils.dump(value, "Dumping value in classinzone")
			if keyClassStr == className then
				-- Do something with the matching key
				--BL.log.dump(valueListOfToons, "Dumping valueListOfToons")

				-- valueListOfToons is now hashmap of {"krompe" => {SpellState = {spellname = {LastUsed = 0}}}, "otherChar" => {SpellState = {spellname = {LastUsed = 0}}} }
				for charName, spellState in pairs(valueListOfToons) do
					--print("Found matching value: " .. toon.CleanName())
					--BL.log.dump(toon, "Dumping toon")
					charName = charName
					if charName == nil then
						charName = "NIL"
					end
					ImGui.Text(charName)

					--ImGui.Checkbox(charName, true)
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
	ui.CheckInputType(label, value, "string", "InputText")
	return ImGui.InputText(label, tostring(value))
end

function ui.drawSpell(spellName)
	-- Get the table of icons, which live in an animation texture
	local anim = mq.FindTextureAnimation("A_SpellIcons")
	-- get the spell icon
	local spell = mq.TLO.Spell(spellName)
	if not spell then
		return
	end
	-- once you know the index of the icon inside the texture, set the cell
	anim:SetTextureCell(spell.SpellIcon())
	-- render the texture at the cell
	---@diagnostic disable-next-line: missing-parameter
	ImGui.DrawTextureAnimation(anim)
end

function ui.mainWindowEvent()
	Open, ShowUI = ImGui.Begin("Burninator", true)
	if ShowUI then
		ui.buildWindow()
	end
	ImGui.End()
end

function ui.init(eventHandlers)
	ui.eventHandlers = eventHandlers
	mq.imgui.init("Burninator", ui.mainWindowEvent)
end

return ui
