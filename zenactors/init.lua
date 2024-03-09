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
    BL.dump(pipefile)
    if not pipefile then
        BL.error("Error opening pipe: %s", name)
        return 0
    end
    
    -- WRITE
    --local buffer = cbor_message
    --BL.info("Writing to pipe...")
    --pipefile:write(buffer, #buffer)
    --pipefile:flush()
    --mq.delay(2000)
    
    -- READ
    --local readlen = pipefile:read(data, 4)
    --local data, len = pipefile:readall()
    local data
    local read_len = pipefile:read(data, 4096)
    BL.dump(read_len, "Read data from pipe with length:")
    BL.dump(data)
    local data_string = ffi.string(data, read_len)
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
--BL.dump(cbored)
--local decoded = cbor.decode(cbored)
--BL.dump(decoded)

test_pipe(cbored)
