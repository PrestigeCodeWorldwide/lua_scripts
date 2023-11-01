local mq = require("mq")

local commandHandler = {}

local function initBinds()
	mq.bind("/nt", commandHandler.navTarget)
end

function commandHandler.navTarget()
	mq.cmd('/nav target')
end

local function main()
	initBinds()
	print("Aliases loaded.")

	while true do
		mq.delay(100)
	end
end


main()