--- @type Mq
local mq = require('mq')
local BL = require('biggerlib')

local debug = false
local paused = false

local devMode = true
local devPath = 'zen/supersic'
local relPath = 'supersic'

local function checkIAmGroupTank()
	local groupTank = mq.TLO.Group.MainTank()

	if groupTank == mq.TLO.Me.CleanName() then
		return true
	else
		--BL.warn("I am NOT group tank role!  Please fix for SicTank to work!")
		--mq.cmd("/g WARNING: MY GROUP MAIN TANK ROLE IS NOT SET. SuperSic.lua will not work!")
		return false
	end
end

local function printHelp()
	BL.info(
		'SuperSicTank loaded!  Use /sic pause on|off to pause and unpause. Use /sic debug show debug logs.  Now your Sic Tank mode will continue tanking until xtar is empty.'
	)
end

local function doTankLoop()
	local cwtnState = mq.TLO.CWTN.Mode()
	--BL.info("CWTN State: %s", cwtnState)

	local function isAutoAttacking()
		return mq.TLO.Me.Combat()
	end

	local function getXTargetCount()
		return mq.TLO.Me.XTarget()
	end

	if
		cwtnState == 'SicTank'
		and getXTargetCount() > 0
		and not isAutoAttacking()
		and not mq.TLO.Me.Invis()
	then
		--target xtar 1
		local currentXtar = 1
		local nextTarget = mq.TLO.Me.XTarget(currentXtar)
		local targetID = nextTarget.ID()
		local targetDistance = nextTarget.Distance()

		while currentXtar <= getXTargetCount() and targetDistance > 5000 do
			currentXtar = currentXtar + 1
			nextTarget = mq.TLO.Me.XTarget(currentXtar)
			targetID = nextTarget.ID()
			targetDistance = nextTarget.Distance()
		end
		if currentXtar < getXTargetCount() and targetDistance > 5000 then
			-- no xtar targets in range
			BL.warn(
				'We have xtarget targets out of range!  They\'re probably stuck with distance: %d, currentXtar: %d getTargetCount: %d',
				targetDistance,
				currentXtar,
				getXTargetCount()
			)
			return
		end

		if debug then
			BL.info('Attacking next Xtar Target: %d', targetID)
		end

		local target = mq.TLO.Spawn(targetID)

		--attack
		if target then
			-- Note when using DoTarget(), or other Target TLO based things, you do not need the mq.delay like mq.cmd does
			target.DoTarget()
			mq.cmd('/attack on')
			if debug then
				BL.info('Attacking engaged')
			end
		elseif debug then
			BL.warn('No target found with id %d', targetID)
		end
	elseif debug then
		if cwtnState ~= 'SicTank' then
			BL.info('Not in SicTank mode')
		end
		if getXTargetCount() <= 0 then
			BL.info('No xtar targets found')
		end
		if isAutoAttacking() then
			BL.info('Already auto attacking')
		end
	end
end

------------------------------------------------- EVENTS ----------------------------------------------------

local function bind_ssic(...)
	local args = { ... }
	local key = args[1]
	local value = args[2]

	if not key or key == 'help' then
		printHelp()
	elseif key == 'pause' then
		if value then
			paused = value
		else
			paused = true -- default to true
		end
		BL.info('Supersic paused: %s', paused)
	elseif key == 'debug' then
		if value then
			debug = value
		else
			debug = not debug -- flip
		end
		BL.info('Supersic debug: %s', debug)
	end
end

mq.bind('/ssic', bind_ssic)

------------------------------------------------- EXECUTION -------------------------------------------------
printHelp()

while true do
	if not paused then
		if checkIAmGroupTank() then
			doTankLoop()
		end
	end
	mq.delay(1023)
end
