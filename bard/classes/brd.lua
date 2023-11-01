--- @type Mq
local mq = require 'mq'
local class = require('classes.classbase')
local logger = require('utils.logger')
local timer = require('utils.timer')
local abilities = require('ability')
local common = require('common')
local state = require('state')
local assist = require('routines.assist')

local zen

function class.spellRotationChangeCheck()
	if class.spellRotationsChanged then
		class.initSpellRotations(zen)
		class.spellRotationsChanged = false
		return true
	end
	return false
end

function class.init(_zen)
	zen = _zen
	class.classOrder = { 'sitCheck', 'spellRotationChangeCheck', 'assist', 'mez', 'assist', 'aggro', 'burn', 'cast',
		'mash', 'ae', 'recover', 'buff', 'rest' }
	class.EPIC_OPTS = { always = 1, shm = 1, burn = 1, never = 1 }
	class.MEDLEY_OPTS = {
		melee = 1,
		caster = 1,
		meleedot = 1,
		tank = 1,
		ADPSFirst = 1,
		DOTFirst = 1,
		downtime = 1,
		test = 1
	}
	class.medleyRunning = false
	class.spellRotations = { melee = {}, caster = {}, meleedot = {}, raidtank = {}, downtime = {} }
	class.DEFAULT_SPELLSET = 'meleedot'
	class.spellRotationsChanged = true

	class.initBase(_zen, 'brd')

	-- resets stick to default
	mq.cmd('/squelch /stick off')
	mq.cmd('/squelch /stick mod 0')
	-- Let /stick front work for non-tanks DO NOT REMOVE
	mq.cmd('/squelch /stick set nohottfront on')

	class.initClassOptions()
	class.loadSettings()
	class.initSpellLines(_zen)
	class.initSpellRotations(_zen)
	class.initDPSAbilities(_zen)
	class.initBurns(_zen)
	class.initBuffs(_zen)
	class.initDefensiveAbilities(_zen)
	class.initRecoverAbilities(_zen)

	-- Bellow handled separately as we want it to run its course and not be refreshed early
	class.bellow = common.getAA('Boastful Bellow')

	-- aa mez
	class.dirge = common.getAA('Dirge of the Sleepwalker')
	class.sonic = common.getAA('Sonic Disturbance')
	class.fluxstaff = common.getItem('Staff of Viral Flux')

	class.selos = common.getAA('Selo\'s Sonata')

	if mq.TLO.Me.Combat() then
		class.startMedley()
	else
		class.startMedley("downtime")
	end
end

function dump(t, indent)
	indent = indent or '  '

	-- Base case: if t is not a table, print and return
	if type(t) ~= "table" then
		print(indent .. tostring(t))
		return
	end

	-- Recursive case: iterate through the table and call dump() for each element
	for k, v in pairs(t) do
		if type(v) == "table" then
			print(indent .. tostring(k) .. " :")
			dump(v, indent .. "  ")
		else
			print(indent .. tostring(k) .. " : " .. tostring(v))
		end
	end
end

function class.sitCheck()
	-- get main assist
	local myAssist = assist.getMainAssist()
	-- see if he's sitting
	local isSitting = myAssist.Sitting()
	local meSitting = mq.TLO.Me.Sitting()

	if isSitting and not meSitting then
		-- turn off medley/songs
		if class.OPTS.USEMEDLEY.value then
			class.stopMedley()
		end

		-- sit
		mq.cmd('/sit')
		-- Delay long enough the TLO starts returning True for Sitting()
		mq.delay(3500, function()
			return mq.TLO.Me.Sitting()
		end)
	elseif not isSitting and mq.TLO.Me.Sitting() then
		mq.cmd("/stand")
	end
end

function class.IsInvis()
	return mq.TLO.Me.Invis() or ((state.loop and state.loop.Invis))
end

function class.stopMedley()
	if class.medleyRunning ~= 'none' then
		class.priorMedley = class.medleyRunning
		mq.cmd('/medley stop')
		-- Often need to call stop twice for it to fully take effect
		mq.delay(10)
		mq.cmd('/medley stop')
		class.medleyRunning = 'none'
	end
end

function class.startMedley(medleyName)
	if class.OPTS.USEMEDLEY.value and not class.IsInvis() and not mq.TLO.Me.Sitting() then
		if not medleyName or medleyName == '' then
			medleyName = class.OPTS.MEDLEYTYPE.value
		end

		mq.cmd('/medley ' .. medleyName)
		class.medleyRunning = medleyName
	end
end

function info(...)
	local args = { ... }
	--printf(logger.logLine(strtoprint))
	printf(logger.logLine(args))
end

