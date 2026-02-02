--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("DockOfTheBay Script v1.11 Started")
mq.cmd("/plugin boxr load")

local MitesDebuff = "Clinging Mites"
local MiteNPCName = "crushing ball"

local MechanicEmote = "#*#Chief Mechanic focuses energy on #1#, #2#, #3#, and #4#.#*#"
local FirstMechanicLocation = "/nav locyx -368 420"
local SecondMechanicLocation = "/nav locyx  -190 478"
local ThirdMechanicLocation = "/nav locyx 48 238"
local FourthMechanicLocation = "/nav locyx -240 290"
  
local function EventHandlerMechanicEmote(line, nameOne, nameTwo, nameThree, nameFour) 
    local myName = mq.TLO.Me.CleanName()
    local waypointCommand = nil
    
    if myName == nameOne then
        waypointCommand = FirstMechanicLocation
    elseif myName == nameTwo then
        waypointCommand = SecondMechanicLocation
    elseif myName == nameThree then
        waypointCommand = ThirdMechanicLocation
    elseif myName == nameFour then
        waypointCommand = FourthMechanicLocation
    else
        -- I wasn't called out, do nothing
    end
    
    if waypointCommand ~= nil then 
        --BL.cmd.pauseAutomation()
	    --mq.cmd("/docommand /${Me.Class.ShortName} mode 0") 
        BL.cmd.ChangeAutomationModeToManual()
        mq.delay(750)
        BL.cmd.StandIfFeigned()
        BL.cmd.removeZerkerRootDisc()
        -- navigate to safe spot
        mq.cmd(waypointCommand)
        -- 25 seconds or if debuff fades early
        mq.delay(25000, function()
            return not BL.IHaveBuff("Embedded Energy")
        end)
        -- finished, resume
        --BL.cmd.resumeAutomation()
        BL.cmd.StandIfFeigned()
	    --mq.cmd("/docommand /${Me.Class.ShortName} mode 2") 
        BL.cmd.ChangeAutomationModeToChase()
        mq.cmd("/rs Done running from mechanic emote")
    end
end

mq.event(
    "MechanicEmote",
    MechanicEmote,
    function(line, nameOne, nameTwo, nameThree, nameFour)
        EventHandlerMechanicEmote(line, nameOne, nameTwo, nameThree, nameFour)
    end
)

local function HandleMitesMechanic()
    -- if we have the debuff, navigate to crushing ball
    if BL.IHaveBuff(MitesDebuff) then
        BL.cmd.pauseAutomation()
        
        -- continue trying to nav to crushing ball until debuff drops
        while BL.IHaveBuff(MitesDebuff) do
            mq.cmdf("/nav spawn npc %s", MiteNPCName)
            mq.delay(1000)
        end
        
        -- Debuff is gone, resume
        BL.cmd.resumeAutomation()
    end
end

while true do
    BL.checkChestSpawn("a_weathered_chest")
    --HandleMitesMechanic()
    mq.doevents()
    mq.delay(123)
end
