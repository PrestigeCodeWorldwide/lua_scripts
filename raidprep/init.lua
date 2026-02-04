---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")
--- @type ImGui
local imgui = require("ImGui")
--- @type Actors
local ActorsLib = require("actors")
local buffUI = require("raidprep.buffactors")
local burnsUI = require("raidprep.burns")


BL.info("RaidPrep v1.82 Started")

local openGUI = true
--local selectedScripts = {}
--local selectedClass = nil
local autoAssistAt = 99
local CampRadius = 60
local ChaseDistance = 15
local AoECount = 2
local BurnCount = 99
local StickHow = -1
local UseAoE = 0 -- 0=SET, 1=ON, 2=OFF
local RaidMode = false
local UseAlliance = 0
local UseMelee = 0 -- 0=SET, 1=All ON, 2=Priests Only, 3=Casters Only, 4=All OFF
--local BYOS = 0
--local pwwImg = mq.CreateTexture(mq.TLO.Lua.Dir() .. "/raidprep/PWW.png")
--local raidAssistOptions = { "${Raid.MainAssist[1].Name}", "${Raid.MainAssist[2].Name}", "${Raid.MainAssist[3].Name}" }
local selectedRaidAssist = "Select RA"
local AllButSelfBind = "/noparse /dge /docommand /${Me.Class.ShortName}"
local AllIncludingSelfBind = "/noparse /dga /docommand /${Me.Class.ShortName}"
local applytoallChecked = false -- Controls whether to include self in CWTN commands
local scriptDir = debug.getinfo(1, "S").source:match("@(.*[\\/])") or ""
local settingsFile = scriptDir .. "raidprep_settings.lua"
local forceRefresh = 0
local isWindowMinimized = false
local windowHeight = 600 -- default height, will be adjusted when window is restored

-- Helper function to get the appropriate bind based on applytoallChecked
local function getCWTNBind()
    return applytoallChecked and AllIncludingSelfBind or AllButSelfBind
end

local function applySettings()
    mq.cmdf("%s autoAssistAt %d", getCWTNBind(), autoAssistAt)
    mq.cmdf("%s CampRadius %d", getCWTNBind(), CampRadius)
    mq.cmdf("%s ChaseDistance %d", getCWTNBind(), ChaseDistance)
    mq.cmdf("%s AoECount %d", getCWTNBind(), AoECount)
    mq.cmdf("%s BurnCount %d", getCWTNBind(), BurnCount)
    mq.cmdf("%s StickHow %d", getCWTNBind(), StickHow)

    mq.cmdf("%s useaoe %s", getCWTNBind(), UseAoE and "on" or "off")
    mq.cmdf("%s RaidMode %s", getCWTNBind(), RaidMode and "on" or "off")
    mq.cmdf("%s usealliance %s", getCWTNBind(), UseAlliance and "on" or "off")
    mq.cmdf("%s usemelee %s", getCWTNBind(), UseMelee and "on" or "off")
    --mq.cmdf("%s byos %s", getCWTNBind(), BYOS and "on" or "off")

    if selectedRaidAssist and selectedRaidAssist ~= "Select RA" then
        mq.cmdf("%s RaidAssist %s", getCWTNBind(), selectedRaidAssist)
    end

    print("Settings applied to all toons.")
end

-- Load settings from file
local function loadSettings()
    print("Attempting to load settings from: " .. settingsFile)
    local file = io.open(settingsFile, "r")
    if file then
        print("Successfully opened settings file")
        local content = file:read("*all")
        file:close()

        -- Execute the Lua file to load settings
        local chunk, err = load(content)
        if chunk then
            local settings = chunk()
            autoAssistAt = settings.autoAssistAt or autoAssistAt
            CampRadius = settings.CampRadius or CampRadius
            ChaseDistance = settings.ChaseDistance or ChaseDistance
            AoECount = settings.AoECount or AoECount
            BurnCount = settings.BurnCount or BurnCount
            StickHow = settings.StickHow or StickHow
            UseAoE = settings.UseAoE or UseAoE
            RaidMode = settings.RaidMode or RaidMode
            UseAlliance = settings.UseAlliance or UseAlliance
            UseMelee = settings.UseMelee or UseMelee
            --BYOS = settings.BYOS or BYOS
            selectedRaidAssist = settings.selectedRaidAssist or selectedRaidAssist
            applySettings()
            forceRefresh = 2 -- <-- trigger the UI to update
            print("Settings loaded successfully")
        else
            print("Error loading settings: " .. tostring(err))
        end
    else
        print("Settings file not found")
    end
end

-- Save settings to file
local function saveSettings()
    print("Attempting to save settings to: " .. settingsFile)

    -- Get the current working directory
    local currentDir = package.config:sub(1, 1) -- Get path separator
    print("Current directory: " .. currentDir)
    print("Full path: " .. currentDir .. settingsFile)

    local settings = {
        autoAssistAt = autoAssistAt,
        CampRadius = CampRadius,
        ChaseDistance = ChaseDistance,
        AoECount = AoECount,
        BurnCount = BurnCount,
        StickHow = StickHow,
        UseAoE = UseAoE,
        RaidMode = RaidMode,
        UseAlliance = UseAlliance,
        UseMelee = UseMelee,
        --BYOS = BYOS,
        selectedRaidAssist = selectedRaidAssist
    }

    -- Create a Lua table definition
    local content = "return {\n"
    for k, v in pairs(settings) do
        if type(v) == "boolean" then
            content = content .. string.format("    %s = %s,\n", k, v and "true" or "false")
        elseif type(v) == "number" then
            content = content .. string.format("    %s = %d,\n", k, v)
        elseif type(v) == "string" then
            content = content .. string.format("    %s = \"%s\",\n", k, v)
        end
    end
    content = content .. "}\n"

    local file = io.open(settingsFile, "w")
    if file then
        print("Successfully opened file for writing")
        file:write(content)
        file:close()
        print("Settings saved successfully")
        applySettings() -- Apply the settings after saving
    else
        print("Failed to open file for writing")
    end
end

-- Load settings when script starts
--loadSettings()
--applySettings()

local selectedExpansion = "--Misc Scripts--"
local expansions = {
    "--Misc Scripts--",
    "The Outer Brood",
    "Laurion's Song",
    "Night of Shadows",
    "Terror of Luclin",
    "Claws of Veeshan",
    "Torment of Velious"
}

