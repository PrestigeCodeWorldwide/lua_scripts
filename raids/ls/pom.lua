local mq = require("mq")
local BL = require("biggerlib")

local function memMezSpell()
	mq.cmd("/enc byos on")
	mq.delay(50)
	local Spellname = "flummox"
	if mq.TLO.Me.Gem(Spellname)() and mq.TLO.Me.Gem(Spellname)() > 0 then
		return
	end -- Should be memmed already

	mq.cmdf('/memspell 13 "%s"', Spellname)
	mq.delay("4s")
	mq.TLO.Window("SpellBookWnd").DoClose()
end

local function doMezRabbit()
	local rabbit = mq.TLO.Spawn("npc rabbit")

	if not rabbit then
		return
	end

	if mq.TLO.Target() ~= rabbit then
		rabbit.DoTarget()
	end

	if rabbit.Distance() < 100 then
		BL.cmd.pauseAutomation()
		mq.cmd("/cast flummox")
		mq.delay(50)
		mq.cmd("/cast flummox")
		-- Give rabbit time to leave and come back
		mq.delay(7000)
		BL.cmd.resumeAutomation()
	end
end

memMezSpell()
while true do
	doMezRabbit()
	mq.delay(1000)
end

-- WIP Notes
-- Hot potato stuff
---- Rabbit mez
--local rabbitTrigger = "A white rabbit appears!"
---- Names to follow emotes functions
--local EventEnum = {
--	["Cheer my greatness"] = "/cheer",
--	["Clap for me"] = "/clap",
--	["Dance for me"] = "/dance",
--	["Raise your hands in praise of me"] = "/praise",
--	["Kneel before me"] = "/kneel",
--	["Bow to me"] = "/bow",
--}
---- The parser function
--local function parseParagraph(paragraph)
--	local PersonToEventMapping = {}
--	paragraph = paragraph:sub(("Come close to me. "):len() + 1)
--	for sentence in paragraph:gmatch("[^%.]+") do
--		for event, enum in pairs(EventEnum) do
--			if sentence:find(event) then
--				local person = sentence:match("%, (%a+)%.") -- Assumes names are alphanumeric
--				if person then
--					PersonToEventMapping[person] = enum
--					break
--				end
--			end
--		end
--	end
--	return PersonToEventMapping
--end
---- Example usage
--local paragraph =
--	"Cheer my greatness, PersonA.  Clap for me, PersonB.  Dance for me, PersonC.  Cheer my greatness, PersonD.  Dance for me, PersonE."
--local PersonToEventMapping = parseParagraph(paragraph)
---- Accessing the result
--print(PersonToEventMapping["PersonB"]) -- Output should be "Clap"-

--mq.cmd("/clap")
--mq.delay(500)

--mq.cmd("/dance")
--mq.delay(500)
--mq.cmd("/raise")
--mq.delay(500)
--mq.cmd("/bow")
--mq.delay(500)
--mq.cmd("/cheer")
--mq.delay(500)
--mq.cmd("/kneel")
--mq.delay(500)

--/dgga /multiline ; /clap ; /timed 5 /dance ; /timed 10 /raise ; /timed 15 /bow ; /timed 20 /cheer ; /timed 25 /kneel ;

--------------------------------
-- target rabbit
-- watch for rabbit to come within 90 distance
-- cast mez
-- delay 8 seconds
