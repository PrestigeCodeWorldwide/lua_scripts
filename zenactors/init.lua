--- @type Mq
local mq = require('mq')
local BL = require("biggerlib")
local bitser = require('biggerlib.bitser')
local PackageMan = require('mq/PackageMan')
local socket = PackageMan.Require('luasocket', 'socket')
local cjson = PackageMan.Require('lua-cjson', 'cjson')



local MessageTypes = {
	-- string.char required otherwise these will be treated as ASCII (48 for 0, etc)
	CONNECT = string.char(0),
	CLIENTMESSAGESEND  = string.char(1),
}

local ClientConnectRequest = {
	clientOperation = "ClientConnectAttempt",
}

local ClientSendMessage = {
	clientOperation = "ClientMessage",
	message = "",
	clientId = cjson.null,
	mailbox = "default"
}



local host, port = "164.152.109.187", 8080

local tcp = assert(socket:tcp())
tcp:connect(host, port)
tcp:settimeout(0.1)

--print("Sending message:")
--print(json_message)
--tcp:send(json_message)
--mq.delay(100)


local state = {
	CONNECTING = 0,
	CONNECTED = 1
}

local currentState = state.CONNECTING

local function sendActorMessage(message)
	ClientSendMessage.message = message
	local json_message = cjson.encode(ClientSendMessage) .. "\n"
	--BL.info("Sending message JSON: %s", json_message)
	tcp:send(json_message)
	
	mq.delay(100)
end

local function sendClientConnectRequest()
	-- Use the cjson.encode function to convert the table into a JSON string, uses \n as stream ending delimiter
	local json_message = cjson.encode(ClientConnectRequest) .. "\n"
	tcp:send(json_message)
	BL.info("Sent connect request:")
	BL.dump(json_message)
end

------------------------ EXECUTION -------------------------------------------

sendClientConnectRequest()

while true do
	local s, status, partial = tcp:receive('*l')
	
	--BL.dump(s, "S")
	--BL.dump(status, "status")
	--BL.dump(partial, "partial")
	
	if currentState == state.CONNECTING then
		
		if BL.NotNil(partial) and type(partial) == "string" then
			local message = cjson.decode(partial)
			--set my new client ID from server
			
			ClientSendMessage.clientId = message.ClientConnectApproved
			currentState = state.CONNECTED
			BL.info("Set clientID from server successfully")
		end
	end
	
	if currentState == state.CONNECTED then
		
		--get messages from server
		if BL.NotNil(partial) then
			BL.dump(partial, "Message From Server")
		end
		sendActorMessage("TestMessage")
		mq.delay(5000)
		-- this is where i want to accept more messages
		--BL.dump(s, "S")
		--BL.dump(status, "status")
		--BL.dump(partial, "partial")
	end
	
	if status == "closed" then break end
	mq.delay(100)

end
print("Connection closed")
tcp:close()

