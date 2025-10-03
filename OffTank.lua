---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")
---@type ImGui
require('ImGui')

-- version 0.09
-- edited by Dragon to allow the user to choose the distance for the assisting
-- 11-3-23 - Added five NoS raids--Strat
-- 1-31-24 - Added Pit Fight and T2 LS Placeholders --Strat
-- 3-2-24 - Added 23rd Anni Raid- Strat
-- 5-19-25 - Refactored UI to avoid 60 upvalues error and added 5 ToB raids - Strat


local my_class = mq.TLO.Me.Class.ShortName()
local assigned_mob = ''
local assigned_mob1 = ''
local assigned_mob2 = ''
local prev_ToV_Raid = ''
local prev_CoV_Raid = ''
local prev_ToL_Raid = ''
local prev_NoS_Raid = ''
local prev_LS_Raid = ''
local prev_ToB_Raid = ''
local prev_Misc_Raid = ''

-- Minimum and maximim distance for Imgui input to prevent numbers too low/high
local MIN_DIST = 20
local MAX_DIST = 200
-- The distance in which the assigned mob can be targeted and attacked
-- default is 150
local distance = 100
local isChanged = false

local open_gui = true
local should_draw_gui = true
local pause = false
local chosenMode = mq.TLO.CWTN.Mode()

mq.bind("/offtank reset", function()
	chosenMode = mq.TLO.CWTN.Mode()
	print("Setting idle mode to " .. chosenMode)
end)

mq.bind("/offtank pause on", function()
	pause = true
	mq.cmd('/squelch /nav stop')
	print("Offtank paused")
end)

mq.bind("/offtank pause off", function()
	pause = false
	print("Offtank resumed")
end)

mq.bind("/offtank pause", function()
	pause = true
	mq.cmd('/squelch /nav stop')
	print("Offtank paused")
end)

local function cwtnCHOSEN()
	if mq.TLO.CWTN.Mode() ~= chosenMode then
		mq.cmdf('/%s mode %s', my_class, chosenMode)
	end
end

local function cwtnTANK()
	if mq.TLO.CWTN.Mode() ~= 'Tank' then
		mq.cmdf('/%s mode 4', my_class)
	end
end

local function target()
	if mq.TLO.Target() ~= assigned_mob then
		mq.delay('1s')
		mq.cmdf('/target %s', assigned_mob)
	end
end

local function target1()
	if mq.TLO.Target() ~= assigned_mob1 then
		mq.delay('1s')
		mq.cmdf('/target %s', assigned_mob1)
	end
end

local function target2()
	if mq.TLO.Target() ~= assigned_mob2 then
		mq.delay('1s')
		mq.cmdf('/target %s', assigned_mob2)
	end
end


local function main()
	if pause then
		mq.delay(100)
		return
	end
	if assigned_mob ~= '' and mq.TLO.Spawn(assigned_mob).Distance() ~= nil and mq.TLO.Spawn(assigned_mob).Distance() < distance then
		target()
		mq.delay('1ms')
		cwtnTANK()
		mq.delay('1ms')
		mq.cmd('/attack on')
		mq.delay('5ms')
	elseif
		assigned_mob1 ~= '' and mq.TLO.Spawn(assigned_mob1).Distance() ~= nil and mq.TLO.Spawn(assigned_mob1).Distance() < distance then
		target1()
		mq.delay('1ms')
		cwtnTANK()
		mq.delay('1ms')
		mq.cmd('/attack on')
		mq.delay('5ms')
	elseif assigned_mob2 ~= '' and mq.TLO.Spawn(assigned_mob2).Distance() ~= nil and mq.TLO.Spawn(assigned_mob2).Distance() < distance then
		target2()
		mq.delay('1ms')
		cwtnTANK()
		mq.delay('1ms')
		mq.cmd('/attack on')
		mq.delay('5ms')
	else
		cwtnCHOSEN()
	end
end

