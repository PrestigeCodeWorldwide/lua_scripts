local useDanNet = true
local zones = require("ladonzones")
local mq = require("mq")
local travelguide = {}

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

--local args = { ... }
--printf('Script called with %d arguments:', #args)
--for i, arg in ipairs(args) do
--	printf('arg[%d]: %s', i, arg)
--end

--local zonelist = travelguide.searchZones(args[1])

-- print each item in zonelist on its own line

local matches = {}
local useGroupTravel = false


local function commandHandler(...)
	local args = { ... }
	if not args[1] then
		print("Called /tg without zone search name")
		return
	end
	local firstArgLower = args[1]:lower()
	if firstArgLower == "group" then
		print("Sending travel to all group members")
		useGroupTravel = true
		return
	elseif firstArgLower == "solo" or firstArgLower == "self" then
		print("Traveling solo from now on")
		useGroupTravel = false
		return
	end


	-- Checks to see if /tg <input> input var is a number or string
	-- If string, we search and display results
	-- If number, we consider it a choice and travel there
	local choiceNumber = tonumber(args[1])

	-- Search for zone name, string was passed in rather than number
	if choiceNumber == nil then
		local zone = args[1]:lower()
		matches = travelguide.searchZones(zone)

		for i, zone in ipairs(matches) do
			-- zone[1] is the human name "North Qeynos", zone[2] is the zone shortname "qeynos2"
			printf("%d - %s (%s)", i, zone[1], zone[2])
		end
		-- Travel to selected match
	else
		local match = matches[choiceNumber]

		if useGroupTravel then
			print("Traveling GROUP to: " .. match[2])
			if useDanNet then
				mq.cmd("/dgga /travelto " .. match[2])
			else
				mq.cmd("/bcaa //travelto " .. match[2])
			end
		else
			print("Traveling SELF to: " .. match[2])
			mq.cmd("/travelto " .. match[2])
		end
	end
end

local function commandHandlerGroup(...)
	local args = { ... }
	local oldGroupTravel = useGroupTravel
	useGroupTravel = true
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

-- Binds: /tg is plain and uses whichever group/solo mode has been set
-- /tga is forced group travel command, then returns to previous mode
-- /tgs is forced solo travel command, then returns to previous mode
mq.bind('/tg', commandHandler)
mq.bind('/tga', commandHandlerGroup)
mq.bind('/tgs', commandHandlerSolo)
print("TravelGuide now listening...")
while true do
	mq.delay(1000)
end
