--- @type Mq
local mq = require('mq')
local BL = require("biggerlib")
local PackageMan = require('mq/PackageMan')
local socket = PackageMan.Require('luasocket', 'socket')
local cjson = PackageMan.Require('lua-cjson', 'cjson')

--- @class Settings
local Settings = {
	host = "127.0.0.1",
	port = 8080,
	channel = "testChannel",
	room = "testRoom",
	ClientId = cjson.null,
	delay = 1031
}

--- @enum ConnectionState
--- This enum is used as a state machine since lua has no async to speak of and sockets really like to block
local ConnectionState = {
	DISCONNECTED = 0,
	SOCKET_CONNECTION_REQUESTED = 1,
	SOCKET_CONNECTED = 2,
	CLIENT_CONNECTION_REQUESTED = 3,
	CLIENT_CONNECTED = 4,
	ROOM_CONNECTION_REQUESTED = 5,
	ROOM_CONNECTED = 6,
}

--- @class LuasocketTCP
local luasocket_tcp = {
	--- @type function
	close = function() end,
	--- @type function
	--- @param data string The data to send to the server, as one string.
	send = function(self, data) end,
	--- @type function
	--- @param pattern string The pattern to match for receiving data. "*l" for line, "*a" for all data, or a number for that many bytes.
	--- @param prefix string|nil Optional prefix to prepend to the received data.
	receive = function(self, pattern, prefix) end,
}

--- @class ZActor
local ZActor = {
	--- @type LuasocketTCP
	tcp = nil,
	--- @type ConnectionState
	currentConnectionState = ConnectionState.DISCONNECTED
}

function ZActor:ConnectSocket()
	if self.currentConnectionState ~= ConnectionState.DISCONNECTED then
		BL.warn("Cannot connect socket, not in correct state!")
		return
	end
	BL.info("Creating Socket")
	local tcp = assert(socket.tcp())
	tcp:settimeout(5) -- 0 is non-blocking mode
	BL.info("Connecting to server...")
	local result, err = tcp:connect(Settings.host, Settings.port)
	BL.info("Done with initial connect attempt: %s", tostring(result))
	--if not result then
	--	BL.info("Failed to connect: %s", err)
	--	if err == 'timeout' then
	--		-- connection is in progress
	--		local writeable, readable, error = socket.select(nil, { tcp }, 5.0)
	--		if not writeable or #writeable == 0 then
	--			error = error or 'timeout'
	--			print('Failed to connect: ' .. error)
	--			tcp:close()
	--			return
	--		end
	--		BL.info("Done selecting socket")
	--	else
	--		print('Failed to connect: ' .. err)
	--		tcp:close()
	--		return
	--	end
	--end

	--tcp:settimeout(3.0) -- set back to blocking mode with a timeout
	self.tcp = tcp
	BL.info("Setting connection state to SOCKET_CONNECTION_REQUESTED")
	self.currentConnectionState = ConnectionState.SOCKET_CONNECTION_REQUESTED
end

function ZActor:HandleSocketConnectionResponse(partial)
	if self.currentConnectionState ~= ConnectionState.SOCKET_CONNECTION_REQUESTED then
		BL.warn("Cannot handle socket connection response, not in correct state!")
		return
	end

	if BL.NotNil(partial) and type(partial) == "string" then
		local message = cjson.decode(partial)
		--set my new client ID from server

		Settings.ClientId = message.ClientConnectApproved
		self.currentConnectionState = ConnectionState.SOCKET_CONNECTED
		BL.info("Set clientID from server successfully")
	end
end

function ZActor:SendClientConnectRequest()
	if self.currentConnectionState ~= ConnectionState.SOCKET_CONNECTED then
		BL.warn("Cannot send client connect request, not in correct state!")
		return
	end

	BL.info("Sending client connect request")

	local ClientConnectRequest = {
		clientOperation = "ConnectAttempt",
	}
	local json_message = cjson.encode(ClientConnectRequest) .. "\n"
	BL.info("Sending connection reqeust: %s", json_message)
	ZActor.tcp:send(json_message)
	BL.dump(json_message, "Sent connect request:")
	self.currentConnectionState = ConnectionState.CLIENT_CONNECTION_REQUESTED
end

function ZActor:HandleClientConnectionResponse(partial)
	if self.currentConnectionState ~= ConnectionState.CLIENT_CONNECTION_REQUESTED then
		BL.warn("Cannot handle client connection response, not in correct state!")
		return
	end

	BL.dump(partial, "PARTIAL")
	if BL.IsNil(partial) then
		BL.warn("COULD NOT CONNECT TO SERVER because partial was nil!")
		return false
	end

	if type(partial) == "function" then partial = partial() end

	BL.info("Partial: %s", partial)
	local message = cjson.decode(partial)
	if message.ClientConnectApproved then
		Settings.ClientId = message.ClientConnectApproved
		self.currentConnectionState = ConnectionState.CLIENT_CONNECTED
		BL.info("Set clientID from server successfully")
	end
	return BL.NotNil(message)
end

function ZActor:HandleRoomConnectionResponse(partial)
	if self.currentConnectionState ~= ConnectionState.ROOM_CONNECTION_REQUESTED then
		BL.warn("Cannot handle room connection response, not in correct state!")
		return
	end

	if BL.NotNil(partial) and type(partial) == "string" then
		local message = cjson.decode(partial)
		BL.dump(message, "Partial assembled from server:")
		BL.info("Set clientID from server successfully: %s", message.ClientConnectApproved)
		Settings.ClientId = message.ClientConnectApproved
		self.currentConnectionState = ConnectionState.ROOM_CONNECTED
	end