function class.doSingleMez()
	if state.mobCount <= 1 or not mez_spell or not mq.TLO.Me.Gem(mez_spell.CastName)() then
		return
	end
	for id, mobdata in pairs(state.targets) do
		if state.debug then
			logger.debug(logger.flags.routines.mez, '[%s] meztimer: %s, currentTime: %s, timerExpired: %s', id,
				mobdata['meztimer'].start_time, mq.gettime(), mobdata['meztimer']:timerExpired())
		end
		if id ~= state.assistMobID and (mobdata['meztimer'].start_time == 0 or mobdata['meztimer']:timerExpired()) then
			local mob = mq.TLO.Spawn('id ' .. id)
			if mob() and not state.mezImmunes[mob.CleanName()] then
				local spellData = mq.TLO.Spell(mez_spell.CastName)
				local maxLevel = spellData.Max(1)() or mq.TLO.Me.Level()
				if id ~= state.assistMobID and mob.Level() <= maxLevel and mob.Type() == 'NPC' then
					mq.cmd('/attack off')
					mq.delay(100, function()
						return not mq.TLO.Me.Combat()
					end)
					mob.DoTarget()
					mq.delay(1000, function()
						return mq.TLO.Target.BuffsPopulated()
					end)
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
							-- Actual mez being "cast", probably need to pause medley, cast, then re-enable medley?
							-- Maybe make a concrete mez subroutine?
							--abilities.use(mez_spell)

							mq.cmd('/medley queue "Slumber of the Diabo" -interrupt')
							info("Mez cast, delaying 4500")
							mq.delay(4500)

							logger.debug(logger.flags.routines.mez, 'STMEZ setting meztimer mob_id %d', id)
							state.targets[id].meztimer:reset()
							mq.doevents('eventMezImmune')
							mq.doevents('eventMezResist')
							state.mezTargetID = 0
							state.mezTargetName = nil
							return true
						end
					end
				elseif mob.Type() == 'Corpse' then
					state.targets[id] = nil
				end
			end
		end
	end
end

-- This function takes over for class.cast() if we're using Medley.  It will handle all the things cast() handles, but start /medley <proper_type> instead of casting
function class.medley()
	--printf("In medley with combat state: %s", mq.TLO.Me.CombatState())

	-- If in combat, we use the chosen combat song - states are ACTIVE, COMBAT, COOLDOWN
	if mq.TLO.Me.CombatState() == 'COMBAT' and not class.IsInvis() then
		if class.OPTS.USEMEDLEY.value then
			if class.medleyRunning ~= class.OPTS.MEDLEYTYPE.value then
				mq.cmd('/medley ' .. class.OPTS.MEDLEYTYPE.value)

				class.medleyRunning = class.OPTS.MEDLEYTYPE.value
			end
		end
	elseif not class.IsInvis() and not mq.TLO.Me.Sitting() then
		-- If not in combat, we use the downtime song
		if class.OPTS.USEMEDLEY.value then
			if class.medleyRunning ~= 'downtime' then
				mq.cmd('/medley downtime')
				class.medleyRunning = 'downtime'
			end
		end
	end

	-- If we're invis, stop medley
	if class.IsInvis() and class.medleyRunning ~= 'none' then
		class.stopMedley()
	end

	if not class.IsInvis() then
		-- Combat checks for clickies
		if mq.TLO.Target.Type() == 'NPC' and mq.TLO.Me.CombatState() == 'COMBAT' then
			if (class.OPTS.USEEPIC.value == 'always' or state.burnActive or (class.OPTS.USEEPIC.value == 'shm' and mq.TLO.Me.Song('Prophet\'s Gift of the Ruchu')())) then
				if class.useEpic() then
					mq.delay(250)
					return true
				end
			end
			for _, clicky in ipairs(class.castClickies) do
				if clicky.TargetType == 'Single' then
					-- if single target clicky then make sure in combat
					if (clicky.Duration == 0 or not mq.TLO.Target.Buff(clicky.CheckFor)()) then
						if clicky:use() then
							mq.delay(250)
							return true
						end
					end
				elseif clicky.Duration == 0 or (not mq.TLO.Me.Buff(clicky.CheckFor)() and not mq.TLO.Me.Song(clicky.CheckFor)()) then
					-- otherwise just use the clicky if its instant or we don't already have the buff/song
					if clicky:use() then
						mq.delay(250)
						return true
					end
				end
			end
		end
	end
	return false
end

