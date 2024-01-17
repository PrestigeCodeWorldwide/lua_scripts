---@type Mq
local mq = require('mq')
--- @type ImGui
require('ImGui')
local BL = require('biggerlib')

-- #region DoubleInvis

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
		'/timed %s /dex %s /multiline ; /stopcast; /timed 1 /alt act %s',
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
		local result1 = query(name, 'Me.Invis[1]', 100)
		local result2 = query(name, 'Me.Invis[2]', 100)
		local both_result = false

		if result1 == 'TRUE' and result2 == 'TRUE' then
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
	if mq.TLO.Spawn('Group Bard').ID() > 0 then
		local bard = mq.TLO.Spawn('Group Bard').Name()
		if bard == mq.TLO.Me.Name() then
			mq.cmd('/mutliline ; /stopsong; /timed 1 /alt act 3704; /timed 3 /alt act 231')
		else
			mq.cmdf(
				'/dex %s /multiline ; /stopsong; /timed 1 /alt act 3704; /timed 3 /alt act 231',
				bard
			)
		end
		print('\ag-->\atINVer: \ay', bard, '\at IVUer: \ay', bard, '\ag<--')
	else
		--without a bard, find who can invis and who can IVU
		local inver = 0
		local ivuer = 0
		local grpsize = mq.TLO.Group.Members()

		--check classes that can INVIS only
		for i = 0, grpsize do
			if string.find('RNG DRU SHM', classShortName(i)) ~= nil then
				inver = i
				break
			end
		end

		--check classes that can IVU only
		for i = 0, grpsize do
			if string.find('CLR NEC PAL SHD', classShortName(i)) ~= nil then
				ivuer = i
				break
			end
		end

		--check classes that can do BOTH
		if inver == 0 then
			for i = 0, grpsize do
				if string.find('ENC MAG WIZ', classShortName(i)) ~= nil then
					inver = i
					break
				end
			end
		end

		if ivuer == 0 then
			for i = grpsize, 0, -1 do
				if string.find('ENC MAG WIZ', classShortName(i)) ~= nil then
					ivuer = i
					if i == inver then
						print('\arUnable to Double Invis')
						mq.exit()
					end
					break
				end
			end
		end

		--catch anyone else in group
		if
			string.find('WAR MNK ROG BER', classShortName(inver)) ~= nil
			or string.find('WAR MNK ROG BER', classShortName(ivuer)) ~= nil
		then
			print('\arUnable to Double Invis')
			mq.exit()
		end

		print(
			'\ag-->\atINVer: \ay',
			mq.TLO.Group.Member(inver).Name(),
			'\at IVUer: \ay',
			mq.TLO.Group.Member(ivuer).Name(),
			'\ag<--'
		)

		--if i am group leader and can INVIS, then do the INVIS thing
		if classShortName(inver) == 'SHM' and inver == 0 then
			mq.cmd('/multiline ; /stopcast; /timed 3 /alt act 630')
		elseif string.find('ENC MAG WIZ', classShortName(inver)) ~= nil then
			mq.cmd('/multiline ; /stopcast; /timed 1 /alt act 1210')
		elseif string.find('RNG DRU', classShortName(inver)) ~= nil then
			mq.cmd('/multiline ; /stopcast; /timed 1 /alt act 518')
		end

		--if i have an INVISER in the group, then 'tell them' do the INVIS thing
		if classShortName(inver) == 'SHM' and inver ~= 0 then
			tell(4, inver, 630)
		elseif string.find('ENC MAG WIZ', classShortName(inver)) ~= nil then
			tell(0, inver, 1210)
		elseif string.find('RNG DRU', classShortName(inver)) ~= nil then
			tell(5, inver, 518)
		end

		--if i am group leader and can IVU, then do the IVU thing
		if string.find('CLR NEC PAL SHD', classShortName(ivuer)) ~= nil and ivuer == 0 then
			mq.cmd('/multiline ; /stopcast; /timed 1 /alt activate 1212')
		else
			mq.cmd('/multiline ; /stopcast; /timed 1 /alt activate 280')
		end

		--if i have an IVUER in the group, then 'tell them' do the IVU thing
		if string.find('CLR NEC PAL SHD', classShortName(ivuer)) ~= nil and ivuer ~= 0 then
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
-- #endregion DoubleInvis

