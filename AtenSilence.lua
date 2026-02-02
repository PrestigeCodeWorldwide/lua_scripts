---@type Mq
local mq = require('mq')
---@type BL
local BL = require("biggerlib")

BL.info("AtenSilence v1.1 Started")
BL.info("Should work for group or raid version")

local myname = mq.TLO.Me.CleanName()
local myclass = mq.TLO.Me.Class.ShortName()
local runawayemote = "#*#Aten Ha Ra points at " .. myname .. " with one arm#*#"
local generalatenemote = "#*#Aten Ha Ra points at #1# with one arm#*#"
local SAFE_LOC = {x = 1222.67, y = -48.97, z = 236.41}
local isRunningAway = false

-- Function to handle the run away logic
local function handleRunAway()
    if isRunningAway then return end
    isRunningAway = true
    
    BL.info("Running away from Aten Ha Ra's silence!")
    
    -- Save current state
    --local wasInCombat = mq.TLO.Me.Combat()
    local wasMQP = mq.TLO.Macro.Paused()
    local wasTwisting = mq.TLO.Me.Casting() and mq.TLO.Me.Casting.ID() > 0
    
    -- Stop any current actions
    if myclass == 'BER' and mq.TLO.Me.ActiveDisc.Name() == mq.TLO.Spell('Frenzied Resolve Discipline').RankName() then
        mq.cmd('/stopdisc')
    end
    
    -- Set to manual mode
    BL.cmd.ChangeAutomationModeToManual()
    if wasTwisting then mq.cmd('/twist off') end
    mq.cmd('/timed 5 /afollow off')
    mq.cmd('/nav stop')
    mq.cmd('/target clear')
    mq.delay(100)
    
    -- Navigate to safe spot
    BL.info("Moving to safe location...")
    mq.cmdf('/nav locxyz %f %f %f', SAFE_LOC.x, SAFE_LOC.y, SAFE_LOC.z)
    
    -- Wait for navigation to complete or timeout after 15 seconds
    local startTime = os.clock()
    while mq.TLO.Navigation.Active() and (os.clock() - startTime) < 15 do
        mq.delay(100)
    end
    
    -- Wait at safe spot for a bit
    mq.delay(13000)
    
    -- Return to normal operations
    BL.info("Returning to normal operations...")
    BL.cmd.ChangeAutomationModeToChase()
    if not wasMQP then mq.cmd('/mqp off') end
    if wasTwisting then mq.cmd('/twist on') end
    
    isRunningAway = false
end

-- Event handler
local function event_handler(line)
    if isRunningAway then return end
    
    local my_name = mq.TLO.Me.CleanName()
    local raid_ma = mq.TLO.Raid() and mq.TLO.Raid.MainAssist(1).Name() or ""
    local group_ma = mq.TLO.Group.MainAssist() or ""
    local i_am_ma = (raid_ma == my_name) or (group_ma == my_name)
    
    -- Get target from emote
    local target = line:match("Aten Ha Ra points at (.-) with one arm")
    if not target then return end
    
    -- Check if we should run away
    -- Run away if: we are targeted (but we're not MA) OR MA is targeted (but we're not MA)
    if target == my_name and not i_am_ma then
        -- We are targeted but we're not MA
        handleRunAway()
    elseif (target == raid_ma or target == group_ma) and not i_am_ma then
        -- MA is targeted but we're not the MA
        handleRunAway()
    end
end

-- Register the event
mq.event("AtenSilenceRun", generalatenemote, event_handler)

-- Main loop
while true do
    BL.checkChestSpawn("a_shadowbound_chest")
    mq.doevents()
    mq.delay(100)
end