function class.initClassOptions()
	-- base.addOption(key, label, value, options, tip, type, exclusive, tlo, tlotype)

	class.addOption('CAMPHARD', 'Camp Hard (never move)', false, nil, 'If checked, character will not move or navigate',
		'checkbox', nil, 'CampHard', 'bool')
	class.addOption('USEEPIC', 'Epic', 'always', class.EPIC_OPTS, 'Set how to use bard epic', 'combobox', nil, 'UseEpic',
		'string')
	class.addOption('MEZST', 'Mez ST', true, nil, 'Mez single target', 'checkbox', nil, 'MezST', 'bool')
	class.addOption('MEZAE', 'Mez AE', true, nil, 'Mez AOE', 'checkbox', nil, 'MezAE', 'bool')
	class.addOption('MEZAECOUNT', 'Mez AE Count', 3, nil, 'Threshold to use AE Mez ability', 'inputint', nil,
		'MezAECount', 'int')
	class.addOption('USEMEDLEY', 'Use Medley', false, nil, 'Use MQ2Medley instead of managing songs', 'checkbox', nil,
		'UseMedley', 'bool')
	class.addOption('MEDLEYTYPE', 'Medley Type', 'melee', class.MEDLEY_OPTS, 'Use MQ2Medley instead of managing songs',
		'combobox', nil, 'MedleyType', 'string')
	class.addOption('STICKHOW', 'StickHow', '!front snaproll moveback uw loose', nil, 'stick command', 'inputtext', nil,
		'StickHowTLO', 'string')

	class.addOption('USESELOS', 'Use Selos', true, nil, 'Use Selos (Turn off for nav problems)', 'checkbox', nil,
		'UseSelos', 'bool')
	class.addOption('USEFUNERALDIRGE', 'Use Funeral Dirge', true, nil, 'Use Funeral Dirge during burns automatically',
		'checkbox', nil, 'UseFuneralDirge', 'bool')
	--class.addOption('USEINSULTS', 'Use Insults', true, nil, 'Use insult songs', 'checkbox', nil, 'UseInsults', 'bool')
	--class.addOption('USEINTIMIDATE', 'Use Intimidate', false, nil, 'Use Intimidate (It may fear mobs without the appropriate AA\'s)', 'checkbox', nil, 'UseIntimidate', 'bool')
	class.addOption('USEBELLOW', 'Use Bellow', true, nil, 'Use Boastful Bellow AA', 'checkbox', nil, 'UseBellow', 'bool')
	-- Caco not worth debuff slot anymore
	--class.addOption('USECACOPHONY', 'Use Cacophony', true, nil, 'Use Cacophony AA', 'checkbox', nil, 'UseCacophony', 'bool')
	class.addOption('USEFADE', 'Use Fade', false, nil, 'Fade when aggro', 'checkbox', nil, 'UseFade', 'bool')
	class.addOption('RALLYGROUP', 'Rallying Group', false, nil, 'Use Rallying Group AA', 'checkbox', nil, 'RallyGroup',
		'bool')
	class.addOption('USESWARM', 'Use Swarm', true, nil, 'Use swarm pet AAs', 'checkbox', nil, 'UseSwarm', 'bool')
	class.addOption('USESNARE', 'Use Snare', false, nil, 'Use snare song', 'checkbox', nil, 'UseSnare', 'bool')
	class.addOption('USEAMPLIFY', 'Use Amplify', true, nil, 'Use Amplification during downtime', 'checkbox', nil,
		'UseAmplify', 'bool')
	class.addOption('USECARETAKER', 'Use Caretaker', true, nil, 'Use Caretaker self-buff', 'checkbox', nil,
		'UseCaretaker', 'bool')
	class.addOption('USEPROGRESSIVE', 'Use Ecliptic Psalm', true, nil, 'Use Ecliptic Progressive', 'checkbox', nil,
		'UseProgressive', 'bool')
	class.addOption('USECRESCENDO', 'Use Crescendo', true, nil, 'Use Crescendo Regen (Uses endurance)', 'checkbox', nil,
		'UseCrescendo', 'bool')
	class.addOption('USEPULSE', 'Use Pulse', true, nil, 'Use Pulse (Regen + Heal buff)', 'checkbox', nil, 'UsePulse',
		'bool')
	class.addOption('USEDOTS', 'Use DoTs', true, nil, 'Toggle use of DoT songs', 'checkbox', nil, 'UseDoTs', 'bool')
	-- TODO: Finish useinsult by figuring out why it's handled differently
	--class.addOption('USEINSULT', 'Use Insult Synergy Nuke', true, nil, 'Toggle use of Insults (Lots of mana)', 'checkbox', nil, 'UseInsult', 'bool')
	--class.addOption('USEFIREDOTS', 'Use Fire DoT', false, nil, 'Toggle use of Fire DoT songs if they are in the selected song list', 'checkbox', nil, 'UseFireDoTs', 'bool')
	--class.addOption('USEFROSTDOTS', 'Use Frost DoT', false, nil, 'Toggle use of Frost DoT songs if they are in the selected song list', 'checkbox', nil, 'UseFrostDoTs', 'bool')
	--class.addOption('USEPOISONDOTS', 'Use Poison DoT', false, nil, 'Toggle use of Poison DoT songs if they are in the selected song list', 'checkbox', nil, 'UsePoisonDoTs', 'bool')
	--class.addOption('USEDISEASEDOTS', 'Use Disease DoT', false, nil, 'Toggle use of Disease DoT songs if they are in the selected song list', 'checkbox', nil, 'UseDiseaseDoTs', 'bool')
	--class.addOption('USEREGENSONG', 'Use Regen Song', false, nil, 'Toggle use of hp/mana regen song line', 'checkbox', nil, 'UseRegenSong', 'bool')
	--class.addOption('USETWIST', 'Use Twist', false, nil, 'Use MQ2Twist instead of managing songs', 'checkbox', nil, 'UseTwist', 'bool')
end

