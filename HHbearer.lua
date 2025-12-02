---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

BL.info("HHbearer v1.04 Started")

local myname = mq.TLO.Me.CleanName()
local myclassname = mq.TLO.Me.Class.ShortName()
local bearerEmote = "#*#A bearer focuses on " .. myname .. "#*#"
local bearerSpawned = false
local SAFE_DISTANCE = 100  -- Distance at which to trigger movement
local MOVE_DISTANCE = 100  -- How far to move when too close

-- Function to check if any bearer NPC is spawned and get its distance
local function getBearerInfo()
    local bearer = mq.TLO.Spawn("npc bearer")
    if bearer() and bearer.ID() > 0 then
        return true, bearer.Distance3D() or 0, bearer
    end
    return false, 0, nil
end

-- Function to move north a specific distance
local function moveNorth(distance)
    local startX = mq.TLO.Me.X()
    local startY = mq.TLO.Me.Y()
    local targetY = startY + distance
    
    mq.cmdf("/nav locxy %f %f", startX, targetY)
    
    -- Wait until we've moved the distance or 5 seconds pass
    local startTime = os.clock()
    while os.clock() - startTime < 5 do
        if not mq.TLO.Navigation.Active() then
            break  -- Navigation completed or was stopped
        end
        mq.delay(100)
    end
    mq.cmd("/nav stop")
end

local function handleBearerEvent()
    BL.info("Bearer emote detected - waiting for bearer to spawn...")
    
    -- Check for bearer for up to 10 seconds
    local startTime = os.clock()
    local isSpawned = false
    
    while os.clock() - startTime < 10 do
        isSpawned = getBearerInfo()
        if isSpawned then
            break
        end
        mq.delay(500)
    end
    
    if isSpawned then
        BL.info("Bearer found, activating safety mode...")
        bearerSpawned = true
    else
        BL.info("Bearer not found after 5 seconds, ignoring emote.")
    end
end

mq.event("BearerEvent", bearerEmote, handleBearerEvent)

-- Main loop
while true do
    mq.doevents()
    BL.checkChestSpawn("An_elaborate_chest")
    
    -- If bearer is spawned, handle mode switching and distance checking
    if bearerSpawned then
        local isSpawned, distance, bearer = getBearerInfo()
        
        if isSpawned then
                BL.info("Bearer detected - going to manual mode...")
                mq.cmdf("/%s mode 0", myclassname)
            
            -- Check distance and move if too close
            if distance < SAFE_DISTANCE then
                BL.info("Bearer too close! Moving away...")
                moveNorth(MOVE_DISTANCE)
            end
            
            mq.delay(1000)
        else
            -- Bearer is gone, return to chase mode
                BL.info("Bearer no longer present - returning to chase mode...")
                mq.cmdf("/%s mode 2", myclassname)
            bearerSpawned = false
        end
    end

    mq.delay(100)
end