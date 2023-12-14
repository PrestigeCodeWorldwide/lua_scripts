--- @type Mq
local mq = require("mq")
local named = require("data.named")
local config = require("interface.configuration")
local helpers = require("utils.helpers")
local logger = require("utils.logger")
local movement = require("utils.movement")
local timer = require("utils.timer")
local abilities = require("ability")
local constants = require("constants")
local mode = require("mode")
local state = require("state")

local common = {}

local familiar = mq.TLO.Familiar and mq.TLO.Familiar.Stat.Item.ID() or mq.TLO.FindItem("Personal Hemic Source").ID()
-- Familiar: Personal Hemic Source
local illusion = mq.TLO.Illusion and mq.TLO.Illusion.Stat.Item.ID() or mq.TLO.FindItem("Jann's Veil").ID()
-- Illusion Benefit Greater Jann
local mount = mq.TLO.Mount and mq.TLO.Mount.Stat.Item.ID() or mq.TLO.FindItem("Golden Owlbear Saddle").ID()
-- Mount Blessing Meda

-- Generic Helper Functions

function common.isNamedMob(zone_short_name, mob_name)
	return named[zone_short_name:lower()] and named[zone_short_name:lower()][mob_name]
end

-- MQ Helper Functions

---Lookup the ID for a given spell.
--- @param spellName string #The name of the spell.
--- @return table|nil #Returns a table containing the spell rank name and spell ID
local function getSpell(spellName)
	local spell = mq.TLO.Spell(spellName)
	local rankname = spell.RankName()
	if not mq.TLO.Me.Book(rankname)() then
		return nil
	end
	return { ID = spell.ID(), Name = rankname }
end

function common.getBestSpell(spells, options)
	for i, spellName in ipairs(spells) do
		local bestSpell = getSpell(spellName)
		if bestSpell then
			if not options then
				options = {}
			end
			for key, value in pairs(options) do
				bestSpell[key] = value
			end
			return abilities.Spell:new(bestSpell)
		end
	end
	return nil
end

---Lookup the ID for a given AA.
---@param aaName string @The name of the AA.
---@param options table|nil @A table of options relating to the AA, such as the setting name controlling use of the AA
---@return table|nil @Returns a table containing the AA name, AA ID and the provided option name.
function common.getAA(aaName, options)
	local aaData = mq.TLO.Me.AltAbility(aaName)
	if aaData() then
		if not options then
			options = {}
		end
		local spellData = { ID = aaData.ID(), Name = aaData.Name() }
		for key, value in pairs(options) do
			spellData[key] = value
		end
		return abilities.AA:new(spellData)
	end
	return nil
end

local function getDisc(discName)
	local disc = mq.TLO.Spell(discName)
	local rankName = disc.RankName()
	if not rankName or not mq.TLO.Me.CombatAbility(rankName)() then
		return nil
	end
	return { ID = disc.ID(), Name = rankName }
end

---Lookup the ID for a given disc.
---@param discs table @An ordered list of discs from best to worst
---@param options table|nil @A table of options relating to the disc, such as the setting name controlling use of the disc
---@return table|nil @Returns a table containing the disc name with rank, disc ID and the provided option name.
function common.getBestDisc(discs, options)
	for _, discName in ipairs(discs) do
		local bestDisc = getDisc(discName)
		if bestDisc then
			print(logger.logLine("Found Disc: %s (%s)", bestDisc.Name, bestDisc.ID))
			if not options then
				options = {}
			end
			for key, value in pairs(options) do
				bestDisc[key] = value
			end
			return abilities.Disc:new(bestDisc)
		end
	end
	print(logger.logLine("[%s] Could not find disc!", discs[1]))
	return nil
end

function common.getItem(itemName, options)
	if not itemName then
		return nil
	end
	local itemRef = mq.TLO.FindItem("=" .. itemName)
	if itemRef() and itemRef.Clicky() then
		if not options then
			options = {}
		end
		local spellData = { ID = itemRef.ID(), Name = itemRef.Name() }
		for key, value in pairs(options) do
			spellData[key] = value
		end
		return abilities.Item:new(spellData)
	end
	return nil
end

function common.getSkill(name, options)
	if not mq.TLO.Me.Ability(name) or not mq.TLO.Me.Skill(name)() or mq.TLO.Me.Skill(name)() == 0 then
		return nil
	end
	if not options then
		options = {}
	end
	local spellData = { Name = name }
	for key, value in pairs(options) do
		spellData[key] = value
	end
	return abilities.Skill:new(spellData)
