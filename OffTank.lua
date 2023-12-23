---@type Mq
-- version 0.06
-- 11-16-23 - Add group roles checks to ensure NOT main tank role
-- edited by Dragon to allow the user to choose the distance for the assiend
-- mobs when pulling.
-- 11-3-23 - Added five NoS raids--Strat.

local mq = require("mq")
--- @type ImGui
require("ImGui")

local my_class = mq.TLO.Me.Class.ShortName()
local assigned_mob = ""
local assigned_mob1 = ""
local assigned_mob2 = ""

-- Minimum and maximim distance for Imgui input to prevent numbers too low/high
local MIN_DIST = 50
local MAX_DIST = 150
-- The distance in which the assigned mob can be targeted and attacked
-- default is 150
local distance = 150
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
	mq.cmd("/squelch /nav stop")
	print("Offtank paused")
end)

mq.bind("/offtank pause off", function()
	pause = false
	print("Offtank resumed")
end)

mq.bind("/offtank pause", function()
	pause = true
	mq.cmd("/squelch /nav stop")
	print("Offtank paused")
end)

local function cwtnCHOSEN()
	if mq.TLO.CWTN.Mode() ~= chosenMode then
		mq.cmdf("/%s mode %s", my_class, chosenMode)
	end
end

local function cwtnTANK()
	if mq.TLO.CWTN.Mode() ~= "Tank" then
		mq.cmdf("/%s mode 4", my_class)
	end
end

local function target()
	if mq.TLO.Target() ~= assigned_mob then
		mq.delay("1s")
		mq.cmdf("/target %s", assigned_mob)
	end
end

local function target1()
	if mq.TLO.Target() ~= assigned_mob1 then
		mq.delay("1s")
		mq.cmdf("/target %s", assigned_mob1)
	end
end

local function target2()
	if mq.TLO.Target() ~= assigned_mob2 then
		mq.delay("1s")
		mq.cmdf("/target %s", assigned_mob2)
	end
end

local function removeMainTankRole(mtName)
	mq.cmd("/grouproles unset " .. mtName .. " 1")
	print("Removed main tank role")
end

local function getGroupMainTank()
	return mq.TLO.Group.MainTank()
end

local function checkGroupTankRoleIsEmpty()
	local groupRole = getGroupMainTank()

	if groupRole == nil then
		return true
	else
		print("WARNING: GROUP MAIN TANK ROLE IS SET!")
		mq.cmd("/rs WARNING: MY GROUP MAIN TANK ROLE IS ENABLED")
		removeMainTankRole(groupRole)
		return false
	end
end

local function init()
	local groupMT = getGroupMainTank()
	if groupMT ~= nil then
		removeMainTankRole(groupMT)
	end
	return checkGroupTankRoleIsEmpty()
end

local function main()
	init()

	if pause then
		mq.delay(100)
		return
	end
	-- Make sure group MT role didn't get switched back on
	checkGroupTankRoleIsEmpty()

	if
		assigned_mob ~= ""
		and mq.TLO.Spawn(assigned_mob).Distance() ~= nil
		and mq.TLO.Spawn(assigned_mob).Distance() < distance
	then
		target()
		mq.delay("1ms")
		cwtnTANK()
		mq.delay("1ms")
		mq.cmd("/attack on")
		mq.delay("5ms")
	elseif
		assigned_mob1 ~= ""
		and mq.TLO.Spawn(assigned_mob1).Distance() ~= nil
		and mq.TLO.Spawn(assigned_mob1).Distance() < distance
	then
		target1()
		mq.delay("1ms")
		cwtnTANK()
		mq.delay("1ms")
		mq.cmd("/attack on")
		mq.delay("5ms")
	elseif
		assigned_mob2 ~= ""
		and mq.TLO.Spawn(assigned_mob2).Distance() ~= nil
		and mq.TLO.Spawn(assigned_mob2).Distance() < distance
	then
		target2()
		mq.delay("1ms")
		cwtnTANK()
		mq.delay("1ms")
		mq.cmd("/attack on")
		mq.delay("5ms")
	else
		cwtnCHOSEN()
	end
