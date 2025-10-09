-- Placeholder mob list for Hunterhood
-- Maps named mobs to their placeholder mobs

local ph_list = {
    -- Format: ["Named Mob"] = {"Placeholder1", "Placeholder2", ...}

    --------- Beginning of ToB PH list ---------
    -- Aureate Covert
    ["scalewrought aerialist"] = {
        "scalewrought skyguardian"
    },
    ["scalewrought director"] = {
        "a scalewrought curator"
    },
    ["scalewrought driver"] = {
        "scalewrought sentinel"
    },
    ["scalewrought manager"] = {
        "scalewrought maker"
    },
    ["scalewrought marshal"] = {
        "scalewrought skydefender"
    },
    ["scalewrought quartermaster"] = {
        "scalewrought craftsman"
    },
    ["scalewrought trainer"] = {
        "scalewrought striker"
    },
    ["scalewrought watcher"] = {
        "scalewrought inspector"
    },

    --Hodstock Hills
    ["Alleza"] = {
        "an elder caiman"
    },
    ["Elewisa the Oathbound"] = {
        "a fallen champion"
    },
    ["Ephialtes"] = {
        "tribulation"
    },
    ["First Raider"] = {
        "a scalewrought raider"
    },
    ["First Scout"] = {
        "a scalewrought assailant"
    },
    ["First Soldier"] = {
        "a scalewrought soldier"
    },
    ["First Stormer"] = {
        "a scalewrought stormer"
    },
    ["Muji"] = {
        "an elder badger"
    },
    ["Queseris Trisleth"] = {
        "a bandit cutpurse"
    },
    ["Riptide"] = {
        "an elder shark"
    },

    --The Chambers of Puissance
    ["Kellis the Young"] = {
        "a scalewrought mender"
    },
    ["scalewrought administrator"] = {
        "a scalewrought steward"
    },
    ["scalewrought archseer"] = {
        "a scalewrought gazer"
    },
    ["scalewrought foreman"] = {
        "a scalewrought repairer"
    },
    ["scalewrought monitor"] = {
        "a scalewrought perceiver"
    },
    ["scalewrought operator"] = {
        "a scalewrought artificer"
    },
    ["scalewrought skykeeper"] = {
        "a scalewrought skyterror"
    },
    ["scalewrought skysearer"] = {
        "a scalewrought skysentry"
    },
    ["scalewrought vitalmancer"] = {
        "a scalewrought ethermancer"
    },

    --The Gilded Spire
    ["Mirala"] = {
        "1 Hour Timer"
    },
    ["scalewrought breaker"] = {
        "A Scalewrought Striker"
    },
    ["scalewrought crusher"] = {
        "A Scalewrought Bruiser"
    },
    ["scalewrought nimbus"] = {
        "a scalewrought cloudguardian"
    },
    ["scalewrought overwatch"] = {
        "a scalewrought inspector"
    },
    ["scalewrought skymarshal"] = {
        "a scalewrought skyguardian"
    },
    ["scalewrought smasher"] = {
        "a scalewrought pounder"
    },
    ["scalewrought tool"] = {
        "a scalewrought maker"
    },
    ["Zarek"] = {
        "1 Hour Timer"
    },

    --The Harbinger's Cradle
    ["Ma`Maie, the Nest Mother"] = {
        "a scalewrought guardian"
    },
    ["scalewrought machinist"] = {
        "a scalewrought lookout"
    },
    ["scalewrought overseer"] = {
        "a scalewrought deliverer"
    },
    ["scalewrought rancher"] = {
        "scalewrought caregiver"
    },
    ["scalewrought servitor"] = {
        "a scalewrought farmhand"
    },
    ["scalewrought trooper"] = {
        "scalewrought sentry"
    },
    ["scalewrought viceroy"] = {
        "a scalewrought supervisor"
    },
    ["Tha`k Rustae, the Butcher"] = {
        "a scalewrought harvester"
    },

    --The Theater of Eternity
    ["Anguillifor"] = {
        "a tenacious moray"
    },
    ["Captain Luft"] = {
        "a shock trooper"
    },
    ["Captain Riyu"] = {
        "a vicious trooper"
    },
    ["Chthamalus"] = {
        "a mature barnacle"
    },
    ["Copperworth"] = {
        "a respected servant"
    },
    ["Diabollis"] = {
        "an abyssal terror"
    },
    ["Eye of Mother"] = {
        "a reinforced scouter"
    },
    ["Mambatali"] = {
        "an elite guardian"
    },
    ["Tatanami"] = {
        "an aetherial hydra"
    },
    ["Unigami"] = {
        "a void conger"
    },

    --------- Beginning of LS PH list ---------
    --Ankexfen Keep
    ["Ankexfen Experiment"] = {
        "a gorge scavenger"
    },
    ["Chef Goremand"] = {
        "an Ankexfen workhand"
    },
    ["Guard Captain Krizad"] = {
        "an Ankexfen torturer"
    },
    ["Lorekeeper Fandrel"] = {
        "an Ankexfen archwizard"
    },
    ["Mortimus"] = {
        "a battle-tested polar bear"
    },
    ["The Mountain Cryptid"] = {
        "an alpine dweller"
    },
    ["Rimeclaw"] = {
        "a frostbitten worg"
    },
    ["Stablemaster Magna"] = {
        "an Ankexfen reinsman"
    },
    ["Uncia the Snowstalker"] = {
        "a frost-paw skulker"
    },
    ["Underboss Lazam"] = {
        "an Ankexfen knife twister"
    },

    --Laurion Inn
    ["a brood queen"] = {
        "a leech elder"
    },
    ["a djinn"] = {
        "an air mehit lord"
    },
    ["a geonid"] = {
        "a cracked golem"
    },
    ["a lich"] = {
        "an undead lord"
    },
    ["a luggald"] = {
        "a white shark"
    },
    ["a queen recluse"] = {
        "a treant lord"
    },
    ["a queen widow"] = {
        "a drachnid hunter"
    },
    ["a spectre"] = {
        "a haunt"
    },
    ["a statue"] = {
        "a granite grabber"
    },
    ["a water dragon"] = {
        "an aggressive alligator"
    },
    ["an efreeti"] = {
        "a fire mephit lord"
    },
    ["an owlbear"] = {
        "a brownie lord",
        "a brownie queen",
    },

    --Moors of Nokk
    ["Captain Defan"] = {
        "a Nokk lieutenant"
    },
    ["Chaplain Kor Bloodmoon"] = {
        "a Nokk tactician"
    },
    ["Firestarter Tlag"] = {
        "a Nokk fireblade"
    },
    ["Fleawalker"] = {
        "a Nokk battleworg"
    },
    ["Sergeant Kharsk"] = {
        "a Nokk adjutant"
    },
    ["Sergeant Kveldulf"] = {
        "a Nokk sentinel"
    },
    ["Tarantis"] = {
        "a crevice spider"
    },
    ["Tutt"] = {
        "a bog turtler"
    },

    --Pal'Lomen
    ["Bonestripper"] = {
        "a hungry hotariton"
    },
    ["Charka"] = {
        "a Rallosian champion"
    },
    ["Cind the Kind"] = {
        "a Rallosian destroyer"
    },
    ["Crusher the Rusher"] = {
        "a Rallosian legionnaire"
    },
    ["Fernstalker"] = {
        "a clever puma"
    },
    ["General Dotal"] = {
        "a Rallosian adjudicator"
    },
    ["Queen Hotaria"] = {
        "a queensguard"
    },
    ["Tonnar Blevak"] = {
        "a rallosian archivist"
    },
    ["Violet Violence"] = {
        "a Rallosian cabalist"
    },

    --The Hero's Forge
    ["Alloy"] = {
        "a forgebound worker"
    },
    ["Arcanaforged"] = {
        "a spiritforged wizard"
    },
    ["Battleforged"] = {
        "a spiritforged berserker"
    },
    ["Geomimus"] = {
        "a geolode"
    },
    ["Goliath Forge Frog"] = {
        "a forged frog"
    },
    ["Ingot"] = {
        "a forgebound inspector"
    },
    ["Kindleheart"] = {
        "a rekindled phoenix"
    },
    ["Terrastride"] = {
        "a summit guardian"
    },
    ["Valorforged"] = {
        "a spiritforged warrior"
    },

    --Timorous Falls
    ["A Rallosian Lunatic"] = {
        "a rallosian zealot"
    },
    ["A Rallosian Sorcerer"] = {
        "a rallosian extremist"
    },
    ["Big Dipper"] = {
        "a timorous perch"
    },
    ["Bunion"] = {
        "a calloused woodsman"
    },
    ["Flariton"] = {
        "a parched corvid"
    },
    ["Horatio"] = {
        "an angry wasp"
    },
    ["Shoru"] = {
        "a fortified raptor"
    },
    ["SingleMalt"] = {
        "a worg howler"
    },
    ["The Dreaded Red Eye"] = {
        "a flying culex"
    },
    ["Ticktock"] = {
        "a vicious lashwhip"
    },

    --Unkempt Woods
    ["Drillmaster Suja"] = {
        "a Rallosian trainer"
    },
    ["General Orrak"] = {
        "a Rallosian highlance"
    },
    ["Grenn Rustblade"] = {
        "a Rallosian swiftblade"
    },
    ["Honored Elder Skraiw"] = {
        "an aviak elder"
    },
    ["Oka"] = {
        "a basilisk stonegazer"
    },
    ["Sergeant Korsh"] = {
        "a Rallosian tactician"
    },
    ["Stinky"] = {
        "a skunk doe"
    },
    ["Tenderstump"] = {
        "	a treant planter"
    },

    --------- Beginning of NoS PH list ---------
    --Darklight Caverns
    ["Chromatic Widow Queen"] = {
        "an ethereal widow"
    },
    ["Eelworm"] = {
        "an overgrown nematode"
    },
    ["Geoxyle"] = {
        "a root reaper"
    },
    ["Kezhda the Frenzied"] = {
        "a spirit sapper"
    },
    ["Mycorrhizal Mutation"] = {
        "a spore stalker"
    },
    ["Rabid Rhizanthella"] = {
        "a prickly perennial"
    },
    ["Variegated Monstera"] = {
        "an aberrant blossom"
    },

    --Deepshade
    ["Agaricusus"] = {
        "a hearty saprophyte"
    },
    ["Ayoaenae"] = {
        "an apathetic thespian"
    },
    ["Bavanjam"] = {
        "a spectral grizzly"
    },
    ["Drinil"] = {
        "a rowdy stand in"
    },
    ["Faceted Windra"] = {
        "a crystal medusa"
    },
    ["Psylopsybyl"] = {
        "a pungent stinkhorn"
    },
    ["Sehtab Mahlinee"] = {
        "a disgruntled stagehand"
    },
    --Firefall Pass
    ["Bedrock Burrower"] = {
        "a Firefall hollower"
    },
    ["Diabo Xi Vesta"] = {
        "Qua Liako",
        "Qua Centien",
        "Qua Zethon",
    },
    ["Firefallizard"] = {
        "a cinderscale saurek"
    },
    ["Fowl Matriarch"] = {
        "firefall falcon",
        "soot-specked hawk",
    },
    ["Igneous Insect"] = {
        "a ravine roamer",
    },
    ["Rock Lobber"] = {
        "a fissure fiend",
    },

    --Paludal Caverns
    ["Arly Golyeck"] = {
        "a recondite roughhouser"
    },
    ["Herachuel"] = {
        "a royal guardian"
    },
    ["Maricella Slithra"] = {
        "a recondite footpad"
    },
    ["Merrimore Ychansk"] = {
        "a recondite wanderer"
    },
    ["Toxiplax"] = {
        "a dead eyed shik`nar"
    },
    ["Vahlkamph"] = {
        "a fungal aberrant"
    },

    --Ruins of Shadow Haven
    ["Brute"] = {
        "a toughened phlarg fiend"
    },
    ["Flail"] = {
        "spirit-touched scrap"
    },
    ["Mace"] = {
        "animated scrap"
    },
    ["Overgrowth"] = {
        "a contaminated digger"
    },
    ["Skitter"] = {
        "an elder shik'nar outcast"
    },
    ["Stone Chitin"] = {
        "a dour delver"
    },
    ["Velutipes"] = {
        "a sensate reishi"
    },

    --Shadeweaver's Tangle
    ["Commander Esline"] = {
        "a Loda kai guard Commander"
    },
    ["Molten Wildfire"] = {
        "a painted elemental"
    },
    ["Scorched Cackling Bones"] = {
        "scorched bones"
    },
    ["Shak Dathor Overlord"] = {
        "a shak dathor swayer"
    },
    ["Sharp Claw"] = {
        "a mature hopper"
    },
    ["Stoneclaw Broodmother"] = {
        "a stoneclaw crawler"
    },
    ["Thorn Petal"] = {
        "a gloompetal thistle"
    },

    --Shar Vahl, Divided
    ["Crimsonclaw"] = {
        "a rockhopper adolescent"
    },
    ["Geerot Stabgut"] = {
        "a grimling invader"
    },
    ["Gheg Gorespit"] = {
        "a grimling scout"
    },
    ["Kurati the Feral"] = {
        "a wrathful Sahtebi"
    },
    ["Tailfang"] = {
        "a scorpion elder"
    },
    ["Toraji, Korath`s Warder"] = {
        "an ancient skeleton"
    },
    ["Wiggle"] = {
        "a hungry xakra worm"
    },

    ---------Beginning of ToL PH list---------
    --Basilica of Adumbration
    ["Congealed Shadow Mass"] = {
        "a tangible shadow"
    },
    ["Dark Agent of Luclin"] = {
        "a basilica secret keeper"
    },
    ["Gloomclaw"] = {
        "an obsidian taskmaster"
    },
    ["Irate Servant of Luclin"] = {
        "a shrewd abettor of luclin"
    },
    ["Itzal, Luclin`s Hunter"] = {
        "a tekuel"
    },
    ["Mistakenly Animated Salt Golem"] = {
        "an animated experiment"
    },
    ["Xetheg, Luclin`s Warder"] = {  -- TODO: verify
        "a tekuel"
    },

    --Bloodfalls
    ["A Retainer of Shadow"] = {
        "a laborer of shadow"
    },
    [" Centien Xi Va Xakra"] = {
        "a war shade"
    },
    ["Coagulus"] = {
        "a viscious blood bag"
    },
    ["Cruor"] = {
        "a sanguineous blood beast"
    },
    ["Lady Constance"] = {
        "a nameless vampire"
    },
    ["Nikolas the Exiled"] = {
        "a lost vampire"
    },
    ["Pli Xin Laiko"] = {
        "Zun Xin Liako"
    },

    --Ka Vethan
    ['Centi Thall'] = {
        "Centi Atulus"
    },
    ['Diabo Tatrua'] = {
        "Gel'Temariel Centi"
    },
    ['Diabo Va Thall'] = {
        "Fer'Tatrua Centi"
    },
    ['Diabo Xi Va'] = {
        "Fer'Temariel Centi"
    },
    ['Diabo Xi Xin'] = {
        "Teka'Temariel Centi"
    },
    ['The Protector'] = {
        "a shade guardian"
    },

    --Maiden's Eye
    [" Centien Rashen Xaui"] = {
        "Pli Torgarath Xi Vex"
    },
    ["Darkmeat"] = {
        "a luclin scavenger",
        "a luclin stalker"
    },
    ["Diabo Xi Akuel"] = {
        "a well-fed rockbreaker"
    },
    [" Lucca Brightfeld"] = {
        "a winged scavenger"
    },
    ["Namdrows"] = {
        "a mind burrower"
    },
    ["Quietus the Forgotten"] = {
        "an erased hero's guard",
        "a lost shade or forlorn"
    },
    ["Temariel Xi Tetoracu"] = {
        "Dabo Xi Vereor"
    },
    ["Tess Zelinstein"] = {
        "a peckish vampyre",
        "a beaten vampyre"
    },
    ["Txiki"] = {
        "a gleeful miscreant"
    },
    ["Xenacious Von Deek"] = {
        "a rabid bat",
        "a repressed vampyre",
        "a pacified vampyre",
    },

    --Shadow Valley
    ["a scorched terror"] = {
        "a gnarled terror"
    },
    ["a tenebrous slight"] = {
        "a tenebrous shadow"
    },
    [" an avaricious mass"] = {
        "an avenging mass"
    },
    ["an illusive dim"] = {
        "an illusive swarm"
    },
    ["Ander, Wolf of Shadows"] = {
        "a ruinous wolf"
    },
    ["Bynn the Tormented"] = {
        "an obscured shade"
    },
    ["Tearc, Shade Keeper"] = {
        "a remnant of shade",
        "an unsettled tumbler"
    },

    --Umbral Plains
    ["Bloodwretch"] = {
        "a netherbian ripper"
    },
    ["Captain Resh Sogran"] = {
        "a fallen sergeant"
    },
    ["Fleshrot"] = {
        "a netherbian carrion"
    },
    ["Fyrthek Fior"] = {
        "a fyr jen keeper"
    },
    ["Gantru Shojralen"] = {
        "a gantru ralktran"
    },
    ["Nightfall"] = {
        "a dark shadow"
    },
    ["Rumblecrush"] = {
        "a hefty stone guardian"
    },
    ["Shak Dathor Warlord"] = {
        "a shak dathor keeper"
    },
    ["Sylra Fris"] = {
        "a syl ren keeper"
    },
    ["Telaris Xeturisun"] = {
        "Torgarath Renthais"
    },

    --Vex Thal
    ["Diabo Xi Va Temariel"] = {
        "Kela Va"
    },
    ["Diabo Xi Xin Thall"] = {
        "Xin Thall"
    },
    [" Kaas Thox Xi Ans Dyek"] = {
        "Qua Kaas Thox"
    },
    ["Thall Va Kelun"] = {
        "Thall Xi Va"
    },
    [" Thall Xundraux Diabo"] = {
        "Kela Thall"
    },
    ["Thox Xakra"] = {
        "Raux Xakra"
    },
    ["Va Xakra"] = {
        "Kaas Xakra"
    },

    ---------Beginning of CoV PH list---------
    --Cobalt Scar
    ["Morwenna Undertow"] = {
        "a neriad huntress"
    },
    ["Delmare Undertow"] = {
        "a neriad guard"
    },
    ["Pikebreath"] = {
        "a restless othmir"
    },
    ["Ol` Grinnin` Finley"] = {
        "a deepwater gnasher"
    },
    ["Desirae Fanfare"] = {
        "an alluring siren"
    },
    ["Octave Sforzando"] = {
        "any siren then cycle ends with",
        "a siren muse"
    },
    ["Skolskin Haeger"] = {
        "a protective ulthork"
    },
    ["Kirezelbough"] = {
        "any wyvern then cycle ends with",
        "a winged terror"
    },

    --Dragon Necropolis
    ["dragon_necropolis_1"] = {
        "dragon_necropolis_1"
    },

    --Skyshrine
    ["skyshrine_1"] = {
        "skyshrine_1"
    },

    --The Sleeper's Tomb
    ["the_sleeper_s_tomb_1"] = {
        "the_sleeper_s_tomb_1"
    },

    --The Temple of Veeshan
    ["the_temple_of_veeshan_1"] = {
        "the_temple_of_veeshan_1"
    },

    --The Western Wastes
    ["the_western_wastes_1"] = {
        "the_western_wastes_1"
    },

    ---------Beginning of ToV PH list---------
    ---Crystal Caverns---
    ["Crystal Grinder"] = {
        "a crystal skitterer"
    },
    ["Gem collector"] = {
        "a focus geonid"
    },
    ["Life Leech"] = {
        "a terror carver",
        "a hollow carver",
    },
    ["Queen Dracnia"] = {
        "a crystal purifier",
        "a drachnid retainer",
    },

    --Kael Drakkel
    ["kael_drakkel_1"] = {
        "kael_drakkel_1"
    },

    --Eastern Wastes
    ["a returned dracoliche"] = {
        "a restless dracoliche"
    },
    ["Bolman"] = {
        "a frozen fright"
    },
    ["Cadcane the Unmourned"] = {
        "a cold skeleton"
    },
    ["Coldears"] = {
        "a frosted mammoth"
    },
    ["Mahaha"] = {
        "a hypothermic ghoul"
    },
    [" Monolith the Unstoppable"] = {
        "an exiled sentry"
    },
    [" Servant of the Sleeper"] = {
        "a restless dracholiche"
    },
    ["Sofia the Quiet"] = {
        "a wandering mourner"
    },
    ["Vekboz Wolfpunch"] = {
        "a Coldain fighter"
    },
    ["Windchill"] = {
        "a frosted dire wolf"
    },
    ["Zburator the Damned"] = {
        "a hoarfrost cadaver"
    },

    --The Great Divide
    ["a forgotten raid leader"] = {
        "a forgotten enforcer"
    },
    ["a tizmak augur"] = {
        "a shivering tizmak"
    },
    ["Blizzent"] = {
        "a shivering shardwurm"
    },
    ["Bloodmaw"] = {
        "a frosted kodiak"
    },
    ["Gerton Dumkin"] = {
        "a Coldain fighter"
    },
    ["Gorul Longshanks"] = {
        "a corrupted giant"
    },
    ["Laima Ratgur"] = {
        "a frigid coldain"
    },
    ["Loremaster Metiheib the Lost"] = {
        "a windchilled marrowbones"
    },
    [" Lost Squire of Narandi"] = {
        "a forgotten enforcer"
    },
    ["Margidor"] = {
        "A shivering corpse"
    },
    ["Orfur, Priest of Zek"] = {
        "a shivering screamer"
    },
    ["Thosgromri Warmgranite"] = {
        "a frigid cadaver"
    },

    --The Ry'Gorr Mines
    ["Ry`Gorr Herbalist"] = {
        "a Ry'Gorr apprentice"
    },
    ["Ry`Gorr Inspector"] = {
        "a restless Ry'Gorr foreman"
    },

    --The Tower of Frozen Shadow
    ["tower_of_frozen_shadow_1"] = {
        "tower_of_frozen_shadow_1"
    },

    --Velketor's Labyrinth
    ["velketor_s_labyrinth_1"] = {
        "velketor_s_labyrinth_1"
    },

    ---------Beginning of TBL PH list---------\
    --Stratos: Zephyr's Flight
    ["Cloud_Iron_Lance"] = {
        "an abundant gale"
    },
    ["Daring Cloud Spear"] = {
        "a dusty mephit"
    },
    ["Dawnbreeze"] = {
        "a whirlweaver phoenix"
    },
    ["Dour Eighth Guardian"] = {
        "a dignified djinn"
    },
    ["Eastern Radiant Glance"] = {
        "a voluminous gale"
    },
    ["Glassbeak Stormbreaker"] = {
        "a windweaver phoenix"
    },
    ["Horizon of Destiny"] = {
        "a tempestuous gust"
    },
    ["Infinite Horizon Star"] = {
        "a billowing gale"
    },
    ["Silver Eyes Dread"] = {
        "a glorious djinn"
    },
    ["Starshine, Icebreaker"] = {
        "a brumebreeze armor"
    },
    ["Triumphal Still Sky"] = {
        "a grand djinn"
    },
    ["Wild Blossom Star's_Flight"] = {
        "an easterly mephit's_Flight"
    },
    
    ---------Beginning of RoS PH list---------
    --Sathir's Tomb
    ["a Kar`zok grave robber"] = {
        "a Krellnakor filcher",
        "a Fereth appraiser"
    },
    ["a Kar`zok infiltrator"] = {
        "a Krellnakor enforcer",
        "a Wulthan thief",
        "a Krellnakor scavenger",
        "an Arcron lifter",
    },
    ["Arisen Gloriant Kra`du"] = {
        "an Arisen steward",
        "an Elevated skeleton",
    },
    [" Xalgoz the Arisen"] = {
        "an Arisen ritualist",
        "an Exalted spirit",
    },
    ["Ancient Apparition"] = {
        "an arisen apparition"
    },
    
    --Gorowyn
    ["Artikla, Fereth Despot"] = {
        "a Fereth commander"
    },
    ["Elkikatar"] = {
        "a Kar'Zok scourge"
    },
    ["Gnaw"] = {
        "a chokidai elder"
    },
    ["Head Boiler Akett"] = {
        "a soup boiler"
    },
    ["High Arcron Zeklor"] = {
        "an Arcron burner"
    },
    ["Hissilith, the Brittlebones"] = {
        "an enslaved skeleton"
    },
    ["Overlord Klerkon"] = {
        "a Krellnakor destroyer"
    },
    [" Overlord Teralov"] = {
        "a Krellnakor terror"
    },
    [" Overlord Tevik"] = {
        "a Krellnakor seeker"
    },
    ["Rekatok One-Eye"] = {
        "an aging pit fighter"
    },
    ["The Magmalisk"] = {
        "a hungry lavalisk"
    },
    [" Wulthan High Inquisitor Kraz"] = {
        "a Wulthan administrator"
    },
    ["Fereth Captain Ordran"] = {
        "a fereth captain"
    },
    ["Wulthan Elder Priest Ovun"] = {
        "a wulthan priest"
    },

    --Howling Stones
    ["Howling_Stones"] = {
        "howling_stones"
    },

    --The Skyfire Mountains
    ["The_Skyfire_Mountains"] = {
        "the_skyfire_mountains"
    },

    --The Overthere
    ["Banshee"] = {
        "a screeching chokidai"
    },
    ["Bloodstalker"] = {
        "a blood-stained stalker"
    },
    ["a bluff golem"] = {
        "a rocky cliff golem"
    },
    ["Drakis"] = {
        "a dreadful scorpikis"
    },
    ["Fang"] = {
        "a stonepeep cockatrice"
    },
    ["a grotesque succulent"] = {
        "a sickly succulent"
    },
    ["an iron sentinel"] = {
        "a rubble golem"
    },
    ["Janissary Virzak"] = {
        "a Wulthan Zealot"
    },
    ["a Kar`Zok lacerator"] = {
        "a Fereth procurator"
    },
    ["a majestic cockatrice"] = {
        "a stoneglint cockatrice"
    },
    ["Myrmidon Tundak"] = {
        "a Krellnakor officer"
    },
    ["Needle"] = {
        "a needle-covered succulent"
    },
    ["Observer Eyrzekla"] = {
        "a mysterious sarnak"
    },
    ["Rigelon the Watcher"] = {
        "a shifty scorpikis"
    },
    ["Saber"] = {
        "a raging rhino"
    },
    ["Arcron Thaumaturge Osellik"] = {
        "an arcron thaumaturge"
    },
    ["Flamescale Overlord Takarious"] = {
        "a Krellnakor overlord"
    },

    --Veeshan's Peak
    ["Veeshan_s_Peak"] = {
        "veeshan_s_peak"
    },
    
    ---------Beginning of EoK PH list---------
    --Chardok
    ["Battle Master Ska`tu"] = {
        "a reanimated berserker",
        "a reanimated dragoon",
        "a reanimated partisan",
    },
    ["The Bridge Keeper"] = {
        "a bridge guardian"
    },
    ["Crackjaw"] = {
        "a starving beetle",
        "a frenzied beetle",
    },
    ["Deathfang"] = {
        "a chokidai bonecrusher",
        "a cholidai lacerater",
    },
    ["Dread Overseer Akalod"] = {
        "Heroic Adventure: Others' Things",
        "a weary overseer",
    },
    ["Dry Rot"] = {
        "a moldering fungusman"
    },
    ["Flight Master Hak`ouz"] = {
        "a flight coordinator"
    },
    ["Fractured Shard"] = {
        "a magic tear"
    },
    ["Grand Advisor Zum`uul"] = {
        "a Shai`din scribe"
    },
    ["Grand Herbalist Mak`ha"] = {
        "a Di`zok herb gardener",
        "a chokidai herbdigger",
    },
    ["Kennel Master Al`ele"] = {
        "a kennel mucker",
        "a kennel keeper",
    },
    ["Observer Aq`touz"] = {
        "a Di`zok watcher"
    },
    ["Overseer Dal`guur"] = {
        "a Di`zok foreman",
        "a Di`zok slavemaster",
    },
    ["Queen Velazul`s Aide"] = {
        "royal escort"
    },
    ["Royal Guard Kakator"] = {
        "Heroic Adventure: On Behest of the Emperor",
        "a weary royal guard"
    },
    ["Selrach`s Regent"] = {
        "royal guard"
    },
    ["Shai'din Warmaster Roh`ki"] = {
        "a Di`zok strategist"
    },
    ["The Sokokar Matron"] = {
        "a sokokar consort",
        "a sokokar welpling",
    },
    [" Watch Captain Hir`roul"] = {
        "a Di`zok watchman"
    },

    --Frontier Mtns
    ["Belligerent Biarn"] = {
        "a Konikor drunk"
    },
    ["Bi`faak the Shadowwalker"] = {
        "a Drogan reveler"
    },
    ["Blooddrinker Furasza"] = {
        "a Syldon flamewarden"
    },
    ["Brute Herder Ar`shok"] = {
        "a Syldon agitator"
    },
    ["Corrupted Grove Guardian"] = {
        "a grove guardian"
    },
    ["Delirious Berserker"] = {
        "a Drogan berserker"
    },
    ["Drillmaster Mak`tak"] = {
        "a Syldon drill sergeant"
    },
    ["Flamewarden Zev`ran"] = {
        "a Syldon neophyte",
        "an experimental behemoth"
    },
    ["Flintikki Peltpile"] = {
        "a frontier bear"
    },
    ["Masterchef Ram`see"] = {
        "a Syldon chef"
    },
    ["Orechomper"] = {
        "a Legion miner"
    },
    ["Reese the Rhinopocalypse"] = {
        "a frontier poacher"
    },
    ["Spyhunter Zath`ran"] = {
        "a Syldon greenhorn"
    },

    --Gates of Kor-Sha
    ["korsha_ext_1"] = {
        "korsha_ext_1"
    },

    --Korsha Labratory
    ["korsha_ext_two_1"] = {
        "korsha_ext_two_1"
    },

    --Lceanium
    ["A Drolvarg Captain"] = {
        "a drolvarg gnasher"
    },
    ["A Drolvarg Lord"] = {
        "a drolvarg ravisher"
    },
    ["Darg Hillock"] = {
        "a mountain giant brae"
    },
    ["Dread Drikat"] = {
        "a drachnid stinger"
    },
    ["Hunter Haltha"] = {
        "a mountain giant peak"
    },
    ["Kergag, the Mountain"] = {
        "a mountain giant lord"
    },
    ["Nightvenom"] = {
        "a venomous drachnid"
    },
    ["Slitherblade"] = {
        "a dread widow"
    },
    ["The Blazing Hen"] = {
        "a stoneglare cockatrice"
    },
    ["The Dreadland Wanderer"] = {
        "a greater spurbone"
    },
    ["The Lost Hunter"] = {
        "a rotting skeleton"
    },
    ["The Stone Dove"] = {
        "a calcifier cockatrice"
    },
    ["Tithnak Shadowhunter"] = {
        "a dire widow"
    },
    ["Yeti Matriarch"] = {
        "a huge tundra yeti"
    },
    ["Yeti Patriarch"] = {
        "a massive tundra yeti"
    },

    --Scorched Woods
    ["scorched_woods_1"] = {
        "scorched_woods_1"
    },

---------Beginning of TBM PH list---------
--Crypt of Sul
    ["Bokon Revel the Reborn"] = {
        "an unliving hulk"
    },
    ["Citizen Pain"] = {
        "Heroic Adventure: To The Brave, Go The Spoils!",
        "a reserved worshiper"
    },
    ["Devourer of All"] = {
        "an insatiable fiend"
    },
    ["Grinder"] = {
        "Heroic Adventure: The Head of the Snake",
        "a faithblind hulk"
    },
    ["High Priestess Kal`vius"] = {
        "a high bokon"
    },
    ["Spine Eater"] = {
        "Heroic Adventure: The Bokon High Council",
        "a drooling ghoul"
    },
    ["The Watcher"] = {
        "a skeletal sentinel"
    },

    ---------Beggining of SoF PH list---------
    --Dragonscale Hills
    ["Arachnotron"] = {
        "a spiderwork scavenger"
    },
    ["Bloodbeak"] = {
        "a cursed crow"
    },
    ["Captain of the Leafguard"] = {
        "a Darkvine"
    },
    ["Chief Thundragon"] = {
        "Spawns every 10 min 40 sec"
    },
    ["Click-o-nik"] = {
        "a clockwork overseer"
    },
    ["Delilah Windrider"] = {
        "Unknown"
    },
    ["Diddle D"] = {
        "a clockwork overseer"
    },
    ["Dungore"] = {
        "a doombug scavenger"
    },
    ["Elder Krunggar Whiptail"] = {
        "a minotaur weaponsmaster",
        "a minotaur furyblade"
    },
    ["Fiddle D"] = {
        "a clockwork overseer"
    },
    ["Gillipuzz"] = {
        "dragonscale_hills_12"
    },
    ["King Mustef"] = {
        "a frisky shadowcat"
    },
    ["Leafrot"] = {
        "dragonscale_hills_14"
    },
    ["Mad MX"] = {
        "a clockwork overseer"
    },
    ["Strawshanks"] = {
        "a blighted scarecrow"
    },
    ["Tangler Timbleton"] = {
        "dragonscale_hills_17"
    },
    ["Ton o`Tin"] = {
        "dragonscale_hills_18"
    },
    ["Witchkin"] = {
        "a dragonscale viper"
    },

    ---------Beginning of TSS PH list---------
    ---Ashengate---
    ["ashengate_1"] = {
        "ashengate_1"
    },
    --Blackfeather Roost
    ["blackfeather_roost_1"] = {
        "blackfeather_roost_1"
    },
    --Blightfire Moors
    ["a marsh creeper"] = {
        "a briar thorn"
    },
    ["an advance scout"] = {
        "an advance scout"
    },
    ["Cliffstalker"] = {
        "a slashclaw cub",
        "a young slashclaw"
    },
    ["Dragoneater"] = {
        "a sporali decomposer"
    },
    ["Duskfall"] = {
        "a ghostpack huntress",
        "a ghostpack stalker",
        "a ghostpack howler"
    },
    ["Ezzerak the Engineer"] = {
        "Ezzerak the Engineer"
    },
    ["Mossback"] = {
        "Mossback"
    },
    ["Plaguebringer"] = {
        "an ancient plaguebone"
    },
    ["Skycore"] = {
        "a ridge watcher"
    },
    ["Thunderwood"] = {
        "Thunderwood"
    },
    --Crescent Reach
    ["crescent_reach_1"] = {
        "crescent_reach_1"
    },
    --Direwind Cliffs
    ["direwind_cliffs_1"] = {
        "direwind_cliffs_1"
    },
    --Frostcrypt
    ["frostcrypt_1"] = {
        "frostcrypt_1"
    },
    --Goru'Kar Mesa
    ["Anghel"] = {
        "a Minohten satyr"
    },
    ["Aurelia"] = {
        "a napaea windstriker"
    },
    ["Craita"] = {
        "an oread stonehide"
    },
    ["Fantoma"] = {
        "a mesa alpha wolf"
    },
    ["Florenta"] = {
        "a dryad tender",
        "a dryad maiden",
        "a dryad windweaver",
        "a dryad protector",
    },
    ["Ghita"] = {
        "a Minohten satyr"
    },
    ["Glasson"] = {
        "Quest Only: Hanook #2: Oh No!"
    },
    ["Incinspaianjen"] = {
        "a dark widow"
    },
    ["Ionela"] = {
        "a potamide maiden",
        "a potamide matron",
        "a potamide noble",
        "a potamide protector",
        "a potamide retainer",
    },
    ["Latham"] = {
        "60 minute timer"
    },
    ["Mal"] = {
        "a murkwater ooze"
    },
    ["Manunchi"] = {
        "a windwillow wisp"
    },
    ["Nemarsarpe"] = {
        "a diamondback snake"
    },
    ["Plasa"] = {
        "a harpy hunter"
    },
    ["Refugiu"] = {
        "a rotwood strangler"
    },
    ["Sandu"] = {
        "a Tuffein satyr"
    },
    ["Schelet"] = {
        "a lingering dryad"
    },
    ["Tarsiit Movila"] = {
        "a rotwood tangleweed"
    },
    ["Ternsmochin"] = {
        "a lost rotwood"
    },
    ["Uriasarpe"] = {
        "a ring snake"
    },
    ["Ursalua"] = {
        "a mesa bear",
        "a mesa mother bear",
    },
    --Icefall Glacier
    ["Blackfoot"] = {
        "any nightmoon"
    },
    ["icefall_glacier_2"] = {
        "icefall_glacier_2"
    },
    ["icefall_glacier_3"] = {
        "icefall_glacier_3"
    },
    ["icefall_glacier_4"] = {
        "icefall_glacier_4"
    },
    ["icefall_glacier_5"] = {
        "icefall_glacier_5"
    },
    ["icefall_glacier_6"] = {
        "icefall_glacier_6"
    },
    ["icefall_glacier_7"] = {
        "icefall_glacier_7"
    },
    ["icefall_glacier_8"] = {
        "icefall_glacier_8"
    },
    ["icefall_glacier_9"] = {
        "icefall_glacier_9"
    },
    ["icefall_glacier_10"] = {
        "icefall_glacier_10"
    },
    ["icefall_glacier_11"] = {
        "icefall_glacier_11"
    },
    ["icefall_glacier_12"] = {
        "icefall_glacier_12"
    },
    ["icefall_glacier_13"] = {
        "icefall_glacier_13"
    },
    ["icefall_glacier_14"] = {
        "icefall_glacier_14"
    },
    --Stone Hive
    ["stone_hive_1"] = {
        "stone_hive_1"
    },
    --Sunderock Springs
    ["sunderock_springs_1"] = {
        "sunderock_springs_1"
    },
    --The Steppes
    ["Chef Gudez"] = {
        "any Darkfell",
        "a Darkfell archer",
        "a Darkfell captain",
        "a darkfell elite",
        "a Darkfell gnoll",
        "a Darkfell guard",
    },
    ["Deathfang"] = {
        "a mature wasp spider"
    },
    ["Firebelly the Cook"] = {
        "a Stonemight"
    },
    ["Gruet Longsight"] = {
        "any Darkfell",
        "a Darkfell archer",
        "a Darkfell captain",
        "a darkfell elite",
        "a Darkfell gnoll",
        "a Darkfell guard",
    },
    ["Gruntor the Mad"] = {
        "a hill giant"
    },
    ["Hesmire Farflight"] = {
        "a guardian of the grove"
    },
    ["High Shaman Firglum"] = {
        "a Darkfell elder",
        "a Darkfell shaman",
    },
    ["Hunter Borty"] = {
        "Unknown"
    },
    ["Hunter Groppa"] = {
        "Unknown"
    },
    ["Littlebiter the Skinchanger"] = {
        "a Stonemight elder"
    },
    ["Midnight"] = {
        "a Steppes leopard"
    },
    ["Nanertak"] = {
        "Unknown"
    },
    ["Oldbones"] = {
        "a dire wolf",
        "a hill giant",
        "A stone viper",
        "A brown bear",
    },
    ["Skurl"] = {
        "a Stonemight veteran",
        "a Stonemight elder",
    },
    ["Sneaktalker Gizdor"] = {
        "any Darkfell",
        "a Darkfell archer",
        "a Darkfell captain",
        "a darkfell elite",
        "a Darkfell gnoll",
        "a Darkfell guard",
    },
    ["Splotchy"] = {
        "any Stonemight"
    },
    ["Tarbelly the Wanderer"] = {
        "multiple types"
    },
    --Valdeholm
    ["valdeholm_1"] = {
        "valdeholm_1"
    },
    --Vergalid Mines
    ["vergalid_mines_1"] = {
        "vergalid_mines_1"
    },
    --

    --Add more entries here following the same pattern
    -- Each key is the named mob, and the value is a table of possible placeholders
}

-- Function to get placeholders for a named mob
local function getPlaceholders(namedMob)
    return ph_list[namedMob] or {}
end

-- Function to check if a mob is a placeholder for any named mob
local function isPlaceholder(mobName)
    for namedMob, placeholders in pairs(ph_list) do
        for _, ph in ipairs(placeholders) do
            if mobName:lower() == ph:lower() then
                return true, namedMob
            end
        end
    end
    return false, nil
end

return {
    getPlaceholders = getPlaceholders,
    isPlaceholder = isPlaceholder,
    ph_list = ph_list -- Export the full table if needed
}
