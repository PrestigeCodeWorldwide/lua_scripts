-- v1.04
---@type Mq
local mq = require("mq")
---@type ImGui
local imgui = require("ImGui")

-- Addclicky settings
local UseCures = 0 -- 0=SET, 1=ON, 2=OFF

-- Section selection
local selectedSection = "Cures" -- Default to Cures section

-- Section data
local sectionData = {
    Cures = {
        { name = "Venenium", displayName = "Venenium", state = 0 },
        { name = "Cleansing Rod", displayName = "Cleansing Rod", state = 0 },
        { name = "Distillate of Antidote XV", displayName = "Distillate of Antidote XV", state = 0 },
        { name = "Shield of Immaculate", displayName = "Shield of Immaculate", state = 0 },
        { name = "Shield of Immaculate Light", displayName = "Shield of Immaculate Light", state = 0 }
    },
    Burn = {
        { name = "Rage of Rolfron", displayName = "Rage of Rolfron", state = 0 },
        --{ name = "BurnNamed", displayName = "Burn Named", state = 0 },
        --{ name = "BurnAE", displayName = "Burn AE", state = 0 }
    },
    Offensive = {
        { name = "Draught of Shattered Evocations", displayName = "Draught of Shattered Evocations", state = 0 },
        { name = "Flask of Shattered Bolstering", displayName = "Flask of Shattered Bolstering", state = 0 },
        { name = "Consigned Bite of the Shissar XXII", displayName = "Consigned Bite of the Shissar XXII", state = 0 },
        { name = "Consigned Bite of the Shissar XXIII", displayName = "Consigned Bite of the Shissar XXIII", state = 0 },
        { name = "Spider's Bite XXII", displayName = "Spider's Bite XXII", state = 0 },
        { name = "Scorpion's Agony XXI", displayName = "Scorpion's Agony XXI", state = 0 },
        { name = "Tallon's Tactic XXIII", displayName = "Tallon's Tactic XXIII", state = 0 },
        { name = "Vallon's Tactic XXIII", displayName = "Vallon's Tactic XXIII", state = 0 },
        { name = "Amulet of Necropotence", displayName = "Amulet of Necropotence", state = 0 },
    },
    Downtime = {
        { name = "ActiveDownTime", displayName = "Active Downtime", state = 0 },
        { name = "Amulet of Necropotence", displayName = "Amulet of Necropotence", state = 0 }
    }
}

-- Helper function to get the appropriate bind based on applytoallChecked
local function getCWTNBind(applytoallChecked, AllIncludingSelfBind, AllButSelfBind)
    return applytoallChecked and AllIncludingSelfBind or AllButSelfBind
end

-- Apply addclicky settings
local function applyAddclickySettings(applytoallChecked, AllIncludingSelfBind, AllButSelfBind)
    if UseCures == 1 then
        -- ALL ON - activate all cures
        for _, cure in ipairs(sectionData.Cures) do
            mq.cmdf("%s activate cure \"%s\"", AllIncludingSelfBind, cure.name)
            cure.state = 1
        end
    elseif UseCures == 2 then
        -- ALL OFF - deactivate all cures
        for _, cure in ipairs(sectionData.Cures) do
            mq.cmdf("%s deactivate cure \"%s\"", AllIncludingSelfBind, cure.name)
            cure.state = 2
        end
    end
    
    -- Apply section-specific settings
    for sectionName, section in pairs(sectionData) do
        if sectionName == "Burn" then
            for _, item in ipairs(section) do
                if item.state == 1 then
                    mq.cmdf("%s activate burn \"%s\"", AllIncludingSelfBind, item.name)
                else
                    mq.cmdf("%s deactivate burn", AllIncludingSelfBind)
                end
            end
        elseif sectionName == "Offensive" then
            for _, item in ipairs(section) do
                if item.state == 1 then
                    mq.cmdf("%s activate offensive \"%s\"", AllIncludingSelfBind, item.name)
                else
                    mq.cmdf("%s deactivate offensive \"%s\"", AllIncludingSelfBind, item.name)
                end
            end
        elseif sectionName == "Downtime" then
            for _, item in ipairs(section) do
                if item.state == 1 then
                    mq.cmdf("%s activate downtime \"%s\"", AllIncludingSelfBind, item.name)
                else
                    mq.cmdf("%s deactivate downtime \"%s\"", AllIncludingSelfBind, item.name)
                end
            end
        else
            -- For Cures section, use cure commands
            for _, cure in ipairs(sectionData.Cures) do
                if cure.state == 1 then
                    mq.cmdf("%s activate cure \"%s\"", AllIncludingSelfBind, cure.name)
                else
                    mq.cmdf("%s deactivate cure \"%s\"", AllIncludingSelfBind, cure.name)
                end
            end
        end
    end