function class.initSpellLines(_zen)
	-- All spells ID + Rank name
	-- All spells ID + Rank name
	class.addSpell('aura',
		{ 'Aura of Pli Xin Liako', 'Aura of Margidor', 'Aura of Begalru', 'Aura of the Muse', 'Aura of Insight' })  -- spell dmg, overhaste, flurry, triple atk
	class.addSpell('composite', { 'Ecliptic Psalm', 'Composite Psalm', 'Dissident Psalm', 'Dichotomic Psalm' })     -- DD+melee dmg bonus + small heal
	class.addSpell('aria', { 'Aria of Pli Xin Liako', 'Aria of Margidor', 'Aria of Begalru', })                     -- spell dmg, overhaste, flurry, triple atk
	class.addSpell('warmarch', { 'War March of Centien Xi Va Xakra', 'War March of Radiwol', 'War March of Dekloaz' }) -- haste, atk, ds
	class.addSpell('arcane', { 'Arcane Harmony', 'Arcane Symphony', 'Arcane Ballad', 'Arcane Aria' })               -- spell dmg proc
	class.addSpell('suffering',
		{ 'Shojralen\'s Song of Suffering', 'Omorden\'s Song of Suffering', 'Travenro\'s Song of Suffering',
			'Storm Blade', 'Song of the Storm' })                                                                       -- melee dmg proc
	class.addSpell('spiteful', { 'Von Deek\'s Spiteful Lyric', 'Omorden\'s Spiteful Lyric', 'Travenro\' Spiteful Lyric' }) -- AC
	class.addSpell('pulse',
		{ 'Pulse of Nikolas', 'Pulse of Vhal`Sera', 'Pulse of Xigarn', 'Cantata of Life', 'Chorus of Life',
			'Wind of Marr', 'Chorus of Marr', 'Chorus of Replenishment', 'Cantata of Soothing' },
		{ opt = 'USEREGENSONG' })                                                                         -- heal focus + regen
	class.addSpell('sonata', { 'Xetheg\'s Spry Sonata', 'Kellek\'s Spry Sonata', 'Kluzen\'s Spry Sonata' }) -- spell shield, AC, dmg mitigation
	class.addSpell('dirge', { 'Dirge of the Onokiwan', 'Dirge of the Restless', 'Dirge of Lost Horizons' }) -- spell+melee dmg mitigation
	class.addSpell('firenukebuff',
		{ 'Constance\'s Aria', 'Sontalak\'s Aria', 'Quinard\'s Aria', 'Rizlona\'s Fire', 'Rizlona\'s Embers' }) -- inc fire DD for instant nukes, not dots
	class.addSpell('firemagicdotbuff',
		{ 'Fyrthek Fior\'s Psalm of Potency', 'Velketor\'s Psalm of Potency', 'Akett\'s Psalm of Potency' }) -- inc fire+mag dot
	class.addSpell('crescendo',
		{ 'Zelinstein\'s Lively Crescendo', 'Zburator\'s Lively Crescendo', 'Jembel\'s Lively Crescendo' }) -- small heal hp, mana, end
	class.addSpell('insult', { 'Yelinak\'s Insult', 'Sathir\'s Insult' })                                 -- synergy DD
	class.addSpell('insult2', { 'Sogran\'s Insult', 'Omorden\'s Insult', 'Travenro\'s Insult' })          -- synergy DD 2
	class.addSpell('chantflame',
		{ 'Shak Dathor\'s Chant of Flame', 'Sontalak\'s Chant of Flame', 'Quinard\'s Chant of Flame',
			'Vulka\'s Chant of Flame', 'Tuyen\'s Chant of Fire', 'Tuyen\'s Chant of Flame' }, { opt = 'USEFIREDOTS' })
	class.addSpell('chantfrost',
		{ 'Sylra Fris\' Chant of Frost', 'Yelinak\'s Chant of Frost', 'Ekron\'s Chant of Frost',
			'Vulka\'s Chant of Frost', 'Tuyen\'s Chant of Ice', 'Tuyen\'s Chant of Frost' }, { opt = 'USEFROSTDOTS' })
	class.addSpell('chantdisease',
		{ 'Coagulus\' Chant of Disease', 'Zlexak\'s Chant of Disease', 'Hoshkar\'s Chant of Disease',
			'Vulka\'s Chant of Disease', 'Tuyen\'s Chant of the Plague', 'Tuyen\'s Chant of Disease' },
		{ opt = 'USEDISEASEDOTS' })
	class.addSpell('chantpoison',
		{ 'Cruor\'s Chant of Poison', 'Malvus\'s Chant of Poison', 'Nexona\'s Chant of Poison',
			'Vulka\'s Chant of Poison', 'Tuyen\'s Chant of Venom', 'Tuyen\'s Chant of Poison' },
		{ opt = 'USEPOISONDOTS' })
	class.addSpell('alliance',
		{ 'Coalition of Sticks and Stones', 'Covenant of Sticks and Stones', 'Alliance of Sticks and Stones' })
	class.addSpell('mezst', { 'Slumber of the Diabo', 'Slumber of Zburator', 'Slumber of Jembel' })
	class.addSpell('mezae', { 'Wave of Nocturn', 'Wave of Sleep', 'Wave of Somnolence' })

	-- haste song doesn't stack with enc haste?
	class.addSpell('overhaste', { 'Ancient: Call of Power', 'Warsong of the Vah Shir', 'Battlecry of the Vah Shir' })
	class.addSpell('bardhaste', { 'Verse of Veeshan', 'Psalm of Veeshan', 'Composition of Ervaj' })
	class.addSpell('snare', { 'Selo\'s Consonant Chain' }, { opt = 'USESNARE' })
	class.addSpell('debuff', { 'Harmony of Sound' })

	-- Older songs still frequently used
	class.addSpell('amplify', { 'Amplification' }, { opt = 'USEAMPLIFY' })
	class.addSpell('caretaker', { 'Jonthan\'s Mightful Caretaker' }, { opt = 'USECARETAKER' })
end

