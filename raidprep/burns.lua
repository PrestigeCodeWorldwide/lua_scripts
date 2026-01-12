---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")
--- @type ImGui
local imgui = require("ImGui")
--- @type Actors
local ActorsLib = require("actors")

local function sendBurnCommand(command)
    -- Send the command to all group members
    mq.cmd("/dga " .. command)
end

local function getClassAbbreviation(className)
    local abbreviations = {
        Warrior = "War",
        Rogue = "Rog",
        Wizard = "Wiz",
        Paladin = "Pal",
        Cleric = "Clr",
        Shadowknight = "SK",
        Berserker = "Ber",
        Monk = "Mnk",
        Ranger = "Rng",
        Shaman = "Shm",
        Druid = "Dru",
        Bard = "Brd",
        Beastlord = "BST",
        Enchanter = "Enc",
        Necromancer = "Nec",
        Magician = "Mag"
    }
    return abbreviations[className] or className:sub(1, 3)
end

-- Table of burn disciplines organized by cooldown time and class
local burnDisciplines = {
    -- 5-Minute Cooldown
    [5] = {
        -- Class A burns (e.g., DPS)
        A = {
            { class = "Warrior", command = "/disc Bloodlust" },
            { class = "Rogue",   command = "/disc Frenzied Stabbing" },
            { class = "Wizard",  command = "/disc Arcane Blaze" },
        },
        -- Class B burns (e.g., Tanks/Healers)
        B = {
            { class = "Paladin",      command = "/disc Holy Forge" },
            { class = "Cleric",       command = "/disc Celestial Regeneration" },
            { class = "Shadowknight", command = "/disc Unholy Aura" },
        }
    },
    -- 10-Minute Cooldown
    [10] = {
        A = {
            { class = "Berserker", command = "/disc Rage of Rallos" },
            { class = "Monk",      command = "/disc Five Point Palm" },
            { class = "Ranger",    command = "/disc Outrider's Accuracy" },
        },
        B = {
            { class = "Shaman", command = "/disc Spirit Call" },
            { class = "Druid",  command = "/disc Nature's Fury" },
            { class = "Bard",   command = "/disc Aria of the Poet" },
        }
    },
    -- 15-Minute Cooldown
    [15] = {
        A = {
            { class = "Beastlord", command = "/disc Feral Swipe" },
            { class = "Rogue",     command = "/disc Twisted Chance" },
            { class = "Wizard",    command = "/disc Improved Twincast" },
        },
        B = {
            { class = "Paladin",   command = "/disc Blessed Aura" },
            { class = "Cleric",    command = "/disc Divine Avatar" },
            { class = "Enchanter", command = "/disc Mana Blaze" },
        }
    },
    -- 20-Minute Cooldown
    [20] = {
        A = {
            { class = "Berserker", command = "/disc Cry of Battle" },
            { class = "Monk",      command = "/disc Innerflame Dragon" },
            { class = "Ranger",    command = "/disc Guardian of the Forest" },
        },
        B = {
            { class = "Shaman",      command = "/disc Ancestral Guard" },
            { class = "Druid",       command = "/docile" },
            { class = "Necromancer", command = "/disc Funeral Pyre" },
        }
    }
}

local function drawBurnButton(label, command, color, hoverColor)
    imgui.PushStyleColor(ImGuiCol.Button, color[1], color[2], color[3], color[4] or 1.0)
    imgui.PushStyleColor(ImGuiCol.ButtonHovered, hoverColor[1], hoverColor[2], hoverColor[3], hoverColor[4] or 1.0)
    if imgui.Button(label, -1, 40) then
        sendBurnCommand(command)
    end
    imgui.PopStyleColor(2)
end

local function drawBurnsTab()
    -- Define colors for each cooldown type
    local cooldownColors = {
        [5] = { 0.0, 1.0, 0.0 },  -- Green
        [10] = { 0.0, 1.0, 1.0 }, -- Cyan
        [15] = { 1.0, 1.0, 0.0 }, -- Yellow
        [20] = { 1.0, 0.5, 0.0 }  -- Orange
    }

    -- Draw each cooldown section
    for cooldown, color in pairs(cooldownColors) do
        local cooldownBurns = burnDisciplines[cooldown] or {}
        local sectionName = string.format("%d-Minute Cooldown Burns", cooldown)

        -- Section header
        imgui.TextColored(color[1], color[2], color[3], 1.0, sectionName)
        imgui.Separator()

        -- Calculate button colors
        local buttonColor = {
            math.max(0, color[1] * 0.6),
            math.max(0, color[2] * 0.6),
            math.max(0, color[3] * 0.6),
            0.8
        }

        local hoverColor = {
            math.min(1.0, color[1] * 1.2),
            math.min(1.0, color[2] * 1.2),
            math.min(1.0, color[3] * 1.2),
            0.9
        }

        -- Create a table for the burn buttons
        if imgui.BeginTable(sectionName .. "_table", 2, ImGuiTableFlags.Borders) then
            -- Draw A/B buttons
            imgui.TableNextRow()

            -- Button A
            imgui.TableNextColumn()
            local aClasses = {}
            for _, burn in ipairs(cooldownBurns.A or {}) do
                table.insert(aClasses, getClassAbbreviation(burn.class))
            end
            local buttonAText = string.format("%dm: %s", cooldown, table.concat(aClasses, ","))
            imgui.PushStyleColor(ImGuiCol.Button, color[1] * 0.6, color[2] * 0.6, color[3] * 0.6, 0.8)
            imgui.PushStyleColor(ImGuiCol.ButtonHovered, color[1] * 1.2, color[2] * 1.2, color[3] * 1.2, 0.9)
            if imgui.Button(buttonAText, -1, 40) then
                -- Execute all A burns for this cooldown
                for _, burn in ipairs(cooldownBurns.A or {}) do
                    sendBurnCommand(burn.command)
                end
            end
            imgui.PopStyleColor(2)
            -- Button B
            imgui.TableNextColumn()
            local bClasses = {}
            for _, burn in ipairs(cooldownBurns.B or {}) do
                table.insert(bClasses, getClassAbbreviation(burn.class))
            end
            local buttonBText = string.format("%dm: %s", cooldown, table.concat(bClasses, ","))
            imgui.PushStyleColor(ImGuiCol.Button, color[1] * 0.6, color[2] * 0.6, color[3] * 0.6, 0.8)
            imgui.PushStyleColor(ImGuiCol.ButtonHovered, color[1] * 1.2, color[2] * 1.2, color[3] * 1.2, 0.9)
            if imgui.Button(buttonBText, -1, 40) then
                -- Execute all B burns for this cooldown
                for _, burn in ipairs(cooldownBurns.B or {}) do
                    sendBurnCommand(burn.command)
                end
            end
            imgui.PopStyleColor(2)



            imgui.EndTable()
        end

        imgui.Spacing()
    end
end

return {
    drawBurnsTab = drawBurnsTab
}
