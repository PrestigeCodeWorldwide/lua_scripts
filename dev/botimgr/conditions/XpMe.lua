local mq = require('mq')
local BL = require('biggerlib')

if not package.loaded['events'] then print('This script is intended to be imported to Lua Event Manager (LEM). Try "\a-t/lua run lem\a-x"') end

---@return boolean @Returns true if the action should fire, otherwise false.
local function condition()
    --local counter = mq.TLO.Me.Diseased.CounterNumber()
    --return counter and counter > 0 and
    --    mq.TLO.Me.ItemReady('Shield of the Immaculate')()
    return not mq.TLO.Me.Buff("Heightened Learning")()
end

local function action()
    BL.cmd.pauseAutomation()
    mq.cmd("/useitem Dusty Ceremonial Elixir of Scholarship")
    mq.delay(1000)
    BL.cmd.resumeAutomation()
end

return { condfunc = condition, actionfunc = action }
