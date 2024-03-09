local mq          = require("mq")
local fs          = require('fs.fs')
local BL          = require("biggerlib")
local ffi         = require("ffi")
local cbor        = require("cbor")

local writeCount  = 0
local readCount   = 0
local keepRunning = true

mq.bind("/zaquit", function()
    BL.info("Received quit message")
    keepRunning = false
end)
mq.bind("/zareset", function()
    BL.info("Received reset request")
    keepRunning = false
    mq.cmd("/multiline ; /timed 20 /lua stop zen/zenactors; /timed 30 /lua run zen/zenactors")
    
end)

local function decode_message(message_string)
    local decoded = cbor.decode(message_string)
    return decoded
end

local function test_pipe(pipefile, cbor_message)
    -- WRITE
    local buffer = cbor_message
    BL.info("WRITE to pipe...")
    pipefile:write(buffer, #buffer)
    pipefile:flush()
    writeCount = writeCount + 1
    mq.delay(2000)

    -- READ
    BL.info("READ from pipe...")
    --local readlen = pipefile:read(data, 4)
    local data, read_len = pipefile:readall()
    --local data
    --local read_len = pipefile:read(data, 512)
    BL.dump(read_len, "Read data from pipe with length:")
    BL.dump(data)

    if read_len > 0 then
        local data_string = ffi.string(data, read_len)
        BL.info("Received from server: %s", data_string)
        local decoded = decode_message(data_string)
        BL.dump(decoded, "Decoded final cbor message from server:")
        if decoded.message_type == "MsgMQCommandString" then
            BL.info("Received Command")
            local command = decoded.payload.message
            BL.dump(command, "Command:")
            mq.cmd(command)
            
            
        end
    end
end

local function init()
    -- required permissions for the underlying named pipe
    local opt = 'r+'
    local name = [[\\.\pipe\zenactorpipe]]
    local pipefile = fs.open(name, opt)
    
    if not pipefile then
        BL.error("Error opening pipe: %s", name)
        return 0
    end
    return pipefile
end

local KeepAliveMsg = {
    KeepAlive = nil,
}
local cbored = cbor.encode(KeepAliveMsg)

local MQMessage = {
    message_type = {
        ["MsgRoomConnectionRequest"] = "",        
    },
    sequence_id = 0,
    mode = "",
    payload = {}
}


local pipefile = init()
while keepRunning do
    test_pipe(pipefile, cbored)
    mq.delay(2000)
end
pipefile:close()