------------------------------------------Start Shei Camp Lua - Aaly ------------------------------------------------------
-- Information for Quest NPC
local npcName = 'Shalowain'
--local npcID = 5033
--To Identify our class shortname
local myClass = mq.TLO.Me.Class.ShortName()
local myZone = mq.TLO.Zone.ID()
local function gmDistanceME()
	local GroupSize = mq.TLO.Group.Members()
	for g = 1, GroupSize, 1 do
		local MemberDistance = mq.TLO.Group.Member(g).Distance()
		while MemberDistance > 20 do
			local isMoving = mq.TLO.Group.Member(g).Moving()
			local Member = mq.TLO.Group.Member(g).Name()
			if not isMoving then
				mq.cmdf(
					'/multiline ; /dex %s /target Shalowain ; /timed 10 /dex %s /nav target',
					Member,
					Member
				)
			end
			mq.delay(1000)
		end
	end
end

local function gmDistanceInstance()
	local GroupSize = mq.TLO.Group.Members()
	for g = 1, GroupSize, 1 do
		local MemberDistance = mq.TLO.Group.Member(g).Distance()
		local Member = mq.TLO.Group.Member(g).Name()
		local Toon = mq.TLO.Group.Member(g)
		while Toon.Distance() > 20 do
			local isMoving = mq.TLO.Group.Member(g).Moving()
			if not isMoving then
				mq.cmdf('/dex %s /nav locxy -521.27 -309.95', Member)
			end
			mq.delay(1000)
		end
	end
end
local function comeToMe()
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
					mq.cmdf('/dex %s /nav spawn id %s', Member, MeID)
					mq.delay(1000)
				end
			end
		end
	end
end
--This checks to see if i am moving and will wait to continue
local function WaitOnNav()
	print('\apStill Moving!')
	while mq.TLO.Me.Moving() do
		mq.delay(1000)
	end
end

-- This is checking if everyone in group is in zone, if not we waiting
local function Missing()
	print('In Missing')
	if mq.TLO.Group.AnyoneMissing() == true then
		print('\apWe Seem To Be Missing Some Group Members')
		print('\apLets Give Them A Moment To Zone In')
		while mq.TLO.Group.AnyoneMissing() == true do
			mq.delay(5000)
		end
	end
end

--This is Calling Hylander's doubleinvis Lua, which is above. This is a function to double invis.
local function DBLinvis()
	while not all_double_invis() do
		the_invis_thing()
		mq.delay(5000)
	end
end

--This is to make us drop invis
local function MakeMeVis()
	mq.cmd('/dgga /makemevis')
end

local function amIClose()
	mq.cmd('/boxr pause')
	if mq.TLO.Target.CleanName() ~= npcName then
		print('\apI Am Not Close Enough To, targeting: ' .. npcName)
		mq.cmdf('/target %s', npcName)
		mq.delay(1000)
	end

	print('\apMoving To Shalowain')
	mq.cmd('/nav target')
	WaitOnNav()
end

local function getTask()
	if myZone == 859 and mq.TLO.Target.Distance() <= 30 then
		if mq.TLO.Task('Final Fugue').ID() == nil then
			print('\apLooks Like We Dont Have Our Task, Lets Fix That!')
			mq.delay(1000)
			mq.cmdf('/%s mode 0', myClass)
			mq.delay(1000)
			mq.cmd('/dgga /boxr pause')
			mq.delay(1000)
			MakeMeVis()
			mq.delay(1000)
			if mq.TLO.Target.CleanName() ~= npcName then
				mq.cmdf('/target %s', npcName)
			end
			mq.delay(2000)
			mq.cmd('/say smaller')
			mq.delay(5000)
		end
	end
end

