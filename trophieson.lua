--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("TrophiesOn Script v1.0 Started")

-- TODO: Specify the 8 trophies you want to upgrade
-- This should be an array of trophy names exactly as they appear in the Available Trophy Benefits list
local TROPHIES_TO_UPGRADE = {
    -- Add your 8 trophy names here, for example:
    "Brazier of Magic",
    "Banner of the Outer Brood",
    "Crest of Heroism",
    "Subterranean Lily Bloom",
    "Shadow Torchiere",
    "Temple Torchery",
    "Rallos Zek's Axe Replica",
    --"Scavenger's Prize",
    "Mortal's Ethereal Wonder",
}

local function GetActiveTrophyBenefits()
    local benefits = {}
    local mainWindow = mq.TLO.Window("TributeTrophyWnd")
    local wasOpen = mainWindow.Open() or false
    
    -- Open the trophy window if it's not already open
    if not wasOpen then
        BL.info("Opening trophy window...")
        mq.cmd("/windowstate TributeTrophyWnd open")
        mq.delay(2000)  -- Give it time to open
    end

    -- Get the active benefit list from the right pane
    local benefitList = mq.TLO.Window("TributeTrophyWnd/TTW_ActiveTrophyBenefitList")
    
    if benefitList() then
        local count = benefitList.Items() or 0
        BL.info("Found %d active trophy benefits", count)
        
        for i = 1, count do
            local itemText = benefitList.List(i)
            if itemText and itemText ~= "" then
                BL.info("Active benefit %d: %s", i, itemText)
                table.insert(benefits, tostring(itemText))
            end
        end
    else
        BL.info("Could not access active trophy benefits list")
    end
    
    -- Close the window if we opened it
    if not wasOpen and mainWindow.Open() then
        mq.cmd("/windowstate TributeTrophyWnd close")
    end
    
    return benefits
end

local function GetAvailableTrophyBenefits()
    local benefits = {}
    local mainWindow = mq.TLO.Window("TributeTrophyWnd")
    local wasOpen = mainWindow.Open() or false
    
    -- Open the trophy window if it's not already open
    if not wasOpen then
        BL.info("Opening trophy window...")
        mq.cmd("/windowstate TributeTrophyWnd open")
        mq.delay(2000)  -- Give it time to open
    end

    -- Get the available benefit list from the left pane
    local availableList = mq.TLO.Window("TributeTrophyWnd/TTW_AvailableTrophyBenefitList")
    
    if availableList() then
        local count = availableList.Items() or 0
        BL.info("Found %d available trophy benefits", count)
        
        for i = 1, count do
            local itemText = availableList.List(i)
            if itemText and itemText ~= "" then
                BL.info("Available benefit %d: %s", i, itemText)
                table.insert(benefits, tostring(itemText))
            end
        end
    else
        BL.info("Could not access available trophy benefits list")
    end
    
    -- Close the window if we opened it
    if not wasOpen and mainWindow.Open() then
        mq.cmd("/windowstate TributeTrophyWnd close")
    end
    
    return benefits
end

local function ClickUpgradeButton(trophyName)
    local mainWindow = mq.TLO.Window("TributeTrophyWnd")
    local wasOpen = mainWindow.Open() or false
    
    -- Open the trophy window if it's not already open
    if not wasOpen then
        BL.info("Opening trophy window for upgrade...")
        mq.cmd("/windowstate TributeTrophyWnd open")
        mq.delay(2000)
    end

    -- Wait a bit more to ensure window is fully loaded
    mq.delay(1000)
    
    -- Get the available benefit list
    local availableList = mq.TLO.Window("TributeTrophyWnd/TTW_AvailableTrophyBenefitList")
    
    if availableList() then
        local count = availableList.Items() or 0
        
        -- Find the trophy in the available list
        for i = 1, count do
            local itemText = availableList.List(i)
            if itemText then
                -- Use pattern matching to handle potential encoding issues
                if string.find(tostring(itemText), trophyName, 1, true) or 
                   string.find(trophyName, tostring(itemText), 1, true) then
                    BL.info("Found trophy '%s' at position %d, selecting it...", trophyName, i)
                    
                    -- Select the trophy in the list
                    availableList.Select(i)
                    mq.delay(500)
                    
                    -- Look for and click the Upgrade button
                    local upgradeButton = mq.TLO.Window("TributeTrophyWnd/TTW_UpgradeButton")
                    if upgradeButton() then
                        BL.info("Clicking upgrade button for trophy: %s", trophyName)
                        mq.cmd("/notify TributeTrophyWnd TTW_UpgradeButton leftmouseup")
                        mq.delay(1000)  -- Wait for the upgrade to process
                        return true
                    else
                        BL.info("Could not find upgrade button for trophy: %s", trophyName)
                    end
                    break
                end
            end
        end
        
        BL.info("Trophy '%s' not found in available list", trophyName)
    else
        BL.info("Could not access available trophy benefits list for upgrade")
    end
    
    -- Close the window if we opened it
    if not wasOpen and mainWindow.Open() then
        mq.cmd("/windowstate TributeTrophyWnd close")
    end
    
    return false