------------ Expansions ---------------------------
local expansions = {
	[1] = 'The Burning Lands',
	[2] = 'Torment of Velious',
	[3] = 'Claws of Veeshan',
	[4] = 'Terror of Luclin',
	[5] = 'Night of Shadows',
	[6] = 'Laurions Song',
	[7] = 'The Outer Brood',
	[8] = 'Misc',
}

local expansion = 'None'
------------ Raids ---------------------------
local ToV_Raids = {
	[1] = 'Griklor',
	[2] = 'ServantOfSleeper',
	[3] = 'RestlessAssault',
	[4] = 'SeekingTheSorcerer',
}
local ToV_Raid = 'None'

local CoV_Raids = {
	[1] = 'Zlandicar',
	[2] = 'Sontalak',
	[3] = 'Crusaders',
	[4] = 'Aaryonar',
	[5] = 'Klandicar',
	[6] = 'Tantor'
}
local CoV_Raid = 'None'

local ToL_Raids = {
	[1] = 'SwarmCommander',
	[2] = 'Zelnithak',
	[3] = 'DoomShade',
	[4] = 'Goranga',
	[5] = 'PrimalVampire',
}
local ToL_Raid = 'None'

local NoS_Raids = {
	[1] = 'Insatiable',
	[2] = 'MeanStreets',
	[3] = 'PitFight',
	[4] = 'SpiritFades',
	[5] = 'Door',
	[6] = 'ShadowsMove'
}
local NoS_Raid = 'None'

local LS_Raids = {
	[1] = 'PoM',
	[2] = 'Kanghammer',
	[3] = 'T2a',
	[4] = 'T2b',
	[5] = 'T2c',
	[6] = 'T3a'
}
local LS_Raid = 'None'

local ToB_Raids = {
	[1] = 'LeviathanHeart',
	[2] = 'Hodstock',
	[3] = 'ToE',
	[4] = 'Cannons',
	[5] = 'ControlRoom',
	[6] = 'Docks'
}
local ToB_Raid = 'None'

local Misc_Raids = {
	[1] = 'Anni23rd',
	[2] = 'PH',
}
local Misc_Raid = 'None'