end

------------ Expansions ---------------------------
local expansions = {
	[1] = "The Burning Lands",
	[2] = "Torment of Velious",
	[3] = "Claws of Veeshan",
	[4] = "Terror of Luclin",
	[5] = "Night of Shadows",
}

local expansion = "None"
------------ Raids ---------------------------
local ToV_Raids = {
	[1] = "Griklor",
	[2] = "ServantOfSleeper",
	[3] = "RestlessAssault",
	[4] = "SeekingTheSorcerer",
}
local ToV_Raid = "None"

local CoV_Raids = {
	[1] = "Zlandicar",
	[2] = "Sontalak",
	[3] = "Crusaders",
	[4] = "Aaryonar",
	[5] = "Klandicar",
	[6] = "Tantor",
}
local CoV_Raid = "None"

local ToL_Raids = {
	[1] = "SwarmCommander",
	[2] = "Zelnithak",
	[3] = "DoomShade",
	[4] = "Goranga",
	[5] = "PrimalVampire",
}
local ToL_Raid = "None"

local NoS_Raids = {
	[1] = "Insatiable",
	[2] = "MeanStreets",
	[3] = "PitFight",
	[4] = "SpiritFades",
	[5] = "Door",
}
local NoS_Raid = "None"

------------ Raid Mobs ---------------------------
------Beginning of ToV Raid Mob List------
local Griklor = {
	[1] = "a_cursed_dervish00",
	[2] = "a_cursed_dervish01",
	[3] = "a_restless_Ry`Gorr00",
	[4] = "a_restless_Ry`Gorr01",
	[5] = "a_haunted_Ry`Gorr00",
	[6] = "a_haunted_Ry`Gorr01",
}
local ServantOfSleeper = {
	[1] = "a_velium_sentry00",
	[2] = "a_velium_sentry01",
	[3] = "a_velium_sentry02",
}
local RestlessAssault = {
	[1] = "Narandi_the_Restless00",
	[2] = "Narandi_the_Restless01",
	[3] = "Narandi_the_Restless02",
	[4] = "Narandi_the_Restless03",
	[5] = "a_restless_Kromrif00",
	[6] = "a_restless_Kromrif01",
	[7] = "a_restless_dire_wolf00",
	[8] = "a_restless_dire_wolf01",
}
local SeekingTheSorcerer = {
	[1] = "a_restless_fleshpile00",
	[2] = "a_restless_fleshpile01",
	[3] = "a_restless_fleshpile02",
	[4] = "a_restless_fleshpile03",
	[5] = "a_rambling_kobold00",
	[6] = "a_rambling_kobold01",
	[7] = "a_rambling_kobold02",
}
------Beginning of CoV Raid Mob List------
local Zlandicar = {
	[1] = "a_dracoliche00",
	[2] = "a_dracoliche01",
	[3] = "a_dracoliche02",
	[4] = "a_dracoliche03",
}
local Sontalak = {
	[1] = "a_burning_aggressor00",
	[2] = "a_burning_aggressor01",
	[3] = "a_burning_aggressor02",
	[4] = "a_combative_follower00",
	[5] = "a_combative_follower01",
	[6] = "a_combative_follower02",
	[7] = "a_combative_adherent00",
	[8] = "a_combative_adherent01",
	[9] = "a_combative_adherent02",
}
local Crusaders = {
	[1] = "An_atrium_disciple00",
	[2] = "An_atrium_disciple01",
	[3] = "A_bodyguard00",
	[4] = "A_bodyguard01",
	[5] = "a_foyer_guardian00",
	[6] = "a_foyer_guardian01",
	[7] = "a_domicile_defender00",
	[8] = "a_domicile_defender01",
	[9] = "a_combative_adherent02",
}
local Klandicar = {
	[1] = "A_guardian_of_Klandicar00",
	[2] = "A_guardian_of_Klandicar01",
	[3] = "A_guardian_of_Klandicar02",
	[4] = "a_restless_kromrif00",
	[5] = "a_restless_kromrif01",
	[6] = "An_egg_tender00",
	[7] = "An_egg_tender01",
	[8] = "An_egg_tender02",
	[9] = "An_egg_tender03",
}
local Tantor = {
	[1] = "A_primal_guardian00",
	[2] = "A_primal_guardian01",
	[3] = "A_primal_guardian02",
	[4] = "A_primal_guardian03",
}
------Beginning of ToL Raid Mob List------
local SwarmCommander = {
	[1] = "A_netherbian_warrior00",
	[2] = "A_netherbian_warrior01",
	[3] = "A_netherbian_warrior02",
	[4] = "A_netherbian_warrior03",
	[5] = "A_netherbian_warrior04",
	[6] = "A_netherbian_warrior05",
	[7] = "A_netherbian_warrior06",
	[8] = "A_netherbian_energist00",
	[9] = "A_netherbian_ravager00",
	[10] = "A_netherbian_ravager01",
	[11] = "a_netherbian_infestor00",
	[12] = "a_netherbian_infestor01",
	[13] = "A_netherbian_infuser00",
	[14] = "A_netherbian_infuser01",
	[15] = "A_netherbian_invigorator00",
	[16] = "A_newborn_drone00",
	[17] = "A_netherbian_drone00",
	[18] = "A_netherbian_drone01",
}
local Zelnithak = {
	[1] = "A_zelniak00",
	[2] = "A_zelniak01",
	[3] = "A_small_zelniak00",
	[4] = "A_small_zelniak01",
	[5] = "A_young_zelniak00",
	[6] = "A_young_zelniak01",
}
local DoomShade = {
	[1] = "A_dark_master00",
	[2] = "A_fading_shade00",
	[3] = "A_fading_shade01",
	[4] = "A_fading_shade02",
	[5] = "A_fading_shade03",
}
local Goranga = {
	[1] = "Eom_sentien00",
	[2] = "Eom_sentien01",
	[3] = "Eom_sentien02",
	[4] = "Liquid_shadow00",
	[5] = "Liquid_shadow01",
	[6] = "Liquid_shadow02",
	[7] = "Liquid_shadow03",
	[4] = "Pli_liako00",
	[5] = "Pli_liako01",
	[6] = "Pli_liako02",
	[7] = "Pli_liako03",
}
local PrimalVampire = {
	[1] = "An_amorphous_vampire00",
	[2] = "An_amorphous_vampire01",
	[3] = "A_floating_feast00",
	[4] = "A_floating_feast01",
	[5] = "A_floating_feast02",
	[6] = "A_floating_feast03",
	[7] = "A_floating_feast04",
	[4] = "A_tenacious_tick00",
	[5] = "A_tenacious_tick0001",
	[6] = "A_tenacious_tick0002",
	[7] = "A_tenacious_tick0003",
}
------Beginning of NoS Raid Mob List------
local Insatiable = {
	[1] = "a_cliknar_nymph00",
	[2] = "a_cliknar_nymph01",
	[3] = "a_cliknar_nymph02",
	[4] = "a_cliknar_nymph03",
	[5] = "a_cliknar_nymph04",
	[6] = "a_cliknar_nymph05",
	[7] = "a_cliknar_nymph06",
	[8] = "an_immature_shiknar00",
	[9] = "an_immature_shiknar01",
	[10] = "an_immature_shiknar02",
	[11] = "a_shiknar00",
	[12] = "a_shiknar01",
	[13] = "a_shiknar02",
	[14] = "a_shiknar03",
	[15] = "a_shiknar04",
	[16] = "a_shiknar_aberration00",
	[17] = "an_expanding_spore00",
	[18] = "an_expanding_spore01",
}
local MeanStreets = {
	[1] = "a_riled_up_thug00",
	[2] = "a_riled_up_thug02",
	[3] = "a_riled_up_thug03",
	[4] = "a_wild-eyed_thug00",
	[5] = "a_wild-eyed_thug01",
	[6] = "a_wild-eyed_thug02",
	[7] = "an_impassioned_thug00",
	[8] = "an_impassioned_thug01",
	[9] = "an_impassioned_thug02",
	[10] = "an_outraged_thug00",
	[11] = "an_outraged_thug01",
	[12] = "an_outraged_thug02",
	[13] = "a_tiger00",
	[14] = "Flickering_Illusion00",
	[15] = "Flickering_Illusion01",
}
local PitFight = {
	[1] = "A_dark_master00",
	[2] = "A_fading_shade00",
	[3] = "A_fading_shade01",
	[4] = "A_fading_shade02",
	[5] = "A_fading_shade03",
}
local SpiritFades = {
	[1] = "Lesser_Depletion00",
	[2] = "Lesser_Depletion01",
	[3] = "Lesser_Manipulation00",
	[4] = "Lesser_Manipulation01",
	[5] = "Lesser_Weakness00",
	[6] = "Lesser_Weakness01",
	[7] = "Lesser_Lethargy00",
}
local Door = {
	[1] = "Whirling_debris00",
	[2] = "Whirling_debris01",
	[3] = "Whirling_debris02",
	[4] = "Whirling_debris03",
	[5] = "Whirling_debris04",
	[6] = "Whirling_debris05",
}
------------ End of Raid Mobs ---------------------------
local function draw_combo_box(label, resultvar, options, showClearTarget)
	if ImGui.BeginCombo(label, resultvar) then
		if showClearTarget and ImGui.Selectable("Clear target", resultvar == "") then
			resultvar = ""
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

