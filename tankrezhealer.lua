---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')
---@type ImGui
local ImGui = require('ImGui')

local rezToken = "Token of Resurrection"



local function checkHealerIsDead()
    local healerSpawn = mq.TLO.Spawn("Caellia")

    if healerSpawn.Dead() then
        BL.info("Healer is dead!")
        return true
    end

    return false
end
local didPauseGrind = false
local function rezTokenHealer()
    -- wait to leave combat
    while mq.TLO.Me.Combat()
        or mq.TLO.Me.XTarget() > 0
    do
        mq.delay(500)
    end
    -- pause cwtn/grind
    BL.cmd.pauseAutomation()
    if mq.TLO.Grind.Paused then
        BL.info("Grind is active, pausing.")
        mq.cmd("/grind pause")
        mq.delay(1000)
        didPauseGrind = true
    end
    -- target healer and rez
    mq.cmdf('/target %s', State.HealerName)
    mq.delay(500)
    BL.info("Rezzing healer")
    mq.cmdf('/useitem %s', rezToken)
    mq.delay(10000) -- 7 sec cast time on the rez token
    -- resume cwtn/grind
    BL.cmd.resumeAutomation()
    if didPauseGrind then
        mq.cmd("/grind resume")
        mq.delay(1000)
        didPauseGrind = false
    end
end

local counter = 0
local function DrawUI()
    if not State.Paused then counter = counter + 1 end
    --print out counter's value, shows whether script is paused or not for demo purposes
    BL.Gui.Text(counter)
   
    -- Make a button that runs the function when pressed
    BL.Gui.Button("Button", function()
        print('Button was pressed')
    end)
    
    ImGui.SameLine()
    checkBox1 = ImGui.Checkbox("Box 1", checkBox1) -- toggling this updates the checkBox1 variable. Use in other 'if' statements
    ImGui.SameLine(300)                            -- You can specify distance. Number is how many pixels from left side of window
    checkBox2 = ImGui.Checkbox("Box 2", checkBox2)
    ImGui.Separator()
end

----------------------------------- Execution --------------------------------

---@type ScriptState
local State = {
    Paused = false,
    HealerName = "Caellia",

}

BL.Gui:Init({
    WindowName = "Tank Rez Healer",
    ScriptName = "tankrezhealer",
    ScriptState = State,
    DrawFunction = DrawUI,
})

while true do
    if not State.Paused then
        local dead = checkHealerIsDead()
        if dead then
            rezTokenHealer()
        end
    end
    mq.delay(1023)
end