------------ Raid Mobs ---------------------------
------Beginning of ToV Raid Mob List------
local Griklor = {
	[1] = 'a_cursed_dervish00',
	[2] = 'a_cursed_dervish01',
	[3] = 'a_restless_Ry`Gorr00',
	[4] = 'a_restless_Ry`Gorr01',
	[5] = 'a_haunted_Ry`Gorr00',
	[6] = 'a_haunted_Ry`Gorr01',
}
local ServantOfSleeper = {
	[1] = 'a_velium_sentry00',
	[2] = 'a_velium_sentry01',
	[3] = 'a_velium_sentry02',
}
local RestlessAssault = {
	[1] = 'Narandi_the_Restless00',
	[2] = 'Narandi_the_Restless01',
	[3] = 'Narandi_the_Restless02',
	[4] = 'Narandi_the_Restless03',
	[5] = 'a_restless_Kromrif00',
	[6] = 'a_restless_Kromrif01',
	[7] = 'a_restless_dire_wolf00',
	[8] = 'a_restless_dire_wolf01',
}
local SeekingTheSorcerer = {
	[1] = 'a_restless_fleshpile00',
	[2] = 'a_restless_fleshpile01',
	[3] = 'a_restless_fleshpile02',
	[4] = 'a_restless_fleshpile03',
	[5] = 'a_rambling_kobold00',
	[6] = 'a_rambling_kobold01',
	[7] = 'a_rambling_kobold02',
}
------Beginning of CoV Raid Mob List------
local Zlandicar = {
	[1] = 'a_dracoliche00',
	[2] = 'a_dracoliche01',
	[3] = 'a_dracoliche02',
	[4] = 'a_dracoliche03',
}
local Sontalak = {
	[1] = 'a_burning_aggressor00',
	[2] = 'a_burning_aggressor01',
	[3] = 'a_burning_aggressor02',
	[4] = 'a_combative_follower00',
	[5] = 'a_combative_follower01',
	[6] = 'a_combative_follower02',
	[7] = 'a_combative_adherent00',
	[8] = 'a_combative_adherent01',
	[9] = 'a_combative_adherent02'
}
local Crusaders = {
	[1] = 'An_atrium_disciple00',
	[2] = 'An_atrium_disciple01',
	[3] = 'A_bodyguard00',
	[4] = 'A_bodyguard01',
	[5] = 'a_foyer_guardian00',
	[6] = 'a_foyer_guardian01',
	[7] = 'a_domicile_defender00',
	[8] = 'a_domicile_defender01',
	[9] = 'a_combative_adherent02'
}
local Klandicar = {
	[1] = 'A_guardian_of_Klandicar00',
	[2] = 'A_guardian_of_Klandicar01',
	[3] = 'A_guardian_of_Klandicar02',
	[4] = 'a_restless_kromrif00',
	[5] = 'a_restless_kromrif01',
	[6] = 'An_egg_tender00',
	[7] = 'An_egg_tender01',
	[8] = 'An_egg_tender02',
	[9] = 'An_egg_tender03'
}
local Tantor = {
	[1] = 'A_primal_guardian00',
	[2] = 'A_primal_guardian01',
	[3] = 'A_primal_guardian02',
	[4] = 'A_primal_guardian03',
}
------Beginning of ToL Raid Mob List------
local SwarmCommander = {
	[1] = 'A_netherbian_warrior00',
	[2] = 'A_netherbian_warrior01',
	[3] = 'A_netherbian_warrior02',
	[4] = 'A_netherbian_warrior03',
	[5] = 'A_netherbian_warrior04',
	[6] = 'A_netherbian_warrior05',
	[7] = 'A_netherbian_warrior06',
	[8] = 'A_netherbian_energist00',
	[9] = 'A_netherbian_ravager00',
	[10] = 'A_netherbian_ravager01',
	[11] = 'a_netherbian_infestor00',
	[12] = 'a_netherbian_infestor01',
	[13] = 'A_netherbian_infuser00',
	[14] = 'A_netherbian_infuser01',
	[15] = 'A_netherbian_invigorator00',
	[16] = 'A_newborn_drone00',
	[17] = 'A_newborn_drone01',
	[18] = 'A_newborn_drone02',
	[19] = 'A_newborn_drone03',
	[20] = 'A_netherbian_drone00',
	[21] = 'A_netherbian_drone01',
}
local Zelnithak = {
	[1] = 'A_zelniak00',
	[2] = 'A_zelniak01',
	[3] = 'A_small_zelniak00',
	[4] = 'A_small_zelniak01',
	[5] = 'A_young_zelniak00',
	[6] = 'A_young_zelniak01',
}
local DoomShade = {
	[1] = 'A_dark_master00',
	[2] = 'A_fading_shade00',
	[3] = 'A_fading_shade01',
	[4] = 'A_fading_shade02',
	[5] = 'A_fading_shade03',
}
local Goranga = {
	[1] = 'Eom_sentien00',
	[2] = 'Eom_sentien01',
	[3] = 'Eom_sentien02',
	[4] = 'Liquid_shadow00',
	[5] = 'Liquid_shadow01',
	[6] = 'Liquid_shadow02',
	[7] = 'Liquid_shadow03',
	[8] = 'Pli_liako00',
	[9] = 'Pli_liako01',
	[10] = 'Pli_liako02',
	[11] = 'Pli_liako03',
}
local PrimalVampire = {
	[1] = 'An_amorphous_vampire00',
	[2] = 'An_amorphous_vampire01',
	[3] = 'A_floating_feast00',
	[4] = 'A_floating_feast01',
	[5] = 'A_floating_feast02',
	[6] = 'A_floating_feast03',
	[7] = 'A_floating_feast04',
	[8] = 'A_tenacious_tick00',
	[9] = 'A_tenacious_tick01',
	[10] = 'A_tenacious_tick02',
	[11] = 'A_tenacious_tick03',
}
------Beginning of NoS Raid Mob List------
local Insatiable = {
	[1] = 'a_cliknar_nymph00',
	[2] = 'a_cliknar_nymph01',
	[3] = 'a_cliknar_nymph02',
	[4] = 'a_cliknar_nymph03',
	[5] = 'a_cliknar_nymph04',
	[6] = 'a_cliknar_nymph05',
	[7] = 'a_cliknar_nymph06',
	[8] = 'an_immature_shiknar00',
	[9] = 'an_immature_shiknar01',
	[10] = 'an_immature_shiknar02',
	[11] = 'a_shiknar00',
	[12] = 'a_shiknar01',
	[13] = 'a_shiknar02',
	[14] = 'a_shiknar03',
	[15] = 'a_shiknar04',
	[16] = 'a_shiknar_aberration00',
	[17] = 'an_expanding_spore00',
	[18] = 'an_expanding_spore01',
}
local MeanStreets = {
	[1] = 'a_riled_up_thug00',
	[2] = 'a_riled_up_thug02',
	[3] = 'a_riled_up_thug03',
	[4] = 'a_wild-eyed_thug00',
	[5] = 'a_wild-eyed_thug01',
	[6] = 'a_wild-eyed_thug02',
	[7] = 'an_impassioned_thug00',
	[8] = 'an_impassioned_thug01',
	[9] = 'an_impassioned_thug02',
	[10] = 'an_outraged_thug00',
	[11] = 'an_outraged_thug01',
	[12] = 'an_outraged_thug02',
	[13] = 'a_tiger00',
	[14] = 'Flickering_Illusion00',
	[15] = 'Flickering_Illusion01',
}
local PitFight = {
	[1] = 'A_blacksoul_defender00',
	[2] = 'a_grimling_hunter00',
	[3] = 'A_skirmisher00',
	[4] = 'A_skirmisher_elite00',
	[5] = 'A_skirmisher_guard00',
	[6] = 'A_dark_master00',
	[7] = 'a_warblood_recruit00',
	[8] = 'A_skeleton00',
}
local SpiritFades = {
	[1] = 'Lesser_Depletion00',
	[2] = 'Lesser_Depletion01',
	[3] = 'Lesser_Manipulation00',
	[4] = 'Lesser_Manipulation01',
	[5] = 'Lesser_Weakness00',
	[6] = 'Lesser_Weakness01',
	[7] = 'Lesser_Lethargy00',
	[8] = 'Manifest_Drowsiness00',
	[9] = 'Manifest_Apathy00',
}
local Door = {
	[1] = 'Whirling_debris00',
	[2] = 'Whirling_debris01',
	[3] = 'Whirling_debris02',
	[4] = 'Whirling_debris03',
	[5] = 'Whirling_debris04',
	[6] = 'Whirling_debris05',
}
local ShadowsMove = {
	[1] = 'Whirling_debris00',
	[2] = 'Whirling_debris01',
	[3] = 'Whirling_debris02',
	[4] = 'Whirling_debris03',
	[5] = 'Whirling_debris04',
	[6] = 'Whirling_debris05',
}
------Beginning of LS Raid Mob List------
local PoM = {
	[1] = 'a_white_jester00',
	[2] = 'a_white_jester01',
	[3] = 'a_white_jester02',
	[4] = 'a_black_jester00',
	[5] = 'a_black_jester01',
	[6] = 'a_black_jester02',
}
local Kanghammer = {
	[1] = 'Rufus_Invictus00',
	[2] = 'a_Takish_engineer00',
}
local T2a = {
	[1] = 'A_dark_master00',
	[2] = 'A_fading_shade00',
	[3] = 'A_fading_shade01',
	[4] = 'A_fading_shade02',
	[5] = 'A_fading_shade03',
}
local T2b = {
	[1] = 'Lesser_Depletion00',
	[2] = 'Lesser_Depletion01',
	[3] = 'Lesser_Manipulation00',
	[4] = 'Lesser_Manipulation01',
	[5] = 'Lesser_Weakness00',
	[6] = 'Lesser_Weakness01',
	[7] = 'Lesser_Lethargy00',
	[8] = 'Manifest_Drowsiness00',
	[9] = 'Manifest_Apathy00',
}
local T2c = {
	[1] = 'Whirling_debris00',
	[2] = 'Whirling_debris01',
	[3] = 'Whirling_debris02',
	[4] = 'Whirling_debris03',
	[5] = 'Whirling_debris04',
	[6] = 'Whirling_debris05',
}
local T3a = {
	[1] = 'Whirling_debris00',
	[2] = 'Whirling_debris01',
	[3] = 'Whirling_debris02',
	[4] = 'Whirling_debris03',
	[5] = 'Whirling_debris04',
	[6] = 'Whirling_debris05',
}

