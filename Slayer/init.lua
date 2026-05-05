---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")
--- @type ImGui
local imgui = require("ImGui")
local Actors = require("actors")
local ids = require("slayer.ids")

BL.info("Slayer script 1.03 loaded")

-- GUI state
local showGUI = true -- Always true to prevent window from being closed permanently
local selectedTab = 0 -- 0 = Overview, 1 = Details
local selectedAchievement = 1 -- Default to first achievement in dropdown

-- Multi-toon setup using Actors (like itrack)
local myName = mq.TLO.Me.CleanName()
local mailboxName = "SlayerTracker"
local actor
local slayerData = {}
local connectedToons = {}
local lastSeenTime = {} -- Track when each toon was last seen

-- UI colors
local colGreen = ImVec4(0.409, 1.000, 0.409, 1.000)
local colWhite = ImVec4(1, 1, 1, 1)
local colYellow = ImVec4(1, 1, 0, 1)

-- Get achievement data by ID
local function getAchievementData(achievementID)
    local myAch = mq.TLO.Achievement
    local ach = myAch(achievementID)
    
    if not ach or not ach() then
        return nil
    end
    
    local completed = ach.Completed() or false
    
    return {
        id = achievementID,
        name = ids.getAchievementName(achievementID),
        completed = completed,
        points = ach.Points() or 0
    }
end

-- Function to check Slayer achievements
local function checkAchievements()
    local achievements = {}
    
    -- Check ALL achievements from ids.lua
    local allAchievementIDs = ids.getAllAchievementIDs()
    for _, achievementID in ipairs(allAchievementIDs) do
        local data = getAchievementData(achievementID)
        if data then
            achievements[achievementID] = {
                id = data.id,
                name = data.name,
                completed = data.completed,
                points = data.points
            }
        end
    end
    
    -- Store locally
    slayerData[myName] = achievements
    
    -- Share with other toons using Actors
    actor:send({ mailbox = mailboxName, }, { Achievements = achievements, Sender = myName, })
end

-- Register Actor for multi-toon communication
local function RegisterActors()
    actor = Actors.register(mailboxName, function(message)
        if not message() then return end
        local received_message = message()
        local who = received_message.Sender or "Unknown"
        local achievements = received_message.Achievements or {}

        -- Update last seen time for this toon
        lastSeenTime[who] = os.time()

        -- Handle achievement data
        if achievements and next(achievements) then
            if slayerData[who] == nil then slayerData[who] = {} end
            for achievementID, data in pairs(achievements) do
                slayerData[who][achievementID] = data
            end
        end
    end)
end

-- Clean up disconnected toons (timeout after 10 seconds)
local function cleanupDisconnectedToons()
    local currentTime = os.time()
    local toonsToRemove = {}
    
    for toonName, lastTime in pairs(lastSeenTime) do
        if currentTime - lastTime > 10 then
            table.insert(toonsToRemove, toonName)
        end
    end
    
    -- Remove disconnected toons
    for _, toonName in ipairs(toonsToRemove) do
        slayerData[toonName] = nil
        lastSeenTime[toonName] = nil
        BL.info("Removed disconnected toon: " .. toonName)
    end
end

-- Update connected toons list
local function updateConnectedToons()
    -- Clean up disconnected toons first
    cleanupDisconnectedToons()
    
    connectedToons = {}
    for toonName, _ in pairs(slayerData) do
        table.insert(connectedToons, toonName)
    end
    
    -- Sort toons alphabetically
    table.sort(connectedToons)
end

