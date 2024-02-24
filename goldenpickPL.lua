local mq = require('mq')
local BL = require('biggerlib')
local radiusZ = 30
local radiusXY = 75

local successfullyHitTarget = false

local OnHitEventMatcher = 'You hit #1# for 1 points #*#.'
----
mq.event('HitCurrentMobSuccessfullyEvent', OnHitEventMatcher, function(line, name)
	successfullyHitTarget = true
end)


local function hitAll()
	mq.cmd("/hidecorpse all")
	mq.delay(50)
	mq.cmd("/nav spawn kodajii")
	BL.WaitForNav()

	local spawnCount = mq.TLO.SpawnCount("npc targetable los radius " .. radiusXY .. " zradius " .. radiusZ)()
	local hitArrayID = {}
	for i = 1, spawnCount do
		local spawn = mq.TLO.NearestSpawn(i, "npc targetable los radius " .. radiusXY .. " zradius " .. radiusZ)
		if spawn() and not (spawn.Name():find("pet") or spawn.Name():find("Pet")) then
			hitArrayID[i] = spawn.ID()
		end
	end
	BL.info("iterating spawns with count: ", #hitArrayID)
    for i, npcID in ipairs(hitArrayID) do
		BL.info("Iteration starting, count: ", i, " of ", #hitArrayID, " npcID: ", npcID)
		local target = mq.TLO.Spawn(npcID)
		target.DoTarget()
        mq.delay(500)		
		mq.cmdf("/dgza /echo Attacking new target : %s who is %d out of %d total", target.Name(), i, #hitArrayID)
		successfullyHitTarget = false
		
		mq.cmd('/stick 12 uw !front')
		mq.delay(500)
		BL.info("Turning attack on")
		mq.cmd('/attack on')
		
		while not successfullyHitTarget do
			if not mq.TLO.Me.Combat() then mq.cmd('/attack on') end
			mq.doevents()
			mq.delay(200)
		end
		mq.doevents()
        
        mq.delay(500)
		BL.info("Finished iteration: ", i)
	end
	mq.cmd('/attack off')
	mq.cmd("/dgza /echo DONE HITTING ALL!")
end

local function main()
	mq.cmd("/dgza /echo Starting Golden Pick Hitall...")
    mq.delay(100)
	mq.doevents()
	hitAll()
end

main()