------Beginning of ToB Raid Mob List------
local LeviathanHeart = {
	[1] = 'The_Custodian00',
	[2] = 'a_mind_melder00',
	[3] = 'a_mind_melder01',
	[4] = 'a_bright_energist00',
	[5] = 'a_dark_energist00',
	[6] = 'a_voidburned_skyguard00',
	[7] = 'a_voidburned_skyguard01',
	[8] = 'a_soldier00',
	[9] = 'a_soldier01',
	[10] = 'a_soldier02',
	[11] = 'a_soldier03',
	[12] = 'a_soldier04',
}
local Hodstock = {
	[1] = 'The_Custodian00',
	[2] = 'a_mind_melder00',
	[3] = 'a_mind_melder01',
	[4] = 'a_bright_energist00',
	[5] = 'a_dark_energist00',
	[6] = 'a_dark_energist01',
	[7] = 'an_impassioned_thug00',
	[8] = 'an_impassioned_thug01',
	[9] = 'an_impassioned_thug02',
	[10] = 'an_outraged_thug00',
	[11] = 'an_outraged_thug01',
	[12] = 'an_outraged_thug02',
	[13] = 'a_tiger00',
	[14] = 'Flickering_Illusion00',
	[15] = 'Flickering_Illusion01',
}
local ToE = {
	[1] = 'A_dark_master00',
	[2] = 'A_fading_shade00',
	[3] = 'A_fading_shade01',
	[4] = 'A_fading_shade02',
	[5] = 'A_fading_shade03',
}
local Cannons = {
	[1] = 'Lesser_Depletion00',
	[2] = 'Lesser_Depletion01',
	[3] = 'Lesser_Manipulation00',
	[4] = 'Lesser_Manipulation01',
	[5] = 'Lesser_Weakness00',
	[6] = 'Lesser_Weakness01',
	[7] = 'Lesser_Lethargy00',
	[8] = 'Manifest_Drowsiness00',
	[9] = 'Manifest_Apathy00',
}
local ControlRoom = {
	[1] = 'Whirling_debris00',
	[2] = 'Whirling_debris01',
	[3] = 'Whirling_debris02',
	[4] = 'Whirling_debris03',
	[5] = 'Whirling_debris04',
	[6] = 'Whirling_debris05',
}
local Docks = {
	[1] = 'Whirling_debris00',
	[2] = 'Whirling_debris01',
	[3] = 'Whirling_debris02',
	[4] = 'Whirling_debris03',
	[5] = 'Whirling_debris04',
	[6] = 'Whirling_debris05',
}
------Beginning of Misc Raid Mob List------
local Anni23rd = {
	[1] = 'A_sebilite_golem00',
	[2] = 'A_sebilite_golem01',
	[3] = 'An_Imperial_construct00',
	[4] = 'An_Imperial_construct01',
	[5] = 'A_skeleton00',
	[6] = 'A_skeleton01',
	[7] = 'A_skeleton02',
	[8] = 'A_skeleton03',
}
local PH = {
	[1] = 'a_white_jester00',
	[2] = 'a_white_jester01',
	[3] = 'a_white_jester02',
	[4] = 'a_black_jester00',
	[5] = 'a_black_jester01',
	[6] = 'a_black_jester02',
}

