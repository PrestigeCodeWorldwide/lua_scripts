--- @type Mq
local mq = require("mq")

print("Spam Mezzing Dusk...")

while true do
	mq.cmd("/target Dusk")
	mq.delay(100)
	mq.cmd("/cast Chaotic")
	mq.delay(4500)
end