local expansionScripts = {
    ["--Misc Scripts--"] = { "BannerBack", "Bard", "BoxHUD", "ButtonMaster", "epiclaziness", "GoldenPickPL", "GuildClicky", "Hemicfam","HunterHUD", "HunterHood", "LEM", "Magellan", "Moblist", "Offtank", "OfftankX", "TankBandoSwap", "TCN" },
    ["The Outer Brood"] = { "BroodRaid", "ControlRoom", "DockoftheBay", "HHbearer", "HPMez", "HPRaid", "LHeartRaid", "SilenceTheCannons", "ToECannons", "ToERitual" },
    ["Laurion's Song"] = { "AK", "FFBandoSwap", "HFRaid", "Moors", "PoMTato", "TFRaid" },
    ["Night of Shadows"] = { "Darklight", "OpenTheDoorBanes", "OpenTheDoorRunAway", "ShadowsMove" },
    ["Terror of Luclin"] = { "Doomshade", "FreeTheGoranga", "SheiBane" },
    ["Claws of Veeshan"] = { "Tantor" },
    ["Torment of Velious"] = { "Griklor", "ToFS3", "VelksRaid" },
}

local scriptTooltips = {
    -- Misc Scripts
    ["BannerBack"] = "Runs toon back to GH and takes banner back if they are in the Lobby",
    ["Bard"] = "Koda's Bard automation lua",
    ["BoxHUD"] = "Heads-up display for boxed characters",
    ["ButtonMaster"] = "Customizable button interface for common commands",
    ["GoldenPickPL"] = "Uses the Golden Pick to hit each mob once during PL'ing",
    ["GuildClicky"] = "Manages guild hall zone port clickies",
    ["Hemicfam"] = "Casts Scrykin then Personal Hemic familiar",
    ["HunterHUD"] = "Tracks hunter achievements",
    ["HunterHood"] = "HunterHUD with added features",
    ["LEM"] = "lua event manager",
    ["Magellan"] = "/travelto zones with UI",
    ["Moblist"] = "Tracks spawns in a zone with UI",
    ["Offtank"] = "Allows selecting specific mobs to offtank automatically",
    ["OfftankX"] = "Allows selecting a specific xtarget # to offtank automatically",
    ["TankBandoSwap"] = "Will auto swap from 2H/DW to 1H/SH based on selected # of xtargets you have",
    ["TCN"] = "Tradeskill Consturction Next",

    -- The Outer Brood scripts
    ["SilenceTheCannons"] =
    "Runs away toons called out for the Overcharged Orbs emote during the Silence the Cannons raid",
    ["LHeartRaid"] = "Loots lenses and swaps targets on the bright/dark engergist during the Leviathan Heart raid",
    ["HPRaid"] = "Runs toons for the 2 cures and swaps stickhow's during the High Priest raid",
    ["HPMez"] = "Bard Mez Messengers during the High Priest raid",
    ["DockoftheBay"] = "Runs the 4 toons to safe spots in the East tunnel during the Dock of the Bay raid",
    ["BroodRaid"] = "Runs toons to the south tunnel until debuff is gone during the Brood Architect raid",
    ["ControlRoom"] =
    "(Run only on the toon you want doing the /say) Will target and /say the correct phrases to the frog during the Control Room raid",
    ["ToERitual"] = "Run only on the driver of the group. Does the 4 colored circles thing during the ToE raid",
    ["ToECannons"] = "Run only on the driver of the group. Kills the Cannoneers thing during the ToE raid",
    ["HHbearer"] = "Handles bearer call out during the Hodstock raid",

    -- Add more tooltips for other scripts as needed
    ["AK"] = "Runs toons outside the fort to safe spots during the Ankexfen Keep raid",
    ["FFBandoSwap"] = "Bandolier swaps rogues/bards to stun whips during the Final Fugue raid",
    ["HFRaid"] = "Runs toons away on Shalowain emote and sends pets to kill eggs during the Hero's Forge raid",
    ["Moors"] = "Runs to safe spot on the Magus' aura during the Moors of Nokk raid",
    ["PoMTato"] = "Helper lua for getting Cold Potato achievement during the Plane of Mischief raid",
    ["TFRaid"] = "Runs toons away on the Seed of Hate debuff during the Timorous Falls raid",
    ["Darklight"] =
    "Runs toons away from the green aura if they get the Thinning Skin debuff during the Spirit Fades raid",
    ["OpenTheDoorBanes"] = "Auto cast corruption cure on the 3 dervishes during the When One Door Closes raid",
    ["OpenTheDoorRunAway"] = "Does a couple of the run aways during the When One Door Closes raid",
    ["FreeTheGoranga"] = "Runs toon to SE building out of LoS during the Free the Goranga raid",
    ["Griklor"] = "Called out toons will auto follow Griklor around during the Griklor the Restless raid",
    ["VelksRaid"] = "Can't remember, does stuff",
    ["ShadowsMove"] = "Handles the Setting Sun and Rising Sun emotes during the Firefall Pass raid",
    ["ToFS3"] = "Calls out which character and race is duplicated for ToFS #3 raid",
    ["Doomshade"] = "Runs characters to safe spots for the viral and doom emotes during the Doomshade raid",
}

