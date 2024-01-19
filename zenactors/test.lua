local ffi = require("ffi")
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

ffi.cdef [[
	int add_in_rust(unsigned int a, unsigned int b);
]]

local function TestFFIDllCall()
	local rust_lib = ffi.load(
		"G:\\Games\\EQHax\\RGLauncherTest\\lua\\zen\\rust\\actor_relay_service\\target\\debug\\zenactor_ffi.dll")
	--local mydll = assert(package.loadlib(
	--	"G:\\Games\\EQHax\\RGLauncherTest\\lua\\zen\\rust\\actor_relay_service\\target\\debug\\zenactor_ffi.dll",
	--    "add_in_rust"))
	local result = rust_lib.add_in_rust(1, 2)
	BL.info("Result from rust: %d", result)
	--local result = mydll(1, 2)
end

TestFFIDllCall()

while shouldContinue do
	---- Required, this is how you fetch messages from other toons
	--ZActor:Tick()

	--if devMode then
	--	local message = string.format("Test Msg: %s - %d", mq.TLO.Me.CleanName(), msgCount)
	--	ZActor:SendMessage(message)
	--end
	mq.delay(delay)
end

BL.info("Connection closed, ending ZenActors Test Script.")
