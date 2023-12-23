--- @type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")
local actors = require("actors")
local BL = require("biggerlib")

local shouldTerminate = false

local group = {}
--- Add another agent to our list of group members, happens in response to an actor announcing
local function addGroupMember(sender)
	--BL.info("Adding group member from sender %s", sender.character)
	group[sender.character] = "Loading..."
end

local function removeGroupMember(sender)
	--BL.info("Removing group member %s", sender.character)
	table.remove(group, sender.character)
end

-- this is then message handler, so handle all messages we expect
-- we are guaranteed that the only messages here we receive are
-- ones that we send, so assume the structure of the message
local actor = actors.register(function(message)
	if message.content.id == "echoCurrentTaskStep" and message.sender then
		-- request came in asking me to send my current quest step
		local taskName = mq.TLO.Window("TaskWnd/TASK_TaskWnd/TASK_TaskList").List(1, 3) or "STEP NOT FOUND"
		---@diagnostic disable-next-line: param-type-mismatch
		local taskStep = mq.TLO.Task(taskName).Step()
		-- Respond with which step I'm on
		message:send({ id = "currentTaskStepResponse", step = taskStep })
	elseif message.content.id == "currentTaskStepResponse" then
		-- someone sent back their current Task Step from echoCurrentTaskStep
		message:reply(0, {})
		-- Add their current step to our GUI display
		group[message.sender.character] = message.content.step
	elseif message.content.id == "announce" then
		-- a new actor (group member) has joined
		addGroupMember(message.sender)
	elseif message.content.id == "drop" then
		-- a group member has dropped, remove them from the list
		removeGroupMember(message.sender)
	end
end)

local open_gui = true
local should_draw_gui = true

local tableRandom = math.random(1, 100)

local function drawNameButton(name)
	local buttonText = name
	local col = nil

	-- Set color to normal one for name
	col = { 0, 1, 0 }
	ImGui.PushStyleColor(ImGuiCol.Text, col[1], col[2], col[3], 1)

	if ImGui.SmallButton(buttonText .. "##" .. name) then
		mq.cmdf("/squelch /dex %s /foreground", name)
	end
	ImGui.PopStyleColor(1)
end

local function QuestHud_UI()
	if not open_gui or mq.TLO.MacroQuest.GameState() ~= "INGAME" then
		return
	end
	open_gui, should_draw_gui = ImGui.Begin("QuestHUD", open_gui)
	if should_draw_gui then
		if ImGui.GetWindowHeight() <= 360 or ImGui.GetWindowWidth() <= 177 then
			ImGui.SetWindowSize(360, 177)
		end

		local flags = bit32.bor(
			ImGuiTableFlags.Resizable,
			ImGuiTableFlags.Reorderable,
			ImGuiTableFlags.Hideable,
			ImGuiTableFlags.RowBg,
			ImGuiTableFlags.BordersOuter,
			ImGuiTableFlags.BordersV,
			ImGuiTableFlags.ScrollY,
			ImGuiTableFlags.NoSavedSettings
		)
		local tabName = "Characters"
		if ImGui.BeginTable("##bhtable" .. tabName .. tostring(tableRandom), 2, flags, 0, 0, 0.0) then
			ImGui.TableSetupColumn(
				"Name",
				bit32.bor(ImGuiTableColumnFlags.DefaultSort, ImGuiTableColumnFlags.WidthFixed),
				60.0
			)
			ImGui.TableSetupColumn("Quest Step", bit32.bor(ImGuiTableColumnFlags.WidthStretch), -1.0)

			ImGui.TableHeadersRow()
			for member, step in pairs(group) do
				ImGui.TableNextRow()
				ImGui.TableNextColumn()
				drawNameButton(member)
				ImGui.TableNextColumn()
				ImGui.Text(step)
			end
			ImGui.EndTable()
		end
	end
	ImGui.End()
end

mq.imgui.init("QuestHUD", QuestHud_UI)

while not shouldTerminate do
	actor:send({ id = "echoCurrentTaskStep" })
	mq.delay(1021)
end
