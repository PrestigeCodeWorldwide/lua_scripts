local mq = require('mq')

local horizontalOffset = 750
local verticalOffset = 150
local function baglineup()
	local EQPath = string.format('%s/eqclient', mq.TLO.EverQuest.Path())
	local window_width = mq.TLO.Ini.File(EQPath).Section('VideoMode').Key('WindowedWidth').Value()
	--local window_width = 1920 -- change this to fit your game resolution
	print('\agStarting Bag line up \nDont touch your keyboard or mouse')
	
	mq.cmd('/cleanup')
	local numbagslots = mq.TLO.Me.NumBagSlots() + 22
	for bag = numbagslots, 23, -1 do
		if mq.TLO.Me.Inventory(bag).Container() > 0 then
			printf('\ayLining up bagslot: \at%s', bag - 22)
			mq.cmdf('/itemnotify %s rightmouseup', bag)
			mq.delay(250)
			local width = mq.TLO.Window('ContainerWindow').Width() * 1.25
			local height = mq.TLO.Window('ContainerWindow').Height()
			mq.TLO
				.Window('ContainerWindow')
				.Move(string.format('%s,%s,%s,%s', window_width - width - horizontalOffset, verticalOffset, width, height))
			mq.delay(250)
			mq.cmdf('/itemnotify %s rightmouseup', bag)
			window_width = window_width - width
		else
			printf('\ayBagslot: \at%s\ay - not a container', bag - 22)
		end
	end
	print('\ayDONE!!')
end

baglineup()