local function drawluaTab()
    -- Expansion dropdown and Stop All button
    imgui.PushStyleColor(ImGuiCol.Text, 0.0, 8.85, 0.0, 1.0) -- Expansion text color
    imgui.Text("Expansion:")
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.SetNextItemWidth(150) -- Set width for the combo box
    if imgui.BeginCombo("##Expansion", selectedExpansion or "Select...") then
        for _, expansion in ipairs(expansions) do
            if imgui.Selectable(expansion, selectedExpansion == expansion) and selectedExpansion ~= expansion then
                selectedExpansion = expansion
                --selectedScripts = {}
                print("Selected Expansion: " .. expansion)
            end
        end
        imgui.EndCombo()
    end

    -- Add Stop All button
    imgui.SameLine(0, 10)
    if imgui.Button("?", 20, 0) then
        -- Add functionality to stop all scripts here
        print("Stopping all scripts...")
        mq.cmd("/dga /lua stop")
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text("Mystery Button! What does it do?")
        imgui.EndTooltip()
    end

    -- Check for selected expansion
    if selectedExpansion and expansionScripts[selectedExpansion] then
        imgui.Separator()
        imgui.Columns(2, "ScriptsColumns", true) -- Divider
        imgui.SetColumnWidth(0, 140)

        -- Column headers in lime green
        imgui.PushStyleColor(ImGuiCol.Text, 0.0, 8.85, 0.0, 1.0) -- Scripts text color
        imgui.Text("Scripts:")
        imgui.NextColumn()
        imgui.PushStyleColor(ImGuiCol.Text, 0.0, 8.85, 0.0, 1.0) -- Command text color
        imgui.Text("Command:")
        imgui.PopStyleColor(2)                                   -- Pop both style colors
        imgui.NextColumn()

        for _, script in ipairs(expansionScripts[selectedExpansion]) do
            -- Column 1: script name
            imgui.Text(script)
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text(scriptTooltips[script] or (script .. " Script"))
                imgui.EndTooltip()
            end
            imgui.NextColumn()

            -- Column 2: Dannet command Buttons
            imgui.PushID(script)

            if imgui.Button("S") then
                print("Running script on self: " .. script)
                mq.cmdf("/lua run %s", script)
            end
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text("Run " .. script .. " on self")
                imgui.EndTooltip()
            end
            imgui.SameLine()

            if imgui.Button("A") then
                print("Running script on all: " .. script)
                mq.cmdf("/squelch /dga /lua run %s", script)
            end
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text("Run " .. script .. " on all")
                imgui.EndTooltip()
            end
            imgui.SameLine()

            if imgui.Button("ABS") then
                print("Running script on all but self: " .. script)
                mq.cmdf("/squelch /dge /lua run %s", script)
            end
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text("Run " .. script .. " on all but self")
                imgui.EndTooltip()
            end
            imgui.SameLine()

            if imgui.Button("Stop") then
                print("Stopping script on all: " .. script)
                mq.cmdf("/squelch /dga /lua stop %s", script)
            end
            if imgui.IsItemHovered() then
                imgui.BeginTooltip()
                imgui.Text("Stop " .. script .. " on all")
                imgui.EndTooltip()
            end

            imgui.PopID()
            imgui.NextColumn()
        end


        imgui.Columns(1)
    end
end

--Class Tab UI
local function drawClassTab()
    imgui.Separator()
    imgui.Columns(2)
    imgui.SetColumnWidth(0, 100) -- fixed width for left column

    -- Column headers in lime green
    imgui.PushStyleColor(ImGuiCol.Text, 0.0, 8.85, 0.0, 1.0) -- Class and Commandtext color
    imgui.Text("Class")
    imgui.NextColumn()
    imgui.Text("Command")
    imgui.PopStyleColor()
    imgui.NextColumn()

    local classAbilities = {
        Bard = {
            { label = "ADT", cmd = "/squelch /dga /brd ActiveDownTime on", offcmd = "/squelch /dga /brd ActiveDownTime off", tooltip = "ActiveDowntime" },
            { label = "MST", cmd = "/squelch /dga /brd UseMezST on",       offcmd = "/squelch /dga /brd UseMezST off",       tooltip = "MezST" },
            { label = "MAE", cmd = "/squelch /dga /brd UseMezAoE on",      offcmd = "/squelch /dga /brd UseMezAoE off",      tooltip = "MezAoE" }
        },
        Beastlord = {
            { label = "FEI", cmd = "/squelch /dga /bst UseFeign on",  offcmd = "/squelch /dga /bst UseFeign off",  tooltip = "Feign" },
            { label = "SAL", cmd = "/squelch /dga /bst SlowAll on",   offcmd = "/squelch /dga /bst SlowAll off",   tooltip = "SlowAll" },
            { label = "SAN", cmd = "/squelch /dga /bst SlowNamed on", offcmd = "/squelch /dga /bst SlowNamed off", tooltip = "SlowNamed" }
        },
        Berserker = {
            { label = "DEV", cmd = "/squelch /dga /ber UseDevAssault on", offcmd = "/squelch /dga /ber UseDevAssault off", tooltip = "DevAssault" },
            { label = "FRZ", cmd = "/squelch /dga /ber UseFrenzied on",   offcmd = "/squelch /dga /ber UseFrenzied off",   tooltip = "Frenzied" },
            { label = "CRY", cmd = "/squelch /dga /ber UseWarCry on",     offcmd = "/squelch /dga /ber UseWarCry off",     tooltip = "WarCry" }
        },
        Cleric = {
            { label = "SPL", cmd = "/squelch /dga /clr MemSplash on",      offcmd = "/squelch /dga /clr MemSplash off",      tooltip = "MemSplash" },
            { label = "ANT", cmd = "/squelch /dga /clr UseAnticipated on", offcmd = "/squelch /dga /clr UseAnticipated off", tooltip = "Anticipated" },
            { label = "RET", cmd = "/squelch /dga /clr UseRetort on",      offcmd = "/squelch /dga /clr UseRetort off",      tooltip = "Retort" }
        },
        Monk = {
            { label = "DEV", cmd = "/squelch /dga /mnk UseDevAssault on",  offcmd = "/squelch /dga /mnk UseDevAssault off",  tooltip = "DevAssault" },
            { label = "DES", cmd = "/squelch /dga /mnk UseDestructive on", offcmd = "/squelch /dga /mnk UseDestructive off", tooltip = "Destructive" },
            { label = "FEI", cmd = "/squelch /dga /mnk UseFeign on",       offcmd = "/squelch /dga /mnk UseFeign off",       tooltip = "Feign" }
        },
        Paladin = {
            { label = "SCO", cmd = "/squelch /dga /pal SplashCureOnly on", offcmd = "/squelch /dga /pal SplashCureOnly off", tooltip = "SplashCureOnly" },
            { label = "AOV", cmd = "/squelch /dga /pal UseActofValor on",  offcmd = "/squelch /dga /pal UseActofValor off",  tooltip = "ActofValor" },
            { label = "CAL", cmd = "/squelch /dga /pal UseDivineCall on",  offcmd = "/squelch /dga /pal UseDivineCall off",  tooltip = "DivineCall" }
        },
        Rogue = {
            { label = "ACG", cmd = "/squelch /dga /rog AutoCorpseGrab on",   offcmd = "/squelch /dga /rog AutoCorpseGrab off",   tooltip = "AutoCorpseGrab" },
            { label = "LIG", cmd = "/squelch /dga /rog UseLigamentSlice on", offcmd = "/squelch /dga /rog UseLigamentSlice off", tooltip = "LigamentSlice" },
            { label = "PET", cmd = "/squelch /dga /rog UsePet on",           offcmd = "/squelch /dga /rog UsePet off",           tooltip = "UsePet" }
        },
        Shadowknight = {
            { label = "INS", cmd = "/squelch /dga /shd UseInsidious on", offcmd = "/squelch /dga /shd UseInsidious off", tooltip = "Insidious" },
            { label = "PET", cmd = "/squelch /dga /shd UsePet on",       offcmd = "/squelch /dga /shd UsePet off",       tooltip = "Pet" },
            { label = "FEI", cmd = "/squelch /dga /shd UseFeign on",     offcmd = "/squelch /dga /shd UseFeign off",     tooltip = "Feign" }
        },
        Shaman = {
            { label = "CUR", cmd = "/squelch /dga /shm MemCureAll on", offcmd = "/squelch /dga /shm MemCureAll off", tooltip = "MemCureAll" },
            { label = "DOT", cmd = "/squelch /dga /shm UseDot on",     offcmd = "/squelch /dga /shm UseDot off",     tooltip = "Dot" },
            { label = "PET", cmd = "/squelch /dga /shm UsePet on",     offcmd = "/squelch /dga /shm UsePet off",     tooltip = "Pet" }
        },
        Warrior = {
            { label = "T2D", cmd = "/squelch /dga /war T2DefenseOnly on", offcmd = "/squelch /dga /war T2DefenseOnly off", tooltip = "T2DefenseOnly" },
            { label = "FRT", cmd = "/squelch /dga /war UseFortitude on",  offcmd = "/squelch /dga /war UseFortitude off",  tooltip = "Fortitude" },
            { label = "PHM", cmd = "/squelch /dga /war UsePhantom on",    offcmd = "/squelch /dga /war UsePhantom off",    tooltip = "Phantom" }
        },
    }

    for _, class in ipairs({
        "Bard", "Beastlord", "Berserker", "Cleric",
        "Monk", "Paladin",
        "Rogue", "Shadowknight", "Shaman", "Warrior",
    }) do
        -- Column 1: Class name (default color)
        imgui.Text(class)
        imgui.NextColumn()

        imgui.PushID(class)
        local abilities = classAbilities[class]
        if abilities then
            local rowY = imgui.GetCursorPosY()
            local startX = imgui.GetCursorPosX()
            local slotWidth = 70 -- spacing between checkbox slots

            for i, ability in ipairs(abilities) do
                imgui.SetCursorPos(startX + (i - 1) * slotWidth, rowY)

                local varName = class .. "_" .. ability.label
                _G[varName] = _G[varName] or false
                local checked, changed = imgui.Checkbox(ability.label, _G[varName])
                _G[varName] = checked

                if imgui.IsItemHovered() and ability.tooltip then
                    imgui.BeginTooltip()
                    imgui.TextUnformatted(ability.tooltip)
                    imgui.EndTooltip()
                end

                if changed then
                    if checked then
                        mq.cmd(ability.cmd)
                    elseif ability.offcmd then
                        mq.cmd(ability.offcmd)
                    end
                end
            end
        else
            imgui.PushStyleColor(ImGuiCol.Text, 0.0, 1.0, 0.0, 1.0) -- Lime green text
            imgui.Text("No Abilities Defined")
            imgui.PopStyleColor()
        end
        imgui.PopID()
        imgui.NextColumn()
    end

    imgui.Columns(1)