end

function ZActor:SendRoomConnectRequest()
	if self.currentConnectionState ~= ConnectionState.CLIENT_CONNECTED then
		BL.warn("Cannot send room connect request, not in correct state!")
		return
	end

	self:SendRoomJoinRequest(Settings.room)
	self.currentConnectionState = ConnectionState.ROOM_CONNECTION_REQUESTED
end

--- @param room string Room loosely corresponds to "Group of characters across all computers who want to group together"
--- @param channel string Channel loosely corresponds to "Which script is communicating to the Group"
--- @param message string Message to actually send, should probably start with some sort of header for categorization
local function sendActorMessage(room, channel, message)
	local ClientSendMessage = {
		clientId = Settings.ClientId,
		clientOperation = {
			Message = {
				room = room,
				channel = channel,
				message = message
			},
		}
	}
	local json_message = cjson.encode(ClientSendMessage) .. "\n"
	BL.info("Sending message JSON: %s", json_message)
	ZActor.tcp:send(json_message)
end

--- @param message string
function ZActor:SendMessage(message)
	if self.currentConnectionState ~= ConnectionState.ROOM_CONNECTED then
		BL.warn("Cannot send message, not in correct state!")
		return
	end
	sendActorMessage(Settings.room, Settings.channel, message)
end

function ZActor:SendRoomJoinRequest(room)
	local RoomJoinRequest = {
		clientId = Settings.ClientId,
		clientOperation = {
			RoomJoin = room
		}
	}
	local json_message = cjson.encode(RoomJoinRequest) .. "\n"
	ZActor.tcp:send(json_message)
	BL.info("Sent room join request:")
	BL.dump(json_message)
end

--- Called to disconnect from a given room
---@param room string
function ZActor:SendRoomLeaveRequest(room)
	local RoomLeaveRequest = {
		clientOperation = {
			RoomLeave = room
		}
	}

	-- Use the cjson.encode function to convert the table into a JSON string, uses \n as stream ending delimiter	
	local json_message = cjson.encode(RoomLeaveRequest) .. "\n"
	ZActor.tcp:send(json_message)
	BL.info("Sent room leave request:")
	BL.dump(json_message)
end

function ZActor:HandleIncomingMessage(partial)
	BL.info("In connectionState.ROOM_CONNECTED")

	local status, message = pcall(cjson.decode, partial)

	if not status then
		message = partial
	end

	BL.dump(message, "Partial assembled from server:")

	-- Call user callback fn with message here
	if BL.NotNil(message) then ZActor.messageHandler(message) end
	return message
end

--- Checks for incoming tcp message from server
-- @return messageReceived
function ZActor:Receive()
	local messageReceived = nil

	local recvt = { ZActor.tcp }
	local sendt = {}
	local timeout = 5 -- non-blocking
	local readable, writable, status = socket.select(recvt, sendt, timeout)
	BL.dump(readable)

	-- If there is no readable socket, return early so we don't block
	if #readable <= 0 then
		BL.info("No readable socket")
		return
	end
	BL.info("Finally got a readable socket")
	
	local s, status, partial = ZActor.tcp:receive('*l')
	BL.info("Received from server: %s -- %s -- %s", s, status, partial)


	if self.currentConnectionState == ConnectionState.SOCKET_CONNECTION_REQUESTED then
		BL.info("In connectionState.SOCKET_CONNECTION_REQUESTED")
		self:HandleSocketConnectionResponse(partial)
	elseif self.currentConnectionState == ConnectionState.CLIENT_CONNECTION_REQUESTED then
		BL.info("In connectionState.CLIENT_CONNECTION_REQUESTED")
		local connected = self:HandleClientConnectionResponse(partial)
		if not connected then
			BL.warn("COULD NOT CONNECT TO SERVER!")
			return nil
		end
	elseif self.currentConnectionState == ConnectionState.ROOM_CONNECTION_REQUESTED then
		self:HandleRoomConnectionResponse(partial)
	elseif self.currentConnectionState == ConnectionState.ROOM_CONNECTED then
		messageReceived = self:HandleIncomingMessage(partial)
	end

	return messageReceived
end

-- This handles the clientside sending of the server negotiation
-- If we're anything other than fully connected to a room, we attempt to move that forward here
function ZActor:ManageConnection()
	local curr = self.currentConnectionState
	if curr == ConnectionState.DISCONNECTED then
		self:ConnectSocket()
	elseif curr == ConnectionState.SOCKET_CONNECTED then
		self:SendClientConnectRequest()
		--elseif curr == ConnectionState.CLIENT_CONNECTED then
		--	self:SendRoomJoinRequest(Settings.room)
	end
end

function ZActor:Tick()
	self:ManageConnection()

	self:Receive()
end

function ZActor:Disconnect()
	self:SendRoomLeaveRequest(Settings.room)
end

function ZActor:Init(room, channel, messageHandler)
	Settings.room = room
	Settings.channel = channel
	self.messageHandler = messageHandler
end

-- kludge to force the socket to close when zactor goes out of scope
local mt = {
	-- Destructor
	__gc = function(self)
		self.Disconnect()
	end,
}

setmetatable(ZActor, mt)

return ZActor