------------ End of Raid Mobs ---------------------------
local function draw_combo_box(label, resultvar, options, showClearTarget)
	if ImGui.BeginCombo(label, resultvar) then
		if showClearTarget and ImGui.Selectable('Clear target', resultvar == '') then
			resultvar = ''
		end
		for _, j in ipairs(options) do
			if ImGui.Selectable(j, j == resultvar) then
				resultvar = j
			end
		end
		ImGui.EndCombo()
	end
	return resultvar
end


-- Split version of OffTank UI to avoid 60 upvalues error

local function draw_ToV_UI()
    ToV_Raid = draw_combo_box('Raid Select', ToV_Raid, ToV_Raids)
    if ToV_Raid ~= prev_ToV_Raid then
        assigned_mob, assigned_mob1, assigned_mob2 = '', '', ''
    end
    local raidTable = {
        Griklor = Griklor,
        ServantOfSleeper = ServantOfSleeper,
        RestlessAssault = RestlessAssault,
        SeekingTheSorcerer = SeekingTheSorcerer,
    }
    local mobList = raidTable[ToV_Raid]
    if mobList then
        assigned_mob = draw_combo_box('OT Target 1', assigned_mob, mobList, true)
        assigned_mob1 = draw_combo_box('OT Target 2', assigned_mob1, mobList, true)
        assigned_mob2 = draw_combo_box('OT Target 3', assigned_mob2, mobList, true)
    end
    prev_ToV_Raid = ToV_Raid
