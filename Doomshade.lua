local mq = require('mq')
local os = require('os')
local BL = require('biggerlib')

BL.info("Doomshade script v1.06 loaded.")

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
    while mq.TLO.Navigation.Active() do
        mq.delay(100)
    end
    print("You reached the safe spot.")
end

local function waitForBuffToClearAndReturn(safeSpot)
    print("Waiting for 'Shade's Doom' buff to clear...")
    while true do
        -- Wait at safe spot until buff clears (check all buff types)
        while mq.TLO.Me.Buff("Shade's Doom")() or mq.TLO.Me.Song("Shade's Doom")() do
            mq.delay(500)
        end
        print("'Shade's Doom' buff cleared. Attempting to return to raid...")
        
        -- Start returning
        BL.cmd.returnToRaidMainAssist()
        
        -- Monitor for re-infection during return
        local startTime = mq.gettime()
        local reinfected = false
        
        while mq.TLO.Navigation.Active() do
            if mq.TLO.Me.Buff("Shade's Doom")() or mq.TLO.Me.Song("Shade's Doom")() then
                print("Re-infected during return! Running back to safe spot...")
                -- Cancel current navigation
                mq.cmd('/nav stop')
                mq.delay(500)
                reinfected = true
                break
            end
            mq.delay(500)
            
            -- Safety timeout to prevent infinite loop
            if mq.gettime() - startTime > 30000 then
                print("Return timeout, proceeding anyway")
                break
            end
        end
        
        -- If we got re-infected, navigate back to safe spot and continue waiting
        if reinfected then
            print("Back at safe spot, waiting for buff to clear again...")
            mq.cmdf('/nav locxyz %d %d %d', safeSpot[1], safeSpot[2], safeSpot[3])
            delayTillSafeSpot()
        else
            -- Successfully returned without re-infection
            break
        end
    end
    
    print("Successfully returned to raid.")
end

local function waitAtSafeSpotCountdown(seconds)
    for i = 1, (seconds or DELAY / 1000) do
        print(string.format('Return in %d', i))
        mq.delay(1000)
    end
end

local function handleViralEvent(somenames)
    if not BL.nameListIncludesMe(somenames) then return end
    
    BL.cmd.coordinateWithScript("offtank", function()
        BL.cmd.pauseAutomation()
        BL.cmd.removeZerkerRootDisc()
        
        local names = BL.parseAllNames(somenames)
        local myname = mq.TLO.Me.CleanName()
        local mySafeSpot = nil
        
        for i, name in ipairs(names) do
            if name == myname and viralLocs[i] then
                mySafeSpot = viralLocs[i]
                print(string.format("Running to Viral spot %d: %d, %d, %d", 
                      i, mySafeSpot[1], mySafeSpot[2], mySafeSpot[3]))
                mq.cmdf('/nav locxyz %d %d %d', mySafeSpot[1], mySafeSpot[2], mySafeSpot[3])
                break
            end
        end
        
        if mySafeSpot then
            delayTillSafeSpot()
            waitForBuffToClearAndReturn(mySafeSpot)
        end
        
        BL.cmd.resumeAutomation()
    end)
end

local function handleDarknessEvent(somenames)
    if not BL.nameListIncludesMe(somenames) then return end
    
    BL.cmd.coordinateWithScript("offtank", function()
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
        waitAtSafeSpotCountdown(15)
        BL.cmd.returnToRaidMainAssist()
        BL.cmd.resumeAutomation()
    end)
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