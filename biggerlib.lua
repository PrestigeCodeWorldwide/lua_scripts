---@type Mq
local mq = require 'mq'

local BL = {}
BL.cmd = {}
BL.log = {}
BL.enum = {}

local log_prefix = '\a-t[\ax\ayBL\ax\a-t]\ax \aw'

--- Takes a full line of text and extracts every player named into a list
function BL.parseAllNames(names)
	local withoutAnd = names:gsub(", and", ",")

	-- Split string by comma
	local nameList = {}
	for name in withoutAnd:gmatch("[^,]+") do
		-- Trim whitespace and insert into list
		table.insert(nameList, name:match("^%s*(.-)%s*$"))
	end

	return nameList
end

--- Returns true if the nameList passed in from event contains the name of the current character
function BL.nameListIncludesMe(namesString)
	print(namesString)
	local names = BL.parseAllNames(namesString)
	print("names is " .. tostring(names))

	local myname = mq.TLO.Me.CleanName()

	for _, name in ipairs(names) do
		if name == myname then
			return true
		end
	end

	return false
end

function BL.getRandomPointOnCircle()
    local h, k = mq.TLO.Me.X(), mq.TLO.Me.Y()
		local r = 160
		local z = -46
    -- Generate a random angle between 0 and 2*pi
    local theta = math.random() * 2 * math.pi
    
    -- Calculate the X and Y coordinates based on the random angle
    local X = h + r * math.cos(theta)
    local Y = k + r * math.sin(theta)
    
    return X, Y
end

function BL.cmd.pauseAutomation()
	mq.cmd('/boxr Pause')
	mq.cmd('/timed 5 /afollow off')
	mq.cmd('/nav stop')
	mq.cmd('/twist stop')
	mq.cmd('/attack off')
	mq.cmd('/target clear')
end

function BL.cmd.resumeAutomation()
	mq.cmd('/boxr Unpause')
	mq.cmd('/twist start')
end

-- This function waits for 'delay' seconds, then navigates to a location.
-- It will not return until the destination is reached
function BL.cmd.runToAfterDelay(x, y, z, delay)
	mq.delay(delay .. "s")
	mq.cmdf('/nav locxyz %d %d %d', x, y, z)
	while mq.TLO.Nav.Active() do -- wait till I get there before continuing next command
		--pause wait for nav
		mq.delay(100)
	end
	print(string.format("Navigation arrived at: " .. x .. y .. z))
end

--- Used in specific raids when bots need to NOT stand close to each other during a dot/aura
function BL.cmd.setRngSeedFromPlayerPosition()
	local h, k = mq.TLO.Me.X(), mq.TLO.Me.Y()
	math.randomseed(os.time() * h / k)
end

function BL.cmd.returnToRaidMainAssist()
	mq.delay(10)
	--Check to see if we have a raid assist, then return to him
	local mainAssistName = mq.TLO.Raid.MainAssist.Name()
	if mainAssistName then
		mq.cmd('/nav spawn pc =' .. mainAssistName)	
	else 
		print("WARNING: No raid main assist set")			
	end
end

function BL.cmd.removeZerkerRootDisc()
	local my_class = mq.TLO.Me.Class.ShortName()
	if my_class == 'BER' and mq.TLO.Me.ActiveDisc.Name() == mq.TLO.Spell('Frenzied Resolve Discipline').RankName() then
		mq.cmd('/stopdisc')
	end
end

-- Enums/matching
--- This is used to create a single variant of an enum, such as:
--- local MyEnum = {
---    VariantA = function(...) return createVariant("VariantA", ...) end,
---    VariantB = function(...) return createVariant("VariantB", ...) end,
---    -- Add more variants as needed
---}
function BL.enum.createVariant(name, ...)
	return {type = name, data = {...}}
end

function  BL.enum.match(enumValue, matchTable)
	local func = matchTable[enumValue.type]
	if func then
		return func(table.unpack(enumValue.data))
	end
end

-- Logging
function BL.log.logLine(...)
	local timestampPrefix = BL.log.timestamps and '\a-w[' .. os.date('%X') .. ']\ax' or ''
	return string.format(timestampPrefix .. log_prefix .. string.format(...) .. '\ax')
end

function BL.log.info(...)
	local timestampPrefix = BL.log.timestamps and '\a-w[' .. os.date('%X') .. ']\ax' or ''
	local output = string.format(timestampPrefix .. log_prefix .. string.format(...) .. '\ax')
	print(output)
	return output
end

function BL.log.dumpRecurse(data, depth)
	if data == nil then
		return "NIL"
	end
	if type(data) == 'table' then
		local output = '{'
		for key, value in pairs(data) do
			output = output ..
				string.format('\n%s%s = %s', string.rep(' ', depth or 4), key, logger.dump(value, (depth or 4) + 4))
		end
		return output .. '\n' .. string.rep(' ', depth or 4) .. '}'
	else
		return tostring(data)
	end
end

function BL.log.dump(data, depth)
	print("DUMP: " .. BL.log.dumpRecurse(data, depth))
end

function BL.log.inspect(...)
	local args = { ... }
	BL.log.info(inspect.inspect(args))
end

return BL