end

local function draw_CoV_UI()
    CoV_Raid = draw_combo_box('Raid Select', CoV_Raid, CoV_Raids)
    if CoV_Raid ~= prev_CoV_Raid then
        assigned_mob, assigned_mob1, assigned_mob2 = '', '', ''
    end
    local raidTable = {
        Zlandicar = Zlandicar,
        Sontalak = Sontalak,
        Crusaders = Crusaders,
        Klandicar = Klandicar,
        Tantor = Tantor,
    }
    local mobList = raidTable[CoV_Raid]
    if mobList then
        assigned_mob = draw_combo_box('OT Target 1', assigned_mob, mobList, true)
        assigned_mob1 = draw_combo_box('OT Target 2', assigned_mob1, mobList, true)
        assigned_mob2 = draw_combo_box('OT Target 3', assigned_mob2, mobList, true)
    end
    prev_CoV_Raid = CoV_Raid
end

local function draw_ToL_UI()
    ToL_Raid = draw_combo_box('Raid Select', ToL_Raid, ToL_Raids)
    if ToL_Raid ~= prev_ToL_Raid then
        assigned_mob, assigned_mob1, assigned_mob2 = '', '', ''
    end
    local raidTable = {
        SwarmCommander = SwarmCommander,
        Zelnithak = Zelnithak,
        DoomShade = DoomShade,
        Goranga = Goranga,
        PrimalVampire = PrimalVampire,
    }
    local mobList = raidTable[ToL_Raid]
    if mobList then
        assigned_mob = draw_combo_box('OT Target 1', assigned_mob, mobList, true)
        assigned_mob1 = draw_combo_box('OT Target 2', assigned_mob1, mobList, true)
        assigned_mob2 = draw_combo_box('OT Target 3', assigned_mob2, mobList, true)
    end
    prev_ToL_Raid = ToL_Raid
end

local function draw_NoS_UI()
    NoS_Raid = draw_combo_box('Raid Select', NoS_Raid, NoS_Raids)
    if NoS_Raid ~= prev_NoS_Raid then
        assigned_mob, assigned_mob1, assigned_mob2 = '', '', ''
    end
    local raidTable = {
        Insatiable = Insatiable,
        MeanStreets = MeanStreets,
        PitFight = PitFight,
        SpiritFades = SpiritFades,
        Door = Door,
    }
    local mobList = raidTable[NoS_Raid]
    if mobList then
        assigned_mob = draw_combo_box('OT Target 1', assigned_mob, mobList, true)
        assigned_mob1 = draw_combo_box('OT Target 2', assigned_mob1, mobList, true)
        assigned_mob2 = draw_combo_box('OT Target 3', assigned_mob2, mobList, true)
    end
    prev_NoS_Raid = NoS_Raid
end

