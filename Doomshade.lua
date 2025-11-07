local mq = require('mq')
local os = require('os')
local BL = require('biggerlib')

BL.info("Doomshade script v1.02 loaded.")

local viralLocs = {
    { -99, -310, -49 },  -- Viral 4 on map
    { 89, -435, -44 },   -- Viral 5 on map
    { 318, -362, -44 },  -- Viral 6 on map
    { 399, -184, -52 },  -- Viral 7 on map
    { 353, -11, -47 }    -- Viral 8 on map
}

local darknessLocs = {
    { 191, 86, -46 },    -- Darkness 1 on map
    { -30, 48, -45 },    -- Darkness 2 on map
    { -132, -99, -47 }   -- Darkness 3 on map
}

local DELAY = 24000

local function delayTillSafeSpot()
    print("Navigating to safe spot.")
    BL.cmd.WaitForNav()
    print("You reached the safe spot.")
end

local function waitAtSafeSpotCountdown(seconds)
    for i = 1, (seconds or DELAY / 1000) do
        print(string.format('Return in %d', i))
        mq.delay(1000)
    end
end

local function handleViralEvent(somenames)
    if not BL.nameListIncludesMe(somenames) then return end
    
    BL.cmd.pauseAutomation()
    BL.cmd.removeZerkerRootDisc()
    
    local names = BL.parseAllNames(somenames)
    local myname = mq.TLO.Me.CleanName()
    
    for i, name in ipairs(names) do
        if name == myname and viralLocs[i] then
            print(string.format("Running to Viral spot %d: %d, %d, %d", 
                  i, viralLocs[i][1], viralLocs[i][2], viralLocs[i][3]))
            mq.cmdf('/nav locxyz %d %d %d', viralLocs[i][1], viralLocs[i][2], viralLocs[i][3])
            break
        end
    end
    
    delayTillSafeSpot()
    waitAtSafeSpotCountdown()
    BL.cmd.returnToRaidMainAssist()
    BL.cmd.resumeAutomation()
end

local function handleDarknessEvent(somenames)
    if not BL.nameListIncludesMe(somenames) then return end
    
    BL.cmd.pauseAutomation()
    BL.cmd.removeZerkerRootDisc()
    
    local names = BL.parseAllNames(somenames)
    local myname = mq.TLO.Me.CleanName()
    
    for i, name in ipairs(names) do
        if name == myname and darknessLocs[i] then
            print(string.format("Running to Darkness spot %d: %d, %d, %d", 
                  i, darknessLocs[i][1], darknessLocs[i][2], darknessLocs[i][3]))
            mq.cmdf('/nav locxyz %d %d %d', darknessLocs[i][1], darknessLocs[i][2], darknessLocs[i][3])
            break
        end
    end
    
    delayTillSafeSpot()
    waitAtSafeSpotCountdown(15) -- Shorter wait for darkness
    BL.cmd.returnToRaidMainAssist()
    BL.cmd.resumeAutomation()
end

-- Main event handler
local function event_handler(line, somenames)
    --if not mq.TLO.Zone.ShortName() == 'umbraltwo_raid' then return end
    
    if line:find("Doomshade curses") then
        handleViralEvent(somenames)
    elseif line:find("sends shadows at") then
        handleDarknessEvent(somenames)
    end
end

-- Register events
mq.event("DoomshadeViral", "#*#Doomshade curses #1#.#*#", event_handler)
mq.event("DoomshadeDarkness", "#*#sends shadows at #1#.#*#", event_handler)

-- Main loop
while true do
    BL.checkChestSpawn("a_darkened_chest")
    mq.doevents()
    mq.delay(100)
end