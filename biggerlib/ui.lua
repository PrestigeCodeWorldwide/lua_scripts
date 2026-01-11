---@type Mq
local mq = require('mq')
local Log = require('biggerlib.Log')
---@type ImGui
local ImGui = require('ImGui')



---@class UIConfig
---@field WindowName string
---@field ScriptName string
---@field ScriptState ScriptState
---@field DrawFunction function

---@class UIState
---@field Transparency boolean
---@field TitleBar boolean
---@field Locked boolean
---@field WindowPos ImVec2
---@field WindowSize ImVec2
---@field DevMode boolean

---@class GuiUtils
---@field GetOnOffColor (fun(val: string): string)|nil

---@class Gui
---@field Config UIState
---@field OpenGUI boolean
---@field ShouldDrawGUI boolean
---@field Name string
---@field UpdateCallbackFn function|nil
---@field ScriptState ScriptState
---@field ScriptName string
---@field Util GuiUtils
---@field Tick fun(self: Gui)|nil
---@field Init fun(self: Gui, uiConfig: UIConfig)|nil
---@field Destroy fun(self: Gui)|nil
---@field Button fun(ButtonText: string|number, IfPressedCallback: function)|nil
---@field Text fun(Text: string|number)|nil
---returns newValue, changed
---@field Checkbox ( fun(self: Gui,Text: string|number, Value: boolean): boolean, boolean)|nil
---@field Save fun(self: Gui)|nil
---@field Load fun(self: Gui)|nil

---@type UIState
local UIState = {
    Transparency = false,
    TitleBar = true,
    Locked = false,
    WindowPos = ImVec2(100, 100),
    WindowSize = ImVec2(500, 500),
    DevMode = true,
}

---@type Gui
local Gui = {
    Config = UIState,
    Name = "",
    OpenGUI = true,
    ShouldDrawGUI = true,
    ScriptState = {},
    ScriptName = "",
    DirtySave = false,
    Util = {},
}

local Icons = {
    FA_PLAY = '\xef\x81\x8b',
    FA_PAUSE = '\xef\x81\x8c',
    FA_STOP = '\xef\x81\x8d',
    FA_SAVE = '\xee\x85\xa1',
    FA_UNDO = '\xef\x83\xa2',
    FA_LOCK = '\xef\x80\xa3',
    FA_UNLOCK = '\xef\x82\x9c'
}

---------------------------------- Definitions --------------------------------------------
local function coalesceConfigs(libConfig, scriptConfig)
    local config = {
        LibConfig = libConfig,
        ScriptConfig = scriptConfig
    }
    return config
end

Gui.Save = function(self)
    local path = self.ScriptName .. "Cfg.lua"
    Log.info("Serializing settings to %s", path)
    Log.dump(self.ScriptState, "ScriptState")
    mq.pickle(path, coalesceConfigs(self.Config, self.ScriptState))
    self.ScriptState.DirtyFlag = false
end

Gui.Load = function(self)
    local path = self.ScriptName .. "Cfg.lua"
    local configData, err = loadfile(mq.configDir .. '/' .. path)
    if err then
        -- failed to read the config file, create it using pickle
        mq.pickle(path, coalesceConfigs(self.Config, self.ScriptState))
    elseif configData then
        -- file loaded, put content into your config table
        local configs = configData()
        self.Config = configs.LibConfig
        self.ScriptState = configs.ScriptConfig
    end
    self.ScriptState.DirtyFlag = false
end

