-- Made by Aaly --

-- This is meant to be ran from your tank
-- Best ran with CWTN Plugins!
-- Any advice on how to make this better  or some pointers for some one just starting out would be incredible

-- Things to Add
-- Instance timer to leave instance safely before the mission timer expires
-- Something to recognize if we end up in GL dead, to either log out or rez corpses ?

print("\ayHello! Welcome to HFCamp")

local mq = require("mq")

-- Information for Quest NPC
local npcName = "Elisel"
local gotMission = false

--To Identify our class shortname
local myClass = string.lower(mq.TLO.Me.Class.ShortName())

local myZone = mq.TLO.Zone.ID()

local minutesToGrindPerInstance = 240

----------------------------------------- Hylander Double Invis Lua ----------------------------------------------------------
local function classShortName(x)
	local y = mq.TLO.Group.Member(x).Class.ShortName()
	return y
end

local function query(peer, query, timeout)
	mq.cmdf('/dquery %s -q "%s"', peer, query)
	mq.delay(timeout)
	local value = mq.TLO.DanNet(peer).Q(query)()
	return value
end

local function tell(delay, gm, aa)
	local z = mq.cmdf(
		"/timed %s /dex %s /multiline ; /stopcast; /timed 1 /alt act %s",
		delay,
		mq.TLO.Group.Member(gm).Name(),
		aa
	)
	return z
end

local function all_double_invis()
	local dbl_invis_status = false
	local grpsize = mq.TLO.Group.Members()

	for gm = 0, grpsize do
		local name = mq.TLO.Group.Member(gm).Name()
		local result1 = query(name, "Me.Invis[1]", 100)
		local result2 = query(name, "Me.Invis[2]", 100)
		local both_result = false

		if result1 == "TRUE" and result2 == "TRUE" then
			both_result = true
			--print(string.format("\ay%s \at%s \ag%s", name, "DBL Invis: ", both_result))
		else
			--print('gm'..gm)
			break
		end

		if gm == grpsize then
			dbl_invis_status = true
		end
	end
	return dbl_invis_status
end

local function the_invis_thing()
	--if i am bard or group has bard, do the bard invis thing
	if mq.TLO.Spawn("Group Bard").ID() > 0 then
		local bard = mq.TLO.Spawn("Group Bard").Name()
		if bard == mq.TLO.Me.Name() then
			mq.cmd("/mutliline ; /stopsong; /timed 1 /alt act 3704; /timed 3 /alt act 231")
		else
			mq.cmdf("/dex %s /multiline ; /stopsong; /timed 1 /alt act 3704; /timed 3 /alt act 231", bard)
		end
		print("\ag-->\atINVer: \ay", bard, "\at IVUer: \ay", bard, "\ag<--")
	else
		--without a bard, find who can invis and who can IVU
		local inver = 0
		local ivuer = 0
		local grpsize = mq.TLO.Group.Members()

		--check classes that can INVIS only
		for i = 0, grpsize do
			if string.find("RNG DRU SHM", classShortName(i)) ~= nil then
				inver = i
				break
			end
		end

		--check classes that can IVU only
		for i = 0, grpsize do
			if string.find("CLR NEC PAL SHD", classShortName(i)) ~= nil then
				ivuer = i
				break
			end
		end

		--check classes that can do BOTH
		if inver == 0 then
			for i = 0, grpsize do
				if string.find("ENC MAG WIZ", classShortName(i)) ~= nil then
					inver = i
					break
				end
			end
		end

		if ivuer == 0 then
			for i = grpsize, 0, -1 do
				if string.find("ENC MAG WIZ", classShortName(i)) ~= nil then
					ivuer = i
					if i == inver then
						print("\arUnable to Double Invis")
						mq.exit()
					end
					break
				end
			end
		end

		--catch anyone else in group
		if
			string.find("WAR MNK ROG BER", classShortName(inver)) ~= nil
			or string.find("WAR MNK ROG BER", classShortName(ivuer)) ~= nil
		then
			print("\arUnable to Double Invis")
			mq.exit()
		end

		print(
			"\ag-->\atINVer: \ay",
			mq.TLO.Group.Member(inver).Name(),
			"\at IVUer: \ay",
			mq.TLO.Group.Member(ivuer).Name(),
			"\ag<--"
		)

		--if i am group leader and can INVIS, then do the INVIS thing
		if classShortName(inver) == "SHM" and inver == 0 then
			mq.cmd("/multiline ; /stopcast; /timed 3 /alt act 630")
		elseif string.find("ENC MAG WIZ", classShortName(inver)) ~= nil then
			mq.cmd("/multiline ; /stopcast; /timed 1 /alt act 1210")
		elseif string.find("RNG DRU", classShortName(inver)) ~= nil then
			mq.cmd("/multiline ; /stopcast; /timed 1 /alt act 518")
		end

		--if i have an INVISER in the group, then 'tell them' do the INVIS thing
		if classShortName(inver) == "SHM" and inver ~= 0 then
			tell(4, inver, 630)
		elseif string.find("ENC MAG WIZ", classShortName(inver)) ~= nil then
			tell(0, inver, 1210)
		elseif string.find("RNG DRU", classShortName(inver)) ~= nil then
			tell(5, inver, 518)
		end

		--if i am group leader and can IVU, then do the IVU thing
		if string.find("CLR NEC PAL SHD", classShortName(ivuer)) ~= nil and ivuer == 0 then
			mq.cmd("/multiline ; /stopcast; /timed 1 /alt activate 1212")
		else
			mq.cmd("/multiline ; /stopcast; /timed 1 /alt activate 280")
		end

		--if i have an IVUER in the group, then 'tell them' do the IVU thing
		if string.find("CLR NEC PAL SHD", classShortName(ivuer)) ~= nil and ivuer ~= 0 then
			tell(2, ivuer, 1212)
		else
			tell(2, ivuer, 280)
		end
	end
	mq.delay(8000)
