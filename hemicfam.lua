---@type Mq
local mq = require("mq")
--- @type BL
local BL = require("biggerlib")

BL.info("Hemicfam v1.1 loaded")

local function hasBuff(buffName)
    return mq.TLO.Me.Buff(buffName)() ~= nil
end

local function ensureFamiliar()
    if not hasBuff("Familiar: Hooded Scrykin") then
        BL.info("Casting Familiar: Hooded Scrykin")
        mq.cmd("/useitem \"familiar of the hooded scrykin\"")
        mq.delay(7000) -- Wait for cast
        -- Check again after casting to see if it landed
        if hasBuff("Familiar: Hooded Scrykin") then
            BL.info("Hooded Scrykin familiar successfully cast")
            return true
        else
            BL.info("Hooded Scrykin familiar failed to cast")
            return false
        end
    end
    return true
end

local function castHemicSource()
    -- Wait a moment to ensure familiar buff is fully processed
    mq.delay(1000)
    BL.info("Casting Personal Hemic Source")
    mq.cmd("/useitem \"Personal Hemic Source\"")
    mq.delay(3500) -- Wait for cast
end

-- Check buffs and act accordingly
if hasBuff("Familiar: Personal Hemic Source") then
    BL.info("Personal Hemic Source already active - nothing to do")
elseif hasBuff("Familiar: Hooded Scrykin") then
    BL.info("Skykrin Familiar found, casting Personal Hemic Source")
    castHemicSource()
else
    BL.info("No buffs found, casting Skykrin Familiar then Personal Hemic Source")
    if ensureFamiliar() then
        -- Wait for familiar to land, then cast hemic
        mq.delay(1000)
        castHemicSource()
    else
        BL.info("Hooded Scrykin familiar not active, skipping Personal Hemic Source")
    end
end


