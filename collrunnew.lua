---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')

local function in_guild_lobby()
	return mq.TLO.Zone.ID() == 344
end

local function in_bazaar()
	return mq.TLO.Zone.ID() == 151
end


-- use throne AA
mq.cmd("/alt act 511")
print("Waiting until we zone into guild lobby")
mq.delay(600000, in_guild_lobby)
print("Zoned into lobby successfully")
mq.cmd("/travelto bazaar")
mq.delay(600000, in_bazaar)
print("Zoned into bazaar successfully")

mq.cmd("/nav locyxz 1253 -871 1")
print("We arrived!")