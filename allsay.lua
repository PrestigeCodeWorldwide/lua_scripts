---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

local function boxPrep()
	mq.cmd("/dgga /assist off")
	mq.cmd("/dgge /boxr pause")
	mq.delay(1000)

	local assistName = mq.TLO.Group.MainTank.CleanName()

	mq.cmdf("/g assisting %s", assistName)
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

-------------------------------------------------------------------
BL.log.info(
	"Allsay running!  I should only be running on your TANK.  Use /asay phrase to have your group assist your tank for target, uninvis, and all say the given phrase.  Use /ahail to have group hail the target."
)

while true do
	mq.delay(1000)
end