end

function common.setSwapGem()
	if not mq.TLO.Me.Class.CanCast() then
		return
	end
	state.swapGem = mq.TLO.Me.NumGems()
end

---Check whether the specified dot is applied to the target.
---@param spell_id number @The ID of the spell to check.
---@param spell_name string @The name of the spell to check.
---@return boolean @Returns true if the spell is applied to the target, false otherwise.
function common.isTargetDottedWith(spell_id, spell_name)
	return mq.TLO.Target.MyBuff(spell_name)() ~= nil
	--if not mq.TLO.Target.MyBuff(spell_name)() then return false end
	--return spell_id == mq.TLO.Target.MyBuff(spell_name).ID()
end

---Determine whether currently fighting a target.
---@return boolean @True if standing with an NPC targeted, and not in a resting state, false otherwise.
function common.isFighting()
	--if mq.TLO.Target.CleanName() == 'Combat Dummy Beza' then return true end -- Dev hook for target dummy
	-- mq.TLO.Me.CombatState() ~= "ACTIVE" and mq.TLO.Me.CombatState() ~= "RESTING" and mq.TLO.Target.Type() ~= "Corpse" and not mq.TLO.Me.Feigning()
	return mq.TLO.Me.CombatState() == "COMBAT" --mq.TLO.Target.ID() and mq.TLO.Me.CombatState() == 'COMBAT' and mq.TLO.Target.Type() == "NPC"-- and mq.TLO.Me.Standing()
end

---Determine if there are any hostile targets on XTarget.
---@return boolean @Returns true if at least 1 hostile auto hater spawn on XTarget, otherwise false.
function common.hostileXTargets()
	if mq.TLO.Me.XTarget() == 0 then
		return false
	end
	for i = 1, 20 do
		if mq.TLO.Me.XTarget(i).TargetType() == "Auto Hater" and mq.TLO.Me.XTarget(i).Type() == "NPC" then
			return true
		end
	end
	return false
end

function common.clearToBuff()
	return mq.TLO.Me.CombatState() ~= "COMBAT" and not common.hostileXTargets() and not common.amIDead()
end

function common.isFightingModeBased()
	local mode = mode.currentMode
	if mode:isTankMode() then
	elseif mode:isAssistMode() then
	elseif mode:getName() == "manual" then
		if mq.TLO.Group.MainTank.ID() == state.loop.ID then
		else
		end
	end
end

---Determine whether currently in control of the character, i.e. not CC'd, stunned, mezzed, etc.
---@return boolean @Returns true if not under any loss of control effects, false otherwise.
function common.inControl()
	return not (
		mq.TLO.Me.Dead()
		or mq.TLO.Me.Ducking()
		or mq.TLO.Me.Charmed()
		or mq.TLO.Me.Stunned()
		or mq.TLO.Me.Silenced()
		or mq.TLO.Me.Feigning()
		or mq.TLO.Me.Mezzed()
		or mq.TLO.Me.Invulnerable()
		or mq.TLO.Me.Hovering()
	)
end

function common.isBlockingWindowOpen()
	-- check blocking windows -- BigBankWnd, MerchantWnd, GiveWnd, TradeWnd
	return mq.TLO.Window("BigBankWnd").Open()
		or mq.TLO.Window("MerchantWnd").Open()
		or mq.TLO.Window("GiveWnd").Open()
		or mq.TLO.Window("TradeWnd").Open()
		or mq.TLO.Window("LootWnd").Open()
end

-- Movement Functions

