--- @type Mq
local mq = require("mq")

local firingLineNav = "/nav loc 440 110 13"
local targetName = "A shadow bearer"

local function target_mob()
	if mq.TLO.Target.CleanName() ~= targetName then
		mq.cmdf("/face fast %s npc", targetName)
		mq.delay(50)
		mq.cmdf("/mqtar %s npc", targetName)
		mq.delay(50)
		mq.cmd("/autofire on")
	end
end

local function FiringLineLocation()
	mq.cmd("/target clear")
	print("Moving to firing line...")
	mq.cmd(firingLineNav)
	while mq.TLO.Nav.Active() do -- wait till I get there before continuing next command
		--pause wait for nav
		mq.delay(100)
	end
	print(string.format("Navigation arrived"))
	mq.cmd("/multiline ; /mqp off; /boxr unpause")
	print("Clearing Target...")
	mq.cmd("/target clear")
	target_mob()
end

local function init()
	print("Starting RangersMove Raid Lua")
	if mq.TLO.Plugin("mq2boxr")() then
		print("\apMQ2Boxr Already Loaded\ap") -- plugin is loaded.. we are good to go
	else
		print("\apLoading MQ2BOXR!\ap")
		mq.cmd("/plugin mq2boxr")
	end
	FiringLineLocation()
end

local function handleEvents()
	mq.doevents()
end

local function SettingSunTriggered()
	mq.cmd("/multiline ; /boxr pause; /mqp on; /backoff on")
	mq.delay("5ms")
	mq.cmd("/rs running from setting sun")
	mq.cmd("/nav loc 930 80 0")
end

local function RisingSunTriggered()
	mq.cmd("/multiline ; /boxr pause; /mqp on; /backoff on")
	mq.delay("5ms")
	mq.cmd("/rs running to Dawn due to rising sun")
	mq.cmd("/target Dawn")
	mq.delay("1s")
	mq.cmd("/nav target")
end

mq.event("SettingSunRunAway", "#*#Your sun begins to set.#*#", SettingSunTriggered)
mq.event("SettingSunReturn", "#*#Your sun sets.#*#", FiringLineLocation)
mq.event(
	"RisingSunTriggered",
	"#*#Your sun rises, painfully bright. Less so if you stay at Dawn.#*#",
	RisingSunTriggered
)
mq.event("RisingSunCompleted", "#*#Dawn removes your fear of the Blinding Day ahead.#*#", FiringLineLocation)

init()
-- if healer, get the Dusk is confused for a moment emote, spam heals on Dusk

while true do
	handleEvents()
	mq.delay(100)
	target_mob()
end
