---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

local function IAmDriver()
	local driver = mq.TLO.Group.MainTank()
	if driver == mq.TLO.Me.CleanName() then
		return true
	else
        --return false
		return true -- i don't think i like this function at all anymore
	end
end

local function boxPrep()
	if not IAmDriver() then
		return
	end
	
	mq.cmd("/dg /assist off")
	local assistName = mq.TLO.Group.MainTank.CleanName()

	mq.cmdf("/dge /assist %s", assistName)
	mq.delay(1500)
	mq.cmd("/dg /makemevisible")
	mq.delay(1500)
end

local function sayCommandHandler(...)
    if not IAmDriver() then
	
		return
	end
	
	local args = { ... }
	
	boxPrep()
	
	-- make our full phrase
	local sayPhrase = table.concat(args, " ")
	
	mq.cmd("/dg /say " .. sayPhrase)
	mq.delay(500)
end

mq.bind("/asay param", sayCommandHandler)

mq.bind("/ahail", function()
	boxPrep()
    mq.cmdf("/dge /assist %s", mq.TLO.Me.CleanName())
	mq.delay(1500)
	mq.cmd("/dg /keypress HAIL")
	mq.delay(100)
end)


mq.bind("/allmount", function()
    
    if mq.TLO.Me.Mount() and  mq.TLO.Me.Mount.ID() > 1 then
        BL.info("Already mounted")
        return
    end
    
    local mountItem = mq.TLO.Mount(1)
    mq.cmdf("/dg")
    
    mq.cmd("/dg /keypress HAIL")
    mq.delay(100)
end)

local groundSpawnPickupMatcherText = "#*#GROUNDPICKUP #1# #2#.#*#"
-- GROUNDPICKUP CHARACTERNAME ITEMNAME. (note the period)
mq.event("GroundSpawnPickup", groundSpawnPickupMatcherText, function(line, charname, itemname)
	if charname ~= mq.TLO.Me.CleanName() then
		-- Someone else's turn to loot this one
		return
	end
	mq.cmdf("/fs Doing Grab for %s", charname)

	local grounditem = mq.TLO.Ground.Search(itemname)
	if BL.IsNil(grounditem) then
		BL.warn("Ground item not found, we shouldn't be here in this event handler right now")
		mq.delay(1500)
		return
	end

	grounditem.Grab()
	mq.delay(1500)
	if mq.TLO.Cursor() == nil then
		BL.warn("Cursor is nil, so I couldn't grab the item!")
		mq.cmd("/g Cursor is nil, so I couldn't grab the item!")
		mq.delay(1500)
	else
		mq.cmd("/g Cursor is not nil, so I grabbed the item!")
	end
	mq.cmd("/autoinventory")
	mq.delay(1500)
	mq.cmdf("/fs Done Grab for %s", charname)
end)

local function leadCharacterThroughLootProcess(characterName, spawnName)
	BL.info("Sending %s to loot ground item %s once it spawns", characterName, spawnName)
	local itsMeLooting = false

	-- Have driver search the whole zone for the ground spawn, but the rest
	-- must wait on that specific one to respawn so we don't have to worry about nav'ing to them
	local searchRadius = ""
	if characterName == mq.TLO.Me.CleanName() then
		itsMeLooting = true
		searchRadius = " radius 9999"
	else
		searchRadius = " radius 30"
	end
	local groundItem = mq.TLO.Ground.Search(spawnName .. searchRadius)

	-- only spew once per character instead of inside while loop
	if BL.IsNil(groundItem()) then
		BL.info("Ground item not found, waiting for spawn")
	end

	while BL.IsNil(groundItem()) do
		mq.delay(1500)
		groundItem = mq.TLO.Ground.Search(spawnName)
	end

	local groundID = groundItem.ID()
	local groundX = groundItem.X()
	local groundY = groundItem.Y()
	local groundZ = groundItem.Z()

	BL.info(
		"Ground item Spawned! %s with ID %s, Position: <%d, %d, %d>",
		groundItem or "NILNILNIL",
		tostring(groundID or "NOID"),
		groundX or -9876,
		groundY or -9865,
		groundZ or -9854
	)

	-- nav to ground item
	BL.info("Nav to ground item")
	-- Move driver to the item and wait until nav'd there, boxes should be on /chase
	mq.cmdf("/nav locxyz %d %d %d", groundX, groundY, groundZ)
	BL.WaitForNav()
	if not itsMeLooting then
		--everyone else should already be there since self goes first, but we'll give them a bump anyway
		mq.cmdf("/dex %s /nav locxyz %d %d %d", characterName, groundX, groundY, groundZ)
		mq.delay(2000)
	end

	BL.info("Nav to ground item complete")

	-- emit event to be caught by that box's version of the script, ghettoactor
	mq.cmdf("/fs GROUNDPICKUP %s %s.", characterName, spawnName)
