---@type Mq
local mq = require("mq")
local BL = require("biggerlib")
local actors = require('actors')

local actor = {}

local State = {
    hailTarget = nil,
    sayTarget = nil,
    sayPhrase = "",
    doAllMount = false,
    --
    giveItemName = "",
    giveItemTargetId = nil
}

local function IAmDriver()
	local driver = mq.TLO.Group.MainTank()
	if driver == mq.TLO.Me.CleanName() then
		return true
	else
        --return false
		return true -- i don't think i like this function at all anymore
	end
end

local function removeInvis()
    mq.cmd("/makemevisible")
    mq.delay(1)
end

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

local function doGiveItemToTarget()
    BL.cmd.pauseAutomation()
    while mq.TLO.Cursor() and  mq.TLO.Cursor.ID() > 1 do
        mq.cmd("/autoinventory")
        mq.delay(250)        
    end
    -- target the right npc
    --mq.cmdf("/dge /assist %s", mq.TLO.Me.CleanName())
    targetSpawn = mq.TLO.Spawn("id "..State.giveItemTargetId)
    targetSpawn.DoTarget()
    mq.delay(1)

    -- get really close
    BL.info("Navving to target")
    mq.cmd("/dg /nav target")
    BL.MakeGroupVisible()

    mq.delay(2000)
    -- give him item somehow
    -- note the escaped quotation marks, these are requiree
        mq.cmdf('/shift /itemnotify "%s" leftmouseup', State.giveItemName)
        BL.info("Picking up item onto cursor")
        mq.delay(500)
    
    if not mq.TLO.Cursor.ID() then
        mq.cmd("/g I couldn't pick the item up from inventory")
    end
    
    mq.cmdf("/click left target")
    mq.delay(500)
    -- click givewnd
    mq.cmdf("/notify GiveWnd GVW_Give_Button leftmouseup")
    mq.delay(1500)

    BL.cmd.resumeAutomation()
    State.giveItemName = ""
    State.giveItemTargetId = nil
end

local function allGiveItemToTargetHandler(...)
	local args = { ... }

	--local itemName = args[1]
    -- make our full phrase
    local itemName = ""
        
    if mq.TLO.Cursor.ID() > 1 then 
        itemName = mq.TLO.Cursor.Name()
    else
        itemName = table.concat(args, " ")
    end
   BL.info("Sending allgive for %s", itemName)
   actor:send({id='allgive', giveItemTargetId = mq.TLO.Target.ID(), giveItemName = itemName})
end
mq.bind("/agive", allGiveItemToTargetHandler)

---------------------------------------------------------------------------

local function DoHail()
    removeInvis()
    State.hailTarget.DoTarget()
    mq.delay(1)
    mq.cmd("/keypress HAIL")
    mq.delay(500)
    State.hailTarget = nil
end

mq.bind("/ahail", function()
    actor:send({id='allhail', targetId = mq.TLO.Target.ID()})
end)

local function DoAllSay()
    removeInvis()
    
    State.sayTarget.DoTarget()
    mq.delay(1)

    mq.cmd("/say " .. State.sayPhrase)
    mq.delay(500)
    State.sayTarget = nil
end
mq.bind("/asay param", function(...)    
    -- make our full phrase
    local args = { ... }
    local sayPhrase = table.concat(args, " ")
    
    actor:send({id='allsay', targetId = mq.TLO.Target.ID(), sayPhrase = sayPhrase})
end)

local function DoAllMount()
    mq.cmd("/dismount")
    mq.delay(10)
    mq.cmd("/removebuff summon drogmor")
    mq.delay(10)
    mq.cmd("/removebuff mount blessing")
    mq.delay(50)
    
    mq.cmd("/keypress =")
    mq.delay(4000)
   
    while not mq.TLO.Me.Mount() do
        mq.cmd("/keypress =")
        mq.delay(4000)
    end
    mq.cmd("/g Mounted!")
    State.doAllMount = false
end



mq.bind("/allmount", function()
   actor:send({id='allmount'})
end)

-------------------------------------------------------------------

actor = actors.register(function(message)
    if message.content.id == 'allhail' then
        State.hailTarget = mq.TLO.Spawn("id " .. message.content.targetId)
    elseif message.content.id == 'allsay' then
        State.sayPhrase = message.content.sayPhrase       
        State.sayTarget = mq.TLO.Spawn("id " .. message.content.targetId)
    elseif message.content.id == 'allmount' then
        State.doAllMount = true
    elseif message.content.id == 'allgive' then
        State.giveItemName = message.content.giveItemName
        State.giveItemTargetId = message.content.giveItemTargetId
    end
end)

BL.log.info(
	"Allsay running! Use /asay phrase to have your group assist your tank for target, uninvis, and all say the given phrase.  Use /ahail to have group hail the target. Use /aground <ground spawn item name> to have group iteratively loot a ground spawn by name."
)

local function Tick()
    -- Do hails
    if BL.NotNil(State.hailTarget) then
        DoHail()
    end
    
    if BL.NotNil(State.sayTarget) then
        DoAllSay()
    end
    
    if State.doAllMount then
        DoAllMount()
    end
    
    if State.giveItemName and State.giveItemName ~= "" and State.giveItemTargetId ~= nil then 
        doGiveItemToTarget()
    end 
    
end

while true do
    mq.doevents()
    Tick()
	mq.delay(546)
end
