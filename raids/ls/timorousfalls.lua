--- @type Mq
local mq = require('mq')
--- @type BL
local BL = require("biggerlib")
--- @type ImGui
local ImGui = require("ImGui")

--[[
hate/love is like hot/cold exactly, but only 2 toons get called out
 note 2 apparent spaces in the copy/paste of the emote from GINA trigger -- before Scymmeran
 [Thu Nov 02 20:39:32 2023] Illandrin seeds hatred into  Scymmeran. This causes a compensatory love to form in Scymmeran.
 - 
 
 Runaway 1 - venom -- 1 toon called out has to run away from raid
 Emote for run away:
 A shadow of venom hisses and glares at #1#
 emote for safe to return after the spell hits the shadow-of-venom'ed toon is:
 '#*#shadow pulls energy and life from your body#*#'

 Runaway 2 - Seed of Hate - toons called out have to run until emote to return
 This drops as soon as you get 400 range from the raid, so we can nav them to somewhere 500+ then they can come back
 Run away emote:
 [Tue Nov 21 21:38:03 2023] A seed of hate is planted in your mind.
 safe to return emote:
 [Tue Nov 21 21:38:14 2023] The seed of hate within you is gone.

]]
    
local HateDebuff = "Expression of Hatred"
local LoveDebuff = "Expression of Love"
local StartRunningFromHateLoveFlag = false
local IsRunningFromHateLove = false

local RunFromVenomFlag = false
local ReturnFromVenomFlag = false

local RunFromSeedFlag = false
local ReturnFromSeedFlag = false

local function EventHandlerHateLoveRunAway(line, nameOne, nameTwo) 
    local myName = mq.TLO.Me.CleanName()
    if myName == nameOne or myName == nameTwo then
        StartRunningFromHateLoveFlag = true
    end
end

mq.event(
    "HateLoveRunAway",
    '#*#Illandrin seeds hatred into #1#. This causes a compensatory love to form in #2#.#*#',
    function(line, nameOne, nameTwo)
       EventHandlerHateLoveRunAway(line, nameOne, nameTwo)
    end
)

mq.event(
    "HateLoveRunAwayWithAddedSpace",
    '#*#Illandrin seeds hatred into  #1#. This causes a compensatory love to form in #2#.#*#',
    function(line, nameOne, nameTwo)
        EventHandlerHateLoveRunAway(line, nameOne, nameTwo)    
    end
)

-- HateLoveReturn is debuff based

mq.event(
    "VenomRunAway",
    "#*#A shadow of venom hisses and glares at #1#.#*#",
    function(line, name)
        if mq.TLO.Me.CleanName() == name then 
            RunFromVenomFlag = true
            ReturnFromVenomFlag = false
            mq.cmd("/echo running from venom emote")
        end
    end
)

mq.event(
    "VenomReturn",
    "#*#shadow pulls energy and life from your body#*#",
    function()
            ReturnFromVenomFlag = true
            RunFromVenomFlag = false
            mq.cmd("/echo Returning from venom emote")
    end
)

mq.event(
    "SeedRunAway",
    "#*#seed of hate is planted in your mind#*#",
    function(line, name)
            RunFromSeedFlag = true
            ReturnFromSeedFlag = false
            mq.cmd("/echo running from SEED emote")
    end
)

mq.event(
    "SeedReturn",
    "#*#seed of hate within you is gone#*#",
    function(line, name)
            ReturnFromSeedFlag = true
            RunFromSeedFlag = false
            mq.cmd("/echo Returning from SEED emote")
    end
)


local function HandleRunningFromHateLove()
    if StartRunningFromHateLoveFlag then
        -- We need to actually run
        StartRunningFromHateLoveFlag = false
        IsRunningFromHateLove = true
        BL.cmd.pauseAutomation()
        mq.delay(500)
    end

    -- check if debuff is gone and resume if so
    if IsRunningFromHateLove then
        mq.cmdf("/nav locyxz 864 -2637 -1")
        -- We should run until we no longer have the debuff
        if not BL.IHaveBuff(HateDebuff) and not BL.IHaveBuff(LoveDebuff) then
            IsRunningFromHateLove = false
            BL.cmd.resumeAutomation()
            mq.cmd("/gu Done running from Hate/Love because debuff is gone")
        end
    end
end

local function HandleRunningFromVenom()
    if ReturnFromVenomFlag then
        RunFromVenomFlag = false
        BL.cmd.resumeAutomation()
        ReturnFromVenomFlag = false -- clean up
    end
    
    if RunFromVenomFlag then
        BL.cmd.pauseAutomation()
        mq.cmdf("/nav locyxz 986 -2386 -7")
    end
end

local function HandleRunningFromSeed()
    if ReturnFromSeedFlag then
        RunFromSeedFlag = false
        BL.cmd.resumeAutomation()
        ReturnFromSeedFlag = false -- clean up
    end
    
    if RunFromSeedFlag then
        BL.cmd.pauseAutomation()
        mq.cmdf("/nav locyxz 1049 -2141 -22")
    end    
end

while true do
    HandleRunningFromHateLove()
    HandleRunningFromVenom()
    HandleRunningFromSeed()
    mq.doevents()
    mq.delay(513)
end