function class.initSpellRotations(_zen)
	-- entries in the dots table are pairs of {spell id, spell name} in priority order
	--class.spellRotations.melee = {
	--	class.spells.composite, class.spells.crescendo, class.spells.aria,
	--	class.spells.spiteful, class.spells.suffering, class.spells.warmarch,
	--	class.spells.pulse, class.spells.dirge
	--}
	-- AFTER always inserted is synergy/mezst/mezae
	-- synergy insult, mezst, mstae

	class.spellRotations.melee = {
		{ spell = class.spells.aria,     reuseTimeMillis = 30000, lastUsedMillis = 0, isHostile = false },
		{ spell = class.spells.warmarch, reuseTimeMillis = 30000, lastUsedMillis = 0, isHostile = false }
	}

	local gemsUsed = 2

	if class.OPTS.USEPULSE.value then
		table.insert(class.spellRotations.melee,
			{ spell = class.spells.pulse, reuseTimeMillis = 30000, lastUsedMillis = 0, isHostile = false })
		gemsUsed = gemsUsed + 1
	end
	if class.OPTS.USEDOTS.value then
		table.insert(class.spellRotations.melee,
			{ spell = class.spells.chantflame, reuseTimeMillis = 18000, lastUsedMillis = 0, isHostile = true })
		table.insert(class.spellRotations.melee,
			{ spell = class.spells.chantdisease, reuseTimeMillis = 18000, lastUsedMillis = 0, isHostile = true })
		table.insert(class.spellRotations.melee,
			{ spell = class.spells.chantfrost, reuseTimeMillis = 18000, lastUsedMillis = 0, isHostile = true })
		table.insert(class.spellRotations.melee,
			{ spell = class.spells.chantpoison, reuseTimeMillis = 18000, lastUsedMillis = 0, isHostile = true })
		gemsUsed = gemsUsed + 4
	end
	if class.OPTS.USECARETAKER.value then
		table.insert(class.spellRotations.melee,
			{ spell = class.spells.caretaker, reuseTimeMillis = 30000, lastUsedMillis = 0, isHostile = false }) -- example lastUsedMillis value
		gemsUsed = gemsUsed + 1
	end
	if class.OPTS.USEPROGRESSIVE.value then
		table.insert(class.spellRotations.melee,
			{ spell = class.spells.composite, reuseTimeMillis = 66000, lastUsedMillis = 0, isHostile = false }) -- Ecliptic recast is 60 sec
		gemsUsed = gemsUsed + 1
	end
	if class.OPTS.USECRESCENDO.value then
		table.insert(class.spellRotations.melee,
			{ spell = class.spells.crescendo, reuseTimeMillis = 30000, lastUsedMillis = 0, isHostile = false }) -- example lastUsedMillis value
		gemsUsed = gemsUsed + 1
	end
	if class.OPTS.USEAMPLIFY.value then
		table.insert(class.spellRotations.melee,
			{ spell = class.spells.amplify, reuseTimeMillis = 66000, lastUsedMillis = 0, isHostile = false }) -- example lastUsedMillis value
		gemsUsed = gemsUsed + 1
	end

	if gemsUsed > 10 then
		print(logger.logLine(
			"WARNING: You have %d gems used in your melee rotation, which doesn't leave room for synergy/mezst/mezae.  Please select fewer.",
			gemsUsed))
	end

	local possibilities = {
		{ spell = class.spells.arcane,    reuseTimeMillis = 30000, lastUsedMillis = 0 }, -- example lastUsedMillis value
		{ spell = class.spells.suffering, reuseTimeMillis = 30000, lastUsedMillis = 0 }, -- example lastUsedMillis value
		{ spell = class.spells.spiteful,  reuseTimeMillis = 30000, lastUsedMillis = 0 }, -- example lastUsedMillis value
		{ spell = class.spells.dirge,     reuseTimeMillis = 30000, lastUsedMillis = 0 } -- example lastUsedMillis value
	}

	for i, entry in ipairs(possibilities) do
		if gemsUsed < 13 then
			table.insert(class.spellRotations.melee, entry)
			gemsUsed = gemsUsed + 1
		else
			break
		end
	end

	if gemsUsed < 13 then
		print(logger.logLine("WARNING: Only %d gems are being used, which is less than the maximum of 13.", gemsUsed))
	end

	-- TODO: Update these to use the new spell rotation system
	class.spellRotations.caster = {
		class.spells.composite, class.spells.crescendo, class.spells.aria,
		class.spells.arcane, class.spells.firenukebuff, class.spells.suffering,
		class.spells.warmarch, class.spells.firemagicdotbuff, class.spells.pulse,
		class.spells.dirge
	}
	-- synergy insult, mezst, mezae

	class.spellRotations.meleedot = {
		class.spells.composite, class.spells.crescendo,
		class.spells.aria, class.spells.warmarch,
		class.spells.suffering, class.spells.pulse, class.spells.dirge,
		class.spells.chatflame, class.spells.chantdisease, class.spells.chantfrost
	}
	-- synergy insult, mezst, mezae
end

function class.initDPSAbilities(_zen)
	table.insert(class.DPSAbilities, common.getBestDisc({ 'Reflexive Rebuttal' }))
	table.insert(class.DPSAbilities, common.getSkill('Intimidation', { opt = 'USEINTIMIDATE' }))
	table.insert(class.DPSAbilities, common.getSkill('Kick'))

	table.insert(class.AEDPSAbilities, common.getAA('Vainglorious Shout', { threshold = 2 }))
