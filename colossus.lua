--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("Colossus Script v1.1 Started")
BL.warn("Fix the /nav loc, this is a placeholder")
mq.cmd("/plugin boxr load")
mq.cmdf("/docommand /${Me.Class.ShortName} autostandonfeign on nosave")

--local stoneDebuff = "Hovering Stone"  -- Debuff to check for instead of timer if there is one
local stoneEmote = "#*#The colossus tosses a large stone into the air and it hovers heavily over #1#.#*"
local runtoLocation = "/nav locyx -454 1690" --Need to fix location, this is a placeholder
  
local function EventHandlerstoneEmote(line, nameOne)
    local myName = mq.TLO.Me.CleanName()
    local waypointCommand = nil
    
    -- If MY name was called out, I need to run away
    if myName == nameOne then
        waypointCommand = runtoLocation
        print(string.format("I was called out! Running to safe spot..."))
    else
        print(string.format("%s was called out, not me", nameOne))
    end
    
    if waypointCommand ~= nil then 
        BL.cmd.ChangeAutomationModeToManual()
        mq.delay(200)
        BL.cmd.StandIfFeigned()
        BL.cmd.removeZerkerRootDisc()
        -- navigate to safe spot
        mq.cmd(waypointCommand)
        print("Running to safe location...")
        -- Wait for stone to pass (18 seconds)
        -- TODO: Uncomment debuff check once we find actual debuff name
        -- mq.delay(18000, function()
        --     return not BL.IHaveBuff(stoneDebuff)
        -- end)
        mq.delay(18000)
        -- Return to previous activity
        BL.cmd.StandIfFeigned()
        BL.cmd.ChangeAutomationModeToChase()
        print("Resuming normal activity")
    end
end

mq.event(
    "stoneEmote",
    stoneEmote,
    EventHandlerstoneEmote
)

while true do
    BL.checkChestSpawn("a_glowing_stone_strongbox")
    mq.doevents()
    mq.delay(123)
end