---Chase after the assigned chase target if alive and in chase mode and the chase distance is exceeded.
local checkChaseTimer = timer:new(1000)
function common.checkChase()
	if mode.currentMode:getName() ~= "chase" then
		return
	end
	--if not checkChaseTimer:timerExpired() then return end
	--checkChaseTimer:reset()
	if
		mq.TLO.Stick.Active()
		or mq.TLO.Me.Combat()
		or mq.TLO.Me.AutoFire()
		or (state.class ~= "brd" and mq.TLO.Me.Casting())
	then
		--if logger.flags.common.chase then
		logger.debug(
			logger.flags.common.chase,
			"Not chasing due to one of: Stick.Active=%s, Me.Combat=%s, Me.AutoFire=%s, Me.Casting=%s",
			mq.TLO.Stick.Active(),
			mq.TLO.Me.Combat(),
			mq.TLO.Me.AutoFire,
			mq.TLO.Me.Casting()
		)
		--end
		return
	end
	local chaseTarget = config.get("CHASETARGET")
	local chase_spawn

	if not chaseTarget or chaseTarget == "" or chaseTarget == " " then
		-- Use group MA if not specified target
		local ma = mq.TLO.Group.MainAssist()
		if not ma then
			logger.info("\ar In Chase Mode, but no MA role found, no Chase Target set manually, so not chasing")
			return
		end

		chase_spawn = mq.TLO.Spawn("pc =" .. ma)
		chaseTarget = ma or false
	else
		chase_spawn = mq.TLO.Spawn("pc =" .. config.get("CHASETARGET"))
	end

	local me_x = mq.TLO.Me.X()
	local me_y = mq.TLO.Me.Y()
	local chase_x = chase_spawn.X()
	local chase_y = chase_spawn.Y()
	if not chase_x or not chase_y then
		--logger.info('Not chasing due to invalid chase spawn X=%s,Y=%s', chase_x, chase_y)
		return
	end
	if helpers.distance(me_x, me_y, chase_x, chase_y) > (config.get("CHASEDISTANCE") ^ 2) then
		if mq.TLO.Me.Sitting() and not mq.TLO.Group.MainAssist.Sitting() then
			mq.cmd("/stand")
		end
		if not movement.navToSpawn("pc =" .. chaseTarget, "dist=20") then
			local chaseSpawn = mq.TLO.Spawn("pc " .. chaseTarget)
			if not mq.TLO.Navigation.Active() and chaseSpawn.LineOfSight() then
				mq.cmdf("/moveto id %s", chaseSpawn.ID())
				mq.delay(1000)
				mq.cmd("/keypress FORWARD")
			end
		end
	end
end

-- Casting Functions

function common.isSpellReady(spell, skipCheckTarget)
	if not spell then
		return false
	end

	if not mq.TLO.Me.SpellReady(spell.Name)() then
		return false
	end
	local spellData = mq.TLO.Spell(spell.Name)
	if
		spellData.Mana() > mq.TLO.Me.CurrentMana() or (spellData.Mana() > 1000 and state.loop.PctMana < state.minMana)
	then
		return false
	end
	if
		spellData.EnduranceCost() > mq.TLO.Me.CurrentEndurance()
		or (spellData.EnduranceCost() > 1000 and state.loop.PctEndurance < state.minEndurance)
	then
		return false
	end
	if not skipCheckTarget and spellData.TargetType() == "Single" then
		if not mq.TLO.Target() or mq.TLO.Target.Type() == "Corpse" then
			return false
		end
	end

	if spellData.Duration.Ticks() > 0 then
		local buff_duration = 0
		local remaining_cast_time = 0
		buff_duration = mq.TLO.Target.MyBuffDuration(spell.Name)()
		if not common.isTargetDottedWith(spell.ID, spell.Name) then
			-- target does not have the dot, we are ready
			return true
		else
			if not buff_duration then
				return true
			end
			remaining_cast_time = spellData.MyCastTime()
			return buff_duration < remaining_cast_time + 3000
		end
	else
		return true
	end
end

-- Burn Helper Functions