end

function class.initBurns(_zen)
	table.insert(class.burnAbilities, common.getItem(mq.TLO.InvSlot('Chest').Item.Name()))
	table.insert(class.burnAbilities, common.getItem('Rage of Rolfron'))
	table.insert(class.burnAbilities, common.getAA('Quick Time'))
	table.insert(class.burnAbilities, common.getAA('Funeral Dirge', { opt = 'USEFUNERALDIRGE' }))
	table.insert(class.burnAbilities, common.getAA('Spire of the Minstrels'))
	table.insert(class.burnAbilities, common.getAA('Bladed Song'))
	table.insert(class.burnAbilities, common.getAA('Dance of Blades'))
	table.insert(class.burnAbilities, common.getAA('Flurry of Notes'))
	table.insert(class.burnAbilities, common.getAA('Frenzied Kicks'))
	table.insert(class.burnAbilities, common.getBestDisc({ 'Thousand Blades' }))
	table.insert(class.burnAbilities, common.getAA('Cacophony', { opt = 'USECACOPHONY' }))
	-- Delay after using swarm pet AAs while pets are spawning
	table.insert(class.burnAbilities, common.getAA('Lyrical Prankster', { opt = 'USESWARM', delay = 1500 }))
	table.insert(class.burnAbilities, common.getAA('Song of Stone', { opt = 'USESWARM', delay = 1500 }))

	table.insert(class.burnAbilities, common.getBestDisc({ 'Puretone Discipline' }))
end

function class.initBuffs(_zen)
	table.insert(class.auras, class.spells.aura)
	table.insert(class.selfBuffs, common.getAA('Sionachie\'s Crescendo'))
end

function class.initDefensiveAbilities(_zen)
	table.insert(class.defensiveAbilities, common.getAA('Shield of Notes'))
	table.insert(class.defensiveAbilities, common.getAA('Hymn of the Last Stand'))
	table.insert(class.defensiveAbilities, common.getBestDisc({ 'Deftdance Discipline' }))

	-- Aggro
	local preFade = function()
		mq.cmd('/attack off')
	end
	local postFade = function()
		mq.delay(1000)
		mq.cmd('/multiline ; /makemevis ; /attack on')
	end
	table.insert(class.fadeAbilities,
		common.getAA('Fading Memories', { opt = 'USEFADE', precase = preFade, postcast = postFade }))
end

function class.initRecoverAbilities(_zen)
	-- Mana Recovery AAs
	class.rallyingsolo = common.getAA('Rallying Solo',
		{ mana = true, endurance = true, threshold = 20, combat = false, ooc = true })
	table.insert(class.recoverAbilities, class.rallyingsolo)
	class.rallyingcall = common.getAA('Rallying Call')
end

local selosTimer = timer:new(30000)
local crescendoTimer = timer:new(53000)
local bellowTimer = timer:new(30000)
local synergyTimer = timer:new(18000)

class.resetClassTimers = function()
	bellowTimer:reset(0)
	synergyTimer:reset(0)
end

-- Casts alliance if we are fighting, alliance is enabled, the spell is ready, alliance isn't already on the mob, there is > 1 necro in group or raid, and we have at least a few dots on the mob.
local function tryAlliance()
	local alliance = class.spells.alliance and class.spells.alliance.Name
	if class.isEnabled('USEALLIANCE') and alliance then
		if mq.TLO.Spell(alliance).Mana() > mq.TLO.Me.CurrentMana() then
			return false
		end
		if mq.TLO.Me.Gem(alliance)() and mq.TLO.Me.GemTimer(alliance)() == 0 and not mq.TLO.Target.Buff(alliance)() and mq.TLO.Spell(alliance).StacksTarget() then
			class.spells.alliance:use()
			return true
		end
	end
	return false
end

local function castSynergy()
	-- don't nuke if i'm not attacking
	local synergy = class.spells.insult and class.spells.insult.Name
	if class.isEnabled('USEINSULTS') and synergyTimer:timerExpired() and synergy and mq.TLO.Me.Combat() then
		if not mq.TLO.Me.Song('Troubadour\'s Synergy')() and mq.TLO.Me.Gem(synergy)() and mq.TLO.Me.GemTimer(synergy)() == 0 then
			if mq.TLO.Spell(synergy).Mana() > mq.TLO.Me.CurrentMana() then
				return false
			end
			class.spells.insult:use()
			synergyTimer:reset()
			return true
		end
	end
	return false
end

local function isDotReady(spellId, spellName)
	-- don't dot if i'm not attacking
	if not spellName or not mq.TLO.Me.Combat() then
		return false
	end
	local actualSpellName = spellName
	if state.subscription ~= 'GOLD' then
		actualSpellName = spellName:gsub(' Rk%..*', '')
	end
	local songDuration = 0
	if not mq.TLO.Me.Gem(spellName)() or mq.TLO.Me.GemTimer(spellName)() ~= 0 then
		return false
	end
	if not mq.TLO.Target() or mq.TLO.Target.ID() ~= state.assistMobID or mq.TLO.Target.Type() == 'Corpse' then
		return false
	end

	songDuration = mq.TLO.Target.MyBuffDuration(actualSpellName)()
	if not common.isTargetDottedWith(spellId, actualSpellName) then
		-- target does not have the dot, we are ready
		logger.debug(logger.flags.class.cast, 'song ready %s', spellName)
		return true
	else
		if not songDuration then
			logger.debug(logger.flags.class.cast, 'song ready %s', spellName)
			return true
		end
	end

	return false
