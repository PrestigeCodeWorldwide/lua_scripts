---@type Mq
local mq = require("mq")
local BL = require("biggerlib")
local state = require("state")
local settings = require("settings")
local ui = require("ui")
local Burn = require("burn")

local function main()
	mq.bind("/burn", Burn.args_cmd_handler)
	settings.init()
	BL.cmd.sendRaidChannelMessage("Burninator loaded")

	-- Matcher Text follows pattern: "Burninate" (trigger phrase) - "Funeral Dirge" (spell name to cast) - "Robothaus" (toon to cast) "." (Period required at end)
	-- Meant for "/rs Burninate - Funeral Dirge - Robothaus." or "/rs Burninate - Perseverance - Caelinaex."
	mq.event("burninate", "#*#Burninate - #1# - #2#.#*#", Burn.burninateEventHandler)

	ui.init(Burn.uiEventHandlers)
	state.refreshClassList()

	while true or not terminate do
		mq.doevents()
		mq.delay(1000)
	end

	ui.destroy()
end

main()
