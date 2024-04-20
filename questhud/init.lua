--- @type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")

local actors = require("actors")
local BL = require("biggerlib")

local taskIndex = 1


local shouldTerminate = false

local group = {}
--- Add another agent to our list of group members, happens in response to an actor announcing
local function addGroupMember(sender)
	--BL.info("Adding group member from sender %s", sender.character)
	group[sender.character] = {
        tasksData = nil,
        taskIndex = 1,
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


-- mq.TLO.Window("TaskWnd/TASK_TaskWnd/TASK_TaskList").Items()

local function getMyCurrentQuestInfo()
    -- make sure UI window is open
    if not mq.TLO.Window('TaskWnd').Open() then
        mq.cmd("/windowstate TaskWnd open")
    end
    -- tostring to appease the linter
    local numTasks = mq.TLO.Window("TaskWnd/TASK_TaskWnd/TASK_TaskList").Items()
    local allTaskInfo = {}
    -- for loop from 1 to numTasks do
    for i = 1, numTasks do
        local taskName = tostring(mq.TLO.Window("TaskWnd/TASK_TaskWnd/TASK_TaskList").List(i, 3))
        
        local taskStep = mq.TLO.Task(taskName).Step()
        
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
        
        --mq.cmdf("/g TASK Name: %s Step: %s Status: %s", taskName, taskStep, taskStatus)
        --return tostring(taskName), tostring(taskStep), tostring(taskStatus)
        table.insert(allTaskInfo, { taskName = taskName, taskStep = taskStep, taskStatus = taskStatus })
    end
    -- how do i sort by taskName before returning allTaskInfo?
    
    -- sort tasks by their names
    table.sort(allTaskInfo, function(a, b)
        return a.taskName < b.taskName
    end)
    
    return allTaskInfo
	
end


-- this is then message handler, so handle all messages we expect
-- we are guaranteed that the only messages here we receive are
-- ones that we send, so assume the structure of the message
local actor = actors.register(function(message)
	if message.content.id == "echoCurrentTaskStep" and message.sender then
		-- request came in asking me to send my current quest step
		
        
        
		local tasksData = getMyCurrentQuestInfo()
		if
            BL.IsNil(tasksData) or #tasksData < 1
        then
            --BL.info("tasks Data is NIL from function")
			return
		end
		-- Respond with which step I'm on
		message:send({
			id = "currentTaskStepResponse",
			tasksData = tasksData,
		})
		-- For now,  also echo it into fellowship until Actors support cross-computer communication

		
	elseif message.content.id == "currentTaskStepResponse" then
		-- someone sent back their current Task Step from echoCurrentTaskStep
		--message:reply(0, {})
		-- Add their current step to our GUI display		
		if
			BL.IsNil(message.content.tasksData)
        then
            BL.info("tasks Data is NIL in response from %s", message.sender)
            group[message.sender.character].tasksData = nil
			return
		end
        --BL.info("Adding %s to group with step %s", message.sender.character, message.content.step)
        
        if not group[message.sender.character] then
            addGroupMember(message.sender)
        end
        
		group[message.sender.character].tasksData = message.content.tasksData
		
	elseif message.content.id == "announce" then
		-- a new actor (group member) has joined
		addGroupMember(message.sender)
	elseif message.content.id == "drop" then
		-- a group member has dropped, remove them from the list
        removeGroupMember(message.sender)
    elseif message.content.id == "incrementTaskIndex" then
        taskIndex = taskIndex + 1
        
	end
end)

-- These go in flow order, so first we ask for quest step echo, then everyone will receive the Request event which causes them to
-- send a response with their name and what step text is.  Finally we catch those responses and add them to our group cache

local function askForQuestStepEcho()
    -- janky driver-only limiter
    --local myclass = mq.TLO.Me.Class()
    --if myclass == "Shadow Knight" or myclass == "Warrior" or myclass == "Paladin" then
        actor:send({ id = "echoCurrentTaskStep" })
        
    --end
end

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

--local function drawTaskButton(name)
--    local buttonText = name
--    local col = nil
    
--    -- Set color to normal one for name
--    col = { 0, 1, 0 }
--    ImGui.PushStyleColor(ImGuiCol.Text, col[1], col[2], col[3], 1)
    
--    if ImGui.SmallButton(buttonText .. "##" .. name) then
--        mq.cmdf("/squelch /dex %s /foreground", name)
--    end
--    ImGui.PopStyleColor(1)
--end

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
            ImGuiTableFlags.BordersH,
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
            ImGui.TableSetupColumn("Step Count", bit32.bor(ImGuiTableColumnFlags.WidthFixed), 40.0)
            ImGui.TableSetupColumn("Step Text", bit32.bor(ImGuiTableColumnFlags.WidthFixed), 100.0)
            
            ImGui.TableHeadersRow()
            for member, groupMemberData in pairs(group) do
                local memberTaskIdx = groupMemberData.taskIndex
                if memberTaskIdx > #groupMemberData.tasksData then
                    mq.cmd("/g task idx overflow")
                    groupMemberData.taskIndex = 1
                    memberTaskIdx = 1
                end
                
                local task = groupMemberData.tasksData[memberTaskIdx]
            
                local taskName = task.taskName or "TASKNAME"
                local taskStep = task.taskStep or "STEP"
                local taskStatus = task.taskStatus or "TASKSTATUS"

                ImGui.TableNextRow()
                ImGui.TableNextColumn()
                drawNameButton(member)
                ImGui.TableNextColumn()                
               
                if ImGui.SmallButton(taskName .. "##" .. tostring(member)) then
                    groupMemberData.taskIndex = groupMemberData.taskIndex + 1
                    memberTaskIdx = groupMemberData.taskIndex
                end
                
                ImGui.TableNextColumn()
                ImGui.Text(taskStatus)
                ImGui.TableNextColumn()
                ImGui.Text(taskStep)
            end
            ImGui.EndTable()
        end
    end
    ImGui.End()
end

mq.imgui.init("QuestHUD", QuestHud_UI)



BL.info("QuestHUD loaded.")

while not shouldTerminate do
	askForQuestStepEcho()

	mq.delay(2021)
end
