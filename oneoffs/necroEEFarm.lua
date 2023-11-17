--- @type Mq
local mq = require("mq")

while true do
	mq.cmd('/cast "Inspire Ally"')
	mq.delay(20)
	mq.cmd('/cast "Incite Ally"')
	mq.delay(20)
	mq.cmd('/cast "Infuse Ally"')
	mq.delay(20)
	mq.cmd('/cast "Imbue Ally"')
	mq.delay(300)
	mq.cmd('/removepetbuff Ally')
	mq.delay(250)
	mq.cmd('/autoinv')
	mq.delay(100)
end