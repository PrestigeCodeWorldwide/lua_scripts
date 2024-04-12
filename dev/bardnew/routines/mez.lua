--- @type Mq
local mq = require("mq")
local assist = require("routines.assist")
local camp = require("routines.camp")
local logger = require("utils.logger")
local abilities = require("ability")
local state = require("state")
local inspect = require("utils.inspect")

local function useClassOPTS()
	local class = require("classes.brd")
	return class.OPTS
end

local mez = {}

function mez.init(zen) end

---Scan mobs in camp and reset mez timers to current time
function mez.initMezTimers(mez_spell)
	camp.mobRadar()
	for id, _ in pairs(state.targets) do
		local mob = mq.TLO.Spawn("id " .. id)
		if mob() and not state.mezImmunes[mob.CleanName()] then
			mob.DoTarget()
			mq.delay(1000, function()
				return mq.TLO.Target.BuffsPopulated()
			end)
			if mq.TLO.Target() and mq.TLO.Target.Buff(mez_spell)() then
				logger.debug(logger.flags.routines.mez, "AEMEZ setting meztimer mob_id %d", id)
				state.targets[id].meztimer:reset()
			end
		end
	end
end

-- Checks the duration of buff buffName on npc ID
function getBuffDurationFromId(id, buffName)
	local duration = mq.TLO.Spawn("id " .. id).Buff(buffName).Duration()
	if duration == nil or duration == "NULL" then
		duration = 0
	end
	return duration
end

---Cast AE mez spell if AE Mez condition (>=3 mobs) is met.
---@param mez_spell table @The name of the AE mez spell to cast.
---@param ae_count number @The mob threshold for using AE mez.
function mez.doAE(mez_spell, ae_count)
	local opts = useClassOPTS()

	if not opts.MEZAE.value then
		--print("No AE mez bc it's disabled")
		return
	end
	
	if state.mobCount >= ae_count and mez_spell then
		-- loop thru mobs and count how many are mezzed with single target
		local mezzedCount = 0
		for id, _ in pairs(state.targets) do
			local durationSingle = getBuffDurationFromId(id, "Slumber of Suja")
			if durationSingle > 27000 then -- Make sure we don't overwrite mobs already long-duration mezzed
				mezzedCount = mezzedCount + 1
			end
		end

		local myGem = mq.TLO.Me.Gem(mez_spell.CastName)()
		local myGemTimer = mq.TLO.Me.GemTimer(mez_spell.CastName)()
		local unmezzedCount = state.mobCount - mezzedCount - 1 -- Subtract additional 1 for main target
		-- If we can cast AoE Mez and we have many unmezzed mobs, cast it
		if myGem then
			if myGemTimer == 0 then
				if unmezzedCount > 1 then
					print(logger.logLine("AE Mezzing (mobCount=%d)", state.mobCount))
					mq.cmd("/g AE Mezzing")
					mq.cmd("/stopsong")
					mq.delay(10)
					abilities.use(mez_spell)
					mez.initMezTimers()
					mq.delay(4500, function()
						return not mq.TLO.Me.Casting()
					end)

					return true
				else
					--printf("Not aoe mezzing bc there aren't enough unmezzed mobs (%s)", tostring(unmezzedCount))
				end
			else
				--print("No AE mez because gemTimer isn't == 0:  gemtimer is: ", myGemTimer or "nil")
			end
		else
			--print("NO AE MEZ BECAUSE myGem is null")
		end
	else
		--print("mobCount: " .. state.mobCount)
		--print("aeCount:" .. ae_count)
		--printf("Or mez_spell doesn't exist: %s", tostring(mez_spell))
	end
end

