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


mq.event(
    "HateLoveRunAway",
    'Illandrin seeds hatred into  Scymmeran. This causes a compensatory love to form in Scymmeran.',
    function(line, nameOne, nameTwo)
            
    end
)

-- HateLoveReturn is debuff based

mq.event(
    "VenomRunAway",
    " A shadow of venom hisses and glares at #1#",
    function(line, nameOne, nameTwo)

    end
)

BL.info("Ran successfully")
















while true do
    mq.doevents()
    mq.delay(1000)
end
