---@type Mq
-- version 0.06
-- Accompanying script for Offtank.lua, does nothing but make sure group role isn't set to MT
-- and gives MTs something to run

local mq = require('mq')
--- @type ImGui
require('ImGui')

local open_gui = true
local should_draw_gui = true
local pause = false

local function removeMainTankRole(mtName)
	mq.cmd('/grouproles unset ' .. mtName .. ' 1')
	print('Removed main tank role')
end

local function getGroupMainTank()
	return mq.TLO.Group.MainTank()
end

local function checkGroupTankRoleIsEmpty()
	local groupRole = getGroupMainTank()

	if groupRole == nil then
		return true
	else
		print('WARNING: GROUP MAIN TANK ROLE IS SET!')
		mq.cmd('/rs WARNING: MY GROUP MAIN TANK ROLE IS ENABLED')
		removeMainTankRole(groupRole)
		return false
	end
end

local function init()
	local groupMT = getGroupMainTank()
	if groupMT ~= nil then
		removeMainTankRole(groupMT)
	end
	return checkGroupTankRoleIsEmpty()
end

local function main()
	init()

	if pause then
		mq.delay(1000)
		return
	end
	-- Make sure group MT role didn't get switched back on
	checkGroupTankRoleIsEmpty()
	mq.delay(1000)
end

local function OT_UI()
	if not open_gui or mq.TLO.MacroQuest.GameState() ~= 'INGAME' then
		return
	end
	open_gui, should_draw_gui = ImGui.Begin('Prestige MainTank', open_gui)

	if should_draw_gui then
		if pause then
			if ImGui.Button('Resume') then
				pause = false
			end
		else
			if ImGui.Button('Pause') then
				pause = true
				mq.cmd('/squelch /nav stop')
			end
		end
	end
	ImGui.End()
end

mq.imgui.init('MainTanking', OT_UI)
init()

while true do
	main()
end
