--[[
    Updates all Bigger luas
]]

---@type Mq
local mq = require('mq')
---@type ImGui
local imgui = require 'ImGui'

-- set variables
local checkBox1 = false --(used to track checkbox status )
local checkBox2 = true

-- function to run the window
function changeMe(open)
	-- We specify a default position/size in case there's no data in the .ini file.
	-- We only do it to make the demo applications a little more welcoming, but typically this isn't required.
	local main_viewport = imgui.GetMainViewport()
	imgui.SetNextWindowPos(main_viewport.WorkPos.x + 650, main_viewport.WorkPos.y + 20, ImGuiCond.FirstUseEver)

	-- change the window size
	imgui.SetNextWindowSize(600, 300, ImGuiCond.FirstUseEver)

	local show = false
	open, show = imgui.Begin("changeMe", open)

	if not show then
		ImGui.End()
		return open
	end

	ImGui.PushItemWidth(ImGui.GetFontSize() * -12);

	-- Main window element area --

	-- Beginning of window elements
	imgui.Text("Text")
	imgui.Text("\n") -- To create a new line
	if ImGui.Button("Button") then
		-- What you want the button to do
		print('Button pressed') -- an example. Can run functions
	end
	imgui.SameLine()
	checkBox1 = imgui.Checkbox("Box 1", checkBox1) -- toggling this updates the checkBox1 variable. Use in other 'if' statements
	imgui.SameLine(300)                         -- You can specify distance. Number is how many pixels from left side of window
	checkBox2 = imgui.Checkbox("Box 2", checkBox2)
	ImGui.Separator()

	-- End of main window element area --

	-- Required for window elements
	imgui.Spacing()
	imgui.PopItemWidth()
	imgui.End()
	return open
end

local openGUI = true

ImGui.Register('changeMe', function()
	openGUI = changeMe(openGUI)
end)

while openGUI do
	--probably unnecessary but i forget to do it when i need it otherwise
	mq.doevents()
	mq.delay(1000)
end