local function zoneIn()
	--if myZone == 859 then
	local GroupSize = mq.TLO.Group.Members()
	if mq.TLO.Task('Final Fugue').ID() ~= nil then
		print('\apWaiting For DynamicZone Flagging, Stand By!')
		while not mq.TLO.DynamicZone.Leader.Flagged() do
			mq.delay(15000)
		end
		for g = 1, GroupSize, 1 do
			local Member = mq.TLO.Group.Member(g).Name()
			print('\ay-->', Member, '<--', '\apShould Be Zoning In Now')
			mq.cmdf('/dex %s /travelto pallomen', Member)
		end
		-- This is to make us the last to zone in
		while mq.TLO.Group.AnyoneMissing() == false do
			mq.delay(2000)
		end
		mq.cmd('/travelto pallomen')
	end
	--end
end

--This is to nav to NPC, get Shei mission and zone in.
local function inME()
	amIClose()
	mq.delay(1000)
	getTask()
	zoneIn()
end
--Setting Puller Settings
local function SetPullSettings()
	print('\apSetting Puller Settings')
	mq.cmdf('/%s pullradius 500', myClass)
	mq.cmdf('/%s pullarch 360', myClass)
	mq.cmdf('/%s zHigh 100', myClass)
	mq.cmdf('/%s zLow 100', myClass)
	-- Watch CC&Healer Mana

	mq.cmdf('/%s mode pullertank', myClass)
	mq.cmdf('/%s pause off', myClass)
end

--Variable for our MoveToCamp, to stop it from repeating
local SetCamp = true

-- This is going to drop our task for us safely
local function DropTask()
	print('\apWe Have Reached The End Of Our Time Here')
	print('\apTime To Blow This Popsicle Stand!')
	mq.cmdf('/%s mode tank', myClass)
	while mq.TLO.Me.CombatState() == 'COMBAT' do
		mq.delay(1000)
	end
	while mq.TLO.Task('Final Fugue').ID() and mq.TLO.Me.CombatState() ~= 'COMBAT' do
		mq.delay(1000)
		mq.cmd('/kickp task')
		mq.delay(1000)
		mq.cmd('/yes')
		mq.delay(60000)
	end
end

-- This is once zoned into instance to wait for all to zone in, double invis, then nav to camp area.
local function MoveToCamp()
	Missing()
	mq.cmd('/dgge /boxr unpause')
	mq.delay(2000)
	mq.cmd('/dgge /boxr chase')
	mq.delay(1000)
	print('\apWe Are Going Into Tank Mode to Ensure We Don\'t Have A Suprise Guest')
	mq.cmdf('/%s mode tank', myClass)
	mq.cmdf('/%s pause off', myClass)
	MakeMeVis()
	print('\apAllowing Time to Buff')
	-- Change this delay to increase buff time or to help with Meding to full
	mq.delay(3000)
	--SetPull()
	SetCamp = false
end

local Run = true

local function SetIgnores()
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
	mq.cmdf('/%s ignore "Captain Kar the Unmovable"', myClass)
end

SetIgnores()

--- @class WaypointStep
--- @field loc string

--- @type WaypointStep[]
local WaypointSteps = {}
local CurrentWaypointStep = 1

local function SetPalTestWaypoints()
	table.insert(WaypointSteps, '-417, 797, -17.66')
	table.insert(WaypointSteps, '-348, 961, -22.62')
	table.insert(WaypointSteps, '1247, 254, 31')
end

local function AddWaypointStep()
	local loc = mq.TLO.Me.LocYXZ()
	table.insert(WaypointSteps, loc)
end

local function GetDistanceFromTwoLocYXZ(loc1, loc2)
	local coords = loc1 .. ':' .. loc2
	local distToWaypoint = mq.TLO.Math.Distance(coords)()
	BL.dump(distToWaypoint, 'distToWaypoint')
	return distToWaypoint
end

local function CheckNavArrived()
	local loc1 = mq.TLO.Me.LocYXZ()
	local loc2 = WaypointSteps[CurrentWaypointStep]
	local distToWaypoint = GetDistanceFromTwoLocYXZ(loc1, loc2)
	BL.dump(distToWaypoint, 'distToWaypoint')
	return distToWaypoint < 20
