---@type Mq
local mq = require 'mq'
--- @type ImGui
require 'ImGui'
local settings = require 'settings'
local utils = require 'utils'

local ui = {
	events = {},
	internal = {},
}

local selectedListItem = { nil, 0 } -- {key, index}
local selectedSection = 'Cleric'    -- Left hand menu selected item

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
	ui.drawSpell()
	ImGui.Separator()
	somekvpair = ui.internal.DrawKeyAndInputText('keytext', 'label', somekvpair)
	ImGui.Separator()
	ui.LeftPaneWindow()

	--if ImGui.Button('Burn now', buttonHalfWidth, 0) then burnNow = true end
	--ImGui.PopStyleColor()
end

function ui.internal.CheckInputType(key, value, typestring, inputtype)
	if type(value) ~= typestring then
		printf('\arWARNING [%s]: %s value is not a %s: type=%s value=%s\a-x', key, inputtype, typestring,
			type(value), tostring(value))
	end
end

local leftPanelWidth = 150
local TABLE_FLAGS = 0
function ui.LeftPaneWindow()
	local x, y = ImGui.GetContentRegionAvail()
	if ImGui.BeginChild("left", leftPanelWidth, y - 1, true) then
		if ImGui.BeginTable('SelectSectionTable', 1, TABLE_FLAGS, 0, 0, 0.0) then
			ImGui.TableSetupColumn('Class', 0, -1.0, 1)
			ImGui.TableSetupScrollFreeze(0, 1) -- Make row always visible
			ImGui.TableHeadersRow()

			for key, className in pairs(utils.Classes) do
				ImGui.TableNextRow()
				ImGui.TableNextColumn()
				local popStyleColor = false
				ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)				
				popStyleColor = true
				
				local sel = ImGui.Selectable(className, selectedSection == className)
				if sel and selectedSection ~= className then
					selectedListItem = { nil, 0 }
					selectedSection = className
				end
				if popStyleColor then ImGui.PopStyleColor() end
			end
			ImGui.Separator()

			ImGui.EndTable()
		end
	end
	ImGui.EndChild()
end

function ui.internal.DrawKeyAndInputText(keyText, label, value)
	ImGui.PushStyleColor(ImGuiCol.Text, 1, 1, 0, 1)
	ImGui.Text(keyText)
	ImGui.PopStyleColor()
	ImGui.SameLine()

	ImGui.SameLine()
	ImGui.SetCursorPosX(175)
	-- the first part, spell/item/disc name, /command, etc
	ui.internal.CheckInputType(label, value, 'string', 'InputText')
	return ImGui.InputText(label, tostring(value))
end

function ui.drawSpell()
	-- Get the table of icons, which live in an animation texture
	local anim = mq.FindTextureAnimation('A_SpellIcons')
	-- get the spell icon
	local spell = mq.TLO.Spell("Unified Hand of Persistence")
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
