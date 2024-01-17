local mq = require('mq')

local noHitZoneShortName = {'PoKnowledge', 'Bazaar', 'Nexus', 'guildlobby'}
local radiusZ = 30
local radiusXY = 75
local function isZoneAllowed(zoneShortName)
	for _, noHitZone in ipairs(noHitZoneShortName) do
		if zoneShortName == noHitZone then
			return false
		end
	end
	return true
end

local successfullyHitTarget = false

local OnHitEventMatcher = 'You hit #1# for 1 points #*#.'
----
mq.event('HitCurrentMobSuccessfullyEvent', OnHitEventMatcher, function(line, name)
successfullyHitTarget = true
end)

-- Define a predicate function that checks if the spawn is an NPC
--local function isNPC(spawn)
--	return spawn.Type() == 'NPC'
--end
--
---- Call getFilteredSpawns with the predicate function
--local npcs = mq.getFilteredSpawns(isNPC)

local function hitAll()
	if not isZoneAllowed(mq.TLO.Zone.ShortName()) then return end
	mq.cmd("/hidecorpse all")
	mq.delay(50)
	mq.cmd("/nav spawn kodajii")
	mq.delay(3000)
	
	local spawnCount = mq.TLO.SpawnCount("npc targetable los radius " .. radiusXY .. " zradius " .. radiusZ)()
	local hitArrayID = {}
	for i = 1, spawnCount do
		local spawn = mq.TLO.NearestSpawn(i, "npc targetable los radius " .. radiusXY .. " zradius " .. radiusZ)
		if spawn() and not (spawn.Name():find("pet") or spawn.Name():find("Pet")) then
			hitArrayID[i] = spawn.ID()
		end
	end
	
	for i, npcID in ipairs(hitArrayID) do
		local target = mq.TLO.Spawn(npcID)
		target.DoTarget()
		mq.cmdf("/dgza /echo Attacking new target : %s who is %d out of %d total", target.Name(), i, #hitArrayID)
		successfullyHitTarget = false
		
		mq.cmd('/stick 8 uw !front')
		mq.delay(20)
		mq.cmd('/attack on')
		
		while not successfullyHitTarget do
			mq.doevents()
			mq.delay(200)
		end
		
		mq.cmd('/attack off')
	end
	
	mq.cmd("/dgza /echo DONE HITTING ALL!")
end

local function main()
	mq.cmd("/dgza /echo Starting Golden Pick Hitall...")
	mq.delay(100)
	hitAll()
end

main()

