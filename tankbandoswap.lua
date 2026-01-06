---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")
local imgui = require("ImGui")

BL.info("TankBandoSwap Script v1.1 Started")

-- Get command-line argument
local arg = ...
local threshold = tonumber(arg) or 3
local swapOnNamed = false

BL.info(string.format("TankBandoSwap started with XTarget threshold: %d, Swap on named: %s", threshold,
    tostring(swapOnNamed)))

local currentSet = "Unknown"
local thresholdInput = threshold

-- ImGui UI
mq.imgui.init("TankBandoSwapUI", function()
    -- Begin window and check if it's open
    local windowOpen = imgui.Begin("Tank Bando Swap", true)
    if not windowOpen then
        imgui.End()
        mq.exit() -- Exit the script when X is clicked
        return
    end

    -- Window content
    imgui.Text("Current Set: " .. (currentSet or "Unknown"))
    if imgui.IsItemHovered() then
        imgui.SetTooltip("Must have bandolier sets named 2H and Shield for SK/PAL\nand DW and Shield for Warrior")
    end
    imgui.Text("XTargets: " .. tostring(mq.TLO.Me.XTarget() or 0))
    imgui.Text("Target is Named: " .. (mq.TLO.Target.Named() and "Yes" or "No"))

    imgui.Text("Current Threshold: ")
    local newThreshold = imgui.InputInt("##threshold", thresholdInput)
    if newThreshold and newThreshold > 0 and newThreshold ~= threshold then
        threshold = newThreshold
        thresholdInput = newThreshold
        BL.info("Threshold updated to: " .. threshold)
    end

    -- Add checkbox for named target swapping
    local newSwapOnNamed = imgui.Checkbox("Swap on Named", swapOnNamed)
    if imgui.IsItemHovered() then
        imgui.SetTooltip("Will swap to Shield set on named mobs when checked")
    end
    if newSwapOnNamed ~= nil and newSwapOnNamed ~= swapOnNamed then
        swapOnNamed = newSwapOnNamed
        BL.info("Swap on named target: " .. tostring(swapOnNamed))
    end

    imgui.End()
end)

-- Logic loop
while true do
    local me = mq.TLO.Me
    local target = mq.TLO.Target
    local xtarCount = me.XTarget()
    local class = me.Class.ShortName()
    local shouldUseShield = xtarCount >= threshold or (swapOnNamed and target.Named())
    local isCasting = me.Casting()

    -- Don't swap if currently casting
    if not isCasting then
        if class == "WAR" then
            if not shouldUseShield and currentSet ~= "DW" then
                BL.info("Warrior: Switching to DW Bandolier")
                mq.cmd("/bandolier activate DW")
                currentSet = "DW"
            elseif shouldUseShield and currentSet ~= "Shield" then
                BL.info("Warrior: Switching to Shield Bandolier")
                mq.cmd("/bandolier activate Shield")
                currentSet = "Shield"
            end
        else
            if not shouldUseShield and currentSet ~= "2H" then
                BL.info("Switching to 2H Bandolier")
                mq.cmd("/bandolier activate 2H")
                currentSet = "2H"
            elseif shouldUseShield and currentSet ~= "Shield" then
                BL.info("Switching to Shield Bandolier")
                mq.cmd("/bandolier activate Shield")
                currentSet = "Shield"
            end
        end
    end

    mq.delay(250)
end
