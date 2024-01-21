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
	char* zen_actor_client_get_rust_logs(ZenActorClientPtr client);
	void zen_actor_client_free(ZenActorClientPtr client);	
	char* zen_actor_client_send_message(ZenActorClientPtr client, const char* message);
	char* zen_actor_client_init(ZenActorClientPtr client);
	int zen_actor_client_step_runtime(ZenActorClientPtr client);
	
]]
--int zen_actor_client_run(ZenActorClientPtr client);

local function GetRustLogs()
	local logs = rust_lib.zen_actor_client_get_rust_logs(client)
	local stringLogs = ffi.string(logs)
	--BL.dump(stringLogs, "STRINGLOGS")
	--BL.info("Length of string is %d", string.len(stringLogs))

	if stringLogs ~= nil and stringLogs ~= "" and string.len(stringLogs) > 2 then
		BL.info("Rust Logs: %s", stringLogs)
	end
end

local function TestFFIDllCall()
	BL.info("Sending test message from lua")
	rust_lib.zen_actor_client_step_runtime(client)
	GetRustLogs()
	local message_send_res = rust_lib.zen_actor_client_send_message(client, "Test Message from Lua")
	BL.info("Sent message result: %s", ffi.string(message_send_res))
	BL.info("Sent message, now receiving messages from server")
	GetRustLogs()
	rust_lib.zen_actor_client_step_runtime(client)


	local messages = rust_lib.zen_actor_client_get_messages_sync(client)

	BL.info("Received Messages from rust: %s", ffi.string(messages))
	GetRustLogs()
	rust_lib.zen_actor_client_step_runtime(client)
	GetRustLogs()
end

local function InitFFI()
	--local result = rust_lib.add_in_rust(1, 2)
	--BL.info("Result from rust: %d", result)
	BL.info("Beginning init with new client")
	local client_status, client_res = pcall(rust_lib.zen_actor_client_new("ActorTestRoom", "ActorTestChannel"))
	BL.info("Client created: %s %s", tostring(client_status), tostring(client_res))
	client = client_res
	BL.dump(client, "Got new client")
	GetRustLogs()

	mq.delay(3000)
	BL.info("Stepping client...")
	local status, res = pcall(rust_lib.zen_actor_client_step_runtime(client))
	BL.info("Client Stepped: %s %s", tostring(status), tostring(res))
	GetRustLogs()
	BL.info("Got client from rust new")
	local init_status, init_res = pcall(rust_lib.zen_actor_client_init(client))
	BL.info("Client inited: %s %s", tostring(init_status), tostring(init_res))
	--mq.delay(1000)
	--BL.info("Initialized client")
	--GetRustLogs()
	----mq.delay(5000)
	--local res = rust_lib.zen_actor_client_step_runtime(client)
	--GetRustLogs()

	--BL.info("Client inited: %s", tostring(res))
end


------------------ Execution
InitFFI()
GetRustLogs()
while shouldContinue do
	--BL.info("Tick")
	--rust_lib.zen_actor_client_step_runtime(client)
	--TestFFIDllCall()

	mq.delay(delay)
end
mq.delay(5000)
-- CLEAN UP
rust_lib.zen_actor_client_free(client)
BL.info("Freed client")
BL.info("Connection closed, ending ZenActors Test Script.")
