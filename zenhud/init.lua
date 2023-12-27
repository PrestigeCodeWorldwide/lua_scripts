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
	group[sender.character] = {
		taskName = "Loading...",
		taskStep = "",
		taskStatus = "",
	}
end

local function removeGroupMember(sender)
	--BL.info("Removing group member %s", sender.character)
	table.remove(group, sender.character)
end

local function statusIsDone(status)
	local status = tostring(status)
	local done = status == "DONE" or status == "Done"
	--mq.cmdf("/g status itself is: %s ,,, statusIsDone: %s", status, tostring(done))
	return done
end

local function getMyCurrentQuestInfo()
	-- tostring to appease the linter
	local taskName = tostring(mq.TLO.Window("TaskWnd/TASK_TaskWnd/TASK_TaskList").List(1, 3))

	local taskStep = mq.TLO.Task(taskName).Step

	local taskStatus = ""
	local CurrentObjectiveIndex = 1
	local noForeverLoop = 0
	-- This is infinite looping somehow
	repeat
		taskStatus = mq.TLO.Task(taskName).Objective(CurrentObjectiveIndex).Status()
		if statusIsDone(taskStatus) then
			CurrentObjectiveIndex = CurrentObjectiveIndex + 1
		end
		noForeverLoop = noForeverLoop + 1
	--mq.delay(250)
	until not statusIsDone(taskStatus) or noForeverLoop > 15
	if noForeverLoop >= 15 then
		BL.warn("Infinite loop detected in getMyCurrentQuestStepAndStatus")
	end

	--taskStatus = mq.TLO.Task(taskName).Objective(CurrentObjectiveIndex).Status()
	--local taskStatus = mq.TLO.Task(taskName).Objective(currentObjective).Status ~= "DONE"

	--mq.cmdf("/g TASK Name: %s Step: %s Status: %s", taskName, taskStep, taskStatus)
	return tostring(taskName), tostring(taskStep), tostring(taskStatus)
end

local function sendMyCurrentQuestStepToFellowship(taskName, taskStep, taskStatus)
	-- There is some good reason for needing to duplicate this, but i don't remember what it was
	--local taskName = mq.TLO.Window("TaskWnd/TASK_TaskWnd/TASK_TaskList").List(1, 3)
	---@diagnostic disable-next-line: param-type-mismatch
	--local taskStep = mq.TLO.Task(taskName).Step

	--local status = ""
	--local CurrentObjectiveIndex = 0 -- note 0 start because we'll immediately increment it in repeat loop
	--repeat
	--	CurrentObjectiveIndex = CurrentObjectiveIndex + 1
	--	status = mq.TLO.Task(taskName).Objective(CurrentObjectiveIndex).Status
	--if statusIsDone(status) then

	--end
	--until not statusIsDone(status)
	--status = mq.TLO.Task(taskName).Objective(CurrentObjectiveIndex).Status

	mq.cmdf(
		"/fs QSCR %s is on task !!%s!! step @@%s@@ status !!%s!!",
		mq.TLO.Me.CleanName(),
		taskName,
		taskStep,
		tostring(taskStatus)
	)
	--mq.cmd("/fs QSCR one, two;;")
end

