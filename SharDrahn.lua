---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

BL.info("SharDrahn script v1.0 loaded.")
mq.cmd("/plugin boxr load")
mq.cmd("/plugin cast load")

-- 1:50 between stoney auras. They start around 58-59%.
-- 1st adds aura start at 74% then 64%, 59%, 51%, 43%, 34%, 26%, 19%, 11%, 3%

-- Check if user has a stat mount
local statMount = mq.TLO.Mount.Stat()
if not statMount then
    mq.cmd("/rs I don't have a stat mount! Fix it!")
    return
end

local mountEmote = "#*#You hear stones crash into each other#*#"
local wingSurgeEmote = "#*#Shar`Drahn begins casting Wing Surge#*#"
local classname = mq.TLO.Me.Class.ShortName()

local function EventHandlermountEmote()
    BL.info("Mount emote detected - checking mount status")
    
    -- Check if current character is mounted
    if not mq.TLO.Me.Mount.ID() or mq.TLO.Me.Mount.ID() == 0 then
        BL.info("Not mounted - casting mount from keyring")
        mq.cmdf("/%s autodismount off nosave", classname)
        mq.delay(250)  -- Increased delay for autodismount to take effect
        
        -- Keep trying to mount until successful or timeout
        local maxAttempts = 10
        local attempt = 0
        
        while attempt < maxAttempts do
            attempt = attempt + 1
            
            local mountName = mq.TLO.Mount.Stat()
            if mountName then
                mq.cmdf('/casting "%s"', mountName)
                mq.delay(1000)  -- Wait for cast to complete
                
                -- Check if successfully mounted
                if mq.TLO.Me.Mount.ID() and mq.TLO.Me.Mount.ID() > 0 then
                    BL.info("Successfully mounted!")
                    break
                else
                    BL.info("Mount failed, retrying...")
                end
            else
                BL.info("No mount found in keyring stat slot")
                break
            end
        end
        
        if attempt >= maxAttempts then
            BL.info("Mount attempts exhausted")
        end
    else
        BL.info("Already mounted")
    end
    
    -- Set fallback timer to turn on autodismount in case Wing Surge emote is missed
    BL.info("Setting 30-second fallback for autodismount on")
    mq.delay(30000)
    mq.cmdf("/%s autodismount on nosave", classname)
    BL.info("Fallback autodismount on executed")
    
    BL.info("Mount check complete - resuming normal activity")
end

local function EventHandlerWingSurge()
    BL.info("Wing Surge detected - turning on autodismount")
    mq.delay(2500)  -- Wait 2.5 seconds after emote
    mq.cmdf("/%s autodismount on nosave", classname)
end

mq.event(
    "mountEmote",
    mountEmote,
    EventHandlermountEmote
)

mq.event(
    "wingSurgeEmote",
    wingSurgeEmote,
    EventHandlerWingSurge
)

while true do
    BL.checkChestSpawn("a_sodden_chest")
    mq.doevents()
    mq.delay(123)
end