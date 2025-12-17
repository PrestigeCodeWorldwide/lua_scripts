--- @type Mq
local mq = require('mq')
local ImGui = require 'ImGui'
local BL = require 'biggerlib'

BL.info("ChainCast v1.1 loaded")

local wasCasting = nil
-- Configuration
local config = {
	aaId = "",
	spellGem = "",
	maxAttempts = 0,
	enabled = false,
	currentAttempts = 0,
	lastCastTime = 0,
	castDelay = 1000, -- Delay between casts (ms)
	autoInv = false,
	window = {
		open = true,
		x = 100,
		y = 100,
		width = 300,
		height = 280
	}
}

local function DoCast()
	if not config.enabled or (config.maxAttempts > 0 and config.currentAttempts >= config.maxAttempts) then
		return
	end

	local now = mq.gettime()
	local timeSinceLastCast = now - config.lastCastTime
	local isCasting = mq.TLO.Me.Casting()
	local isBard = mq.TLO.Me.Class.ShortName() == "BRD"

	-- Don't cast if we're still in the delay period
	if timeSinceLastCast < config.castDelay then
		-- For bards, if we're not casting but the gem is still greyed out, force stop
		if isBard and not isCasting and mq.TLO.Me.CastTimeLeft() > 0 then
			mq.cmd("/stopcast")
		end
		return
	end

	-- For non-bards, check if already casting
	if not isBard and isCasting then
		return
	end

	-- Only proceed if we're not in the middle of a cast and we weren't just casting
	if not isCasting and (wasCasting == nil or wasCasting == false) then
		if config.aaId ~= "" and config.aaId ~= "0" then
			mq.cmd("/alt act " .. config.aaId)
			config.lastCastTime = now
			config.currentAttempts = config.currentAttempts + 1
			if config.autoInv then
				mq.delay(100)
				mq.cmd("/autoinv")
			end
		elseif config.spellGem ~= "" and config.spellGem ~= "0" then
			mq.cmd("/cast " .. config.spellGem)
			config.lastCastTime = now
			config.currentAttempts = config.currentAttempts + 1
			if config.autoInv then
				mq.delay(200)
				mq.cmd("/autoinv")
			end
			-- For bards, add a stopcast after the song duration
			if isBard then
				local songDuration = mq.TLO.Me.CastTimeLeft() or 1000
				mq.delay(songDuration + 100)   -- Wait for song to finish + small buffer
				mq.cmd("/stopcast")
				--mq.cmd("/stopsong")
			end
		end
	end


	-- Update the wasCasting state for the next iteration
	wasCasting = isCasting
end

-- Main function that will be called each frame
local function OnImGuiFrame()
	if not config.window.open then return end

	ImGui.SetNextWindowSize(300, 250, ImGuiCond.FirstUseEver)
	ImGui.SetNextWindowPos(100, 100, ImGuiCond.FirstUseEver)

	if ImGui.Begin("Chain Caster", config.window.open) then
		-- Toggle for enabling/disabling
		local newValue = ImGui.Checkbox("Enable", config.enabled)
		if newValue ~= config.enabled then
			config.enabled = newValue
			if config.enabled then
				config.currentAttempts = 0
			end
		end

		ImGui.SameLine()
		local newAutoInv = ImGui.Checkbox("AutoInv##autoinv", config.autoInv)
		if ImGui.IsItemHovered() then
			ImGui.SetTooltip("Will auto inventory anything on cursor after a cast")
		end
		if newAutoInv ~= config.autoInv then
			config.autoInv = newAutoInv
		end

		-- AA ID input
		ImGui.Text("AA ID:")
		ImGui.SameLine()
		local newAaId = ImGui.InputText("##aaid", config.aaId or "")
		if newAaId ~= nil then
			if newAaId == "" or newAaId:match("^%d*$") then
				config.aaId = newAaId
				if newAaId ~= "" then
					config.spellGem = ""
				end
			end
		end

		-- Spell Gem input
		ImGui.Text("Spell Gem:")
		ImGui.SameLine()
		local newSpellGem = ImGui.InputText("##spellgem", config.spellGem or "")
		if newSpellGem ~= nil then
			if newSpellGem == "" or newSpellGem:match("^%d*$") then
				config.spellGem = newSpellGem
				if newSpellGem ~= "" then
					config.aaId = ""
				end
			end
		end

		-- Cast Delay input
		ImGui.Text("Recast Delay (ms):")
		if ImGui.IsItemHovered() then
			ImGui.SetTooltip("Total delay between cast attempts starting at initial cast")
		end
		ImGui.SameLine()
		local newCastDelay = ImGui.InputText("##castdelay", tostring(config.castDelay or 1000))
		if newCastDelay ~= nil then
			if newCastDelay == "" or newCastDelay:match("^%d*$") then
				config.castDelay = tonumber(newCastDelay) or 1000
			end
		end

		-- Max attempts input
		ImGui.Text("Attempts (0=unlimited):")
		ImGui.SameLine()
		local newMaxAttempts = ImGui.InputText("##maxattempts", tostring(config.maxAttempts or 0))
		if newMaxAttempts ~= nil then
			if newMaxAttempts == "" or newMaxAttempts:match("^%d*$") then
				local num = tonumber(newMaxAttempts) or 0
				config.maxAttempts = math.max(0, math.floor(num))
			end
		end

		-- Status
		ImGui.Separator()
		ImGui.Text(string.format("Status: %s", config.enabled and "Running" or "Stopped"))
		if config.maxAttempts > 0 then
			ImGui.Text(string.format("Attempts: %d/%d", config.currentAttempts, config.maxAttempts))
		else
			ImGui.Text(string.format("Attempts: %d", config.currentAttempts))
		end
	end
	ImGui.End()
end

-- Register the ImGui callback
mq.imgui.init('ChainCaster', function()
    -- Begin window and check if it's open
    local windowOpen = ImGui.Begin("Chain Caster", config.window.open)
    if not windowOpen then
        config.window.open = false
        ImGui.End()
        return
    end
    OnImGuiFrame()
    ImGui.End()
end)

-- Command to toggle the window
mq.bind('/chaincast', function()
	config.window.open = not config.window.open
end)

-- Main loop
while config.window.open do
    DoCast()
    mq.delay(100)
end

-- Exit the script when the window is closed
mq.exit()
