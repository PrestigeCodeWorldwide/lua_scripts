--- @type Mq
local mq = require 'mq'
local assist = require('routines.assist')
local camp = require('routines.camp')
local logger = require('utils.logger')
local abilities = require('ability')
local state = require('state')

local mez = {}

function mez.init(zen)

end

---Scan mobs in camp and reset mez timers to current time
function mez.initMezTimers(mez_spell)
	camp.mobRadar()
	for id, _ in pairs(state.targets) do
		local mob = mq.TLO.Spawn('id ' .. id)
		if mob() and not state.mezImmunes[mob.CleanName()] then
			mob.DoTarget()
			mq.delay(1000, function()
				return mq.TLO.Target.BuffsPopulated()
			end)
			if mq.TLO.Target() and mq.TLO.Target.Buff(mez_spell)() then
				logger.debug(logger.flags.routines.mez, 'AEMEZ setting meztimer mob_id %d', id)
				state.targets[id].meztimer:reset()
			end
		end
	end
end

---Cast AE mez spell if AE Mez condition (>=3 mobs) is met.
---@param mez_spell table @The name of the AE mez spell to cast.
---@param ae_count number @The mob threshold for using AE mez.
function mez.doAE(mez_spell, ae_count)
	if state.mobCount >= ae_count and mez_spell then
		if mq.TLO.Me.Gem(mez_spell.CastName)() and mq.TLO.Me.GemTimer(mez_spell.CastName)() == 0 then
			print(logger.logLine('AE Mezzing (mobCount=%d)', state.mobCount))
			mq.cmd("/medley off")
			mq.delay(50)
			mq.cmd("/medley off")
			mq.delay(50)
			abilities.use(mez_spell)
			mez.initMezTimers()
			mq.delay(4500)
			mq.cmd("/medley")
			
			return true
		end
	end
end

function info(strtoprint)
	--printf(logger.logLine(strtoprint))
	printf(logger.logLine('%s', strtoprint))
end

function dump(o)
	if o == nil then
		return "nil"
	end
	if type(o) == 'table' then
		local s = '{ '
		for k, v in pairs(o) do
			if type(k) ~= 'number' then
				k = '"' .. k .. '"'
			end
			s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

-- Checks the duration of buff buffName on npc ID
function getBuffDurationFromId(id, buffName)
	local duration = mq.TLO.Spawn('id ' .. id).Buff(buffName).Duration()
	if duration == nil or duration == "NULL" then
		duration = 0
	end
	return duration
end

---Cast single target mez spell if adds in camp.
---@param mez_spell table @The name of the single target mez spell to cast.
function mez.doSingle(mez_spell)
	--	print("In mez")
	--logger.debug(logger.flags.announce.spell, 'In Mez')
	if state.mobCount <= 1 or not mez_spell or not mq.TLO.Me.Gem(mez_spell.CastName)() then
		return
	end
	
	for id, mobdata in pairs(state.targets) do
		
		local mobName = mq.TLO.Spawn(id).Name()
		local mob = mq.TLO.Spawn('id ' .. id)
		-- This is where we spin waiting on buffs to load.  We'll then check to see if they include aoe AFTER this returns
		--mq.delay(5000, function()
		--	buffsPop = mq.TLO.Target.BuffsPopulated()
		--	print("Buffs populated: ", buffsPop)
		--	return buffsPop
		--end)
		-- This is to let buffs populate, as BuffsPopulated() does not work
		
		local mezDuration = getBuffDurationFromId(id, "Slumber of the Diabo")
		
		local earlyReturn = false
		-- if the id is not assist mob id, mez
		-- if duration and durationAoE are nil/null then mez
		-- 	if either or both has a value, if the largest of those values is less than 4500, then mez
		-- otherwise don't mez
		
		-- When something is mezzed, the duration counts down in milliseconds.
		-- unmezzed, the duration type is nil
		-- The duration seems to expire a tick *before* the mez actually breaks in-game
		-- I'm using 4500 duration check anyway because I'd rather recast mez a bit early than have one break
		if not earlyReturn then
			if id ~= state.assistMobID and mezDuration < 4500 then
				if mob() and not state.mezImmunes[mob.CleanName()] then
					local spellData = mq.TLO.Spell(mez_spell.CastName)
					local maxLevel = spellData.Max(1)() or mq.TLO.Me.Level()
					if id ~= state.assistMobID and mob.Level() <= maxLevel and mob.Type() == 'NPC' then
						mq.cmd('/attack off')
						mq.delay(100, function()
							return not mq.TLO.Me.Combat()
						end)
						mob.DoTarget()
						
						local pct_hp = mq.TLO.Target.PctHPs()
						if mq.TLO.Target() and mq.TLO.Target.Type() == 'Corpse' then
							state.targets[id] = nil
						elseif pct_hp and pct_hp > 85 then
							local assist_spawn = assist.getAssistSpawn()
							if assist_spawn == -1 or assist_spawn.ID() ~= id then
								state.mezTargetName = mob.CleanName()
								state.mezTargetID = id
								print(logger.logLine('Mezzing >>> %s (%d) <<<', mob.Name(), mob.ID()))
								if mez_spell.precast then
									mez_spell.precast()
								end
								--Zen: Actual mez being "cast", need to pause medley, cast, then re-enable medley
								mq.cmd("/medley off")
								mq.delay(20)
								mq.cmd("/medley off")
								mq.delay(20)
								
								abilities.use(mez_spell)
								-- Zen: Wait on mez to finish casting
								mq.delay(4500, function()
									return not mq.TLO.Me.Casting()
								end)
								
								logger.debug(logger.flags.routines.mez, 'STMEZ setting meztimer mob_id %d', id)
								if state.targets[id] then
									state.targets[id].meztimer:reset()
								end
								
								mq.doevents('eventMezImmune')
								mq.doevents('eventMezResist')
								state.mezTargetID = 0
								state.mezTargetName = nil
								
								--Zen: Turn medley back on
								mq.cmd("/medley")
								return true
							end
						end
					
					
					elseif mob.Type() == 'Corpse' then
						state.targets[id] = nil
					end
				end
				print("Done with either skipping or mezzing")
			end
		end
	end
end

function mez.eventMezBreak(line, mob, breaker)
	print(logger.logLine('\at%s\ax mez broken by \at%s\ax', mob, breaker))
end

function mez.eventMezImmune(line)
	local mezTargetName = state.mezTargetName
	if mezTargetName then
		print(logger.logLine('Added to MEZ_IMMUNE: \at%s', mezTargetName))
		state.mezImmunes[mezTargetName] = 1
	end
end

function mez.eventMezResist(line, mob)
	local mezTargetName = state.mezTargetName
	if mezTargetName and mob == mezTargetName then
		print(logger.logLine('MEZ RESIST >>> \at%s\ax <<<', mezTargetName))
		state.targets[state.mezTargetID].meztimer:reset(0)
	end
end

function mez.setupEvents()
	mq.event('eventMezBreak', '#1# has been awakened by #2#.', mez.eventMezBreak)
	mq.event('eventMezImmune', 'Your target cannot be mesmerized#*#', mez.eventMezImmune)
	mq.event('eventMezResist', '#1# resisted your#*#slumber of the diabo#*#', mez.eventMezResist)
end

return mez
