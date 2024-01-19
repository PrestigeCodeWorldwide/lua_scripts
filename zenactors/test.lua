local mq = require("mq")
local BL = require("biggerlib")
local ZActor = require("init")

local devMode = false
local msgCount = 0
local delay = 1023
local shouldContinue = true

ZActor:Init("ActorTestRoom", "ActorTestChannel", function(message)
	msgCount = msgCount + 1
	BL.info("Received message from someone: %s", message)
end)

while shouldContinue do
	-- Required, this is how you fetch messages from other toons
	ZActor:Tick()

	if devMode then
		local message = string.format("Test Msg: %s - %d", mq.TLO.Me.CleanName(), msgCount)
		ZActor:SendMessage(message)
	end
	mq.delay(delay)
end

BL.info("Connection closed, ending ZenActors Test Script.")