-- Render Overview tab - shows all toons and all achievements
local function renderOverviewTab()
    -- Update connected toons first
    updateConnectedToons()
    
    -- Get all achievement IDs first
    local allAchievementIDs = ids.getAllAchievementIDs()
    
    imgui.Text("Slayer Achievement Overview (" .. #connectedToons .. " connected)")
    imgui.SameLine()
    
    -- Add achievement dropdown for quick filtering/selection
    local achievementNames = {}
    for _, id in ipairs(allAchievementIDs) do
        table.insert(achievementNames, ids.getAchievementName(id))
    end
    
    imgui.SetNextItemWidth(300) -- Set dropdown width to 200 pixels
    local currentIndex = selectedAchievement - 1
    local changed = imgui.Combo("Achievement", currentIndex, achievementNames, #achievementNames)
    if changed then
        selectedAchievement = currentIndex + 1
    end
    
    imgui.Separator()
    
    -- Create horizontally scrollable table
    local tableFlags = bit32.bor(ImGuiTableFlags.Borders, ImGuiTableFlags.RowBg, ImGuiTableFlags.ScrollX, ImGuiTableFlags.ScrollY, ImGuiTableFlags.Resizable)
    
    -- Calculate table height based on number of toons (min 100px, max 500px)
    local tableHeight = math.max(100, math.min(500, #connectedToons * 18 + 50))
    
    if imgui.BeginTable("OverviewTable", #allAchievementIDs + 1, tableFlags, ImVec2(0, tableHeight)) then
        imgui.TableSetupScrollFreeze(1, 1)

        -- Table headers
        imgui.TableSetupColumn("Character", 0, 120)
        for _, achievementID in ipairs(allAchievementIDs) do
            imgui.TableSetupColumn(ids.getAchievementName(achievementID), 0, 60)
        end
        imgui.TableHeadersRow()

        -- Tooltip on header hover
        local hoveredCol = imgui.TableGetHoveredColumn()
        if hoveredCol ~= nil and hoveredCol > 0 and hoveredCol <= #allAchievementIDs then
            local achievementID = allAchievementIDs[hoveredCol]
            if achievementID then
                imgui.BeginTooltip()
                imgui.Text(ids.getAchievementName(achievementID))
                imgui.EndTooltip()
            end
        end
        
        -- Show achievement status for each toon
        for _, toonName in ipairs(connectedToons) do
            imgui.TableNextRow()
            imgui.TableSetColumnIndex(0)
            imgui.Text(toonName)
            
            -- Show status for each achievement
            for colIndex, achievementID in ipairs(allAchievementIDs) do
                imgui.TableSetColumnIndex(colIndex)
                local achievementData = slayerData[toonName] and slayerData[toonName][achievementID]
                if achievementData then
                    if achievementData.completed then
                        imgui.TextColored(colGreen, "Yes")
                    else
                        imgui.TextColored(ImVec4(0.5, 0.5, 0.5, 1), "No")
                    end
                else
                    imgui.TextColored(ImVec4(0.5, 0.5, 0.5, 1), "?")
                end
            end
        end
        
        imgui.EndTable()
    end
    
    imgui.Text("")
end

-- Render Details tab - shows detailed info for selected achievement
local function renderDetailsTab()
    imgui.Text("Slayer Achievement Details")
    imgui.Separator()
    
    imgui.Text("Select an achievement to view details:")
    imgui.Separator()
    
    -- Create dropdown with all achievements
    local allAchievementIDs = ids.getAllAchievementIDs()
    local achievementNames = {}
    for _, id in ipairs(allAchievementIDs) do
        table.insert(achievementNames, ids.getAchievementName(id))
    end
    
    imgui.SetNextItemWidth(200) -- Set dropdown width to 200 pixels
    local currentIndex = selectedAchievement - 1
    local changed = imgui.Combo("Achievement", currentIndex, achievementNames, #achievementNames)
    if changed then
        selectedAchievement = currentIndex + 1
    end
    
    imgui.Separator()
    
    -- Display info about selected achievement
    if selectedAchievement > 0 and selectedAchievement <= #allAchievementIDs then
        local achievementID = allAchievementIDs[selectedAchievement]
        local achievementName = ids.getAchievementName(achievementID)
        
        imgui.Text("Selected: " .. achievementName)
        imgui.Text("ID: " .. achievementID)
        imgui.Text("This dropdown displays all " .. #achievementNames .. " Slayer achievements.")
        imgui.Text("Functionality coming soon...")
    end
end

-- Main GUI render function
local function renderGUI()
    -- Always show window, no close button (pass nil instead of showGUI)
    local shouldDraw, open = imgui.Begin("Slayer Achievements", nil)
    
    if shouldDraw then
        -- Tab system
        if imgui.BeginTabBar("SlayerTabBar", ImGuiTabBarFlags.None) then
            -- Overview Tab
            if imgui.BeginTabItem("Overview") then
                renderOverviewTab()
                imgui.EndTabItem()
            end
            
            -- Details Tab
            if imgui.BeginTabItem("Details") then
                renderDetailsTab()
                imgui.EndTabItem()
            end
            
            imgui.EndTabBar()
        end
    end
    
    imgui.End()
end

-- Command handler
local function slayerCommand(...)
    local args = {...}
    local cmd = args[1] and args[1]:lower() or ""
    
    if cmd == "hide" then
        showGUI = false
        BL.info("Slayer GUI hidden")
    elseif cmd == "show" then
        showGUI = true
        BL.info("Slayer GUI shown")
    elseif cmd == "debug" then
        BL.info("=== Slayer Debug ===")
        BL.info("My name: " .. myName)
        
        local connectedList = {}
        for toonName, _ in pairs(slayerData) do
            table.insert(connectedList, toonName)
        end
        BL.info("Connected toons: " .. table.concat(connectedList, ", "))
        BL.info("=== End Debug ===")
    else
        showGUI = not showGUI
        BL.info("Slayer GUI toggled: " .. (showGUI and "shown" or "hidden"))
    end
end

-- Initialize system
local function initSystem()
    BL.info("Initializing Slayer system...")
    
    -- Register Actors for multi-toon communication
    RegisterActors()
    
    -- Initial achievement check
    checkAchievements()
    
    BL.info("Slayer system initialization complete")
end

-- Bind the GUI render function to the ImGui event
mq.imgui.init('SlayerGUI', renderGUI)

-- Register command
mq.bind('/slayer', slayerCommand)

-- Initialize system
initSystem()

BL.info("Slayer loaded - /slayer to toggle | /slayer debug")

-- Main loop to keep script running
local refreshTimer = os.clock()
while true do
    -- Check achievements every 3 seconds
    if os.difftime(os.clock(), refreshTimer) > 3 then
        checkAchievements()
        refreshTimer = os.clock()
    end
    
    mq.delay(100) -- Short delay to prevent excessive CPU usage
end