local function draw_LS_UI()
    LS_Raid = draw_combo_box('Raid Select', LS_Raid, LS_Raids)
    if LS_Raid ~= prev_LS_Raid then
        assigned_mob, assigned_mob1, assigned_mob2 = '', '', ''
    end
    local raidTable = {
        PoM = PoM,
        Kanghammer = Kanghammer,
        T2a = T2a,
        T2b = T2b,
        T2c = T2c,
    }
    local mobList = raidTable[LS_Raid]
    if mobList then
        assigned_mob = draw_combo_box('OT Target 1', assigned_mob, mobList, true)
        assigned_mob1 = draw_combo_box('OT Target 2', assigned_mob1, mobList, true)
        assigned_mob2 = draw_combo_box('OT Target 3', assigned_mob2, mobList, true)
    end
    prev_LS_Raid = LS_Raid
end

local function draw_ToB_UI()
    ToB_Raid = draw_combo_box('Raid Select', ToB_Raid, ToB_Raids)
    if ToB_Raid ~= prev_ToB_Raid then
        assigned_mob, assigned_mob1, assigned_mob2 = '', '', ''
    end
    local raidTable = {
        LeviathanHeart = LeviathanHeart,
        Hodstock = Hodstock,
        ToE = ToE,
        Cannons = Cannons,
        ControlRoom = ControlRoom,
        Docks = Docks,
    }
    local mobList = raidTable[ToB_Raid]
    if mobList then
        assigned_mob = draw_combo_box('OT Target 1', assigned_mob, mobList, true)
        assigned_mob1 = draw_combo_box('OT Target 2', assigned_mob1, mobList, true)
        assigned_mob2 = draw_combo_box('OT Target 3', assigned_mob2, mobList, true)
    end
    prev_ToB_Raid = ToB_Raid
end

local function draw_Misc_UI()
    Misc_Raid = draw_combo_box('Raid Select', Misc_Raid, Misc_Raids)
    if Misc_Raid ~= prev_Misc_Raid then
        assigned_mob, assigned_mob1, assigned_mob2 = '', '', ''
    end
    local raidTable = {
        Anni23rd = Anni23rd,
        PH = PH,
    }
    local mobList = raidTable[Misc_Raid]
    if mobList then
        assigned_mob = draw_combo_box('OT Target 1', assigned_mob, mobList, true)
        assigned_mob1 = draw_combo_box('OT Target 2', assigned_mob1, mobList, true)
        assigned_mob2 = draw_combo_box('OT Target 3', assigned_mob2, mobList, true)
    end
    prev_Misc_Raid = Misc_Raid
end

local function OT_UI()
    if not open_gui or mq.TLO.MacroQuest.GameState() ~= 'INGAME' then return end
    open_gui, should_draw_gui = ImGui.Begin('Zzaddy OffTank', open_gui)

    ImGui.Text("Set the Distance: ")
    distance, isChanged = ImGui.InputInt("Min: " .. MIN_DIST .. " Max: " .. MAX_DIST, distance, 5, 0, 0)
    if distance < MIN_DIST then distance = MIN_DIST end
    if distance > MAX_DIST then distance = MAX_DIST end
    if isChanged then print(distance) end

    if should_draw_gui then
        if pause then
            if ImGui.Button('Resume') then pause = false end
        else
            if ImGui.Button('Pause') then
                pause = true
                mq.cmd('/squelch /nav stop')
            end
        end

        expansion = draw_combo_box('Expansion Select', expansion, expansions)

        if expansion == 'Torment of Velious' then draw_ToV_UI() end
        if expansion == 'Claws of Veeshan' then draw_CoV_UI() end
        if expansion == 'Terror of Luclin' then draw_ToL_UI() end
        if expansion == 'Night of Shadows' then draw_NoS_UI() end
        if expansion == 'Laurions Song' then draw_LS_UI() end
        if expansion == 'The Outer Brood' then draw_ToB_UI() end
        if expansion == 'Misc' then draw_Misc_UI() end
    end
    ImGui.End()
end

mq.imgui.init('OffTanking', OT_UI)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
print('\arBrought\ar \ayto\ar \agyou\ag \apby\ap \atZzaddy\ar \ayand \arDragon')
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
while true do
	main()
	mq.delay(100)
end
