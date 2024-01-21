local mq = require("mq")
local BL = require("biggerlib")

BL.info("\ayFinal Fugue - Fight")

------------------------------------- DATA -----------------------------------
local myClass = string.lower(mq.TLO.Me.Class.ShortName())

local ZoneData = {
	pallomen = {
		id = 861,
		shortName = "pallomen",
		fullName = "Pal'Lomen",
	},
	laurionInn = {
		id = 859,
		shortName = "laurioninn",
		fullName = "Laurion Inn",
	},
}

local MissionData = {
	finalfugue = {
		startingZone = ZoneData.laurionInn,
		gotMission = false,
		npcName = "Shalowain",
		triggerPhrase = "smaller",
		instanceZone = ZoneData.pallomen,
		taskName = "Final Fugue",
		safePoints = "UNIMPLEMENTED",
		mainGrindRunning = false,
	},
}

-- Change this for each script, maybe add a command / for it?
local CurrentMissionData = MissionData.finalfugue

-- This will put tank into tankmode to complete the task kills.
local function pushTankMode()
	BL.info("Tank Mode Time")
	mq.cmdf("/%s mode sictank", myClass)
	mq.delay(100)
end

local function popTankMode()
	BL.info("Stopping Tank Mode in prep for moving")
	mq.cmdf("/%s mode manual", myClass)
	mq.delay(100)
end

------------------------------------- FUNCTIONS -----------------------------------

local function SetIgnores()
	BL.info("In SetIgnores")
	mq.cmdf('/%s ignore "Shalowain"', myClass)
	mq.cmdf('/%s ignore "Dhakka Nogg"', myClass)
	mq.cmdf('/%s ignore "Thornel Grayleaf"', myClass)
	mq.cmdf('/%s ignore "Elistyl Kanghammer"', myClass)
	mq.cmdf('/%s ignore "Thormir Helmsbane"', myClass)
	mq.cmdf('/%s ignore "Elmara Emberclaw"', myClass)
	mq.cmdf('/%s ignore "a depleted forgebound"', myClass)
end

-- This is checking if everyone in group is in zone, if not we waiting
local function CheckMissingGroupMembers()
	BL.info("Checking for missing group members...")
	if mq.TLO.Group.AnyoneMissing() == true then
		BL.info("\apWe Seem To Be Missing Some Group Members")
		BL.info("\apLets Give Them A Moment To Zone In")
		while mq.TLO.Group.AnyoneMissing() == true do
			mq.delay(5000)
		end
	end
end

local function amIClose()
	if gotMission then
		return
	end

	mq.cmd("/boxr pause")

	if mq.TLO.Target.CleanName() ~= CurrentMissionData.npcName then
		mq.cmdf("/target %s", CurrentMissionData.npcName)
		mq.delay(1000)
	end

	if mq.TLO.Target.Distance() > 30 then
		mq.delay(1000)
		--comeToMe()
		--DBLinvis()
		printf("\apMoving To %s", CurrentMissionData.npcName)
		mq.cmdf("/nav spawn %s", CurrentMissionData.npcName)
		mq.delay(1000)
		BL.WaitForNav()
	end
end

local function FindAndKillAll(targetName, numberToKill)
	pushTankMode()
	local killcount = 0
	while killcount < numberToKill do
		if not mq.TLO.Me.Combat() then
			BL.info("Targeting next target with %d left to kill.", numberToKill - killcount)
			BL.TargetAndNavTo(targetName, 200)
			-- Forces casters to attack mobs even not on xtar
			BL.GroupCmd("/attack on")
			killcount = killcount + 1
		end
		mq.delay(1000)
	end

	popTankMode()
end

local function getTask()
	BL.info("Getting Task")

	if gotMission or mq.TLO.Target == nil or mq.TLO.Target == "NULL" then
		BL.info("Bailing out of getTask early because we already have the mission or we don't have a target")
		return
	end

	local currentZone = mq.TLO.Zone.ID()

	if currentZone ~= CurrentMissionData.startingZone.id then
		BL.error("You're not in the correct zone to get the mission.")
		return
	end

	while mq.TLO.Target.Distance() > 30 do
		BL.info("Moving to target")
		mq.cmdf("/nav spawn %s", CurrentMissionData.npcName)
		mq.delay(1000)
		BL.WaitForNav()
	end

	if mq.TLO.Task(CurrentMissionData.taskName).ID() == nil then
		BL.info("\apRequesting task...")
		mq.cmdf("/%s mode 0", myClass)
		BL.GroupCmd("/boxr pause")
		mq.delay(1000)
		BL.MakeGroupVisible()

		if mq.TLO.Target.CleanName() ~= CurrentMissionData.npcName then
			mq.cmdf("/target %s", CurrentMissionData.npcName)
		end
		mq.delay(1000)
		mq.cmd("/say small")
		mq.delay(5000)
	else
		BL.warn("We're not requesting task because this says we already have it")
		BL.warn(mq.TLO.Task(CurrentMissionData.taskName).ID())
	end
end