local function OT_UI()
	-- Define default values for the variables
	local default_assigned_mob = ""
	local default_assigned_mob1 = ""
	local default_assigned_mob2 = ""

	if not open_gui or mq.TLO.MacroQuest.GameState() ~= "INGAME" then
		return
	end
	open_gui, should_draw_gui = ImGui.Begin("Zzaddy OffTank", open_gui)
	ImGui.Text("Set the Distance: ")
	distance, isChanged = ImGui.InputInt("Min: " .. MIN_DIST .. " Max: " .. MAX_DIST, distance, 5, 0, 0)

	if distance < MIN_DIST then
		distance = MIN_DIST
	end
	if distance > MAX_DIST then
		distance = MAX_DIST
	end
	if isChanged then
		print(distance)
	end

	if should_draw_gui then
		if pause then
			if ImGui.Button("Resume") then
				pause = false
			end
		else
			if ImGui.Button("Pause") then
				pause = true
				mq.cmd("/squelch /nav stop")
			end
		end

		expansion = draw_combo_box("Expansion Select", expansion, expansions)
		----------Beginning of ToV----------
		if expansion == "Torment of Velious" then
			ToV_Raid = draw_combo_box("Raid Select", ToV_Raid, ToV_Raids)

			-- Check if the value of ToV_Raid has changed
			if ToV_Raid ~= prev_ToV_Raid then
				-- Reset the variables to their default values
				assigned_mob = default_assigned_mob
				assigned_mob1 = default_assigned_mob1
				assigned_mob2 = default_assigned_mob2
			end

			if ToV_Raid == "Griklor" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, Griklor, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, Griklor, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, Griklor, true)
			end

			if ToV_Raid == "ServantOfSleeper" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, ServantOfSleeper, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, ServantOfSleeper, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, ServantOfSleeper, true)
			end

			if ToV_Raid == "RestlessAssault" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, RestlessAssault, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, RestlessAssault, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, RestlessAssault, true)
			end

			if ToV_Raid == "SeekingTheSorcerer" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, SeekingTheSorcerer, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, SeekingTheSorcerer, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, SeekingTheSorcerer, true)
			end

			-- Store the current value of ToV_Raid for the next frame
			prev_ToV_Raid = ToV_Raid
		end
		----------Beginning of CoV----------
		if expansion == "Claws of Veeshan" then
			CoV_Raid = draw_combo_box("Raid Select", CoV_Raid, CoV_Raids)

			-- Check if the value of CoV_Raid has changed
			if CoV_Raid ~= prev_CoV_Raid then
				-- Reset the variables to their default values
				assigned_mob = default_assigned_mob
				assigned_mob1 = default_assigned_mob1
				assigned_mob2 = default_assigned_mob2
			end

			if CoV_Raid == "Zlandicar" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, Zlandicar, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, Zlandicar, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, Zlandicar, true)
			end

			if CoV_Raid == "Sontalak" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, Sontalak, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, Sontalak, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, Sontalak, true)
			end

			if CoV_Raid == "Crusaders" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, Crusaders, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, Crusaders, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, Crusaders, true)
			end

			if CoV_Raid == "Klandicar" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, Klandicar, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, Klandicar, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, Klandicar, true)
			end

			if CoV_Raid == "Tantor" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, Tantor, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, Tantor, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, Tantor, true)
			end

			-- Store the current value of CoV_Raid for the next frame
			prev_CoV_Raid = CoV_Raid
		end
		----------Beginning of ToL----------
		if expansion == "Terror of Luclin" then
			ToL_Raid = draw_combo_box("Raid Select", ToL_Raid, ToL_Raids)

			-- Check if the value of ToL_Raid has changed
			if ToL_Raid ~= prev_ToL_Raid then
				-- Reset the variables to their default values
				assigned_mob = default_assigned_mob
				assigned_mob1 = default_assigned_mob1
				assigned_mob2 = default_assigned_mob2
			end

			if ToL_Raid == "SwarmCommander" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, SwarmCommander, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, SwarmCommander, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, SwarmCommander, true)
			end

			if ToL_Raid == "Zelnithak" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, Zelnithak, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, Zelnithak, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, Zelnithak, true)
			end

			if ToL_Raid == "DoomShade" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, DoomShade, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, DoomShade, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, DoomShade, true)
			end

			if ToL_Raid == "Goranga" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, Goranga, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, Goranga, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, Goranga, true)
			end

			if ToL_Raid == "PrimalVampire" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, PrimalVampire, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, PrimalVampire, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, PrimalVampire, true)
			end

			-- Store the current value of ToL_Raid for the next frame
			prev_ToL_Raid = ToL_Raid
		end
		----------Beginning of NoS----------
		if expansion == "Night of Shadows" then
			NoS_Raid = draw_combo_box("Raid Select", NoS_Raid, NoS_Raids)

			-- Check if the value of NoS_Raid has changed
			if NoS_Raid ~= prev_NoS_Raid then
				-- Reset the variables to their default values
				assigned_mob = default_assigned_mob
				assigned_mob1 = default_assigned_mob1
				assigned_mob2 = default_assigned_mob2
			end

			if NoS_Raid == "Insatiable" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, Insatiable, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, Insatiable, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, Insatiable, true)
			end

			if NoS_Raid == "MeanStreets" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, MeanStreets, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, MeanStreets, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, MeanStreets, true)
			end

			if NoS_Raid == "PitFight" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, PitFight, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, PitFight, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, PitFight, true)
			end

			if NoS_Raid == "SpiritFades" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, SpiritFades, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, SpiritFades, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, SpiritFades, true)
			end

			if NoS_Raid == "Door" then
				assigned_mob = draw_combo_box("OT Target 1", assigned_mob, Door, true)
				assigned_mob1 = draw_combo_box("OT Target 2", assigned_mob1, Door, true)
				assigned_mob2 = draw_combo_box("OT Target 3", assigned_mob2, Door, true)
			end

			-- Store the current value of NoS_Raid for the next frame
			prev_NoS_Raid = NoS_Raid
		end
	end
	ImGui.End()
end

mq.imgui.init("OffTanking", OT_UI)
init()
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
print("\arBrought\ar \ayto\ar \agyou\ag \apby\ap \atZzaddy\ar \ayand \arDragon")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
while true do
	main()
end
