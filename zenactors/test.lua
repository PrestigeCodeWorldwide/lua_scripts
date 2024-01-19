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
	typedef void* ZenActorClientPtr;	
	int add_in_rust(unsigned int a, unsigned int b);
	ZenActorClientPtr zen_actor_client_new(const char* room, const char* channel);
	void zen_actor_client_interact(ZenActorClientPtr client);
	char* zen_actor_client_get_messages_sync(ZenActorClientPtr client);
	void zen_actor_client_free(ZenActorClientPtr client);	
]]

local function TestFFIDllCall()
	local luadir = mq.luaDir .. "\\zen\\rust\\actor_relay_service\\target\\debug\\zenactor_ffi.dll"
	BL.info("Lua dir: %s", luadir)

	local rust_lib = ffi.load(luadir)
	local result = rust_lib.add_in_rust(1, 2)
	BL.info("Result from rust: %d", result)

	local client = rust_lib.zen_actor_client_new("ActorTestRoom", "ActorTestChannel")
	BL.info("Got client from rust new")
	local messages = rust_lib.zen_actor_client_get_messages_sync(client)
	BL.info("Got Messages from rust")
	BL.info("Messages: %s", ffi.string(messages))
	-- CLEAN UP
	rust_lib.zen_actor_client_free(client)
	BL.info("Freed client")
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