---Cast single target mez spell if adds in camp.
---@param mez_spell table @The name of the single target mez spell to cast.
function mez.doSingle(mez_spell)
	--print("IN MEZ.DOSINGLE with mobCount: " .. state.mobCount)
	-- Check if mobCount is too low
	if state.mobCount <= 1 then
		--print('Not casting ST mez because mobCount too low')
		return
	end

	-- Check if mez_spell exists
	if not mez_spell then
		print("Not casting ST mez because mez_spell does not exist! ")
		--dump(mez_spell)
		return
	end

	-- Check if gem is ready
	--local gemReady = mq.TLO.Me.Gem(mez_spell.CastName)()
	--if not gemReady then
	--	print('Not casting ST mez because gem isnt ready')
	--	return
	--end

	local opts = useClassOPTS()

	if not opts.MEZST.value then
		print("Not casting ST mez because its disabled in settings")
		return
	end

	for id, _ in pairs(state.targets) do
		local mob = mq.TLO.Spawn("id " .. id)

		local mezDuration = getBuffDurationFromId(id, "Slumber of Suja")
		-- This is only used to short circuit hte fn while testing.  Lua will not let you return early.
		local earlyReturn = false
		if not earlyReturn then
			if id ~= state.assistMobID and mezDuration < 4500 then
				if mob() and not state.mezImmunes[mob.CleanName()] then
					local spellData = mq.TLO.Spell(mez_spell.CastName)
					local maxLevel = spellData.Max(1)() or mq.TLO.Me.Level()
					if id ~= state.assistMobID and mob.Level() <= maxLevel and mob.Type() == "NPC" then
						mq.cmd("/attack off")
						mq.delay(100, function()
							return not mq.TLO.Me.Combat()
						end)
						mob.DoTarget()

						local pct_hp = mq.TLO.Target.PctHPs()
						if mq.TLO.Target() and mq.TLO.Target.Type() == "Corpse" then
							state.targets[id] = nil
						elseif pct_hp and pct_hp > 85 then
							local assist_spawn = assist.getAssistSpawn()
							if assist_spawn == -1 or assist_spawn.ID() ~= id then
								state.mezTargetName = mob.CleanName()
								state.mezTargetID = id
								print(logger.logLine("Single Target Mezzing >>> %s (%d) <<<", mob.Name(), mob.ID()))
								if mez_spell.precast then
									mez_spell.precast()
								end
								--Zen: Actual mez being "cast", need to pause songs, then cast
								mq.cmd("/stopcast")
								mq.delay(10)
								mq.cmd("/stopsong")
								mq.delay(10)

								mq.cmd("/g Single Mezzing " .. mob.CleanName())

								abilities.use(mez_spell)
								-- Zen: Wait on mez to finish casting
								mq.delay(4500, function()
									return not mq.TLO.Me.Casting()
								end)

								logger.debug(logger.flags.routines.mez, "STMEZ setting meztimer mob_id %d", id)
								if state.targets[id] then
									state.targets[id].meztimer:reset()
								end

								mq.doevents("eventMezImmune")
								mq.doevents("eventMezResist")
								state.mezTargetID = 0
								state.mezTargetName = nil

								return true
							end
						end
					elseif mob.Type() == "Corpse" then
						state.targets[id] = nil
					else
						--printf(
						--	"Not single target mezzing because either it's the MT target, it's too high level (%s vs %s) or isn't an NPC (%s)",
						--	mob.Level(), maxLevel, mob.Type())
					end
				end
				--print("Done with either skipping or mezzing")
			else
				--printf("Skipping mob because it's MT target or already mezzed for longer than 4500ms: %d", mezDuration)
			end
		end
	end
end

function mez.eventMezBreak(line, mob, breaker)
	print(logger.logLine("\at%s\ax mez broken by \at%s\ax", mob, breaker))
end

function mez.eventMezImmune(line)
	local mezTargetName = state.mezTargetName
	if mezTargetName then
		print(logger.logLine("Added to MEZ_IMMUNE: \at%s", mezTargetName))
		state.mezImmunes[mezTargetName] = 1
	end
end

function mez.eventMezResist(line, mob)
	local mezTargetName = state.mezTargetName
	if mezTargetName and mob == mezTargetName then
		print(logger.logLine("MEZ RESIST >>> \at%s\ax <<<", mezTargetName))
		state.targets[state.mezTargetID].meztimer:reset(0)
	end
end

function mez.setupEvents()
	mq.event("eventMezBreak", "#1# has been awakened by #2#.", mez.eventMezBreak)
	mq.event("eventMezImmune", "Your target cannot be mesmerized#*#", mez.eventMezImmune)
	mq.event("eventMezResist", "#1# resisted your#*#slumber of the suja#*#", mez.eventMezResist)
end

return mez