end



--CWTN Tab
local function drawCWTNTab()
    if forceRefresh > 0 then
        forceRefresh = forceRefresh - 1
    end

    imgui.Separator()
    local topButtons = {
        { label = "BON",  command = "BurnAlways ON",  tooltip = "BurnAlways ON" },
        { label = "BOFF", command = "BurnAlways OFF", tooltip = "BurnAlways OFF" },
        { label = "CHA",  command = "mode chase",     tooltip = "Chase mode" },
        { label = "ASS",  command = "mode assist",    tooltip = "Assist mode" },
        { label = "PON",  command = "pause ON",       tooltip = "Pause ON" },
        { label = "POFF", command = "pause OFF",      tooltip = "Pause OFF" },
    }

    -- StyleVar indices (ImGuiStyleVar enum)
    local STYLEVAR_FramePadding = 5

    imgui.PushStyleVar(STYLEVAR_FramePadding, 1, 1)

    for _, btn in ipairs(topButtons) do
        imgui.PushID("top_" .. btn.label)
        if imgui.Button(btn.label, 38, 25) then
            if btn.label == "BOFF" then
                mq.cmdf("%s %s", AllIncludingSelfBind, btn.command)
                mq.cmdf("%s %s", AllIncludingSelfBind, "BurnAllNamed OFF")
                print("Issued BurnAlways OFF and BurnAllNamed OFF")
            else
                mq.cmdf("%s %s", AllIncludingSelfBind, btn.command)
                print("Issued " .. btn.command)
            end
        end
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(btn.tooltip)
            imgui.EndTooltip()
        end
        imgui.PopID()
        imgui.SameLine()
    end

    imgui.PopStyleVar()
    imgui.NewLine()

    if imgui.Button("AE On") then
        --mq.cmdf("%s %s", getCWTNBind(), "UseAoE on")
        --mq.cmdf("%s %s", getCWTNBind(), "AoECount 2")
        --mq.cmdf("%s %s", getCWTNBind(), "UseDevAssault on")
        --mq.cmdf("%s %s", getCWTNBind(), "UseDestructive on")
        --mq.cmdf("%s %s", getCWTNBind(), "UseInsidious on")
        mq.cmd("/noparse /dga /docommand /${Me.Class.ShortName} UseAoE on")
        mq.cmd("/noparse /dga /docommand /${Me.Class.ShortName} AoECount 2")
        mq.cmd("/noparse /dga /docommand /${Me.Class.ShortName} UseDevAssault on")
        mq.cmd("/noparse /dga /docommand /${Me.Class.ShortName} UseDestructive on")
        mq.cmd("/noparse /dga /docommand /${Me.Class.ShortName} UseInsidious on")
        mq.cmd(
            "/noparse /dga /if (${Me.Class.ShortName.Equal[SHM]} && ${Me.AltAbility[Languid Bite: Disabled].ID}) /alt act 861")
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text("Turn on all AoE on all characters.")
        imgui.EndTooltip()
    end

    imgui.SameLine()

    if imgui.Button("AE Off") then
        --mq.cmdf("%s %s", getCWTNBind(), "UseAoE off")
        --mq.cmdf("%s %s", getCWTNBind(), "UseDevAssault off")
        --mq.cmdf("%s %s", getCWTNBind(), "UseDestructive off")
        --mq.cmdf("%s %s", getCWTNBind(), "UseInsidious off")
        mq.cmd("/noparse /dga /docommand /${Me.Class.ShortName} UseAoE off")
        mq.cmd("/noparse /dga /docommand /${Me.Class.ShortName} AoECount 99")
        mq.cmd("/noparse /dga /docommand /${Me.Class.ShortName} UseDevAssault off")
        mq.cmd("/noparse /dga /docommand /${Me.Class.ShortName} UseDestructive off")
        mq.cmd("/noparse /dga /docommand /${Me.Class.ShortName} UseInsidious off")
        mq.cmd(
            "/noparse /dga /if (${Me.Class.ShortName.Equal[SHM]} && ${Me.AltAbility[Languid Bite: Enabled].ID}) /alt act 861")
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text("Turn off all AoE on all characters. (includes DevAssault, Destructive, Insidious, Languid Bite)")
        imgui.EndTooltip()
    end

    imgui.SameLine()

    if imgui.Button("D-Glyph") then
        mq.cmdf("%s /alt act 5100", getCWTNBind())
        mq.cmdf("%s /alt buy 5100", getCWTNBind())
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text("Uses Dragon Scale Glyph on all characters but the one you are on now.")
        imgui.EndTooltip()
    end

    imgui.SameLine()

    if imgui.Button("P-Glyph") then
        mq.cmdf("%s /alt act 5303", getCWTNBind())
        mq.cmdf("%s /alt buy 5303", getCWTNBind())
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text("Uses Power/DPS Glyph on all characters but the one you are on now.")
        imgui.EndTooltip()
    end

    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetCursorPosX() + 5)
    -- Store the current state
    local newState = applytoallChecked
    -- Update the checkbox and get the new state
    newState = imgui.Checkbox("All##cwtnall", newState)

    -- Only update and print if the state changed
    if newState ~= applytoallChecked then
        applytoallChecked = newState
        print(applytoallChecked and "Including current character in CWTN commands" or
            "Excluding current character from CWTN commands")
    end

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text("Check to include current character in CWTN commands")
        imgui.EndTooltip()
    end



    -- LEFT COLUMN: All current settings
    -- Utility to wrap settings
    local function updateSetting(label, currentValue, updateFn)
        local old = currentValue
        imgui.PushItemWidth(100) -- Adjust slider width here
        if forceRefresh > 0 then
            imgui.SetNextItemWidth(100)
            imgui.SetKeyboardFocusHere()
        end
        currentValue = imgui.InputInt(label, currentValue)
        imgui.PopItemWidth()
        if currentValue ~= old then
            updateFn(currentValue)
            forceRefresh = 0
        end
        return currentValue
    end

    -- AutoAssistAt
    imgui.PushStyleColor(ImGuiCol.Text, 0.0, 1.0, 0.0, 1.0) -- Green color for number
    autoAssistAt = updateSetting("##AutoAssistAt", autoAssistAt, function(val)
        mq.cmdf("%s autoAssistAt %d", getCWTNBind(), val)
        print(string.format("Set AutoAssistAt to %d", val))
    end)
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.Text("AutoAssistAt")

    -- CampRadius
    imgui.PushStyleColor(ImGuiCol.Text, 0.0, 1.0, 0.0, 1.0) -- Green color for number
    CampRadius = updateSetting("##CampRadius", CampRadius, function(val)
        mq.cmdf("%s CampRadius %d", getCWTNBind(), val)
        print(string.format("Set CampRadius to %d", val))
    end)
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.Text("CampRadius")

    -- ChaseDistance
    imgui.PushStyleColor(ImGuiCol.Text, 0.0, 1.0, 0.0, 1.0) -- Green color for number
    ChaseDistance = updateSetting("##ChaseDistance", ChaseDistance, function(val)
        mq.cmdf("%s ChaseDistance %d", getCWTNBind(), val)
        print(string.format("Set ChaseDistance to %d", val))
    end)
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.Text("ChaseDistance")

    -- AoECount
    imgui.PushStyleColor(ImGuiCol.Text, 0.0, 1.0, 0.0, 1.0) -- Green color for number
    AoECount = updateSetting("##AoECount", AoECount, function(val)
        mq.cmdf("%s AoECount %d", getCWTNBind(), val)
        print(string.format("Set AoECount to %d", val))
    end)
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.Text("AoECount")

    -- BurnCount
    imgui.PushStyleColor(ImGuiCol.Text, 0.0, 1.0, 0.0, 1.0) -- Green color for number
    BurnCount = updateSetting("##BurnCount", BurnCount, function(val)
        mq.cmdf("%s BurnCount %d", getCWTNBind(), val)
        print(string.format("Set BurnCount to %d", val))
    end)
    imgui.PopStyleColor()
    imgui.SameLine()
    imgui.Text("BurnCount")

    -- StickHow combo box with label to the right
    local stickHowOptions = {
        [0] = "0 - Behind 10",
        [1] = "1 - Left 10",
        [2] = "2 - Right 10",
        [3] = "3 - Front 10",
        [4] = "4 - Behind 15",
        [5] = "5 - Left 15",
        [6] = "6 - Right 15",
        [7] = "7 - Front 15",
        [8] = "8 - Behind 10",
        [9] = "9 - 35 Ranger",
    }

    imgui.PushItemWidth(110)
    local preview = stickHowOptions[StickHow] or "Select..."
    -- Set text color for the preview
    if preview == "Select..." then
        imgui.PushStyleColor(ImGuiCol.Text, 0.5, 0.5, 0.5, 1.0) -- Gray text for "Select..."
    else
        imgui.PushStyleColor(ImGuiCol.Text, 0.0, 1.0, 0.0, 1.0) -- Green text for selected option
    end

    if imgui.BeginCombo("##StickHow", preview) then
        imgui.PopStyleColor() -- Pop the color for the dropdown items
        for index, label in pairs(stickHowOptions) do
            local isSelected = (StickHow == index)
            -- Set text color for selected item in dropdown
            if isSelected then
                imgui.PushStyleColor(ImGuiCol.Text, 0.0, 1.0, 0.0, 1.0) -- Green text for selected item
            end
            if imgui.Selectable(label, isSelected) then
                if not isSelected then
                    StickHow = index
                    mq.cmdf("%s StickHow %d", getCWTNBind(), StickHow)
                    print("Set StickHow to " .. label)
                end
            end
            if isSelected then
                imgui.SetItemDefaultFocus()
                imgui.PopStyleColor() -- Pop the green color
            end
        end
        imgui.EndCombo()
    else
        imgui.PopStyleColor() -- Pop the color if combo is not open
    end
    imgui.PopItemWidth()

    imgui.SameLine()
    -- Keep the label gold
    imgui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0) -- Gold color
    imgui.Text("StickHow")
    imgui.PopStyleColor()

    -- RaidMode toggle
    local prevRaidMode = RaidMode
    RaidMode = imgui.Checkbox("RaidMode", RaidMode)
    if RaidMode ~= prevRaidMode then
        local toggleCmd = RaidMode and "on" or "off"
        mq.cmdf("%s RaidMode %s", getCWTNBind(), toggleCmd)
        print(string.format("Set RaidMode to %s", toggleCmd))
    end

    -- Raid Assist dropdown
    imgui.SameLine()
    imgui.Text("RA:")
    imgui.SameLine()

    -- Fetch current assist names
    local assistOptions = {}
    for i = 1, 3 do
        local name = mq.TLO.Raid.MainAssist(i).Name()
        if name and name ~= "" then
            table.insert(assistOptions, name)
        end
    end

    if #assistOptions == 0 then
        assistOptions = { "None" }
    end

    -- Combo UI
    imgui.PushItemWidth(100) -- limit width

    -- Set text color for the preview
    local preview = selectedRaidAssist or "Select RA"
    if preview == "Select RA" then
        imgui.PushStyleColor(ImGuiCol.Text, 0.5, 0.5, 0.5, 1.0) -- Gray text for "Select RA"
    else
        imgui.PushStyleColor(ImGuiCol.Text, 0.0, 1.0, 0.0, 1.0) -- Green text for selected RA
    end

    if imgui.BeginCombo("##RaidAssist", preview) then
        imgui.PopStyleColor() -- Pop the color for the dropdown items

        for _, assist in ipairs(assistOptions) do
            local isSelected = (assist == selectedRaidAssist)
            -- Set text color for selected item in dropdown
            if isSelected then
                imgui.PushStyleColor(ImGuiCol.Text, 0.0, 1.0, 0.0, 1.0) -- Green text for selected item
            end

            if imgui.Selectable(assist, isSelected) then
                -- Only send command if the selection is actually changing
                if not isSelected then
                    selectedRaidAssist = assist
                    mq.cmdf("%s RaidAssist %s", getCWTNBind(), selectedRaidAssist)
                    print("Set RaidAssist to " .. selectedRaidAssist)
                end
            end

            if isSelected then
                imgui.SetItemDefaultFocus()
                imgui.PopStyleColor() -- Pop the green color
            end
        end

        imgui.EndCombo()
    else
        imgui.PopStyleColor() -- Pop the green color if combo is not open
    end

    imgui.PopItemWidth()

    --[[  -- Comment start
    imgui.SameLine()
    local byosText = "BYOS: "
    local byosStateText = { "SET", "ON", "OFF" }
    local byosButtonState = BYOS + 1

    -- Set text color based on state
    local stateColor
    if BYOS == 0 then
        stateColor = { 0.5, 0.5, 0.5, 1.0 } -- Grey for SET
    elseif BYOS == 1 then
        stateColor = { 0.0, 1.0, 0.0, 1.0 } -- Green for ON
    else
        stateColor = { 1.0, 0.0, 0.0, 1.0 } -- Red for OFF
    end

    -- Draw "BYOS:" in gold
    imgui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0) -- Gold color
    imgui.Text(byosText)
    imgui.PopStyleColor()

    -- Draw the state text with appropriate color
    imgui.SameLine(0, 0)        -- No spacing between text elements
    imgui.PushStyleColor(ImGuiCol.Text, unpack(stateColor))
    imgui.PushID("byos_button") -- Add this line
    if imgui.Button(byosStateText[byosButtonState]) then
        BYOS = (BYOS + 1) % 3
        if BYOS == 1 then
            mq.cmdf("/squelch %s byos on", getCWTNBind())
            print("Set BYOS to ON")
        elseif BYOS == 2 then
            mq.cmdf("/squelch %s byos off", getCWTNBind())
            print("Set BYOS to OFF")
        end
    end
    imgui.PopID() -- Add this line
    imgui.PopStyleColor()
--]] -- Comment end

    -- UseAoE toggle
    local aoeText = "AoE: "
    local aoeStateText = { "SET", "ON", "OFF" }
    local aoeButtonState = UseAoE + 1

    -- Set text color based on state
    local aoeStateColor
    if UseAoE == 0 then
        aoeStateColor = { 0.5, 0.5, 0.5, 1.0 } -- Grey for SET
    elseif UseAoE == 1 then
        aoeStateColor = { 0.0, 1.0, 0.0, 1.0 } -- Green for ON
    else
        aoeStateColor = { 1.0, 0.0, 0.0, 1.0 } -- Red for OFF
    end

    -- Draw "AoE:" in gold
    imgui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0) -- Gold color
    imgui.Text(aoeText)
    imgui.PopStyleColor()

    -- Draw the state text with appropriate color
    imgui.SameLine(0, 0)
    imgui.PushStyleColor(ImGuiCol.Text, unpack(aoeStateColor))
    imgui.PushID("aoe_button")
    if imgui.Button(aoeStateText[aoeButtonState]) then
        UseAoE = (UseAoE + 1) % 3
        if UseAoE == 1 then
            mq.cmdf("%s useaoe on", getCWTNBind())
            print("Set AoE to ON")
        elseif UseAoE == 2 then
            mq.cmdf("%s useaoe off", getCWTNBind())
            print("Set AoE to OFF")
        end
    end
    imgui.PopID()
    imgui.PopStyleColor()

    imgui.SameLine()
    local allianceText = "Alliance: "
    local allianceStateText = { "SET", "ON", "OFF" }
    local allianceButtonState = UseAlliance + 1

    -- Set text color based on state
    local allianceStateColor
    if UseAlliance == 0 then
        allianceStateColor = { 0.5, 0.5, 0.5, 1.0 } -- Grey for SET
    elseif UseAlliance == 1 then
        allianceStateColor = { 0.0, 1.0, 0.0, 1.0 } -- Green for ON
    else
        allianceStateColor = { 1.0, 0.0, 0.0, 1.0 } -- Red for OFF
    end

    -- Draw "Alliance:" in gold
    imgui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0) -- Gold color
    imgui.Text(allianceText)
    imgui.PopStyleColor()

    -- Draw the state text with appropriate color
    imgui.SameLine(0, 0)
    imgui.PushStyleColor(ImGuiCol.Text, unpack(allianceStateColor))
    imgui.PushID("alliance_button")
    if imgui.Button(allianceStateText[allianceButtonState]) then
        UseAlliance = (UseAlliance + 1) % 3
        if UseAlliance == 1 then
            mq.cmdf("%s usealliance on", getCWTNBind())
            mq.cmdf("%s forcealliance on", getCWTNBind())
            print("Set Alliance to ON")
        elseif UseAlliance == 2 then
            mq.cmdf("%s usealliance off", getCWTNBind())
            mq.cmdf("%s forcealliance off", getCWTNBind())
            print("Set Alliance to OFF")
        end
    end
    imgui.PopID()
    imgui.PopStyleColor()

    imgui.SameLine()
    local meleeText = "Melee: "
    local meleeStateText = { "SET", "ALL", "PRIESTS", "CASTERS", "OFF" }
    local meleeButtonState = UseMelee + 1

    -- Set text color based on state
    local meleeStateColor
    if UseMelee == 0 then
        meleeStateColor = { 0.5, 0.5, 0.5, 1.0 } -- Grey for SET
    elseif UseMelee == 4 then
        meleeStateColor = { 1.0, 0.0, 0.0, 1.0 } -- Red for OFF
    else
        meleeStateColor = { 0.0, 1.0, 0.0, 1.0 } -- Green for other states
    end

    -- Draw "Melee:" in gold
    imgui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0) -- Gold color
    imgui.Text(meleeText)
    imgui.PopStyleColor()

    -- Draw the state text with appropriate color
    imgui.SameLine(0, 0)         -- No spacing between text elements
    imgui.PushStyleColor(ImGuiCol.Text, unpack(meleeStateColor))
    imgui.PushID("melee_button") -- Add this line
    if imgui.Button(meleeStateText[meleeButtonState]) then
        UseMelee = (UseMelee + 1) % 5
        -- For UseMelee commands, we'll use /dga or /dge directly
        local bindPrefix = applytoallChecked and "/dga" or "/dge"
        if UseMelee == 1 then -- All ON
            mq.cmdf("%s usemelee on", getCWTNBind())
            print("Set Melee to ON for all")
        elseif UseMelee == 2 then -- Priests Only
            -- Turn on for priests
            mq.cmdf("%s /docommand /clr usemelee on", bindPrefix)
            mq.cmdf("%s /docommand /shm usemelee on", bindPrefix)
            mq.cmdf("%s /docommand /dru usemelee on", bindPrefix)
            -- Turn off for casters
            mq.cmdf("%s /docommand /enc usemelee off", bindPrefix)
            mq.cmdf("%s /docommand /nec usemelee off", bindPrefix)
            mq.cmdf("%s /docommand /wiz usemelee off", bindPrefix)
            mq.cmdf("%s /docommand /mag usemelee off", bindPrefix)
            print("Set Melee ON for priests only")
        elseif UseMelee == 3 then -- Casters Only
            -- Turn on for casters
            mq.cmdf("%s /docommand /enc usemelee on", bindPrefix)
            mq.cmdf("%s /docommand /nec usemelee on", bindPrefix)
            mq.cmdf("%s /docommand /wiz usemelee on", bindPrefix)
            mq.cmdf("%s /docommand /mag usemelee on", bindPrefix)
            -- Turn off for priests
            mq.cmdf("%s /docommand /clr usemelee off", bindPrefix)
            mq.cmdf("%s /docommand /shm usemelee off", bindPrefix)
            mq.cmdf("%s /docommand /dru usemelee off", bindPrefix)
            print("Set Melee ON for casters only")
        elseif UseMelee == 4 then -- All OFF
            mq.cmdf("%s usemelee off", getCWTNBind())
            print("Set Melee to OFF for all")
        end
    end
    imgui.PopID()
    imgui.PopStyleColor()

    --imgui.NewLine()
    imgui.Columns(1)
    if imgui.Button("Save") then
        saveSettings()
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text("Save current settings as default")
        imgui.EndTooltip()
    end

    imgui.SameLine()

    -- Load Button
    if imgui.Button("Load") then
        loadSettings()
    end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.Text("Load saved settings")
        imgui.EndTooltip()
    end
    -- Reset to single-column layout
