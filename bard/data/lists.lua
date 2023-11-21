local lists = {}

lists.instantHealClickies = {
	'Orb of Shadows',
	'Distillate of Celestial Healing X',
	--'Distillate of Divine Healing X',
	'Sanguine Mind Crystal III',
}
lists.durationHealClickies = {
	'Distillate of Celestial Healing X',
}
lists.ddClickies = {
	'Molten Orb',
	'Lava Orb',
}
lists.deleteWhenDead = {
	['Molten Orb'] = true,
	['Lava Orb'] = true,
	['Sanguine Mind Crystal III'] = true,
	['Large Modulation Shard'] = true,
}

lists.assists = { group = 1, raid1 = 1, raid2 = 1, raid3 = 1, manual = 1 }
lists.groupWatchOptions = { healer = 1, self = 1, none = 1 }
lists.pullWith = { melee = 1, ranged = 1, spell = 1, item = 1, custom = 1 }
lists.pullStates = {
	NOT = 'NOT',
	SCAN = 'SCAN',
	APPROACHING = 'APPROACHING',
	ENGAGING = 'ENGAGING',
	RETURNING = 'RETURNING',
	WAITING = 'WAITING',
}

lists.manaClasses =
	{ clr = true, dru = true, shm = true, enc = true, mag = true, nec = true, wiz = true }
lists.petClasses =
	{ bst = true, mag = true, nec = true, dru = true, enc = true, shd = true, shm = true }
lists.buffClasses = {
	clr = true,
	dru = true,
	shm = true,
	enc = true,
	mag = true,
	nec = true,
	rng = true,
	bst = true,
}
lists.healClasses = { clr = true, dru = true, shm = true }
lists.tankClasses = { pal = true, shd = true, war = true }
lists.meleeClasses = { ber = true, brd = true, bst = true, mnk = true, rng = true, rog = true }
lists.fdClasses = { mnk = true, nec = true, shd = true, bst = true }

lists.DMZ = {
	[344] = 1,
	[345] = 1,
	[202] = 1,
	[203] = 1,
	[279] = 1,
	[151] = 1,
	[220] = 1,
	[386] = 1,
	[33506] = 1,
}

-- xp6, xp5, xp4
lists.xpBuffs = { 42962, 42617, 42616 }
lists.gmBuffs = { 34835, 35989, 35361, 25732, 34567, 36838, 43040, 36266, 36423 }

lists.booleans = {
	['1'] = true,
	['true'] = true,
	['on'] = true,
	['0'] = false,
	['false'] = false,
	['off'] = false,
}

lists.ignoreBuff = {
	['HC Bracing Defense'] = true,
	['HC Visziaj\'s Grasp Recourse'] = true,
	['HC Defense of Calrena'] = true,
}

lists.slotList =
	'earrings, rings, leftear, rightear, leftfinger, rightfinger, face, head, neck, shoulder, chest, feet, arms, leftwrist, rightwrist, wrists, charm, powersource, mainhand, offhand, ranged, ammo, legs, waist, hands'

lists.routines = {
	heal = 1,
	assist = 1,
	mash = 1,
	burn = 1,
	cast = 1,
	cure = 1,
	buff = 1,
	rest = 1,
	ae = 1,
	mez = 1,
	aggro = 1,
	ohshit = 1,
	rez = 1,
	recover = 1,
	managepet = 1,
}

lists.classLists = {
	'DPSAbilities',
	'AEDPSAbilities',
	'burnAbilities',
	'tankAbilities',
	'tankBurnAbilities',
	'AETankAbilities',
	'healAbilities',
	'fadeAbilities',
	'defensiveAbilities',
	'aggroReducers',
	'recoverAbilities',
	'combatBuffs',
	'auras',
	'selfBuffs',
	'groupBuffs',
	'singleBuffs',
	'petBuffs',
	'cures',
	'clickies',
	'castClickies',
	'pullClickies',
	'debuffs',
}

lists.uiThemes = {
	TEAL = {
		windowbg = ImVec4(0.2, 0.2, 0.2, 0.6),
		bg = ImVec4(0, 0.3, 0.3, 1),
		hovered = ImVec4(0, 0.4, 0.4, 1),
		active = ImVec4(0, 0.5, 0.5, 1),
		button = ImVec4(0, 0.3, 0.3, 1),
		text = ImVec4(1, 1, 1, 1),
	},
	PINK = {
		windowbg = ImVec4(0.2, 0.2, 0.2, 0.6),
		bg = ImVec4(1, 0, 0.5, 1),
		hovered = ImVec4(1, 0, 0.5, 1),
		active = ImVec4(1, 0, 0.7, 1),
		button = ImVec4(1, 0, 0.4, 1),
		text = ImVec4(1, 1, 1, 1),
	},
	GOLD = {
		windowbg = ImVec4(0.2, 0.2, 0.2, 0.6),
		bg = ImVec4(0.4, 0.2, 0, 1),
		hovered = ImVec4(0.6, 0.4, 0, 1),
		active = ImVec4(0.7, 0.5, 0, 1),
		button = ImVec4(0.5, 0.3, 0, 1),
		text = ImVec4(1, 1, 1, 1),
	},
}

lists.icons = {
	FA_PLAY = '\xef\x81\x8b',
	FA_PAUSE = '\xef\x81\x8c',
	FA_STOP = '\xef\x81\x8d',
	FA_SAVE = '\xee\x85\xa1',
	FA_HEART = '\xef\x80\x84',
	FA_FIRE = '\xef\x81\xad',
	FA_MEDKIT = '\xef\x83\xba',
	FA_FIGHTER_JET = '\xef\x83\xbb',
	MD_LOCAL_HOSPITAL = '\xee\x95\x88',
	FA_BICYCLE = '\xef\x88\x86',
	FA_BUS = '\xef\x88\x87',
	MD_EXPLORE = '\xee\xa1\xba',
	MD_HELP = '\xee\xa2\x87',
}

return lists
