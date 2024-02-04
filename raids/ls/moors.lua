--- @type Mq
local mq = require('mq')
local BL = require("biggerlib")

while true do
    BL.RunToWhileDebuffed("Attractive Enemies", 1000, -1)
    mq.delay(1023)
end