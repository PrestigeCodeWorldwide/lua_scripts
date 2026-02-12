---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')

BL.info("ToECannons Script v1.12 Started")
BL.info("Type /tcstop to stop the script and connect Dannet/BCS")
mq.cmd("/plugin boxr load")

local shouldExit = false
local function StopCannons()
    BL.info("Stopping cannons - loading Dannet and connecting BCS")
    mq.cmd("/plugin dannet load")
    mq.delay(1000) -- Wait for plugin to load
    mq.cmd("/bccmd connect")
    mq.delay(500)  -- Wait for connection
    BL.info("ToE Cannons script stopped by command")
    return true
end

mq.bind('/tcstop', function()
    shouldExit = true
    StopCannons()
end)

---@return boolean
local function FacingTarget()
    if mq.TLO.Target.ID() == 0 then return true end
    return math.abs(mq.TLO.Target.HeadingTo.DegreesCCW() - mq.TLO.Me.Heading.DegreesCCW()) <= 20
end

mq.cmd("/bccmd quit")
mq.cmd("/plugin dannet unload")
--mq.cmdf("/docommand /%s mode 0", mq.TLO.Me.Class.ShortName())
BL.cmd.ChangeAutomationModeToManual()
mq.cmdf("/grouproles set %s 1", mq.TLO.Me.CleanName())
mq.cmdf("/grouproles set %s 2", mq.TLO.Me.CleanName())
--mq.cmd("/rs Three pattern - 90, 80, 70 percent")
--mq.cmd("/rs Four pattern - 60, 50, 40, 30 percent")
--mq.cmd("/rs Five pattern - 20 percent")
--mq.cmd("/rs Six pattern - 10 percent")

while not shouldExit do
    -- Check if a military chest has spawned and end script
    local chest = mq.TLO.Spawn("a_military_chest")
    if chest() and chest.ID() > 0 then
        shouldExit = StopCannons()
    end

    --Cannoneer Name= a scalewrought cannoneer	
    local cannoneer = mq.TLO.Spawn("a scalewrought cannoneer")

    if cannoneer() and cannoneer.Distance() > 15 and not mq.TLO.Navigation.Active() then
        BL.info("Navigating to cannoneer.")
        mq.cmd("/nav spawn a scalewrought cannoneer")
        mq.delay(300)
    end

    -- Target cannoneer if it's not already targeted
    if cannoneer() and (not mq.TLO.Target.ID() or mq.TLO.Target.CleanName() ~= "a scalewrought cannoneer") then
        BL.info("Targeting cannoneer.")
        mq.cmd("/squelch /target npc a scalewrought cannoneer")
        mq.delay(200)
        --mq.cmd("/attack on")
    end

    -- Attack if target is cannoneer and you're not already attacking
    if mq.TLO.Target.ID() and mq.TLO.Target.CleanName() == "a scalewrought cannoneer" then
        -- Face target if not already facing
        if not FacingTarget() then
            BL.info("Facing cannoneer.")
            mq.cmd("/face fast")
            mq.delay(100)
        end

        if not mq.TLO.Me.Combat() then
            BL.info("Attacking cannoneer.")
            mq.cmd("/attack on")
        end
    end


    mq.doevents()
    mq.delay(500)
end

