--- @type Mq
local mq = require('mq')
local BL = require("biggerlib")

local HEAL_TARGET = "Dhakka"
local myClass = mq.TLO.Me.Class.ShortName()
local paused = false

--- @class Heal : table
--- @field name string
--- @field delay number

--- @class HealRotation : table
--- @field CLR Heal[]
--- @field SHM Heal[]

--- @type HealRotation
local HealRotations = {
	["CLR"] = {
		{ name = 'Avowed Remedy',       delay = 3500 },
		{ name = 'Guileless Remedy',    delay = 3500 },
		{ name = 'Avowed Intervention', delay = 3500 },
    },
	["SHM"] = {
	{ name = '"Reckless Reinvigoration"', delay = 3500 },
	{ name = '"Reckless Resurgence"',     delay = 3500 },
	{ name = '"Reckless Renewal"',        delay = 3500 },
	}
}

local function init()
	print('Starting Spam Healer')
    if mq.TLO.Plugin('mq2boxr')() then
        print('\apMQ2Boxr Already Loaded\ap') -- plugin is loaded.. we are good to go
    else
        print('\apLoading MQ2BOXR!\ap')
        mq.cmd('/plugin mq2boxr')
    end
	mq.cmd('/multiline ; /boxr pause; /mqp on; /backoff on')
end

--- @param healSpells Heal[]
local function performHealing(healSpells)
	mq.cmd('/target ' .. HEAL_TARGET)
    
    if not mq.TLO.Me.Casting() then
        for _idx, spell in ipairs(healSpells) do
            mq.cmd('/cast ' .. spell.name)
            mq.delay(spell.delay)
        end
    else
        BL.info("Already casting now")
    end
    -- needed delay to wait out the 3rd heal refresh
	mq.delay(500)
end
------------------------- EXECUTION
init()

while true do
	if not paused then 
		performHealing(HealRotations[myClass])	
	end
	mq.delay(100)
end