local function zoneIn()
	local currentZone = mq.TLO.Zone.ID()
	if currentZone == CurrentMissionData.startingZone.id then
		BL.info("\apZoning group into the instance")
		local GroupSize = mq.TLO.Group.Members()
		local taskid = mq.TLO.Task(CurrentMissionData.taskName).ID()
		if taskid ~= nil then
			BL.dump(mq.TLO.Task(CurrentMissionData.taskName).ID())
			BL.info("\apWaiting For Instance to spawn, Stand By!")
			mq.delay(30000)
			while not mq.TLO.DynamicZone.Leader.Flagged() do
				mq.delay(30000)
			end
			for g = 1, GroupSize, 1 do
				local Member = mq.TLO.Group.Member(g).Name()
				BL.info("\ay-->", Member, "<--", "\apShould Be Zoning In Now")
				mq.cmdf("/dex %s /travelto pallomen", Member)
			end
			BL.info("Zoning tank in last")
			mq.cmd("/travelto pallomen")
			while mq.TLO.Zone.ID() ~= CurrentMissionData.instanceZone.id do
				mq.delay(1000)
				BL.GroupCmd("/travelto pallomen")
			end
			BL.info("Tank finished zoning into Instance")
		else
			BL.warn("Task ID is nil")
		end
	end
end

--This is to nav to NPC, get mission and zone in.
local function getMissionFromNPCRoutine()
	BL.info("Beginning Get Mission from NPC routine")
	BL.GroupCmd("/boxr pause")
	amIClose()
	mq.delay(1000)
	getTask()
	zoneIn()
end
--Setting Puller Settings
local function SetPullerSettingsAndBegin()
	BL.info("\apSetting Puller Settings")
	mq.cmdf("/%s pullradius 9999", myClass)
	mq.cmdf("/%s pullarch 360", myClass)
	mq.cmdf("/%s zHigh 999", myClass)
	mq.cmdf("/%s zLow 999", myClass)
	mq.cmdf("/%s campradius 100", myClass)
	-- Watch CC&Healer Mana
	--mq.cmdf("/%s GroupWatch 2", myClass)
	BL.info("\apSetting Vorpal Mode, here we go!")
	mq.cmdf("/%s mode vorpal", myClass)
	mq.cmdf("/%s pause off", myClass)
end

-- This is once zoned into instance to wait for all to zone in, double invis, then nav to camp area.
local function PreptimeBegin()
	BL.info("Let's get you ready")
	CheckMissingGroupMembers()

	mq.delay(1000)

	SetIgnores()
	BL.info("Unpausing everyone")
	BL.GroupCmd("/boxr unpause")
	mq.delay(2000)
	BL.info("Setting boxes to chase")
	mq.cmd("/dgge /boxr chase")
	-- Change this delay to increase buff time or to help with Meding to full
	mq.delay(3000)
	SetPullerSettingsAndBegin()
	BL.info("Let's Begin!")
end

-- This will talk to Shalowain to begin the task.
local function TalktoShalowain()
	BL.info("Talking to Shalowain")
	BL.GroupCmd("/nav spawn shalowain")

	BL.GroupCmd("/target Shalowain")
	BL.WaitForNav()
	BL.MakeGroupVisible()
	mq.cmd("/say they come")
	mq.cmd("/dgge /boxr chase")
	mq.cmd("/target clear")
	mq.delay(1000)
	pushTankMode()
end

-- This will kill warlock.
local function handleOrcWarlocks()
	BL.info("Killing 2 warlocks")

	FindAndKillAll("warlock", 2)
end

-- This will kill hex. Need to put something here that says while target is alive do this part, then move to the next
local function handleOrcHexes()
	BL.info("Killing 2 Hexers")

	FindAndKillAll("hex", 2)
end

-- This will kill soldiers in first spot. Need to put something here that says while target is alive do this part?
local function handleOrcMelees()
	BL.info("Killing 2 Soldiers")

	FindAndKillAll("soldier", 2)

	BL.info("Finished killing soldiers")
end

-- This will kill boars in first spot. Need to put something here that says while target is alive do this part?
local function handleBoars()
	BL.info("Kill Boars")
	FindAndKillAll("boar", 2)
end

-- This will kill handler in first spot. Need to put something here that says while target is alive do this part?
local function handleBoarBigboy()
	BL.info("Kill Handler")
	FindAndKillAll("handler", 1)
end

-- This will kill wraith in first spot. Need to put something here that says while target is alive do this part?
local function handleWraith()
	FindAndKillAll("wraith", 1)
end

-- Would this function work better or how do i integrate the runtoafterdelay?
local function MoveToSecondLocation()
	BL.info("Nav to spot 2")
	BL.GroupCmd("/nav locyxz -166, -534, -23")
	while mq.TLO.Navigation.Active() do
		mq.delay(50)
	end
end

-- This will kill hunters in second spot. Need to put something here that says while target is alive do this part?
local function handleHunters()
	BL.info("Kill Hunter")
	FindAndKillAll("hunter", 3)
end

-- Would this function work better or how do i integrate the runtoafterdelay?
local function MoveToThirdLocation()
	BL.info("Nav to spot 3")
	BL.GroupCmd("/nav locyxz 927, -710, 5")
	while mq.TLO.Navigation.Active() do
		mq.delay(500)
	end
end

--This is to do the mission.
local function DoMission()
	BL.info("Let's begin")
	handleOrcMelees()
	handleOrcWarlocks()
	handleOrcHexes()

	-- this needs some move-to
	handleBoars()
	handleBoarBigboy()
	handleWraith()

	MoveToSecondLocation()
	handleHunters()

	MoveToThirdLocation()
	--tankmode()
end

------------------------------- EXECUTION

local function PrepMission()
	-- First, we need to get the mission from the NPC and zone into the instance
	getMissionFromNPCRoutine()
	-- This will unpause and get toons set up, time to buff.
	PreptimeBegin()
	-- Talk to Shalowain to start the event
	TalktoShalowain()
end

local function main()
	PrepMission()
	DoMission()
end

main()
