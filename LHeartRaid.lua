--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")

BL.info("LHeartRaid Script v1.0 Started")

--mq.cmd("/useadv off")
--mq.cmd("/lootnodrop never")
mq.cmd("/hidecorpse none")
mq.event("LootLens", "#*#An evil eye focuses upon #1#, #2#, and #3#.#*#",
    function(line, nameOne, nameTwo, nameThree)
        -- Change LensName to the item you want to check
        local LensName = "Partially Formed Lens"
        local myName = mq.TLO.Me.CleanName()
        if myName == nameOne or myName == nameTwo or myName == nameThree then
            -- Check if we already have the item
            local hasLens = mq.TLO.FindItem(LensName)()
            if hasLens then
                BL.info("Already have " .. LensName .. " - skipping loot.")
                return
            end
            -- Proceed to loot if not already in inventory
            BL.info('Running to loot a Lens')
            BL.cmd.pauseAutomation()
            mq.delay(100)

            local loopCtr = 0
            while not mq.TLO.Window('LootWnd').Open() and loopCtr < 16 do
                loopCtr = loopCtr + 1
                mq.cmd('/target "remnant\'s corpse"')
                --mq.cmd('/target "corpse"')
                if mq.TLO.Target.ID() > 0 then
                    BL.cmd.StandIfFeigned()
                    BL.cmd.removeZerkerRootDisc()
                    mq.cmd("/nav target")
                    BL.WaitForNav()
                else
                    BL.warn("No valid corpse found to loot.")
                end

                mq.cmd("/loot")
                mq.delay(1000)
            end

            mq.cmd("/nomodkey /shift /itemnotify loot1 rightmouseup")
            mq.delay(1500)
            mq.cmd("/nomodkey /notify LootWnd DoneButton leftmouseup")
            BL.cmd.resumeAutomation()
        end
    end)
--Debuff name Bright= Bright Energy
--Debuff name Dark= Dark Energy
local debuffBright = "Bright Energy"
local debuffDark = "Dark Energy"
local iAmWaiting = false

while true do
    -- Normal check for getting the Bright debuff trigger
    if BL.IHaveBuff(debuffBright) and not iAmWaiting then
        iAmWaiting = true
        BL.info('I have the Bright debuff. Switching Target to Dark')

        BL.cmd.pauseAutomation()
        mq.delay(100)
        mq.cmd("/tar")
        --change to 'a dark energist'
        mq.cmd("/tar npc a dark energist")
        mq.cmd("/nav target")
        BL.WaitForNav()
        mq.cmd("/attack on")
    end
    -- Normal check for getting the Dark debuff trigger
    if BL.IHaveBuff(debuffDark) and not iAmWaiting then
        iAmWaiting = true
        BL.info('I have the Dark debuff. Switching Target to Bright')

        BL.cmd.pauseAutomation()
        mq.delay(100)
        mq.cmd("/tar")
        --change to 'a bright energist'
        mq.cmd("/tar npc a bright energist")
        mq.cmd("/nav target")
        BL.WaitForNav()
        mq.cmd("/attack on")
    end

    -- Check for resuming if we're waiting and the debuff falls off. 
    if not BL.IHaveBuff(debuffBright) and not BL.IHaveBuff(debuffDark) and iAmWaiting then
        iAmWaiting = false
        BL.info("Returning to the fight")
        BL.cmd.resumeAutomation()
    end

    -- Check if blood-soaked chest has spawned and end script
    BL.checkChestSpawn("a_blood-soaked_chest")
    mq.doevents()
    mq.delay(1000)
end