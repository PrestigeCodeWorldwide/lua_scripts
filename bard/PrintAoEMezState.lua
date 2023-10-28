-- IGNORE ME, this is just a testing playground

--- @type Mq
local mq = require 'mq'

function getBuffDurationFromParseStmt(id, mezStmt, debuglabel)
	
	formattedMez = mezStmt:format(id)
	print("Formatted mez statement is: ", formattedMez)
	local durationString = mq.parse(formattedMez)
	if durationString == nil or durationString == "NULL" then
		-- Return zero if null/nil, as we want to mez anything that doesn't already have a mez on it
		print("Duration string is null or nil, returning 0")
		return 0
	end
	--print("Duration string is: ", durationString, " ", debuglabel)
	--print("Type of duration string is: ", type(durationString))
	local duration = tonumber(durationString)
	--print("Duration after tonumber is: ", duration, " ", debuglabel)
	-- tonumber should always succeed since we've checked for null/nil, but just in case....
	--assert(duration ~= nil)
	printf('%d - Duration being returned is: %s - %s', id, duration, debuglabel)
	return duration
end
local id = 18962

--local durationAoE = getBuffDurationFromParseStmt(id, mezStmtAoE, "AoE")
--local mob = mq.TLO.Spawn('id ' .. id)
--local mobbuff = mq.TLO.Spawn('id ' .. id).Buff("Wave of Nocturn")
--print("Mob buff is: ", mobbuff, " ", type(mobbuff), " ", mobbuff())
local mobbuffduration = mq.TLO.Spawn('id ' .. id).Buff("Wave of Nocturn").Duration()
print("Mobbuff duration is: ", mobbuffduration)
--print("Targeting mob 18962")
--mob.DoTarget()
--print("Waiting up to 5 seconds for buffs to populate")
---- This is where we spin waiting on buffs to load.  We'll then check to see if they include aoe AFTER this returns
--mq.delay(5000, function()
--	return mq.TLO.Target.BuffsPopulated()
--end)
--printf("Finished delaying, are buffs now populated? %s", mq.TLO.Target.BuffsPopulated())
--mq.delay(100)
---- CHECK FOR AE MEZ HERE once we've targeted the mob (this is outdated comment i think)
--durationAoE = getBuffDurationFromParseStmt(id, mezStmtAoE, "AoE")