end

local function StartNavToCurrentWaypoint()
	local loc = WaypointSteps[CurrentWaypointStep]
	mq.cmdf('/nav locyxz %s', loc)
end

local function AdvanceCurrentWaypoint() end

local function CheckWaypointListIsCompleted()
	if CurrentWaypointStep >= #WaypointSteps then
		return true
	end
	return false
end

-- Runs once we arrive at a waypoint, go into camp mode and pull all the stuff
local function PullNearbyThings()
	mq.cmd('/dgga /boxr camp')
	mq.delay(1000)
	mq.cmd('/dgga /boxr unpause')
	mq.delay(1000)
	SetPullSettings()

	-- figure out when we're out of mobs to pull.
	while mq.TLO.SpawnCount('npc targetable radius 500 zradius 100')() > 1 do
		mq.delay(1000)
	end
end

local function PROCEED()
	--sanity check
	if CheckWaypointListIsCompleted() then
		BL.error('PROCEED() called when waypoint list is already completed!')
		return
	end

	-- Here we check to see if we're in combat, if not we check for next waypoint to travel to
	while mq.TLO.Me.CombatState() == 'COMBAT' do
		BL.info('In combat')
		if mq.TLO.Navigation.Active() then
			mq.cmd('/nav stop')
			mq.delay(500)
		end
		mq.cmd('/dgga /boxr unpause')
		mq.delay(1000)
		mq.cmd('/dgge /boxr chase')
		mq.delay(1000)
		local myClassShortNameToLower = mq.TLO.Me.Class.ShortName():lower()
		mq.cmdf('/%s mode tank ', myClassShortNameToLower)
		mq.delay(1000)
	end

	if not mq.TLO.Navigation.Active() then
		BL.info('Nav isn\'t active')
		local weArrived = CheckNavArrived()
		--if its not active because we've reached the waypoint, move to next waypoint
		if weArrived then
			PullNearbyThings()
			AdvanceCurrentWaypoint()
		else
			--if its not active because we're not moving, start moving
			StartNavToCurrentWaypoint()
		end
	end

	-- check to see if we've finished all waypoints
	--CheckWaypointListIsCompleted()
end

-- laurioninn is 859
-- pal/lomen is 861 (pallomen)
--main loop

SetPalTestWaypoints()

while Run == true do
	--local coords = "-970, 164, 48.66" .. ":" .. mq.TLO.Me.LocYXZ()
	--local distToWaypoint = mq.TLO.Math.Distance(coords)

	--local currentWPString = coords
	----BL.dump(currentWPString, "currentWPString")
	--mq.cmdf("/nav locyxz %s", currentWPString)
	--mq.delay(1000)

	--if distToWaypoint < 20 then
	--	--move to next waypoint
	--end

	if mq.TLO.Zone.ID() == 859 then
		--print("In Inn")
		Missing()
		inME()
		SetCamp = true
		mq.delay(15000)
	else
		--print("In else")
		if mq.TLO.Zone.ID() == 861 and mq.TLO.Task('Final Fugue').ID ~= nil then
			--print("In Pallomen")
			while SetCamp == true do
				MoveToCamp()
				BL.info('Done moving to camp')
				mq.cmd('/nav stop')
				mq.delay(50)
			end
			if mq.TLO.Task('Final Fugue').ID() ~= nil then
				-- Change the Time here based on when you want to exit
				-- Leaving early prevents getting stuck with the task after completion
				while
					mq.TLO.Task('Final Fugue').Timer.TotalMinutes() >= 240
					and not CheckWaypointListIsCompleted()
				do
					BL.info('PROCEEDing')
					PROCEED()
					mq.delay(1000)
				end
				-- Make sure to change that time here as well!
				if
					mq.TLO.Task('Final Fugue').Timer.TotalMinutes() <= 240
					or CheckWaypointListIsCompleted()
				then
					DropTask()
				end
			end
		end
	end
end
-- pallomen
