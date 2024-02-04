---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

local phrases = {
    
    "Array",
    "Binary",
    "Core",
    "Driveshaft",
    "Error",
    "Ferralitic",
    "Graphite",
    "Hologram",
    "Indeterminate",
    "Juxtapose",
    "Killswitch",
    "Luminescent",
    "Mechanotus",
    "Nevermind",
    "Omniscient",
    "Pinion",
    "Quietus",
    "Retry",
    "System",
    "Tautology",

}


BL.info("Starting Spam")
for i = 1, #phrases do
    local phrase1 = phrases[i]
    for j = 1, #phrases do
        local phrase2 = phrases[j]
        for k = 1, #phrases do
            local phrase3 = phrases[k]
            mq.cmd("/say %s", phrase1)
            mq.delay(1000)
            mq.cmd("/say %s", phrase2)
            mq.delay(1000)
            mq.cmd("/say %s", phrase3)
            mq.delay(1000)
        end
    end
end
BL.info("Finished spam")