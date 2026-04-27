---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

BL.info("Rez script v1.0 loaded.")
--mq.cmd("/dga /rez accept off")

-- State tracking
local rezAccepted = false
local lastCheckTime = 0
local rezAcceptTime = 0 -- Track when Yes was clicked

-- Main function to handle rez logic
local function checkRezWindow()
    local currentTime = mq.gettime()
    
    -- Check every 500ms to avoid spamming
    if currentTime - lastCheckTime < 500 then
        return
    end
    lastCheckTime = currentTime
    
    -- Step 1: Check if the confirm rez window is open (Yes/No dialog)
    if mq.TLO.Window("ConfirmationDialogBox").Open() then
        -- Check if this is a rez confirmation by looking at the dialog text
        local dialogText = mq.TLO.Window("ConfirmationDialogBox").Child("CD_TextOutput").Text()
        if dialogText and (string.find(dialogText:lower(), "resurrect") or string.find(dialogText:lower(), "rejuvenation") or string.find(dialogText:lower(), "rez") ) then
            local yesButton = mq.TLO.Window("ConfirmationDialogBox").Child("Yes_Button")
            if yesButton() and yesButton.Enabled() then
                -- Click Yes to accept rez
                yesButton.LeftMouseUp()
                rezAccepted = true
                rezAcceptTime = currentTime
                BL.info("Clicked Yes to accept rez")
            end
        end
    end
    
    -- Step 2: Check if rez was accepted and we need to click Respawn
    -- Only proceed if we (or MQ plugin) clicked Yes on the confirmation
    -- Add 1 second delay to handle lag in raid environments
    if rezAccepted and (currentTime - rezAcceptTime) >= 1000 then
        -- Check if the respawn window is open
        if mq.TLO.Window("RespawnWnd").Open() then
            -- Check if resurrect option is selected (should be auto-selected after clicking Yes)
            -- Try multiple methods to detect resurrect selection
            local optionsList = mq.TLO.Window("RespawnWnd").Child("RW_OptionsList")
            local respawnButton = mq.TLO.Window("RespawnWnd").Child("RW_SelectButton")
            
            -- Since the window is open and we clicked Yes, assume resurrect is selected
            local resurrectSelected = true
            
            if resurrectSelected then
                if respawnButton() and respawnButton.Enabled() then
                    -- Click the Respawn button
                    respawnButton.LeftMouseUp()
                    BL.info("Clicked Respawn button")
                    rezAccepted = false -- Reset state
                end
            end
        
        -- Reset state if windows are not open (timeout/cleanup)
        if not mq.TLO.Window("ConfirmationDialogBox").Open() and not mq.TLO.Window("RespawnWnd").Open() then
            rezAccepted = false
        end
    end
    end
end

-- Main loop
local function main()
    while true do
        checkRezWindow()
        mq.delay(100) -- Small delay to prevent CPU usage
    end
end

-- Start the script
main()