end



-- Main ImGui draw function
local function drawGUI()
    if not openGUI then
        mq.exit()
        return
    end

    -- Store the number of styles we're pushing
    local stylePushCount = 0
    local function pushStyleColor(...)
        stylePushCount = stylePushCount + 1
        return imgui.PushStyleColor(...)
    end

    -- Set styling for window and title bar
    pushStyleColor(ImGuiCol.WindowBg, 0, 0, 0, 1)         -- Black background
    pushStyleColor(ImGuiCol.TitleBg, 0, 0, 0, 1)          -- Black title bar (inactive)
    pushStyleColor(ImGuiCol.TitleBgActive, 0, 0, 0, 1)    -- Black title bar (active)
    pushStyleColor(ImGuiCol.Text, 0.973, 0.741, 0.129, 1) -- Gold text

    -- Tab and button colors (dark grey)
    pushStyleColor(ImGuiCol.Tab, 0.2, 0.2, 0.2, 1)           -- Inactive tab background
    pushStyleColor(ImGuiCol.TabActive, 0.3, 0.3, 0.3, 1)     -- Active tab background
    pushStyleColor(ImGuiCol.TabHovered, 0.4, 0.4, 0.4, 1)    -- Hovered tab background
    pushStyleColor(ImGuiCol.Button, 0.2, 0.2, 0.2, 1)        -- Button background
    pushStyleColor(ImGuiCol.ButtonHovered, 0.3, 0.3, 0.3, 1) -- Button hovered
    pushStyleColor(ImGuiCol.ButtonActive, 0.4, 0.4, 0.4, 1)  -- Button active

    -- Combo box and dropdowns
    pushStyleColor(ImGuiCol.FrameBg, 0.2, 0.2, 0.2, 1)        -- Combo/Input background
    pushStyleColor(ImGuiCol.FrameBgHovered, 0.3, 0.3, 0.3, 1) -- Combo/Input hovered
    pushStyleColor(ImGuiCol.FrameBgActive, 0.4, 0.4, 0.4, 1)  -- Combo/Input active
    pushStyleColor(ImGuiCol.PopupBg, 0.15, 0.15, 0.15, 1)     -- Dropdown background

    -- Checkboxes and radio buttons
    pushStyleColor(ImGuiCol.CheckMark, 0.0, 8.85, 0.0, 1.0)     -- Changed to match command text green
    pushStyleColor(ImGuiCol.SliderGrab, 0.4, 0.4, 0.4, 1)       -- Slider grab
    pushStyleColor(ImGuiCol.SliderGrabActive, 0.5, 0.5, 0.5, 1) -- Slider grab active

    -- Headers and separators
    pushStyleColor(ImGuiCol.Header, 0.2, 0.2, 0.2, 1)        -- Header background
    pushStyleColor(ImGuiCol.HeaderHovered, 0.3, 0.3, 0.3, 1) -- Header hovered
    pushStyleColor(ImGuiCol.HeaderActive, 0.4, 0.4, 0.4, 1)  -- Header active
    pushStyleColor(ImGuiCol.Separator, 0.5, 0.5, 0.5, 0.5)   -- Separator color

    -- Add button rounding
    imgui.PushStyleVar(ImGuiStyleVar.FrameRounding, 6.0) -- Rounded corners for buttons

    -- Create window with default flags to keep the minimize button
    local windowOpen = openGUI
    if not imgui.Begin("Raid Prep", windowOpen) then
        -- Window is being closed
        openGUI = false
        imgui.End()
        imgui.PopStyleVar() -- Pop the frame rounding style var
        -- Safe pop - try to pop up to the tracked count, but don't error if we run out
        for i = 1, stylePushCount do
            local success, err = pcall(imgui.PopStyleColor)
            if not success then
                -- We've run out of styles to pop, break out of loop
                break
            end
        end
        return
    end

    -- Store window height when not minimized
    if not isWindowMinimized then
        windowHeight = imgui.GetWindowHeight()
    end

    -- Only show content if not minimized
    if not isWindowMinimized then
        -- Safely handle tabs
        if imgui.BeginTabBar("RaidPrepTabs") then
            -- Lua tab
            if imgui.BeginTabItem("lua") then
                local success, err = pcall(drawluaTab)
                if not success then
                    print("[ERROR] In lua tab: " .. tostring(err))
                end
                imgui.EndTabItem()
            end

            -- Class tab
            if imgui.BeginTabItem("Class") then
                local success, err = pcall(drawClassTab)
                if not success then
                    print("[ERROR] In Class tab: " .. tostring(err))
                end
                imgui.EndTabItem()
            end

            -- CWTN tab
            if imgui.BeginTabItem("CWTN") then
                local success, err = pcall(drawCWTNTab)
                if not success then
                    print("[ERROR] In CWTN tab: " .. tostring(err))
                end
                imgui.EndTabItem()
            end

            -- Buffs tab
            if imgui.BeginTabItem("Buffs") then
                local success, err = pcall(buffUI.drawBuffsTab)
                if not success then
                    print("[ERROR] In Buffs tab: " .. tostring(err))
                end
                imgui.EndTabItem()
            end

            -- Add help button after the last tab
            imgui.SameLine()
            imgui.SetCursorPosX(imgui.GetCursorPosX() + imgui.GetContentRegionAvail() - 20) -- Position at far right
            imgui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 0.0, 1.0)                         -- Yellow text
            imgui.Text("?")
            imgui.PopStyleColor()

            if imgui.IsItemHovered() then
                imgui.PushStyleVar(ImGuiStyleVar.WindowPadding, 1, 1) -- Add padding
                imgui.BeginTooltip()
                imgui.Text("--- Raid Prep Help ---")
                imgui.Separator()
                imgui.BulletText("Burn On/Off and AE On/Off uses /dga : All characters")
                imgui.BulletText("All other commands uses /dge : All characters except you")
                imgui.BulletText("Click the All button to use /dga for all commands.")
                imgui.EndTooltip()
                imgui.PopStyleVar()
            end
        end
        imgui.EndTabBar()
    end

    imgui.End()

    -- Clean up styles
    imgui.PopStyleVar() -- Pop the frame rounding style var
    -- Safe pop - try to pop up to the tracked count, but don't error if we run out
    for i = 1, stylePushCount do
        local success, err = pcall(imgui.PopStyleColor)
        if not success then
            -- We've run out of styles to pop, break out of loop
            break
        end
    end

    -- Check if window was closed
    if not windowOpen then
        openGUI = false
    end
