local ffi = require("ffi")
local mq = require("mq")
local BL = require("biggerlib")
--local ZActor = require("init")

local devMode = false
local msgCount = 0
local delay = 1023
local shouldContinue = true

local luadir = mq.luaDir .. "\\zen\\rust\\actor_relay_service\\target\\debug\\zenactor_ffi.dll"
BL.info("Lua dir: %s", luadir)
local rust_lib = ffi.load(luadir)
BL.info("Loaded Rust Lib")

local client = nil

--ZActor:Init("ActorTestRoom", "ActorTestChannel", function(message)
--	msgCount = msgCount + 1
--	BL.info("Received message from someone: %s", message)
--end)

ffi.cdef [[
	typedef void* ZenActorClientPtr;	
	int add_in_rust(unsigned int a, unsigned int b);
	ZenActorClientPtr zen_actor_client_new(const char* room, const char* channel);
	void zen_actor_client_interact(ZenActorClientPtr client);
	char* zen_actor_client_get_messages_sync(ZenActorClientPtr client);
	void zen_actor_client_free(ZenActorClientPtr client);	
	int zen_actor_client_send_message(ZenActorClientPtr client, const char* message);
	char* zen_actor_client_init(ZenActorClientPtr client);
	
]]
--int zen_actor_client_run(ZenActorClientPtr client);


local function TestFFIDllCall()
	BL.info("Sending test message from lua")
	rust_lib.zen_actor_client_send_message(client, "Test Message from Lua")
	BL.info("Sent message, now receiving messages from server")

	local messages = rust_lib.zen_actor_client_get_messages_sync(client)
	BL.info("Got Messages from rust")
	BL.info("Messages: %s", ffi.string(messages))
end

local function InitFFI()
	local result = rust_lib.add_in_rust(1, 2)
	BL.info("Result from rust: %d", result)
	client = rust_lib.zen_actor_client_new("ActorTestRoom", "ActorTestChannel")
	BL.info("Got client from rust new")
	local client_inited = rust_lib.zen_actor_client_init(client)
	BL.info("Client inited: %s", ffi.string(client_inited))
	--rust_lib.zen_actor_client_run(client)
	--BL.info("Successfully ran client")
end

------------------ Execution
InitFFI()

while shouldContinue do
	---- Required, this is how you fetch messages from other toons
	--ZActor:Tick()
	--TestFFIDllCall()
	--if devMode then
	--	local message = string.format("Test Msg: %s - %d", mq.TLO.Me.CleanName(), msgCount)
	--	ZActor:SendMessage(message)
	--end
	mq.delay(delay)
end
-- CLEAN UP
--rust_lib.zen_actor_client_free(client)
BL.info("Freed client")
BL.info("Connection closed, ending ZenActors Test Script.")