end

--main loop here
--[[while true do
    while not all_double_invis() do
        the_invis_thing()
        mq.delay(5000)
    end
    print('\ay-->\atGroup Invis: \agSuccess\ay<--')
    mq.exit()
end--]]
----------------------------------------End of Hylander's Double Invis Lua-----------------------------------------------------------------

------------------------------------------Start Shei Camp Lua - Aaly ------------------------------------------------------

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

local function gmDistanceME()
	local GroupSize = mq.TLO.Group.Members()
	for g = 1, GroupSize, 1 do
		local MemberDistance = mq.TLO.Group.Member(g).Distance()
		while MemberDistance > 20 do
			local isMoving = mq.TLO.Group.Member(g).Moving()
			local Member = mq.TLO.Group.Member(g).Name()
			if not isMoving then
				mq.cmdf("/multiline ; /dex %s /target Elisel ; /timed 10 /dex %s /nav target", Member, Member)
			end
			mq.delay(1000)
		end
	end
end

local function comeToMe()
	print("In comeToMe")
	if mq.TLO.Group.AnyoneMissing() == false then
		local MeID = mq.TLO.Me.ID()
		local GroupSize = mq.TLO.Group.Members()
		for g = 1, GroupSize, 1 do
			local MemberDistance = mq.TLO.Group.Member(g).Distance()
			local Member = mq.TLO.Group.Member(g).Name()
			local Toon = mq.TLO.Group.Member(g)
			while Toon.Distance() > 20 do
				local isMoving = mq.TLO.Group.Member(g).Moving()
				if not isMoving then
					mq.cmdf("/dex %s /nav spawn id %s", Member, MeID)
					mq.delay(1000)
				end
			end
		end
	end
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

--This is Calling Hylander's doubleinvis Lua, which is above. This is a function to double invis.
local function DBLinvis()
	print("\apIn DBLinvis")
	while not all_double_invis() do
		the_invis_thing()
		mq.delay(5000)
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

	if mq.TLO.Target.CleanName() ~= npcName then
		mq.cmdf("/target %s", npcName)
		mq.delay(1000)
	end

	if mq.TLO.Target.Distance() > 30 then
		mq.cmd("/boxr pause")
		mq.delay(1000)
		--comeToMe()
		--DBLinvis()
		print("\apMoving To Elisel")
		mq.cmdf("/nav spawn %s", npcName)
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

	if myZone == 859 and mq.TLO.Target.Distance() <= 30 then
		if mq.TLO.Task("Heroes Are Forged").ID() == nil then
			print("\apLooks Like We Dont Have Our Task, Lets Fix That!")
			mq.delay(1000)
			mq.cmdf("/%s mode 0", myClass)
			mq.delay(1000)
			mq.cmd("/dgga /boxr pause")
			mq.delay(1000)
			MakeMeVis()
			mq.delay(1000)
			if mq.TLO.Target.CleanName() ~= npcName then
				mq.cmdf("/target %s", npcName)
			end
			mq.delay(2000)
			mq.cmd("/say small")
			mq.delay(5000)
			gotMission = true
		end
	end
end

local function zoneIn()
	if myZone == 859 then
		print("\apZoning group into the instance")
		local GroupSize = mq.TLO.Group.Members()
		if mq.TLO.Task("Heroes Are Forged").ID() ~= nil then
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
	print("\apIn Drop Task")
	print("\apWe Have Reached The End Of Our Time Here")
	mq.cmdf("/%s mode tank", myClass)
	while mq.TLO.Me.CombatState() == "COMBAT" do
		mq.delay(1000)
	end
	while mq.TLO.Task("Heroes Are Forged").ID() and mq.TLO.Me.CombatState() ~= "COMBAT" do
		mq.delay(1000)
		mq.cmd("/kickp t")
		mq.delay(1000)
		mq.cmd("/yes")
		gotMission = false

		mq.delay(60000)
	end
end

------------------------------- EXECUTION

local Run = true

--main loop
while Run == true do
	if mq.TLO.Zone.ID() == 859 then
		print("Beginning Laurion Inn zone routine")
		CheckMissingGroupMembers()
		getMissionFromNPCRoutine()
		SetCamp = true
		mq.delay(15000)
	else
		if mq.TLO.Zone.ID() == 862 and mq.TLO.Task("Heroes Are Forged").ID() ~= nil then
			--print("In active hunting portion of main loop")
			while SetCamp == true do
				MoveToCampAndBeginGrind()
			end
			local minutesRemainingBeforeEndingGrind = 360 - minutesToGrindPerInstance

			if mq.TLO.Task("Heroes Are Forged").ID() ~= nil then
				-- Change the Time here based on when you want to exit
				-- Leaving early prevents getting stuck with the task after completion
				while mq.TLO.Task("Heroes Are Forged").Timer.TotalMinutes() >= minutesRemainingBeforeEndingGrind do
					--print("In main GRIND portion of main loop")
					mq.delay(1000)
				end
				-- Make sure to change that time here as well!
				if mq.TLO.Task("Heroes Are Forged").Timer.TotalMinutes() <= minutesRemainingBeforeEndingGrind then
					print("Time is up, beginning Drop routine.")
					DropTask()
				end
			end
		--elseif mq.TLO.Zone.ID() ~= 862 then
		--	print("Not in the target grind zone yet")
		--elseif mq.TLO.Task("Heroes Are Forged").ID() == nil then
		--	print("We don't have the task")
		else
			print("Should never get here MAIN LOOP")
		end
	end
end