end

local function isSongReady(spellId, spellName)
	if not spellName then
		return false
	end
	local actualSpellName = spellName
	if state.subscription ~= 'GOLD' then
		actualSpellName = spellName:gsub(' Rk%..*', '')
	end
	if mq.TLO.Spell(spellName).Mana() > mq.TLO.Me.CurrentMana() or (mq.TLO.Spell(spellName).Mana() > 1000 and state.loop.PctMana < state.minMana) then
		return false
	end
	if mq.TLO.Spell(spellName).EnduranceCost() > mq.TLO.Me.CurrentEndurance() or (mq.TLO.Spell(spellName).EnduranceCost() > 1000 and state.loop.PctEndurance < state.minEndurance) then
		return false
	end
	if mq.TLO.Spell(spellName).TargetType() == 'Single' then
		return isDotReady(spellId, spellName)
	end

	if not mq.TLO.Me.Gem(spellName)() or mq.TLO.Me.GemTimer(spellName)() > 0 then
		return false
	end
	if spellName == (class.spells.crescendo and class.spells.crescendo.name) and (mq.TLO.Me.Buff(actualSpellName)() or not crescendoTimer:timerExpired()) then
		-- buggy song that doesn't like to go on CD
		return false
	end

	local songDuration = mq.TLO.Me.Song(actualSpellName).Duration() or mq.TLO.Me.Buff(actualSpellName).Duration()
	if not songDuration then
		logger.debug(logger.flags.class.cast, 'song ready %s', spellName)
		return true
	else
		local cast_time = mq.TLO.Spell(spellName).MyCastTime()
		if songDuration < cast_time + 500 then
			logger.debug(logger.flags.class.cast, 'song ready %s', spellName)
		end
		return songDuration < cast_time + 500
	end
end

local function findNextSong()
	if tryAlliance() then
		return nil
	end
	if castSynergy() then
		return nil
	end
	if not mq.TLO.Target.Snared() and class.isEnabled('USESNARE') and ((mq.TLO.Target.PctHPs() or 100) < 30) then
		return class.spells.snare
	end
	local songLowestDuration = 999999
	local songLowestDurationToReturn = nil

	for _, spell in ipairs(class.spellRotations[class.OPTS.SPELLSET.value]) do
		-- iterates over the dots array. ipairs(dots) returns 2 values, an index and its value in the array. we don't care about the index, we just want the dot
		local song = spell.spell
		local song_id = song.ID
		local song_name = song.Name
		local songReuseTime = spell.reuseTimeMillis
		local songLastUsedTime = spell.lastUsedMillis

		-- I need to figure out how long the song has remaining.
		local currentTime = mq.gettime()
		-- While iterating, find the song with the lowest time remaining
		local timeSinceLastUse = currentTime - songLastUsedTime
		local timeLeftOnSong = songReuseTime - timeSinceLastUse



		if isSongReady(song_id, song_name)
			and class.isAbilityEnabled(song.opt)
			-- on first-pass priority queue, only recast the song if it's about to drop
			and timeLeftOnSong < 3500
		then
			local myTarget = mq.TLO.Target()
			logger.info("Casting on %s! Song %s has %d ms left", myTarget or "None", song_name, timeLeftOnSong)

			--if song_name ~= (class.spells.composite and class.spells.composite.Name) or mq.TLO.Target() then			
			--	return song
			--end
			if song_name ~= (class.spells.composite and class.spells.composite.Name) or mq.TLO.Target() then
				if spell.isHostile then
					-- Only cast if in combat and target is not self
					if mq.TLO.Me.CombatState() == 'COMBAT' and mq.TLO.Target.Type() == 'NPC' and mq.TLO.Target.ID() ~= mq.TLO.Me.ID() then
						return song
					end
				else
					-- For non-hostile spells, continue with the original logic
					return song
				end
			end
		end
		if timeLeftOnSong < songLowestDuration then
			songLowestDuration = timeLeftOnSong
			songLowestDurationToReturn = spell
		end
	end
	if songLowestDurationToReturn == nil then
		print(logger.logLine("WARNING: No song found to cast"))
		return nil
	else
		local lowestDurationSpell = songLowestDurationToReturn.spell
		
		if songLowestDurationToReturn.isHostile then
			-- Only return the song if in combat and target is not self
			if mq.TLO.Me.CombatState() == 'COMBAT' and mq.TLO.Target.Type() == 'NPC' and mq.TLO.Target.ID() ~= mq.TLO.Me.ID() then
				print(logger.logLine("SINGING HOSTILE SONG FROM LOWEST DURATION: " .. songLowestDurationToReturn.spell.Name))
				return songLowestDurationToReturn.spell
			else 
			logger.info("NO SONG TO CAST BECAUSE NEXT IS HOSTILE AND I HAVE NO HOSTILE TARGET")
			end
			
		else
			-- For non-hostile spells, continue with the original logic
			print(logger.logLine("SINGING GROUP SONG FROM LOWEST DURATION: " .. songLowestDurationToReturn.spell.Name))
			return songLowestDurationToReturn.spell
		end
	end
end

