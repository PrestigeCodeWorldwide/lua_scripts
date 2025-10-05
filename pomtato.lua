local mq = require("mq")
local BL = require("biggerlib")

BL.info("Pomtato v1.2 loaded")

-- Default value if no argument is provided
local hotpotato_person = "Stratsk"

-- Get command line arguments
local args = {...}

-- Check for command line arguments
if #args > 0 then
    hotpotato_person = args[1]
    BL.info("\ag[%s] Setting hot potato target to: %s", mq.TLO.Me.CleanName(), hotpotato_person)
end

local function giveHotPotato()
    BL.info("\ag[%s] Hot potato triggered! Targeting: %s", mq.TLO.Me.CleanName(), hotpotato_person)
    BL.cmd.pauseAutomation()
    mq.delay(500)
    mq.cmd("/autoinventory")
    mq.delay(500)
    mq.cmdf("/target %s", hotpotato_person)
    mq.delay(1000)
    mq.cmdf("/useitem Magnificent Planar Gem")
    --mq.delay(3500)
    BL.cmd.resumeAutomation()
end

-- Bind the /hotpotato command as a backup
mq.bind("/hotpotato", giveHotPotato)

-- Set up event handlers for automatic triggering
local function setupEventHandlers()
    -- Event 1: 
    mq.event("PotatoTell", "#*#A large gem appears in your hands. It starts to build power#*#", function()
        BL.info("\ag[%s] Build power emote recieved! Passing it on...", mq.TLO.Me.CleanName())
        giveHotPotato()
    end)
    
    -- Event 2: 
    mq.event("PotatoEmote", string.format("#*#What is the gem doing on the ground? How about you hold onto it this time, %s#*#", mq.TLO.Me.CleanName() or ""), function()
        BL.info("\ag[%s] Hold onto it emote received! Passing it on...", mq.TLO.Me.CleanName())
        giveHotPotato()
    end)
    
    -- Event 3: 
    mq.event("PotatoRaid", "#*#You just got the gem and fumble to get ahold of it well enough to toss it#*#", function()
        BL.info("\ag[%s] Fumble to get ahold of it emote recieved! Passing it on...", mq.TLO.Me.CleanName())
        giveHotPotato()
    end)
    
    -- Event 4: 
    mq.event("PotatoRaidstart", string.format("#*#He tosses a huge gem to %s#*#", mq.TLO.Me.CleanName() or ""), function()
        BL.info("\ag[%s] Raid start emote recieved! Passing it on...", mq.TLO.Me.CleanName())
        giveHotPotato()
    end)
    
    BL.info("\ag[%s] Hot potato event handlers registered. Use /hotpotato to manually trigger.", mq.TLO.Me.CleanName())
end

-- Initialize event handlers
setupEventHandlers()

-- Main loop to process events
while true do
    mq.doevents()
    mq.delay(100)
end