---Determine whether the conditions are met to engage burn routines.
---@param alwaysCondition function|nil @An extra function which can be provided to determine if the always burn condition should fire.
---@return boolean @Returns true if any burn condition is satisfied, otherwise false.
function common.isBurnConditionMet(alwaysCondition)
	-- activating a burn condition is good for 60 seconds, don't do check again if 60 seconds hasn't passed yet and burn is active.
	if not state.burnActiveTimer:timerExpired() and state.burnActive then
		return true
	else
		state.burnActive = false
	end
	if state.burnNow then
		state.burnActiveTimer:reset()
		state.burnActive = true
		state.burnNow = false
		return true
	elseif mq.TLO.Me.CombatState() == "COMBAT" or common.hostileXTargets() then
		local zone_sn = mq.TLO.Zone.ShortName():lower()
		if config.get("BURNALWAYS") then
			if alwaysCondition and not alwaysCondition() then
				return false
			end
			state.burn_type = nil
			return true
		elseif config.get("BURNALLNAMED") and named[zone_sn] and named[zone_sn][mq.TLO.Target.CleanName()] then
			print(logger.logLine("\arActivating Burns (named)\ax"))
			state.burnActiveTimer:reset()
			state.burnActive = true
			state.burn_type = nil
			return true
		elseif
			mq.TLO.SpawnCount(string.format("xtarhater radius %d zradius 50", config.get("CAMPRADIUS")))()
			>= config.get("BURNCOUNT")
		then
			print(logger.logLine("\arActivating Burns (mob count > %d)\ax", config.get("BURNCOUNT")))
			state.burnActiveTimer:reset()
			state.burnActive = true
			state.burn_type = nil
			return true
		elseif config.get("BURNPCT") ~= 0 and mq.TLO.Target.PctHPs() < config.get("BURNPCT") then
			print(logger.logLine("\arActivating Burns (percent HP)\ax"))
			state.burnActiveTimer:reset()
			state.burnActive = true
			state.burn_type = nil
			return true
		end
	end
	state.burnActiveTimer:reset(0)
	state.burnActive = false
	state.burn_type = nil
	return false
end

---Check Geomantra buff and click charm item if missing and item is ready.
function common.checkCombatBuffs()
	if state.emu then
		return
	end
	if not mq.TLO.Me.Buff("Geomantra")() then
		local charm = mq.TLO.Me.Inventory("Charm")
		local charmSpell = charm.Clicky.Spell()
		if charmSpell and charmSpell:lower():find("geomantra") then
			abilities.use(abilities.Item:new({ Name = charm(), ID = charm.ID() }))
		end
	end
end

---Check and cast any missing familiar, illusion or mount buffs. Removes illusion and dismounts after casting.
function common.checkItemBuffs()
	if familiar and familiar > 0 and not mq.TLO.Me.Buff("Familiar:")() then
		local familiarItem = mq.TLO.FindItem(familiar)
		abilities.use(abilities.Item:new({ Name = familiarItem(), ID = familiarItem.ID() }))
		mq.delay(500 + familiarItem.CastTime())
		mq.cmdf("/removebuff %s", familiarItem.Clicky())
	end
	if illusion and illusion > 0 and not mq.TLO.Me.Buff("Illusion Benefit")() then
		local illusionItem = mq.TLO.FindItem(illusion)
		abilities.use(abilities.Item:new({ Name = illusionItem(), ID = illusionItem.ID() }))
		mq.delay(500 + illusionItem.CastTime())
		mq.cmd("/removebuff illusion:")
	end
	if mount and mount > 0 and not mq.TLO.Me.Buff("Mount Blessing")() and mq.TLO.Me.CanMount() then
		local mountItem = mq.TLO.FindItem(mount)
		abilities.use(abilities.Item:new({ Name = mountItem(), ID = mountItem.ID() }))
		mq.delay(500 + mountItem.CastTime())
		mq.cmdf("/removebuff %s", mountItem.Clicky())
	end
end

local modrods = {
	["Summoned: Dazzling Modulation Shard"] = true,
	["Sickle of Umbral Modulation"] = true,
	["Wand of Restless Modulation"] = true,
	["Summoned: Large Modulation Shard"] = true,
	["Summoned: Medium Modulation Shard"] = true,
	["Summoned: Small Modulation Shard"] = true,
	["Azure Mind Crystal"] = true,
}
---Attempt to click mod rods if mana is below 75%.
function common.checkMana()
	-- modrods
	local pct_mana = state.loop.PctMana
	local pct_end = state.loop.PctEndurance
	local group_mana = mq.TLO.Group.LowMana(70)()
	local feather = mq.TLO.FindItem("=Unified Phoenix Feather") or mq.TLO.FindItem("=Miniature Horn of Unity")
	if pct_mana < 75 and mq.TLO.Me.Class.CanCast() then
		local cursor = mq.TLO.Cursor.Name()
		if
			cursor
			and (
				cursor == "Summoned: Dazzling Modulation Shard"
				or cursor == "Sickle of Umbral Modulation"
				or cursor == "Wand of Restless Modulation"
			)
		then
			mq.cmd("/autoinventory")
			mq.delay(50)
		end
		-- Find ModRods in check_mana since they poof when out of charges, can't just find once at startup.
		for item, _ in pairs(modrods) do
			local modrod = mq.TLO.FindItem(item)
			if modrod() and mq.TLO.Me.PctHPs() > 70 then
				abilities.use(abilities.Item:new({ Name = modrod(), ID = modrod.ID() }))
			end
		end
		-- use feather for self if not grouped (group.LowMana is null if not grouped)
		if feather() and not group_mana and not mq.TLO.Me.Song(feather.Spell.Name())() then
			abilities.use(abilities.Item:new({ Name = feather(), ID = feather.ID() }))
		end
	end
	-- use feather for group if > 2 members are below 70% mana
	if feather() and group_mana and group_mana > 2 and not mq.TLO.Me.Song(feather.Spell.Name())() then
		abilities.use(abilities.Item:new({ Name = feather(), ID = feather.ID() }))
	end

	if mq.TLO.Zone.ShortName() ~= "poknowledge" and mq.TLO.Me.Class.CanCast() then
		local manastone = mq.TLO.FindItem("Manastone")
		if
			manastone()
			and mq.TLO.Me.PctMana() < config.get("MANASTONESTART")
			and state.loop.PctHPs > config.get("MANASTONESTARTHP")
		then
			local manastoneTimer = timer:new((config.get("MANASTONETIME") or 0) * 1000, true)
			while mq.TLO.Me.PctHPs() > config.get("MANASTONESTOPHP") and not manastoneTimer:timerExpired() do
				mq.cmd("/useitem manastone")
			end
		end
	end
