local mq = require("mq")
local actors = require("actors")
--- @type ImGui
require("ImGui")

print("\ayBeginning Heros Forge Grind")

------------------------------------- DATA -----------------------------------
local myClass = string.lower(mq.TLO.Me.Class.ShortName())

local minutesToGrindPerInstance = 45

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
		mainGrindRunning = false,
		paused = false,
		waypointList = {},
	},
	finalfugue = {
		startingZone = ZoneData.laurionInn,
		gotMission = false,
		npcName = "Shalowain",
		triggerPhrase = "smaller",
		instanceZone = ZoneData.pallomen,
		taskName = "Final Fugue",
		safePoints = "UNIMPLEMENTED",
		mainGrindRunning = false,
		paused = false,
		waypointList = {},
	},
}

-- Change this for each script, maybe add a command / for it?
local CurrentMissionData = MissionData.heroesareforged

-------------------------------------- GUI ----------------------------------------
local gui = {}

-- Animations for drawing spell/item icons
gui.animSpellIcons = mq.FindTextureAnimation("A_SpellIcons")
gui.animItems = mq.FindTextureAnimation("A_DragItem")
-- Blue and yellow icon border textures
gui.animBlueWndPieces = mq.FindTextureAnimation("BlueIconBackground")
gui.animBlueWndPieces:SetTextureCell(1)
gui.animYellowWndPieces = mq.FindTextureAnimation("YellowIconBackground")
gui.animYellowWndPieces:SetTextureCell(1)
gui.animRedWndPieces = mq.FindTextureAnimation("RedIconBackground")
gui.animRedWndPieces:SetTextureCell(1)

local guiState = {
	open = true,
	shouldDrawUI = true,
	terminate = false,
	initialRun = true,
	selectedListItem = { nil, 0 }, -- {key, index}
}

gui.guiState = guiState

local function GrindUI()
	-- init
	if not gui.guiState.open and not gui.guiState.shouldDrawUI then
		return
	end

	-- Handle Pause
	--if CurrentMissionData.paused then
	--	if ImGui.Button("Unpause") then
	--		CurrentMissionData.paused = false
	--	end
	--elseif ImGui.Button("Pause") then
	--	CurrentMissionData.paused = true
	--end

	---- Handle Reload
	--if ImGui.Button("Reload") then
	--	mq.cmd("/multiline ; /lua stop zen/herosgrind ; /timed 10 /lua run zen/heroesgrind")
	--end
end

------------------------------------- FUNCTIONS -----------------------------------

local function SetIgnores()
	print("In SetIgnores")
	mq.cmdf('/%s ignore "a Rallosian warlock"', myClass)
	mq.cmdf('/%s ignore "a Rallosian soldier"', myClass)
	mq.cmdf('/%s ignore "a Rallosian hex"', myClass)
	mq.cmdf('/%s ignore "a Rallosian cutpurse"', myClass)
	mq.cmdf('/%s ignore "Shalowain"', myClass)
	mq.cmdf('/%s ignore "Dhakka Nogg"', myClass)
	mq.cmdf('/%s ignore "Thornel Grayleaf"', myClass)
	mq.cmdf('/%s ignore "Elistyl Kanghammer"', myClass)
	mq.cmdf('/%s ignore "Thormir Helmsbane"', myClass)
	mq.cmdf('/%s ignore "Elmara Emberclaw"', myClass)
	mq.cmdf('/%s ignore "a depleted forgebound"', myClass)
	mq.cmdf('/%s ignore "Captain Kar the Unmovable"', myClass)
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
				mq.cmdf("/dex %s /travelto herosforge", Member)
			end
			print("Zoning tank in last")
			mq.cmd("/travelto herosforge")
		end
	end
end

--This is to nav to NPC, get Shei mission and zone in.
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
	mq.cmdf("/%s campradius 60", myClass)
	-- Watch CC&Healer Mana
	--mq.cmdf("/%s GroupWatch 2", myClass)
	print("\apSetting HunterTank Mode, here we go!")
	mq.cmdf("/%s mode huntertank", myClass)
	mq.cmdf("/%s pause off", myClass)
end

--Variable for our MoveToCamp, to stop it from repeating
local SetCamp = true

