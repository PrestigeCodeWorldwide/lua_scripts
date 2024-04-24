local mq = require("mq")
local BL = require("biggerlib")

-- /ctrlkey /itemnotify "etherne essence" leftmouseup
-- ${Window[ContainerWindow].Child[Container_Combine]}
--local win = mq.TLO.Window("ContainerWindow/Container_Combine")

while true do
    
mq.cmd("/notify ContainerWindow Container_Combine leftmouseup")
mq.delay(200)
end