end

mq.imgui.init("RaidPrepUI", drawGUI)

local lastAnnounce = 0
local lastCleanup = 0
local lastProcessCleanups = 0
while true do
    local now = os.time()

    -- Process pending casts every 100ms
    if buffUI.processCasts then
        buffUI.processCasts()
    end

    -- Monitor buffs and auto-request when they drop every 100ms
    if buffUI.monitorBuffs then
        buffUI.monitorBuffs()
    end

    -- Check spell loading completion every 100ms
    if buffUI.checkSpellLoading then
        buffUI.checkSpellLoading()
    end

    -- Process buff UI cleanups every 100ms
    if now - lastProcessCleanups >= 0.1 then
        if buffUI.processCleanups then
            buffUI.processCleanups()
        end
        lastProcessCleanups = now
    end

    -- Every 10 seconds, announce buffs
    if now - lastAnnounce >= 10 then
        if buffUI.announceBuffs then
            buffUI.announceBuffs()
        end
        lastAnnounce = now
    end

    -- Every 5 seconds, clean up stale entries
    if now - lastCleanup >= 5 then
        if buffUI.cleanupStaleEntries then
            buffUI.cleanupStaleEntries()
        end
        lastCleanup = now
    end

    -- Process events and add a small delay
    mq.doevents()
    mq.delay(100) -- Check every 100ms
end
