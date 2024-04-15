local mq = require('mq')

-- Do not edit this if condition
if not package.loaded['events'] then
    print('This script is intended to be imported to Lua Event Manager (LEM). Try "\a-t/lua run lem\a-x"')
end

local function on_load()
    -- Perform any initial setup here when the event is loaded.
end

local function event_handler()
   
        mq.cmd("/alt activate 5304")
   
end

return {onload=on_load, eventfunc=event_handler}