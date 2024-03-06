local mq = require("mq")
local fs = require('fs.fs')
local BL = require("biggerlib")
local ffi = require("ffi")
local cbor = require("cbor")

local function decode_message(message_string)
    local decoded = cbor.decode(message_string)
    return decoded
end

local function test_pipe(cbor_message)
    local opt = 'r+'
    local name = [[\\.\pipe\zenactorpipe]]
    local pipefile = fs.open(name, opt)
    --local pipefile = pipe
    BL.dump(pipefile)
    mq.delay(2000)
    local buffer = cbor_message
    local len = #buffer
    if not pipefile then
        return 0
    end
    BL.info("Writing to pipe...")
    pipefile:write(buffer, len)
    pipefile:flush()
    mq.delay(2000)
    --local readlen = pipefile:read(data, 4)
    local data, len = pipefile:readall()
    BL.info("Read data from pipe with length: %d", len)
    BL.dump(data)
    local data_string = ffi.string(data, len)
    BL.info("Received from server: %s", data_string)
    local decoded = decode_message(data_string)
    BL.dump(decoded, "Decoded final cbor message from server:")

    pipefile:close()
end



local Protocol = {
    First = 1,
    Second = "SecondString"
}

local cbored = cbor.encode(Protocol)
BL.dump(cbored)
local decoded = cbor.decode(cbored)
BL.dump(decoded)

test_pipe(cbored)