-- this is then message handler, so handle all messages we expect
-- we are guaranteed that the only messages here we receive are
-- ones that we send, so assume the structure of the message
local actor = actors.register(function(message)
	if message.content.id == "echoCurrentTaskStep" and message.sender then
		-- request came in asking me to send my current quest step

		local taskName, taskStep, taskStatus = getMyCurrentQuestInfo()
		if
			BL.IsNil(taskName) or BL.IsNil(taskStep) or BL.IsNil(taskStatus)
		then
			return
		end
		-- Respond with which step I'm on
		message:send({
			id = "currentTaskStepResponse",
			taskName = taskName,
			taskStep = taskStep,
			taskStatus = taskStatus,
		})
		-- For now, also echo it into fellowship until Actors support cross-computer communication
		sendMyCurrentQuestStepToFellowship(taskName, taskStep, taskStatus)
	elseif message.content.id == "currentTaskStepResponse" then
		-- someone sent back their current Task Step from echoCurrentTaskStep
		message:reply(0, {})
		-- Add their current step to our GUI display

		if
			BL.IsNil(message.content.taskName)
			or BL.IsNil(message.content.taskStep)
			or BL.IsNil(message.content.taskStatus)
		then
			return
		end
		--BL.info("Adding %s to group with step %s", message.sender.character, message.content.step)
		group[message.sender.character] = {
			taskName = message.content.taskName,
			taskStep = message.content.taskStep,
			taskStatus = message.content.taskStatus,
		}
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

	local windowFlags = bit32.bor(
		ImGuiWindowFlags.NoSavedSettings,
		ImGuiWindowFlags.NoTitleBar,
		ImGuiWindowFlags.NoScrollbar,
		ImGuiWindowFlags.NoScrollWithMouse,
		--ImGuiWindowFlags.NoBringToFrontOnFocus,
		ImGuiWindowFlags.NoNavFocus
	)

	open_gui, should_draw_gui = ImGui.Begin("QuestHUD", open_gui, windowFlags)
	if should_draw_gui then
		if ImGui.GetWindowHeight() <= 50 or ImGui.GetWindowWidth() <= 57 then
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
		if ImGui.BeginTable("##bhtable" .. tabName .. tostring(tableRandom), 4, flags, 0, 0, 0.0) then
			ImGui.TableSetupColumn(
				"Name",
				bit32.bor(ImGuiTableColumnFlags.DefaultSort, ImGuiTableColumnFlags.WidthFixed),
				60.0
			)
			ImGui.TableSetupColumn("Task", bit32.bor(ImGuiTableColumnFlags.WidthFixed), 40.0)
			ImGui.TableSetupColumn("Step Text", bit32.bor(ImGuiTableColumnFlags.WidthFixed), 40.0)
			ImGui.TableSetupColumn("Step Count", bit32.bor(ImGuiTableColumnFlags.WidthFixed), 100.0)

			ImGui.TableHeadersRow()
			--BL.dump(group)
			for member, task in pairs(group) do
				local taskName = task.taskName or "TASKNAME"
				local taskStep = task.taskStep or "STEP"
				local taskStatus = task.taskStatus or "TASKSTATUS"

				ImGui.TableNextRow()
				ImGui.TableNextColumn()
				drawNameButton(member)
				ImGui.TableNextColumn()
				ImGui.Text(taskName)
				ImGui.TableNextColumn()
				ImGui.Text(taskStep)
				ImGui.TableNextColumn()
				ImGui.Text(taskStatus)
			end
			ImGui.EndTable()
		end
	end
	ImGui.End()
end

mq.imgui.init("QuestHUD", QuestHud_UI)

-- These go in flow order, so first we ask for quest step echo, then everyone will receive the Request event which causes them to
-- send a response with their name and what step text is.  Finally we catch those responses and add them to our group cache

local function askForQuestStepEcho()
	-- janky driver-only limiter
	local myclass = mq.TLO.Me.Class()
	if myclass == "Shadow Knight" or myclass == "Warrior" or myclass == "Paladin" then
		actor:send({ id = "echoCurrentTaskStep" })
		mq.cmd("/fs QUESTSTEPECHO.")
		--BL.info("I just asked for quest step echo")
	end
end

-- Triggers when driver says QUESTSTEPECHO. in fellowship
mq.event("QuestStepEchoRequest", "#*#QUESTSTEPECHO.#*#", function(line)
	--mq.cmd("/g responding to request")
	--BL.info("/g responding to request")
	sendMyCurrentQuestStepToFellowship()
end)

mq.event(
	"QuestStepEchoResponse",
	"#*#fellowship, 'QSCR #1# is on task !!#2#!! step @@#3#@@ status !!#4#!!'#*#",
	function(line, characterName, taskName, taskStep, taskStatus)
		-- someone sent back their current Task Step from echoCurrentTaskStep
		-- Add their current step to our GUI display
		if BL.IsNil(taskName) or BL.IsNil(taskStep) or BL.IsNil(taskStatus) then
			return
		end
		BL.info(
			"In final event of the chain setting %s to %s -- %s -- %s",
			characterName,
			taskName,
			taskStep,
			taskStatus
		)

		group[characterName] = { taskName = taskName, taskStep = taskStep, taskStatus = taskStatus }
	end
)

while not shouldTerminate do
	askForQuestStepEcho()
	mq.doevents()
	mq.delay(1021)
end