end

-- Load addclicky settings
local function loadAddclickySettings(settings)
    UseCures = settings.UseCures or UseCures
    
    -- Load individual cure states
    if settings.individualCures then
        for i, cure in ipairs(individualCures) do
            if settings.individualCures[i] and settings.individualCures[i].state ~= nil then
                cure.state = settings.individualCures[i].state
            end
        end
    end
    
    -- Load section data
    if settings.sectionData then
        for sectionName, section in pairs(settings.sectionData) do
            if sectionName ~= "Cures" and sectionData[sectionName] then
                for i, item in ipairs(sectionData[sectionName]) do
                    if settings.sectionData[sectionName][i] and settings.sectionData[sectionName][i].state ~= nil then
                        item.state = settings.sectionData[sectionName][i].state
                    end
                end
            end
        end
    end
end

-- Save addclicky settings
local function saveAddclickySettings(settings)
    settings.UseCures = UseCures
    
    -- Save individual cure states
    settings.individualCures = {}
    for i, cure in ipairs(sectionData.Cures) do
        settings.individualCures[i] = {
            name = cure.name,
            displayName = cure.displayName,
            state = cure.state
        }
    end
    
    -- Save section data
    settings.sectionData = {}
    for sectionName, section in pairs(sectionData) do
        if sectionName ~= "Cures" then
            settings.sectionData[sectionName] = {}
            for i, item in ipairs(sectionData[sectionName]) do
                settings.sectionData[sectionName][i] = {
                    name = item.name,
                    displayName = item.displayName,
                    state = item.state
                }
            end
        end
    end
end