end

local function GetMissingTrophies(activeBenefits, availableBenefits)
    local missingTrophies = {}
    
    -- Create a lookup table for active benefits
    local activeLookup = {}
    for _, benefit in ipairs(activeBenefits) do
        activeLookup[benefit] = true
    end
    
    -- Check each specified trophy
    for _, trophyName in ipairs(TROPHIES_TO_UPGRADE) do
        if trophyName and trophyName ~= "" then
            -- Check if trophy is not in active benefits but is in available benefits
            if not activeLookup[trophyName] then
                -- Also verify it's actually available to upgrade
                for _, available in ipairs(availableBenefits) do
                    if available == trophyName then
                        table.insert(missingTrophies, trophyName)
                        break
                    end
                end
            end
        end
    end
    
    return missingTrophies
end

local function UpgradeSpecifiedTrophies(trophiesToUpgrade)
    local upgradedCount = 0
    
    for _, trophyName in ipairs(trophiesToUpgrade) do
        if trophyName and trophyName ~= "" then
            BL.info("Attempting to upgrade trophy: %s", trophyName)
            if ClickUpgradeButton(trophyName) then
                upgradedCount = upgradedCount + 1
                BL.info("Successfully upgraded trophy: %s", trophyName)
            else
                BL.info("Failed to upgrade trophy: %s", trophyName)
            end
            mq.delay(1000)  -- Brief pause between upgrades
        end
    end
    
    BL.info("Upgraded %d out of %d trophies", upgradedCount, #trophiesToUpgrade)
    return upgradedCount
end

local function main()
    BL.info("Starting trophy upgrade check...")
    
    -- Check if TROPHIES_TO_UPGRADE is properly configured
    if #TROPHIES_TO_UPGRADE == 0 or ( #TROPHIES_TO_UPGRADE == 1 and TROPHIES_TO_UPGRADE[1] == "" ) then
        BL.info("ERROR: TROPHIES_TO_UPGRADE list is not configured. Please edit the script to specify your 8 trophies.")
        mq.cmd("/rs [TrophiesOn] ERROR: Trophy list not configured in script!")
        return
    end
    
    -- Get active and available trophy benefits
    local activeBenefits = GetActiveTrophyBenefits()
    local availableBenefits = GetAvailableTrophyBenefits()
    
    BL.info("Active benefits count: %d", #activeBenefits)
    BL.info("Available benefits count: %d", #availableBenefits)
    
    -- Check which of our specified trophies are missing from active list
    local missingTrophies = GetMissingTrophies(activeBenefits, availableBenefits)
    
    if #missingTrophies > 0 then
        BL.info("Found %d missing trophies to upgrade: %s", #missingTrophies, table.concat(missingTrophies, ", "))
        mq.cmd(string.format("/rs [TrophiesOn] Upgrading %d missing trophies...", #missingTrophies))
        
        local upgradedCount = UpgradeSpecifiedTrophies(missingTrophies)
        
        if upgradedCount > 0 then
            BL.info("Successfully upgraded %d trophies", upgradedCount)
            mq.cmd(string.format("/rs [TrophiesOn] Successfully upgraded %d trophies!", upgradedCount))
        else
            BL.info("No trophies were upgraded")
            mq.cmd("/rs [TrophiesOn] No trophies were upgraded - check trophy names in script")
        end
    else
        BL.info("All specified trophies are already active, no upgrade needed")
        mq.cmd("/rs [TrophiesOn] All specified trophies are already active")
    end
    
    -- Ensure trophy window is closed before exiting
    local trophyWindow = mq.TLO.Window("TributeTrophyWnd")
    if trophyWindow.Open() then
        BL.info("Closing trophy window before script exit...")
        mq.cmd("/windowstate TributeTrophyWnd close")
    end
    
    return activeBenefits, availableBenefits
end

-- Run the main function
return main()