Gui.Tick = function(self)
    if self.ScriptState.DirtyFlag then
        --Log.info("Saving settings")
        self:Save()
    end

    --Log.info("Ticking GUI")
    if not self.OpenGUI then return end

    if self.ShouldDrawGUI then
        local flags = 0
        if not self.Config.TitleBar then flags = ImGuiWindowFlags.NoTitleBar end
        if self.Config.Transparency then flags = bit32.bor(flags, ImGuiWindowFlags.NoBackground) end
        if self.Config.Locked then flags = bit32.bor(flags, ImGuiWindowFlags.NoMove) end
        if self.Config.WindowPos then
            ImGui.SetNextWindowPos(
                self.Config.WindowPos,
                ImGuiCond.Once
            )
        end
        if self.Config.WindowSize then ImGui.SetNextWindowSize(self.Config.WindowSize, ImGuiCond.Once) end

        -- Call ImGui.Begin but don't update self.OpenGUI to prevent permanent closure
        local shouldDraw, shouldContinue = ImGui.Begin(self.Name, true, flags)
        self.ShouldDrawGUI = shouldDraw
        
        -- Check if window is being closed (X button clicked) and exit script
        if not shouldDraw and self.OpenGUI then
            -- Window was closed by X button, exit the script
            mq.exit()
        end
        -- Keep self.OpenGUI as true to prevent window from disappearing permanently
        --Log.info("Calling script callback")

        --draw the generic content
        -- pause/resume
        --[[ COMMENTED OUT - Remove default pause/play buttons
        if self.ScriptState.Paused then
            if ImGui.Button(Icons.FA_PLAY) then
                --Log.warn("Changing PAUSED state to false")
                self.ScriptState.Paused = false
                self.ScriptState.DirtyFlag = true
            end
        else
            if ImGui.Button(Icons.FA_PAUSE) then
                --Log.warn("Changing PAUSED state to TRUE")
                self.ScriptState.Paused = true
                self.ScriptState.DirtyFlag = true
            end
        end
        -- reload script
        
        ImGui.SameLine()
        if ImGui.Button(Icons.FA_UNDO) then
            --Log.warn("Reloading Script")
            if self.Config.DevMode then
                mq.cmdf("/multiline ; /lua stop zen/%s ; /timed 1 /lua run zen/%s", self.ScriptName, self.ScriptName)
            else
                mq.cmdf("/multiline ; /lua stop %s ; /timed 1 /lua run %s", self.ScriptName, self.ScriptName)
            end
        end

        -- lock window button
        ImGui.SameLine()
        --local lockedIcon = self.Config.Locked and Icons.FA_LOCK .. '##lock' .. self.Name or
        local lockedIcon
        if self.Config.Locked then
            lockedIcon = Icons.FA_LOCK
        else
            lockedIcon = Icons.FA_UNLOCK
        end

        if ImGui.Button(lockedIcon) then
            --ImGuiWindowFlags.NoMove
            self.Config.Locked = not self.Config.Locked
            if self.Config.Locked then
                --Log.info("Reminder to save settings with locked change")
                self.ScriptState.DirtyFlag = true
            end
        end
        -- END COMMENTED OUT SECTION ]]

        self.UpdateCallbackFn()

        ImGui.End()
    end
end

Gui.Button = function(ButtonText, IfPressedCallback)
    if type(ButtonText) == "number" then
        ButtonText = tostring(ButtonText)
    end
    if ImGui.Button(ButtonText) then
        IfPressedCallback()
    end
end

Gui.Text = function(Text)
    if type(Text) == "number" then
        Text = tostring(Text)
    end
    ImGui.Text(Text)
    ImGui.Text("\n")
end

Gui.Checkbox = function(self, Text, Value)
    if type(Text) == "number" then
        Text = tostring(Text)
    end
    local value, pressed = ImGui.Checkbox(Text, Value)
    if pressed then self.ScriptState.DirtyFlag = true end
    
    return value, pressed
end

--- Note that this expects a full State table to be passed in as pausedState
--- @param uiConfig UIConfig
Gui.Init = function(self, uiConfig)
    --Log.info("Gui.Init")
    self.Name = uiConfig.WindowName
    self.ScriptName = uiConfig.ScriptName
    self.UpdateCallbackFn = uiConfig.DrawFunction
    self.ScriptState = uiConfig.ScriptState
    self:Load()
    mq.imgui.init(self.Name, function() return self:Tick() end)
end

Gui.Destroy = function(self)
    --Log.info("Gui.Destroy")
    mq.imgui.destroy(self.Name)
end

--------------------- Utils ---------------------
Gui.Util.GetOnOffColor = function(val)
    if val == "on" then
        return "\agon"
    elseif val == "off" then
        return "\aroff"
    end
    return val
end

return Gui