end

local sitTimer = timer:new(10000)
---Sit down to med if the conditions for resting are met.
function common.rest()
	if not config.get("MEDCOMBAT") and (mq.TLO.Me.CombatState() == "COMBAT" or state.assistMobID ~= 0) then
		return
	end
	if state.mobCount > 0 and (mode.currentMode:isTankMode() or mq.TLO.Group.MainTank() == mq.TLO.Me.CleanName()) then
		return
	end
	-- try to avoid just constant stand/sit, mainly for dumb bard sitting between every song
	if sitTimer:timerExpired() then
		if
			(mq.TLO.Me.Class.CanCast() and state.loop.PctMana < config.get("MEDMANASTART"))
			or state.loop.PctEndurance < config.get("MEDENDSTART")
		then
			state.medding = true
		end
		if not mq.TLO.Me.Sitting() and not mq.TLO.Me.Moving() and not mq.TLO.Me.Casting() and state.medding then
			--and not mq.TLO.Me.Combat() and not mq.TLO.Me.AutoFire() and
			--mq.TLO.SpawnCount(string.format('xtarhater radius %d zradius 50', config.get('CAMPRADIUS')))() == 0 then
			mq.cmd("/sit")
			sitTimer:reset()
		end
	end
	if mq.TLO.Me.Class.CanCast() then
		if state.loop.PctMana > 85 then
			state.medding = false
		end
	else
		if state.loop.PctEndurance > 85 then
			state.medding = false
		end
	end
end

-- keep cursor clear for spell swaps and such
local autoInventoryTimer = timer:new(15000)
---Autoinventory an item if it has been on the cursor for 15 seconds.
function common.checkCursor()
	if mq.TLO.Cursor() then
		if common.amIDead() and constants.deleteWhenDead[mq.TLO.Cursor.Name()] then
			print(logger.logLine("Deleting %s from cursor because im dead and have no bags!", mq.TLO.Cursor.Name()))
		elseif autoInventoryTimer.start_time == 0 then
			autoInventoryTimer:reset()
			print(logger.logLine("Dropping cursor item into inventory in 15 seconds"))
		elseif autoInventoryTimer:timerExpired() then
			mq.cmd("/autoinventory")
			autoInventoryTimer:reset(0)
		end
	elseif autoInventoryTimer.start_time ~= 0 then
		logger.debug(logger.flags.common.misc, "Cursor is empty, resetting autoInventoryTimer")
		autoInventoryTimer:reset(0)
	end
end

function common.processList(aList, returnOnFirstUse)
	for _, entry in ipairs(aList) do
		if abilities.use(entry) and returnOnFirstUse then
			return true
		end
	end
end

--Shamelessly stolen from Rekka and E3Next
function common.amIDead()
	for i = 1, 10 do
		local slot = mq.TLO.Me.Inventory("pack" .. i)
		if slot() then
			return false
		end
	end
	if mq.TLO.Me.Inventory("Chest")() then
		return false
	end
	return true
end

return common