function class.cast()
	--print("In class.cast()")
	-- Don't touch songs if we're using mq2twist or mq2medley or we're invis
	if class.isEnabled('USETWIST') or mq.TLO.Me.Invis() then
		print("Skipping medley because USETWIST enabled or i'm invis")
		return false
	end
	if class.isEnabled('USEMEDLEY') then
		--print("Calling medley subroutine")
		class.medley()
		return false
	end

	if not state.loop.Invis and class.doneSinging() and not mq.TLO.Me.Sitting() then
		-- Combat checks for clickies
		if mq.TLO.Target.Type() == 'NPC' and mq.TLO.Me.CombatState() == 'COMBAT' then
			if (class.OPTS.USEEPIC.value == 'always' or state.burnActive or (class.OPTS.USEEPIC.value == 'shm' and mq.TLO.Me.Song('Prophet\'s Gift of the Ruchu')())) then
				if class.useEpic() then
					mq.delay(250)
					return true
				end
			end
			for _, clicky in ipairs(class.castClickies) do
				if clicky.TargetType == 'Single' then
					-- if single target clicky then make sure in combat
					if (clicky.Duration == 0 or not mq.TLO.Target.Buff(clicky.CheckFor)()) then
						if clicky:use() then
							mq.delay(250)
							return true
						end
					end
				elseif clicky.Duration == 0 or (not mq.TLO.Me.Buff(clicky.CheckFor)() and not mq.TLO.Me.Song(clicky.CheckFor)()) then
					-- otherwise just use the clicky if its instant or we don't already have the buff/song
					if clicky:use() then
						mq.delay(250)
						return true
					end
				end
			end
		end
		local spell = findNextSong() -- find the first available dot to cast that is missing from the target
		if spell then
			-- if a song was found
			local didCast = false
			if spell.TargetType == 'Single' and mq.TLO.Target.Type() == 'NPC' then
				if mq.TLO.Me.CombatState() == 'COMBAT' then
					didCast = spell:use()
				end
			else
				didCast = spell:use()
			end

			-- Update lastUsedMillis if the spell was successfully cast
			if didCast then
				local currentTime = mq.gettime()
				for _, entry in ipairs(class.spellRotations[class.OPTS.SPELLSET.value]) do
					if entry.spell.ID == spell.ID then
						print(logger.logLine("Updating lastUsedMillis for " .. spell.Name))
						entry.lastUsedMillis = currentTime
						break
					end
				end
			end

			if not mq.TLO.Me.Casting() then
				-- not casting, so either we just played selos or missed a note, take some time for unknown reasons
				mq.delay(250)
			end
			if spell.Name == (class.spells.crescendo and class.spells.crescendo.Name) then
				crescendoTimer:reset()
			end
			return didCast
		end
	end
	return false
end

local fierceeye = common.getAA('Fierce Eye')
local epic = common.getItem('Blade of Vesagran') or common.getItem('Prismatic Dragon Blade')
function class.useEpic()
	if not fierceeye or not epic then
		if fierceeye then
			return fierceeye:use()
		end
		if epic then
			return epic:use()
		end
		return
	end
	local fierceeye_rdy = mq.TLO.Me.AltAbilityReady(fierceeye.Name)()
	if epic:isReady() and fierceeye_rdy then
		mq.cmd('/stopsong')
		mq.delay(250)
		fierceeye:use()
		mq.delay(250)
		epic:use()
		mq.delay(500)
		return true
	end
end

function class.burnClass()
	class.useEpic()
end

function class.mashClass()
	if class.isEnabled('USEBELLOW') and class.bellow and bellowTimer:timerExpired() and class.bellow:use() then
		bellowTimer:reset()
	end
end

function class.hold()
	if class.rallyingsolo and (mq.TLO.Me.Song(class.rallyingsolo.Name)() or mq.TLO.Me.Buff(class.rallyingsolo.Name)()) then
		if state.mobCount >= 3 then
			return false
		elseif mq.TLO.Target() and mq.TLO.Target.Named() then
			return false
		else
			return true
		end
	else
		return false
	end
end

function class.invis()
	mq.cmd('/stopcast')
	mq.delay(1)
	if class.OPTS.USESELOS.value then
		mq.cmd('/cast "selo\'s song of travel"')
	end
	mq.delay(3500, function()
		return mq.TLO.Me.Invis()
	end)
	state.loop.Invis = true
end

-- aura, chorus, war march, storm, rizlonas, verse, ancient,selos, chant flame, echoes, nivs

function class.pullCustom()
	if class.fluxstaff then
		class.fluxstaff:use()
	elseif class.sonic then
		class.sonic:use()
	end
end

function class.doneSinging()
	-- #TODO: Remove this usemedley forced true and build it into casting
	if class.isEnabled('USETWIST') or class.isEnabled('USEMEDLEY') then
		return true
	end
	if mq.TLO.Me.CastTimeLeft() > 0 and not mq.TLO.Window('CastingWindow').Open() then
		mq.delay(250)
		mq.cmd('/stopsong')
		mq.delay(1)
	end
	if not mq.TLO.Me.Casting() then
		if not class.spells.selos and class.selos and selosTimer:timerExpired() and class.OPTS.USESELOS.value then
			class.selos:use()
			selosTimer:reset()
		end
		return true
	end
	return false
end

return class
