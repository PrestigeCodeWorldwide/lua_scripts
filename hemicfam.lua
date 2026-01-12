---@type Mq
local mq = require("mq")
--- @type BL
local BL = require("biggerlib")

BL.info("Hemicfam v1.0 loaded")

local function hasBuff(buffName)
    return mq.TLO.Me.Buff(buffName)() ~= nil
end

local function ensureFamiliar()
    if not hasBuff("Familiar: Hooded Scrykin") then
        BL.info("Casting Familiar: Hooded Scrykin")
        mq.cmd("/useitem \"familiar of the hooded scrykin\"")
        mq.delay(5200) -- Wait for cast
        return false
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
    ensureFamiliar()
    -- Wait for familiar to land, then cast hemic
    mq.delay(1000)
    castHemicSource()
end


