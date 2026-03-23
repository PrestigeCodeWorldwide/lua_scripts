--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("Trophies Script v1.1 Started")

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

    -- Get the benefit list using the correct path
    local benefitList = mq.TLO.Window("TributeTrophyWnd/TTW_ActiveTrophyBenefitList")
    
    if benefitList() then
        local count = benefitList.Items() or 0
        BL.info("Found %d active trophy benefits", count)
        
        for i = 1, count do
            local itemText = benefitList.List(i)
            if itemText and itemText ~= "" then
                BL.info("Benefit %d: %s", i, itemText)
                table.insert(benefits, tostring(itemText))
            end
        end
    else
        BL.info("Could not access trophy benefits list")
    end
    
    -- Close the window if we opened it
    if not wasOpen and mainWindow.Open() then
        mq.cmd("/windowstate TributeTrophyWnd close")
    end
    
    return benefits
end

local function AreTrophiesActivated()
    local tributeWnd = mq.TLO.Window("TributeBenefitWnd")
    local wasOpen = tributeWnd.Open() or false
    
    -- Open the tribute benefit window if it's not already open
    if not wasOpen then
        BL.info("Opening tribute benefit window...")
        mq.cmd("/windowstate TributeBenefitWnd open")
        mq.delay(1000)
    end
    
    -- Check the activate button text directly
    local buttonText = tributeWnd.Child('TBWT_ActivateButton').Text()
    local isActivated = (buttonText == "Deactivate")
    
    BL.info("Trophy activation button text: %s", buttonText or "nil")
    
    -- Close the window if we opened it
    if not wasOpen and tributeWnd.Open() then
        mq.cmd("/windowstate TributeBenefitWnd close")
    end
    
    return isActivated
end

local function GetPowerSourceStatus()
    local powerSource = mq.TLO.Me.Inventory("powersource")
    
    if not powerSource() then
        BL.info("No power source equipped")
        return nil, 0
    end
    
    local currentPower = tonumber(powerSource.Power()) or 0
    local powerName = powerSource.Name() or "Unknown"
    
    -- Calculate percentage using fixed max power of 2,000,000
    local maxPower = 2000000
    local powerPercentage = (currentPower / maxPower) * 100
    
    BL.info("Power Source: " .. powerName .. " " .. currentPower .. " (" .. math.floor(powerPercentage * 10) / 10 .. " percent)")
    
    return powerName, currentPower, powerPercentage
end

-- Main execution
local function main()
    BL.info("Starting trophy check...")
    local activeBenefits = GetActiveTrophyBenefits()
    local isActivated = AreTrophiesActivated()
    local powerName, currentPower, powerPercentage = GetPowerSourceStatus()
    
    if #activeBenefits == 0 then
        BL.info("No active trophy benefits found")
        mq.cmd("/rs [Trophy] No trophies found, need to upgrade them again!")
        mq.cmd("/g [Trophy] No trophies found, need to upgrade them again!")
    else
        local benefitText = table.concat(activeBenefits, ", ")
        BL.info("Found %d active benefits: %s", #activeBenefits, benefitText)
    end
    
    if not isActivated then
        BL.info("Trophies are not activated")
        mq.cmd("/rs [Trophy] Trophies are NOT activated!")
        mq.cmd("/g [Trophy] Trophies are NOT activated!")
    else
        BL.info("Trophies are activated")
    end
    
    -- Power source check with percentage
    if not powerName then
        BL.info("No power source equipped")
        mq.cmd("/rs [PowerSource] No power source equipped!")
        mq.cmd("/g [PowerSource] No power source equipped!")
    elseif powerPercentage < 2 then
        local percentStr = math.floor(powerPercentage * 10) / 10
        BL.info("Power source is low: " .. percentStr .. " percent")
        mq.cmd("/rs [PowerSource] Power source is LOW: " .. percentStr .. "%")
        mq.cmd("/g [PowerSource] Power source is LOW: " .. percentStr .. "%")
    else
        local percentStr = math.floor(powerPercentage * 10) / 10
        BL.info("Power source OK: " .. percentStr .. " percent")
    end
    
    return activeBenefits
end

-- Run the main function
return main()