end

local GroupCache = {
	"",
	"",
	"",
	"",
	"",
	"",
}

local function InitializeGroupCache()
	GroupCache[1] = mq.TLO.Group.Member(0).CleanName()
	GroupCache[2] = mq.TLO.Group.Member(1).CleanName() or "NONE"
	GroupCache[3] = mq.TLO.Group.Member(2).CleanName() or "NONE"
	GroupCache[4] = mq.TLO.Group.Member(3).CleanName() or "NONE"
	GroupCache[5] = mq.TLO.Group.Member(4).CleanName() or "NONE"
	GroupCache[6] = mq.TLO.Group.Member(5).CleanName() or "NONE"
	
	local myName = mq.TLO.Me.CleanName()
	if GroupCache[1] ~= myName then
		-- its not me, so lets find me
		for i = 2, 6 do
			if GroupCache[i] == myName then
				-- swap me to the front2
				GroupCache[i] = GroupCache.member1
				GroupCache[1] = myName
				break
			end
		end
	end
end

local function groundSpawnPickupCommandHandler(...)
	local args = { ... }

	local spawn = args[1]
	InitializeGroupCache()

	BL.cmd.pauseAutomation()
	mq.delay(1500)

	-- foreach group member once spawn is spawned, send the event to them
	for _, memberName in ipairs(GroupCache) do
		if memberName and memberName ~= "NONE" then
			BL.info("Starting loot proceess for %s", memberName)
			leadCharacterThroughLootProcess(memberName, spawn)
			--give the box time to loot
			mq.delay(5000)
		end
	end
	BL.info("Ground Spawn Process Completed!")
	mq.cmd("/fs Ground Spawn Process Completed!")
	BL.cmd.resumeAutomation()
end

mq.bind("/aground", groundSpawnPickupCommandHandler)

local function allGiveItemToTargetHandler(...)
	local args = { ... }

	--local itemName = args[1]
	BL.cmd.pauseAutomation()
	-- make our full phrase
	local itemName = table.concat(args, " ")

	-- target the right npc
	mq.cmdf("/dge /assist %s", mq.TLO.Me.CleanName())
	mq.delay(1500)

	-- get really close
	BL.info("Navving to target")
	mq.cmd("/dg /nav target")
	BL.MakeGroupVisible()

	mq.delay(2000)
	-- give him item somehow
	BL.info("Picking up item onto cursor")
	-- note the escaped quotation marks, these are requiree
	mq.cmdf('/dg /itemnotify "%s" leftmouseup', itemName)
	mq.delay(500)
	mq.cmdf("/dg /click left target")
	mq.delay(500)
	-- click givewnd
	mq.cmdf("/dg /notify GiveWnd GVW_Give_Button leftmouseup")
	mq.delay(1500)
	
	--BL.cmd.resumeAutomation()
	-- /z
end
mq.bind("/agive", allGiveItemToTargetHandler)

-------------------------------------------------------------------
BL.log.info(
	"Allsay running! Use /asay phrase to have your group assist your tank for target, uninvis, and all say the given phrase.  Use /ahail to have group hail the target. Use /aground <ground spawn item name> to have group iteratively loot a ground spawn by name."
)

while true do
	mq.doevents()
	mq.delay(546)
end
