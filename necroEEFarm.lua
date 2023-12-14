--- @type Mq
local mq = require('mq')

while true do
	mq.cmd('/cast "Inspire Ally"')
	mq.delay(20)
	mq.cmd('/cast "Incite Ally"')
	mq.delay(20)
	mq.cmd('/cast "Infuse Ally"')
	mq.delay(20)
	mq.cmd('/cast "Imbue Ally"')
	mq.delay(3000)
	mq.cmd('/removepetbuff Ally')
	mq.delay(1000)
	mq.cmd('/autoinv')
	mq.delay(1000)
end
