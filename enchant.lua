--- @type Mq
local mq = require('mq')
--- @type ImGui
require 'ImGui'


while true do
	if not mq.TLO.Me.Casting() then
		mq.cmd('/casting "Greater Mass Enchant Clay"')
	end
	mq.delay(1000)
end
