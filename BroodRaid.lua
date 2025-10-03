--- @type Mq
local mq = require('mq')
local BL = require("biggerlib")

-- Get command line arguments
local args = {...}
local ANNOUNCE_CHAR = args[1] and args[1]:lower()  -- Convert to lowercase for case-insensitive comparison

BL.info("BroodRaid Script v1.23 Started" .. (ANNOUNCE_CHAR and (" - Announcements from: " .. ANNOUNCE_CHAR) or " - No announcement character specified"))
BL.info("Current character: " .. mq.TLO.Me.Name())
if ANNOUNCE_CHAR then
    BL.info("Will announce from: " .. ANNOUNCE_CHAR)
end
BL.cmd.TurnOffAllAoE()

--Debuff name= Power of the Skyguardian
local debuffName = "Power of the Skyguardian"
local locX = -704
local locY = -293
local iAmWaiting = false

-- Green Slime spawn detection
-- spawn name= a dripping greenish puddle
local SPAWN_NAME = "Strateg"
local ANNOUNCE_MESSAGE = "The Green Slime has spawned! Run!"
local DESPAWN_MESSAGE = "Slime is no longer up!"
local lastAnnounced = false
local spawnCounter = 0

-- Function to check if the spawn is up
local function isSpawnUp()
    local spawn = mq.TLO.Spawn("pc " .. SPAWN_NAME)
    return spawn.ID() ~= nil and spawn.ID() ~= 0
end

while true do
    -- Green Slime spawn check - only if ANNOUNCE_CHAR is specified
    local currentChar = mq.TLO.Me.Name():lower()  -- Convert to lowercase for comparison
    if ANNOUNCE_CHAR and currentChar == ANNOUNCE_CHAR then
        local spawnIsUp = isSpawnUp()
        if spawnIsUp and not lastAnnounced then
            spawnCounter = spawnCounter + 1
            BL.info("Sending raid message: " .. ANNOUNCE_MESSAGE .. " #" .. spawnCounter)
            mq.cmdf("/rs %s #%d", ANNOUNCE_MESSAGE, spawnCounter)
        elseif not spawnIsUp and lastAnnounced then
            BL.info("Sending raid message: " .. DESPAWN_MESSAGE .. " #" .. spawnCounter)
            mq.cmdf("/rs %s #%d", DESPAWN_MESSAGE, spawnCounter)
        end
        lastAnnounced = spawnIsUp
    end

    -- Normal check for getting the debuff trigger
    if BL.IHaveBuff(debuffName) and not iAmWaiting then
        iAmWaiting = true
        BL.info('I have the AOE debuff, running to safe spot')

        --BL.cmd PauseAutomation()
        mq.cmd("/docommand /${Me.Class.ShortName} mode 0")
        mq.delay(100)
        BL.cmd.StandIfFeigned()
        BL.cmd.removeZerkerRootDisc()
        mq.cmdf('/nav locyx %s %s', locX, locY)
        BL.WaitForNav()
        BL.info("Arrived at safe spot")
    end

    -- Check for resuming if we're waiting and the debuff falls off
    if not BL.IHaveBuff(debuffName) and iAmWaiting then
        iAmWaiting = false
        BL.info("Returning to the fight")
        mq.cmd("/docommand /${Me.Class.ShortName} mode 2")
        --BL.cmd.resumeAutomation()
        BL.cmd.StandIfFeigned()
    end
    BL.checkChestSpawn("a_grimy_chest")
    mq.delay(750)
end