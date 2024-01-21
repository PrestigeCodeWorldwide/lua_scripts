local mq = require("mq")
local actors = require("actors")

local ZoneData = {
	laurionInn = {
		id = 859,
		shortName = "laurioninn",
		fullName = "Laurion's Inn",
	},
	pallomen = {
		id = 861,
		shortName = "pallomen",
		fullName = "Pal'Lomen",
	},
	herosforge = {
		id = 862,
		shortName = "herosforge",
		fullName = "Hero's Forge",
	},
}

local MissionData = {
	heroesareforged = {
		startingZone = ZoneData.laurionInn,
		npcName = "Elisel",
		gotMission = false,
		triggerPhrase = "small",
		instanceZone = ZoneData.herosforge,
		taskName = "Heroes Are Forged",
		safePoints = {
			{ y = -733, x = 1331, z = 56 }, -- southwest
			{ y = 58, x = -783, z = 60 }, -- bottom of ramp leading onto the field
			{ y = -1635, x = -778, z = 7 }, -- Southeast
			{ y = 812, x = 1283, z = 420 }, -- Northwest
		},
	},
	finalfugue = {
		startingZone = ZoneData.laurionInn,
		gotMission = false,
		npcName = "Shalowain",
		triggerPhrase = "smaller",
		instanceZone = ZoneData.pallomen,
		taskName = "Final Fugue",
		safePoints = "UNIMPLEMENTED",
	},
}

-- Change this for each script, maybe add a command / for it?
local CurrentMissionData = MissionData.heroesareforged

local grindIsCurrentlyActive = false

local grindActor = actors.register("unstucker", function(message)
	--printf(
	--	"/g in unstucker message handler, received message from %s with content.isGrinding: %s",
	--	message.sender,
	--	tostring(message.content.isGrinding)
	--)
	--mq.cmdf(
	--	"/g in unstucker message handler, received message from %s with content.isGrinding: %s",
	--	message.sender,
	--	tostring(message.content.isGrinding)
	--)
	--mq.cmd("/g Received grindCurrentlyActive change notification")
	grindIsCurrentlyActive = message.content.isGrinding
end)

local _unstickCounter = 0
local function CheckUnstick()
	print("Checking unstick with grind active : " .. tostring(grindIsCurrentlyActive))
	--grindActor:send("Help")
	-- if i'm not in combat and i'm not moving
	_unstickCounter = _unstickCounter + 1
	-- every 5 seconds if we're out of combat
	if _unstickCounter >= 5 and mq.TLO.Me.Combat() == false and grindIsCurrentlyActive then
		_unstickCounter = 0

		--print("Checking for unstuck")
		local function getMyCurrentLocation()
			local xPos = mq.TLO.Me.X()
			local yPos = mq.TLO.Me.Y()
			return xPos, yPos
		end

		-- Get my position, wait 1 second, get my position again and test distance between them
		local x1, y1 = getMyCurrentLocation()
		mq.delay(1000)
		local x2, y2 = getMyCurrentLocation()

		if x1 == nil or y1 == nil or x2 == nil or y2 == nil then
			print("Unable to get my current location, waiting")
			mq.delay(1000)
			return
		end

		-- get distance from x2,y2 to x1,y1
		local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
		printf("Stuck Distance: %f", distance)
		if distance < 5 then
			print("\ar/g I'm stuck!  Trying to unstick")
			-- pause boxes and self
			mq.cmd("/boxr pause")
			-- pick random direction from SafePoints and nav there for 2 seconds
			local randomSafePoint = CurrentMissionData.safePoints[math.random(#CurrentMissionData.safePoints)]
			mq.cmdf("/nav locyxz %d %d %d", randomSafePoint.y, randomSafePoint.x, randomSafePoint.z)
			mq.delay(2000)
			mq.cmd("/nav stop")
			mq.delay(100)
			-- unpause boxes and self, hopefully unsticking
			mq.cmd("/boxr unpause")
		end
	elseif _unstickCounter >= 5 then -- make sure to reset it even if we're in combat, otherwise it'll go haywire
		_unstickCounter = 0
	end
end

mq.cmd("/g Unstucker loaded")

local Run = true

while Run do
	--local payload = {
	--	sender = "Unstucker",
	--	isGrinding = grindIsCurrentlyActive,
	--}
	--actors.send({ mailbox = "grindActor", script = "zen/herosgrind" }, payload)
	mq.delay(3000)
	--actors.send(payload)
	--grindActor:send(payload)
	--anotherActor:send(payload)
	if grindIsCurrentlyActive then
		CheckUnstick()
	end
end

grindActor:unregister()
