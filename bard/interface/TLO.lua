local mq = require('mq')
local config = require('interface.configuration')
local mode = require('mode')
local state = require('state')

local zen
local AQOType
local TLO = {}

local tlomembers = {
    Paused = function()
        return 'bool', state.paused
    end,
}

local function AQOTLO(index)
    return AQOType, {}
end

function TLO.init(_aqo)
    zen = _aqo

    for k,v in pairs(config) do
        if type(v) == 'table' and v.tlo and v.tlotype then
            --if v.emu == nil or (v.emu and state.emu) or (v.emu == false and not state.emu) then
            if v.emu == nil or v.emu == state.emu then
                tlomembers[v.tlo] = function() return v.tlotype, config.get(k) end
            end
        end
    end

    for k,v in pairs(zen.class.OPTS) do
        if v.tlo and v.tlotype then
            tlomembers[v.tlo] = function() return v.tlotype, v.value end
        end
    end

    AQOType = mq.DataType.new('AQOType', {
        Members = tlomembers
    })
    function AQOType.ToString()
        return ('ZEN Running = %s, Mode = %s'):format(not state.paused, mode.currentMode:getName())
    end

    mq.AddTopLevelObject('ZEN', AQOTLO)
end

return TLO