-- This is once zoned into instance to wait for all to zone in, double invis, then nav to camp area.
local function MoveToCampAndBeginGrind()
	print("Beginning main Grind routine...")
	CheckMissingGroupMembers()

	mq.delay(1000)

	SetIgnores()
	print("Unpausing other boxes")
	mq.cmd("/dgge /boxr unpause")
	mq.delay(2000)
	print("Setting boxes to chase")
	mq.cmd("/dgge /boxr chase")
	mq.delay(1000)
	print("\apWe Are Going Into Tank Mode to Ensure We Don't Have A Suprise Guest")
	mq.cmdf("/%s mode tank", myClass)
	mq.cmdf("/%s pause off", myClass)
	MakeMeVis()
	print("\apAllowing Time to Buff")
	-- Change this delay to increase buff time or to help with Meding to full
	mq.delay(30000)
	SetPullerSettingsAndBegin()
	SetCamp = false
	print("Grinding!")
end

-- This is going to drop our task for us safely
local function DropTask()
	print("\apTime's up!  Dropping Task")

	mq.cmdf("/%s mode tank", myClass)
	while mq.TLO.Me.CombatState() == "COMBAT" do
		mq.delay(1000)
	end
	while mq.TLO.Task(CurrentMissionData.taskName).ID() and mq.TLO.Me.CombatState() ~= "COMBAT" do
		mq.delay(1000)
		mq.cmd("/kickp t")
		mq.delay(1000)
		mq.cmd("/yes")
		gotMission = false

		mq.delay(60000)
	end
end

local _unstickCounter = 0
local distanceDelta = 5
local function CheckUnstick()
	-- if i'm not in combat and i'm not moving
	_unstickCounter = _unstickCounter + 1
	-- every 5 seconds if we're out of combat
	if _unstickCounter >= 5 and mq.TLO.Me.Combat() == false then
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
			--print("Unable to get my current location, waiting")
			mq.delay(1000)
			return
		end

		-- get distance from x2,y2 to x1,y1
		local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
		if distance < distanceDelta then
			mq.cmd("/g I'm Stuck!  Trying to unstick")
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

------------------------------- EXECUTION

------------------------------------- ACTORS --------------------------------------
local grindActor = actors.register("herosgrind", function(message)
	printf(
		"in HEROGRIND grindActor message handler from %s with message: %s",
		message.sender,
		tostring(message.content.isGrinding)
	)
	mq.cmdf(
		"/g in HEROGRIND grindActor message handler from %s with message: %s",
		message.sender,
		tostring(message.content.isGrinding)
	)
end)

CurrentMissionData.mainGrindRunning = false
local payload = {
	isGrinding = CurrentMissionData.mainGrindRunning,
}
actors.send({ mailbox = "unstucker", script = "zen/unstucker" }, payload)

local Run = true

--main loop
while Run == true and not CurrentMissionData.paused do
	GrindUI()
	local payload = {
		isGrinding = CurrentMissionData.mainGrindRunning,
	}
	actors.send({ mailbox = "unstucker", script = "zen/unstucker" }, payload)

	if mq.TLO.Zone.ID() == CurrentMissionData.startingZone.id then
		print("Beginning Mission Task Giver NPC zone routine")
		CheckMissingGroupMembers()
		getMissionFromNPCRoutine()
		SetCamp = true
		mq.delay(30000)
	else
		if
			mq.TLO.Zone.ID() == CurrentMissionData.instanceZone.id
			and mq.TLO.Task(CurrentMissionData.taskName).ID() ~= nil
		then
			--print("In active hunting portion of main loop")
			while SetCamp == true do
				MoveToCampAndBeginGrind()
			end
			local minutesRemainingBeforeEndingGrind = 360 - minutesToGrindPerInstance

			if mq.TLO.Task(CurrentMissionData.taskName).ID() ~= nil then
				-- Change the Time here based on when you want to exit
				-- Leaving early prevents getting stuck with the task after completion
				while
					mq.TLO.Task(CurrentMissionData.taskName).Timer.TotalMinutes()
					>= minutesRemainingBeforeEndingGrind
				do
					--print("In main GRIND portion of main loop")
					CurrentMissionData.mainGrindRunning = true
					CheckUnstick()
					mq.delay(1000)
				end
				-- Make sure to change that time here as well!
				if
					mq.TLO.Task(CurrentMissionData.taskName).Timer.TotalMinutes()
					<= minutesRemainingBeforeEndingGrind
				then
					print("Time is up, beginning Drop routine.")
					DropTask()
					CurrentMissionData.mainGrindRunning = false
				end
			end
			--elseif mq.TLO.Zone.ID() ~= 862 then
			--	print("Not in the target grind zone yet")
			--elseif mq.TLO.Task(CurrentMissionData.taskName).ID() == nil then
			--	print("We don't have the task")
		else
			--This branch is taken after task has been dropped and we're waiting to get booted from zone
		end
	end
end

grindActor:unregister()
