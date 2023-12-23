-- Crummy documentation:
-- Use /tgs and /tgg to send commands
-- If you use a shortname, it will function identically to /travelto and take you/your group there
-- If you do not, it will fuzzy find all zones matching your argument, then show you a list of possible
-- zones you could be searching for.  Choose the number matching the zone you want, and off you go.
-- Designed to alleviate the need to remember every zone's shortname for /travelto
-- If you're still using EQBCS, manually change `local useDanNet = true` to `local useDanNet = false`

--- @type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")

local zones = require("ladonzones")

local travelguide = {}
local matches = {}
local useGroupTravel = true
local useDanNet = true

function travelguide.searchZones(substring)
	local matches = {}
	for i, zone in ipairs(zones) do
		for j, field in ipairs(zone) do
			if type(field) == "string" and string.find(string.lower(field), string.lower(substring)) then
				table.insert(matches, { zone[2], zone[3] })
				break
			end
		end
	end
	return matches
end

function travelguide.searchShortnames(substring)
	for i, zone in ipairs(zones) do
		for j, field in ipairs(zone) do
			if type(field) == "string" and field:lower() == substring:lower() then
				--printf("Found field (%s) matches shortname (%s)", field, zone[3])
				return zone[3]:lower()
			end
		end
	end
	return nil
end

function travelguide.travelTo(shortName)
	if useGroupTravel then
		--print("Traveling GROUP to: " .. shortName)
		if useDanNet then
			mq.cmd("/dgga /travelto " .. shortName)
		else
			mq.cmd("/bcaa //travelto " .. shortName)
		end
	else
		--print("Traveling SELF to: " .. shortName)
		mq.cmd("/travelto " .. shortName)
	end
end

local function commandHandler(args)
	if not args[1] then
		print("Called /tg without zone search name")
		return
	end

	-- Checks to see if /tg <input> input var is a number or string
	-- If string, we search and display results
	-- If number, we consider it a choice and travel there
	local choiceNumber = tonumber(args[1])

	-- Search for zone name, string was passed in rather than number
	if choiceNumber == nil then
		local firstArgLower = args[1]:lower()

		-- Parse commands
		if firstArgLower == "group" then
			print("Sending travel to all group members")
			useGroupTravel = true
			return
		elseif firstArgLower == "solo" or firstArgLower == "self" then
			print("Traveling solo from now on")
			useGroupTravel = false
			return
		elseif firstArgLower == "stop" then
			if useGroupTravel then
				mq.cmd("/dgga /travelto stop")
			else
				mq.cmd("/travelto stop")
			end
		end

		-- See if someone gave an actual shortname and go directly if so
		local shortName = travelguide.searchShortnames(firstArgLower)
		if shortName ~= nil then
			travelguide.travelTo(shortName)
			return
		end

		-- No actual shortname, so search
		matches = travelguide.searchZones(firstArgLower)
		-- Display results for choosing
		for i, zone in ipairs(matches) do
			-- zone[1] is the human name "North Qeynos", zone[2] is the zone shortname "qeynos2"
			printf("%d - %s (%s)", i, zone[1], zone[2])
		end
	else
		-- Someone chose a search result, go to it
		local match = matches[choiceNumber]
		-- travel to discovered/selected shortname
		travelguide.travelTo(match[2])
	end
end

local function commandHandlerGroup(...)
	local args = { ... }
	local oldGroupTravel = useGroupTravel
	useGroupTravel = true
	-- Need to use unpack to forward variadic arguments
	commandHandler(args)
	useGroupTravel = oldGroupTravel
end

local function commandHandlerSolo(...)
	local args = { ... }
	local oldGroupTravel = useGroupTravel
	useGroupTravel = false
	commandHandler(args)
	useGroupTravel = oldGroupTravel
end

-- Binds:
-- /tgg is group travel command, then returns to previous mode
-- /tgs is solo travel command, then returns to previous mode

mq.bind("/tgg", commandHandlerGroup)
mq.bind("/tga", commandHandlerGroup)
mq.bind("/tgs", commandHandlerSolo)

mq.bind("/nt", function(...)
	local args = { ... }
	local targetName = args[1]

	-- allows "/nt corpse eye" to hidecorpse first
	if targetName == "corpse" then
		targetName = args[2]
		mq.cmd("/hidecorpse all")
		mq.delay(1500)
	end

	local spawn = mq.TLO.Spawn(targetName)
	if spawn then
		spawn.DoTarget()
	end
	mq.cmdf("/nav spawn %s", targetName)
end)

print(
	"TravelGuide now listening. Use /tga and /tgs to travel (group/all or solo).  If you're not sure of the zone name, try whatever and it will give you a list.  You can choose from the list options like /tg"
)
while true do
	mq.delay(1000)
end
