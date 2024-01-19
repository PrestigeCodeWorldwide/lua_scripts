---@type Mq
local mq = require("mq")
local BL = require("biggerlib")
local State = require("state")
local settings = require("settings")
local ui = require("ui")
local Burn = require("burn")

local function main()
	terminate = false
	mq.bind("/burn", Burn.args_cmd_handler)
	settings.init()
	BL.cmd.sendRaidChannelMessage("Burninator loaded")
	
	Burn.Init()

	ui.init(Burn.uiEventHandlers)
	State.refreshClassList()

	Burn.TurnOffPluginUses()

	local PeriodicCoPCacheTimer = -1

	while not State.terminate do
		if not State.paused then
			PeriodicCoPCacheTimer = PeriodicCoPCacheTimer - 1
			if PeriodicCoPCacheTimer <= 0 then
				PeriodicCoPCacheTimer = 10
				if State.driver and State.runCircleRotation then
					--mq.cmd("/rs WHOCANPOWER.")
				end
			end

			--Burn.HandleCircleOfPower()
			mq.doevents()
			mq.delay(100)
		end
	end

	ui.destroy()
end

main()