-- Draw the Clickies tab UI
local function drawClickiesTab(applytoallChecked, AllIncludingSelfBind, AllButSelfBind)
    -- Section buttons at the top
    local sectionNames = {"Cures", "Burn", "Offensive", "Downtime"}
    
    -- Draw section buttons
    for i, sectionName in ipairs(sectionNames) do
        local isSelected = (selectedSection == sectionName)
        
        if imgui.Button(sectionName, 70, 22) then
            selectedSection = sectionName
            UseCures = 0 -- Reset to SET when switching sections
        end
        
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text("Show " .. sectionName .. " individual controls")
            imgui.EndTooltip()
        end
        
        if i < #sectionNames then
            imgui.SameLine()
        end
    end
    
    imgui.NewLine()
    
    -- ALL master button
    -- ALL toggle button
    local allText = "ALL"
    local allStateText = { "SET", "ON", "OFF" }
    local allButtonState = UseCures + 1

    -- Set text color based on state
    local allStateColor
    if UseCures == 0 then
        allStateColor = { 0.5, 0.5, 0.5, 1.0 } -- Grey for SET
    elseif UseCures == 1 then
        allStateColor = { 0.0, 1.0, 0.0, 1.0 } -- Green for ON
    else
        allStateColor = { 1.0, 0.0, 0.0, 1.0 } -- Red for OFF
    end

    imgui.PushStyleColor(ImGuiCol.Text, unpack(allStateColor))
    imgui.PushID("all_button")
    if imgui.Button(allStateText[allButtonState], 50, 20) then
        UseCures = (UseCures + 1) % 3
        if UseCures == 1 then
            -- ALL ON - activate all items in selected section
            if selectedSection and sectionData[selectedSection] then
                for _, item in ipairs(sectionData[selectedSection]) do
                    if selectedSection == "Cures" then
                        mq.cmdf("%s activate cure \"%s\"", AllIncludingSelfBind, item.name)
                    elseif selectedSection == "Burn" then
                        mq.cmdf("%s activate burn \"%s\"", AllIncludingSelfBind, item.name)
                    elseif selectedSection == "Offensive" then
                        mq.cmdf("%s activate offensive \"%s\"", AllIncludingSelfBind, item.name)
                    elseif selectedSection == "Downtime" then
                        mq.cmdf("%s activate downtime \"%s\"", AllIncludingSelfBind, item.name)
                    end
                    item.state = 1
                end
            end
            print("Set All " .. selectedSection .. " to ON")
        elseif UseCures == 2 then
            -- ALL OFF - deactivate all items in selected section
            if selectedSection and sectionData[selectedSection] then
                for _, item in ipairs(sectionData[selectedSection]) do
                    if selectedSection == "Cures" then
                        mq.cmdf("%s deactivate cure \"%s\"", AllIncludingSelfBind, item.name)
                    elseif selectedSection == "Burn" then
                        mq.cmdf("%s deactivate burn", AllIncludingSelfBind)
                    elseif selectedSection == "Offensive" then
                        mq.cmdf("%s deactivate offensive \"%s\"", AllIncludingSelfBind, item.name)
                    elseif selectedSection == "Downtime" then
                        mq.cmdf("%s deactivate downtime \"%s\"", AllIncludingSelfBind, item.name)
                    end
                    item.state = 2
                end
            end
            print("Set All " .. selectedSection .. " to OFF")
        end
    end
    imgui.PopID()
    imgui.PopStyleColor()
    
    imgui.SameLine()
    
    -- Draw section name in gold (on right)
    imgui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0) -- Gold color
    imgui.Text(allText)
    imgui.PopStyleColor()
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text("Turns all " .. selectedSection .. " On/Off")
        imgui.EndTooltip()
    end
    
    imgui.NewLine()
    
    -- Individual controls for selected section
    if selectedSection and sectionData[selectedSection] then
        -- Display each item with individual toggle
        for i, item in ipairs(sectionData[selectedSection]) do
            imgui.PushID("item_" .. i)
            
            -- Individual toggle button first (on left)
            local stateText = { "SET", "ON", "OFF" }
            local individualButtonState = item.state + 1
            local individualStateColor
            if item.state == 0 then
                individualStateColor = { 0.5, 0.5, 0.5, 1.0 } -- Grey for SET
            elseif item.state == 1 then
                individualStateColor = { 0.0, 1.0, 0.0, 1.0 } -- Green for ON
            else
                individualStateColor = { 1.0, 0.0, 0.0, 1.0 } -- Red for OFF
            end
            
            imgui.PushStyleColor(ImGuiCol.Text, unpack(individualStateColor))
            if imgui.Button(stateText[individualButtonState], 50, 20) then
                item.state = (item.state + 1) % 3
                if item.state == 1 then
                    if selectedSection == "Cures" then
                        mq.cmdf("%s activate cure \"%s\"", AllIncludingSelfBind, item.name)
                    elseif selectedSection == "Burn" then
                        mq.cmdf("%s activate burn \"%s\"", AllIncludingSelfBind, item.name)
                    elseif selectedSection == "Offensive" then
                        mq.cmdf("%s activate offensive \"%s\"", AllIncludingSelfBind, item.name)
                    elseif selectedSection == "Downtime" then
                        mq.cmdf("%s activate downtime \"%s\"", AllIncludingSelfBind, item.name)
                    end
                    print("Activated " .. item.displayName)
                elseif item.state == 2 then
                    if selectedSection == "Cures" then
                        mq.cmdf("%s deactivate cure \"%s\"", AllIncludingSelfBind, item.name)
                    elseif selectedSection == "Burn" then
                        mq.cmdf("%s deactivate burn", AllIncludingSelfBind)
                    elseif selectedSection == "Offensive" then
                        mq.cmdf("%s deactivate offensive \"%s\"", AllIncludingSelfBind, item.name)
                    elseif selectedSection == "Downtime" then
                        mq.cmdf("%s deactivate downtime \"%s\"", AllIncludingSelfBind, item.name)
                    end
                    print("Deactivated " .. item.displayName)
                end
            end
            imgui.PopStyleColor()
            
            imgui.SameLine()
            
            -- Item name (on right)
            imgui.Text(item.displayName)
            
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text("Toggle " .. item.displayName .. " individually")
                imgui.EndTooltip()
            end
            
            imgui.PopID()
        end
    end
end

-- Export functions
return {
    drawClickiesTab = drawClickiesTab,
    applyAddclickySettings = applyAddclickySettings,
    loadAddclickySettings = loadAddclickySettings,
    saveAddclickySettings = saveAddclickySettings,
    getUseCures = function() return UseCures end,
    setUseCures = function(value) UseCures = value end
}
