--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

-- Parse command line arguments
local args = {...}
local targetName = args[1] or nil
local myName = mq.TLO.Me.CleanName()
local running = true

BL.info("EchoOfHate Script v1.1 Started")
mq.cmd("/plugin boxr load")

if targetName then
    BL.info("Target character: " .. targetName)
    if targetName:lower() == myName:lower() then
        BL.info("Crystal events enabled for " .. myName)
    else
        BL.info("Crystal events disabled - not target character")
    end
else
    BL.info("No target character specified - crystal events disabled")
end

mq.bind("/stopecho", function()
    running = false
    BL.info("EchoRaid stopping gracefully...")
end)

local LowHPEmote = "#*#The Echo recognizes the weakest among you: #1#, #2#, #3#, and #4#.#*#"
local FirstLocation = "/nav locyx 7.80, 118.95"
local SecondLocation = "/nav locyx  123.52, 3.38"
local ThirdLocation = "/nav locyx 7.03, -112.76"
local FourthLocation = "/nav locyx -124.78, 3.20"

local function NorthCrystal(line, arg1, arg2, arg3, arg4, arg5)
    BL.info("Running to North Crystal")
    BL.cmd.pauseAutomation()
    mq.cmd("/nav door id 96")  --/nav door id 96
    BL.WaitForNav()
    mq.cmd("/doortarget")
    mq.delay(300)
    mq.cmd("/click left door")
    BL.cmd.resumeAutomation()
end

local function SouthCrystal(line, arg1, arg2, arg3, arg4, arg5)
    BL.info("Running to South Crystal")
    BL.cmd.pauseAutomation()
    mq.cmd("/nav door id 94")  --/nav door id 94
    BL.WaitForNav()
    mq.cmd("/doortarget")
    mq.delay(300)
    mq.cmd("/click left door")
    BL.cmd.resumeAutomation()
end

local function EastCrystal(line, arg1, arg2, arg3, arg4, arg5)
    BL.info("Running to East Crystal")
    BL.cmd.pauseAutomation()
    mq.cmd("/nav door id 93")  --/nav door id 93
    BL.WaitForNav()
    mq.cmd("/doortarget")
    mq.delay(300)
    mq.cmd("/click left door")
    BL.cmd.resumeAutomation()
end

local function WestCrystal(line, arg1, arg2, arg3, arg4, arg5)
    BL.info("Running to West Crystal")
    BL.cmd.pauseAutomation()
    mq.cmd("/nav door id 95")  --/nav door id 95
    BL.WaitForNav()
    mq.cmd("/doortarget")
    mq.delay(300)
    mq.cmd("/click left door")
    BL.cmd.resumeAutomation()
end

-- Crystal configuration mapping
local CrystalConfig = {
    north = {
        event = "NorthCrystal",
        pattern = "#*#The Echo starts to gather all of its self-loathing#*#",
        func = NorthCrystal
    },
    south = {
        event = "SouthCrystal",
        pattern = "#*#The Echo roils with hatred for all that are not it and focuses#*#",
        func = SouthCrystal
    },
    east = {
        event = "EastCrystal",
        pattern = "#*#The Echo burns with hatred of the weak and focuses#*#",
        func = EastCrystal
    },
    west = {
        event = "WestCrystal",
        pattern = "#*#The Echo glares with rage at all of its opponents and focuses#*#",
        func = WestCrystal
    }
}

local function EventHandlerLowHPEmote(line, nameOne, nameTwo, nameThree, nameFour) 
    local myName = mq.TLO.Me.CleanName()
    local waypointCommand = nil
    
    if myName == nameOne then
        waypointCommand = FirstLocation
    elseif myName == nameTwo then
        waypointCommand = SecondLocation
    elseif myName == nameThree then
        waypointCommand = ThirdLocation
    elseif myName == nameFour then
        waypointCommand = FourthLocation
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
        mq.delay(16000)
        -- finished, resume
        --BL.cmd.resumeAutomation()
        BL.cmd.StandIfFeigned()
	    --mq.cmd("/docommand /${Me.Class.ShortName} mode 2") 
        BL.cmd.ChangeAutomationModeToChase()
        --mq.cmd("/rs Done running from mechanic emote")
    end
end

mq.event(
    "LowHPEmote",
    LowHPEmote,
    function(line, nameOne, nameTwo, nameThree, nameFour)
        EventHandlerLowHPEmote(line, nameOne, nameTwo, nameThree, nameFour)
    end
)

-- Register crystal events only if target name matches current character
if targetName and targetName:lower() == myName:lower() then
    for crystalName, config in pairs(CrystalConfig) do
        mq.event(config.event, config.pattern, config.func)
    end
    BL.info("Registered crystal events for: " .. myName)
else
    BL.info("Crystal events not registered - character not targeted")
end

while running do
    BL.checkChestSpawn("a_twisted_chest")
    mq.doevents()
    mq.delay(123)
end
