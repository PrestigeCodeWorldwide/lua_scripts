local mq = require("mq")
local BL = require("biggerlib")

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
	--make them all stop attacking
	mq.cmd("/dgga /attack off")
	mq.delay(100)
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

local function MakeAllVis()
	mq.cmd("/dga /makemevis")
end

local function RemoveLev()
	mq.cmd("/dga /removelev")
end

local function DoDoubleInvis()
	while not all_double_invis() do
		the_invis_thing()
		mq.delay(5000)
	end
	BL.info("\agDone Invising the group!")
end

mq.bind("/doubleinvis", DoDoubleInvis)
mq.bind("/makeallvis", MakeAllVis)
mq.bind("/removealllev", RemoveLev)

BL.info("\agInvis utils loaded, use /doubleinvis /makeallvis /removealllev")
while true do
	mq.delay(5000)
end
