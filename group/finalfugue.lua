---@type Mq
local mq = require("mq")
-- Locs specific to this event: Final Fugue

print("\ayFinal Fugue - Fight")

------------------------------------- DATA -----------------------------------
local myClass = string.lower(mq.TLO.Me.Class.ShortName())

local ZoneData = {
	pallomen = {
		id = 861,
		shortName = "pallomen",
		fullName = "Pal'Lomen",
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
local CurrentMissionData = MissionData.heroesareforged

------------------------------------- FUNCTIONS -----------------------------------

local function SetIgnores()
	print("In SetIgnores")
	mq.cmdf('/%s ignore "Shalowain"', myClass)
	mq.cmdf('/%s ignore "Dhakka Nogg"', myClass)
	mq.cmdf('/%s ignore "Thornel Grayleaf"', myClass)
	mq.cmdf('/%s ignore "Elistyl Kanghammer"', myClass)
	mq.cmdf('/%s ignore "Thormir Helmsbane"', myClass)
	mq.cmdf('/%s ignore "Elmara Emberclaw"', myClass)
	mq.cmdf('/%s ignore "a depleted forgebound"', myClass)
end

--This checks to see if i am moving and will wait to continue
local function WaitOnNav()
	print("\apStill Moving!")
	while mq.TLO.Me.Moving() do
		mq.delay(1000)
	end
end

-- This is checking if everyone in group is in zone, if not we waiting
local function CheckMissingGroupMembers()
	print("Checking for missing group members...")
	if mq.TLO.Group.AnyoneMissing() == true then
		print("\apWe Seem To Be Missing Some Group Members")
		print("\apLets Give Them A Moment To Zone In")
		while mq.TLO.Group.AnyoneMissing() == true do
			mq.delay(5000)
		end
	end
end

--This is to make us drop invis
local function MakeMeVis()
	mq.cmd("/dgga /makemevis")
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
		WaitOnNav()
	end
end

local function getTask()
	print("Getting Task")

	if gotMission or mq.TLO.Target == nil or mq.TLO.Target == "NULL" then
		print("Bailing out of getTask early because we already have the mission or we don't have a target")
		return
	end

	local currentZone = mq.TLO.Zone.ID()

	if currentZone == CurrentMissionData.startingZone.id and mq.TLO.Target.Distance() <= 30 then
		if mq.TLO.Task(CurrentMissionData.taskName).ID() == nil then
			print("\apRequesting task...")
			mq.delay(1000)
			mq.cmdf("/%s mode 0", myClass)
			mq.delay(1000)
			mq.cmd("/dgga /boxr pause")
			mq.delay(1000)
			MakeMeVis()
			mq.delay(1000)
			if mq.TLO.Target.CleanName() ~= CurrentMissionData.npcName then
				mq.cmdf("/target %s", CurrentMissionData.npcName)
			end
			mq.delay(2000)
			mq.cmd("/say small")
			mq.delay(5000)
			gotMission = true
		end
	end
end

local function zoneIn()
	local currentZone = mq.TLO.Zone.ID()
	if currentZone == CurrentMissionData.startingZone.id then
		print("\apZoning group into the instance")
		local GroupSize = mq.TLO.Group.Members()
		if mq.TLO.Task(CurrentMissionData.taskName).ID() ~= nil then
			print("\apWaiting For Instance to spawn, Stand By!")
			while not mq.TLO.DynamicZone.Leader.Flagged() do
				mq.delay(30000)
			end
			for g = 1, GroupSize, 1 do
				local Member = mq.TLO.Group.Member(g).Name()
				print("\ay-->", Member, "<--", "\apShould Be Zoning In Now")
				mq.cmdf("/dex %s /travelto pallomen", Member)
			end
			print("Zoning tank in last")
			mq.cmd("/travelto pallomen")
		end
	end
end

--This is to nav to NPC, get mission and zone in.
local function getMissionFromNPCRoutine()
	print("Beginning Get Mission from NPC routine")
	mq.cmd("/dgga /boxr pause")
	amIClose()
	mq.delay(1000)
	getTask()
	zoneIn()
end
--Setting Puller Settings
local function SetPullerSettingsAndBegin()
	print("\apSetting Puller Settings")
	mq.cmdf("/%s pullradius 9999", myClass)
	mq.cmdf("/%s pullarch 360", myClass)
	mq.cmdf("/%s zHigh 999", myClass)
	mq.cmdf("/%s zLow 999", myClass)
	mq.cmdf("/%s campradius 100", myClass)
	-- Watch CC&Healer Mana
	--mq.cmdf("/%s GroupWatch 2", myClass)
	print("\apSetting SicTank Mode, here we go!")
	mq.cmdf("/%s mode sictank", myClass)
	mq.cmdf("/%s pause off", myClass)
end

--Variable for our MoveToCamp, to stop it from repeating
local SetCamp = true

-- This is once zoned into instance to wait for all to zone in, double invis, then nav to camp area.
local function MoveToCampAndBeginGrind()
	print("Beginning main routine...")
	CheckMissingGroupMembers()

	mq.delay(1000)

	SetIgnores()
	print("Unpausing other boxes")
	mq.cmd("/dgge /boxr unpause")
	mq.delay(2000)
	print("Setting boxes to chase")
	mq.cmd("/dgge /boxr chase")
	-- Change this delay to increase buff time or to help with Meding to full
	mq.delay(30000)
	SetPullerSettingsAndBegin()
	SetCamp = false
	print("Let's Begin!")
end

-- This will talk to Shalowain to begin the task.
local function TalktoShalowain()
	print("Talking to Shalowain")
	mq.cmd("/tar shalowain")
	mq.delay(1000)
	mq.cmd("/nav target")
	mq.delay(1000)
	mq.cmd(/say they come)
end

-- This will kill warlock. Need to put something here that says while target is alive do this part?
local function killwarlock()
	print("Waiting for Ambush")
	mq.delay(5000)
	mq.cmd(/tar warlock)
	mq.delay(1000)
	mq.cmd(/nav target)
	mq.delay(1000)
	mq.cmd(/attack on)
end

-- This will kill hex. Need to put something here that says while target is alive do this part?
local function killhex()
	print("Waiting for Ambush")
	mq.delay(5000)
	mq.cmd(/tar hex)
	mq.delay(1000)
	mq.cmd(/nav target)
	mq.delay(1000)
	mq.cmd(/attack on)
end

-- This will kill soldiers in first spot. Need to put something here that says while target is alive do this part?
local function killsoldiers()
	print("Kill Soldiers")
	mq.delay(5000)
	mq.cmd(/tar soldier)
	mq.delay(1000)
	mq.cmd(/nav target)
	mq.delay(1000)
	mq.cmd(/attack on)
end

-- This will kill boars in first spot. Need to put something here that says while target is alive do this part?
local function killboar()
	print("Kill Boars")
	mq.delay(5000)
	mq.cmd(/tar boar)
	mq.delay(1000)
	mq.cmd(/nav target)
	mq.delay(1000)
	mq.cmd(/attack on)
end

-- This will kill handler in first spot. Need to put something here that says while target is alive do this part?
local function killhandler()
	print("Kill Handler")
	mq.delay(5000)
	mq.cmd(/tar handler)
	mq.delay(1000)
	mq.cmd(/nav target)
	mq.delay(1000)
	mq.cmd(/attack on)
end

-- This will kill wraith in first spot. Need to put something here that says while target is alive do this part?
local function killwraith()
	print("Kill Wraith")
	mq.delay(5000)
	mq.cmd(/tar wraith)
	mq.delay(1000)
	mq.cmd(/nav target)
	mq.delay(1000)
	mq.cmd(/attack on)
end

-- This will nav to second spot. Need to figure out the delay to get to that spot?
local function navspottwo()
	print("Nav to spot 2")
    mq.cmd(/nav locxyz -166, 534, 23)
end

-- This will kill hunters in second spot. Need to put something here that says while target is alive do this part?
local function killxtars()
	print("Kill Hunter")
	mq.delay(5000)
	mq.cmd(/tar hunter)
	mq.delay(1000)
	mq.cmd(/nav target)
	mq.delay(1000)
	mq.cmd(/attack on)
end

-- This will nav to third spot. Need to figure out the delay to get to third spot?
local function navspotthree()
	print("Nav to spot 3")
    mq.cmd(/nav locxyz 927, -710, 5)
end

-- This will put tank into tankmode to complete the task kills.
local function navspotthree()
	print("Tank Mode Time")
    mq.cmdf("/%s mode tank", myClass)
end

------------------------------- EXECUTION