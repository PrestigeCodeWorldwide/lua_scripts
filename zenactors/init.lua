---@type Mq
local mq          = require("mq")
local fs          = require('fs.fs')
local BL          = require("biggerlib")
local Option      = require("biggerlib.option")
local ffi         = require("ffi")
--local cbor        = require("cbor")
local json   = require("json")
local socket = require("socket")

local writeCount  = 0
local readCount   = 0
local keepRunning = true
local WriteFlag   = true
local ReadFlag    = false

mq.bind("/zaquit", function()
    BL.info("Received quit message")
    keepRunning = false
end)
mq.bind("/zareset", function()
    BL.info("Received reset request")
    keepRunning = false
    mq.cmd("/multiline ; /lua stop zen/zenactors; /timed 10 /lua run zen/zenactors")
end)
mq.bind("/zawrite", function()
    BL.info("Received write request")
    WriteFlag = true
end)

local ConnectionStates = BL.Enum([[
    Disconnected,
    Connected
]])

---@class Pipe
---@field close function(self)

---@class Connection
---@field pipe Pipe|nil
local Connection = {
    pipe = nil,
    ConnectionState = ConnectionStates.Disconnected
}

---@class Utils
local Utils = {}

Utils.decode_message = function(message_string)
    --local decoded = cbor.decode(message_string)
    local decoded = json.decode(message_string)
    return decoded
end

Utils.WriteToPipe = function(pipe, buffer)
    if BL.IsNil(pipe) then return end

    BL.dump(buffer, "WRITE")
    pipe:write(buffer, #buffer)
    pipe:flush()
    writeCount = writeCount + 1
end

--- Reads from a named pipe and decodes the received message.
Utils.ReadFromPipe = function(pipe)
    if BL.IsNil(pipe) then return Option.None end
    local data, read_len = pipe:readall()

    if read_len > 0 then
        local data_string = ffi.string(data, read_len)
        --BL.info("Received from server: %s", data_string)
        local decoded = Utils.decode_message(data_string)
        readCount = readCount + 1
        return Option.Some(decoded)
    end
    return Option.None
end

Utils._tryConnectToPipe = function()
    -- required permissions for the underlying named pipe
    local opt = 'r+'
    local name = [[\\.\pipe\zenactorpipe]]
    BL.info("Opening %s pipe", name)
    local pipefile, err = fs.open(name, opt)
    if BL.IsNil(pipefile) then
        BL.warn("Error opening pipe: %s", err)
    end

    return Option.Wrap(pipefile)
end

Utils.ConnectToPipe = function()
    local pipe = Utils._tryConnectToPipe()
    while pipe:IsNone() do
        mq.delay(1000)
        pipe = Utils._tryConnectToPipe()
    end
    local conn = {
        pipe = pipe:Unwrap(),
        ConnectionState = ConnectionStates.Connected
    }
    return conn
end

--- Currently only connects to named pipe and returns it
local function init()
    return Utils.ConnectToPipe()
end

---@class MQMessageType
local MQMessageType = {
    ConnectMsg = "ConnectMsg",
    TLODataMsg = "TLODataMsg",
    KeepAliveMsg = "KeepAliveMsg",
    MQCommandMsg = "MQCommandMsg"
}

---@class MQMessage
---@field ConnectMsg ConnectMsg
---@field TLODataMsg TLODataMsg

---@class ConnectMsg
---@field message_type table
---@field sequence_id number
---@field mode string
---@field payload table

---@class TLODataMsg
---@field message_type table
---@field sequence_id number
---@field mode string
---@field payload TLODataMsgPayload

---@class TLODataMsgPayload
---@field TLO table



local MQMessage = {
    ConnectMsg = {
        message_type = MQMessageType.ConnectMsg,
        sequence_id = 1,
        payload = {
            room = "testroom",
            channel = "testchannel",
            character = "testcharacter"
        }
    },
    TLODataMsg = {
        message_type = MQMessageType.TLODataMsg,
        sequence_id = 1,
        payload = {
            data = "ChaseAssist",
            type = "String",
            name = "CWTN.Mode",
        }
    },
    KeepAliveMsg = {
        message_type = MQMessageType.KeepAliveMsg,
        sequence_id = 1,
        payload = {
            KeepAlive = 1
        }
    },
    MQCommandMsg = {
        message_type = MQMessageType.MQCommandMsg,
        sequence_id = 1,
        payload = {}
    }
}
local function shallowcopy(orig)
    local copy = {}
    for key, value in pairs(orig) do
        copy[key] = value
    end
    return copy
end
MQMessage.NewTLOMsg = function(in_name, in_data)
  
    local newMsg = shallowcopy(MQMessage.TLODataMsg)
    newMsg.payload = {
        name = in_name,
        data = in_data
    }
    return json.encode(newMsg)
end

MQMessage.NewConnectMsg = function(inRoom, inChannel, inCharacter) 
    local newMsg = shallowcopy(MQMessage.ConnectMsg)
    newMsg.payload = {
        room = inRoom,
        channel = inChannel,
        character = inCharacter
            
    }
    return json.encode(newMsg)
end

MQMessage.NewKeepAliveMsg = function()
    BL.dump(MQMessage.KeepAliveMsg)
    return json.encode(MQMessage.KeepAliveMsg)
end

local msgTloData = MQMessage.NewTLOMsg("CWTN.Mode", "ChaseAssist")
local msgKeepAlive = MQMessage.NewKeepAliveMsg()
BL.dump(msgKeepAlive)
local function test_pipe(pipefile, msgTloData, msgKeepAlive)
    -- WRITE
    if WriteFlag then
        Utils.WriteToPipe(pipefile, MQMessage.NewConnectMsg("testroom", "inChannel", "inCharacter"))
        Utils.WriteToPipe(pipefile, msgKeepAlive)
        Utils.WriteToPipe(pipefile, msgTloData)
        local tloTest = MQMessage.NewTLOMsg("Integer Data", 3)
        Utils.WriteToPipe(pipefile, tloTest)
        local tloTest = MQMessage.NewTLOMsg("Boolean Data", true)
        Utils.WriteToPipe(pipefile, tloTest)
        
        
        
    end
    -- READ
    if ReadFlag then
        local data = Utils.ReadFromPipe(pipefile)

        if data:IsSome() then
            data = data:Unwrap()
            if data.message_type == MQMessageType.MQCommandMsg then
                local command = data.payload.message
                BL.dump(command, "Command:")
                mq.cmd(command)
            else
                BL.dump(data, "Generic message received:")
            end
        end
    end
end
---@type Connection
local conn = init()
while keepRunning do
    if conn.ConnectionState == ConnectionStates.Disconnected then
        conn = Utils.ConnectToPipe()
    elseif conn.ConnectionState == ConnectionStates.Connected then
        test_pipe(conn.pipe, msgTloData, msgKeepAlive)
    end
    mq.delay(5000)
end
conn.pipe:close()
