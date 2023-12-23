---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

local function boxPrep()
	mq.cmd("/dgga /assist off")
	mq.cmd("/dgge /boxr pause")
	mq.delay(1000)

	local assistName = mq.TLO.Group.MainTank.CleanName()

	mq.cmdf("/dgge /assist %s", assistName)
	mq.delay(500)
	mq.cmd("/dgga /makemevisible")
	mq.delay(500)
end

local function sayCommandHandler(...)
	local args = { ... }

	boxPrep()

	-- make our full phrase
	local sayPhrase = table.concat(args, " ")

	mq.cmd("/dgga /say " .. sayPhrase)
	mq.delay(500)
	mq.cmd("/dgga /boxr unpause")
end

mq.bind("/asay param", sayCommandHandler)

mq.bind("/ahail", function()
	boxPrep()

	mq.cmd("/dgga /keypress HAIL")
	mq.delay(500)
	mq.cmd("/dgga /boxr unpause")
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
		mq.delay(1000)
		return
	end

	grounditem.Grab()
	mq.delay(1000)
	mq.cmd("/autoinventory")
	mq.delay(1000)
	mq.cmdf("/fs Done Grab for %s", charname)
	mq.cmd("/boxr unpause")
end)

local function leadCharacterThroughLootProcess(characterName, spawnName)
	BL.info("Sending %s to loot ground item %s once it spawns", characterName, spawnName)

	local groundItem = mq.TLO.Ground.Search(spawnName)

	-- only spew once per character instead of inside while loop
	if BL.IsNil(groundItem()) then
		BL.info("Ground item not found, waiting for spawn")
	end

	while BL.IsNil(groundItem()) do
		mq.delay(1000)
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
	-- Pause automation
	mq.cmdf("/dex %s /boxr pause", characterName)
	mq.delay(1000)

	-- nav to ground item
	BL.info("Nav to ground item")
	mq.cmdf("/dex %s /nav locxyz %d %d %d", characterName, groundX, groundY, groundZ)
	mq.delay(3000)
	BL.info("Nav to ground item complete")

	-- emit event to be caught by that box's version of the script, ghettoactor
	mq.cmdf("/fs GROUNDPICKUP %s %s.", characterName, spawnName)
end

local GroupCache = {
	member1 = "",
	member2 = "",
	member3 = "",
	member4 = "",
	member5 = "",
	member6 = "",
}

local function InitializeGroupCache()
	GroupCache.member1 = mq.TLO.Group.Member(0).CleanName()
	GroupCache.member2 = mq.TLO.Group.Member(1).CleanName() or "NONE"
	GroupCache.member3 = mq.TLO.Group.Member(2).CleanName() or "NONE"
	GroupCache.member4 = mq.TLO.Group.Member(3).CleanName() or "NONE"
	GroupCache.member5 = mq.TLO.Group.Member(4).CleanName() or "NONE"
	GroupCache.member6 = mq.TLO.Group.Member(5).CleanName() or "NONE"
end

local function groundSpawnPickupCommandHandler(...)
	local args = { ... }

	local spawn = args[1]
	InitializeGroupCache()

	-- foreach group member once spawn is spawned, send the event to them
	for _, memberName in pairs(GroupCache) do
		if memberName and memberName ~= "NONE" then
			BL.info("Starting loot proceess for %s", memberName)
			leadCharacterThroughLootProcess(memberName, spawn)
			--give the box time to loot
			mq.delay(5000)
		end
	end
end

mq.bind("/aground", groundSpawnPickupCommandHandler)

-------------------------------------------------------------------
BL.log.info(
	"Allsay running!  I should only be running on your TANK.  Use /asay phrase to have your group assist your tank for target, uninvis, and all say the given phrase.  Use /ahail to have group hail the target."
)

while true do
	mq.doevents()
	mq.delay(546)
end
