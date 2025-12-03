-- v1.135
-- Placeholder mob list for Hunterhood
-- Maps named mobs to their placeholder mobs with zone aware context

local ph_list = {
    -- Format: ["Zone ID"] = { ["Named Mob"] = {"Placeholder1", "Placeholder2", ...} }

    --------- SoR Zo es ---------
    [879] = { -- Candlemaker's Workshop
        ["Caiser the Lava Dweller"] = { "a molten slug" },
        ["Captain Foley"] = { "a solusek knight" },
        ["Everburning Candle Master"] = { "a candle master coercer" },
        ["Flame Devourer"] = { "a candle master leader" },
        ["Furok the Firestarter"] = { "a stomping unbreaker" },
        ["Haywired Creation"] = { "a clockwork engineer" },
        ["Loken the Rabid"] = { "a gnoll leader" },
        ["Melted Monstrosity"] = { "a waxwork colossus" },
        ["Scragen the Vicious"] = { "a kobold pack leader" },
        ["The Great Shell"] = { "a subterranean pincer" },
    },

    [880] = { -- Scarred Grove
        ["Adralydia Stormraven"] = { "a grove scout" },
        ["Ashbark"] = { "an oakward ancient" },
        ["Blood-soaked Pack Leader"] = { "a dread wolf" },
        ["Bonesplinter"] = { "a corpse golem" },
        ["Deathbringer Colossus"] = { "a warbound sentry" },
        ["Fiflip Hopemender"] = { "a lightbearer protector" },
        ["Grimclaw"] = { "a thicket bear" },
        ["Ik`Drun"] = { "a damaged thicket golem" },
        ["Magmus Flame Eater"] = { "a burning warcaster" },
        ["Nul`Kul"] = { "a thicket golem" },
        ["Telthel the Wretched"] = { "a dreadful blade" },
        ["Trung"] = { "a warbringer" },
        ["Vallina"] = { "a wretched abomination" },
    },

    [881] = { -- Arcstone, Shattered Isles
        ["a manasheen plaguebloom"] = { "a manasheen stalk" },
        ["Ash Harbinger"] = { "a firecrest ashfang" },
        ["Broj the Devourer"] = { "an aberrant behemoth" },
        ["Dravok the Rootbinder"] = { "a wandering tanglefoot" },
        ["Fire Maw"] = { "an ash drake" },
        ["Irdrath the Withered"] = { "a volatile scrykin" },
        ["Orvain the Mooncaller"] = { "a spectral stag" },
        ["Velith the Cinderfang"] = { "a blazing emberfang" },
    },

    [882] = { -- Ruined Relic
        ["living marble"] = { "living stone" },
        ["Marith the Fireborn"] = { "a fiery scrykin" },
        ["Pfath of the Wind"] = { "a chilling breath" },
        ["Raw Meat"] = { "a crazed flesh horror" },
        ["Sharosh the Lost"] = { "a lost scrykin" },
        ["Vosk the Terrakin"] = { "a chaotic earth pile" },
        ["Whisper"] = { "a forgotten spiritlight" },
        ["Windshear"] = { "shattered debris" },
    },
    
    [883] = { -- The Vortex
        ["Azureflutter"] = { "a satin laced monarch" },
        ["Chromaire"] = { "a bloated tropicaura vulture" },
        ["Corax the Nethercharged"] = { "a supercharged sentinel" },
        ["Forlien the Abyss Speaker"] = { "a supercharged battlemage" },
        ["Iridesca"] = { "a wide swipping tidebinder" },
        ["NeuroKraken"] = { "a supercharged curadrone" },
        ["OctoXecutor"] = { "a supercharged octodrone" },
        ["Stormstomper"] = { "a brutish galasaur hulk" },
        ["Torrentclaw"] = { "a wicked galasaur shredder" },
    },

    [884] = { -- Labyrinth of Spite
        ["Chirid"] = { "a governess of spite" },
        ["Coagulation of Spite"] = { "a lump of spite" },
        ["Drendre Gnarledgear"] = { "a cursed combatant" },
        ["Husk Devourer"] = { "a hungry drachnid" },
        ["Lherre, the Silkwhisperer"] = { "a silkwhisper attendant" },
        ["Matriarch of Enmity"] = { "a jealous escort" },
        ["Mite"] = { "a nameless husk" },
        ["Scorned Weeper"] = { "a scorn drinker" },
        ["The Headsman"] = { "a hateful executioner" },
    },

    --------- ToB Zones ---------
    [872] = { -- Aureate Covert
        ["scalewrought aerialist"] = { "a scalewrought skyguardian" },
        ["scalewrought director"] = { "a scalewrought curator" },
        ["scalewrought driver"] = { "a scalewrought sentinel" },
        ["scalewrought manager"] = { "a scalewrought maker" },
        ["scalewrought marshal"] = { "a scalewrought skydefender" },
        ["scalewrought quartermaster"] = { "a scalewrought craftsman" },
        ["scalewrought trainer"] = { "a scalewrought striker" },
        ["scalewrought watcher"] = { "a scalewrought inspector" },
    },

    [870] = { -- Hodstock Hills
        ["Alleza"] = { "an elder caiman" },
        ["Elewisa the Oathbound"] = { "a fallen champion" },
        ["Ephialtes"] = { "tribulation" },
        ["First Raider"] = { "a scalewrought raider" },
        ["First Scout"] = { "a scalewrought assailant" },
        ["First Soldier"] = { "a scalewrought soldier" },
        ["First Stormer"] = { "a scalewrought stormer" },
        ["Muji"] = { "an elder badger" },
        ["Queseris Trisleth"] = { "a bandit cutpurse" },
        ["Riptide"] = { "an elder shark" },
    },

    [874] = { -- The Chambers of Puissance
        ["Kellis the Young"] = { "a scalewrought mender" },
        ["scalewrought administrator"] = { "a scalewrought steward" },
        ["scalewrought archseer"] = { "a scalewrought gazer" },
        ["scalewrought foreman"] = { "a scalewrought repairer" },
        ["scalewrought monitor"] = { "a scalewrought perceiver" },
        ["scalewrought operator"] = { "a scalewrought artificer" },
        ["scalewrought skykeeper"] = { "a scalewrought skyterror" },
        ["scalewrought skysearer"] = { "a scalewrought skysentry" },
        ["scalewrought vitalmancer"] = { "a scalewrought ethermancer" },
    },

    [875] = { --The Gilded Spire
        ["Mirala"] = { "1 Hour Timer" },
        ["scalewrought breaker"] = { "A Scalewrought Striker" },
        ["scalewrought crusher"] = { "A Scalewrought Bruiser" },
        ["scalewrought nimbus"] = { "a scalewrought cloudguardian" },
        ["scalewrought overwatch"] = { "a scalewrought inspector" },
        ["scalewrought skymarshal"] = { "a scalewrought skyguardian" },
        ["scalewrought smasher"] = { "a scalewrought pounder" },
        ["scalewrought tool"] = { "a scalewrought maker" },
        ["Zarek"] = { "1 Hour Timer" },
    },

    [873] = { --The Harbinger's Cradle
        ["Ma`Maie, the Nest Mother"] = { "a scalewrought guardian" },
        ["scalewrought machinist"] = { "a scalewrought lookout" },
        ["scalewrought overseer"] = { "a scalewrought deliverer" },
        ["scalewrought rancher"] = { "a scalewrought caregiver" },
        ["scalewrought servitor"] = { "a scalewrought farmhand" },
        ["scalewrought trooper"] = { "a scalewrought sentry" },
        ["scalewrought viceroy"] = { "a scalewrought supervisor" },
        ["Tha`k Rustae, the Butcher"] = { "a scalewrought harvester" },
    },

    [871] = { --The Theater of Eternity
        ["Anguillifor"] = { "a tenacious moray" },
        ["Captain Luft"] = { "a shock trooper" },
        ["Captain Riyu"] = { "a vicious trooper" },
        ["Chthamalus"] = { "a mature barnacle" },
        ["Copperworth"] = { "a respected servant" },
        ["Diabollis"] = { "an abyssal terror" },
        ["Eye of Mother"] = { "a reinforced scouter" },
        ["Mambatali"] = { "an elite guardian" },
        ["Tatanami"] = { "an aetherial hydra" },
        ["Unigami"] = { "a void conger" },
    },

    --------- Beginning of LS PH list ---------
    [860] = { --Ankexfen Keep
        ["Ankexfen Experiment"] = { "a gorge scavenger" },
        ["Chef Goremand"] = { "an Ankexfen workhand" },
        ["Guard Captain Krizad"] = { "an Ankexfen torturer" },
        ["Lorekeeper Fandrel"] = { "an Ankexfen archwizard" },
        ["Mortimus"] = { "a battle-tested polar bear" },
        ["Rimeclaw"] = { "a frostbitten worg" },
        ["Stablemaster Magna"] = { "an Ankexfen reinsman" },
        ["The Mountain Cryptid"] = { "an alpine dweller" },
        ["Uncia the Snowstalker"] = { "a frost-paw skulker" },
        ["Underboss Lazam"] = { "an Ankexfen knife twister" },
    },

    [859] = { -- Laurion Inn
        ["a brood queen"] = { "a leech elder" },
        ["a djinn"] = { "an air mephit lord" },
        ["a geonid"] = { "a cracked golem" },
        ["a lich"] = { "an undead lord" },
        ["a luggald"] = { "a white shark" },
        ["a queen recluse"] = { "a treant lord" },
        ["a queen widow"] = { "a drachnid hunter" },
        ["a spectre"] = { "a haunt" },
        ["a statue"] = { "a granite grabber" },
        ["a water dragon"] = { "an aggressive alligator" },
        ["an efreeti"] = { "a fire mephit lord" },
        ["an owlbear"] = { "a brownie lord", "a brownie queen" },
    },

    [863] = { --Moors of Nokk
        ["Captain Defan"] = { "a Nokk lieutenant" },
        ["Chaplain Kor Bloodmoon"] = { "a Nokk tactician" },
        ["Firestarter Tlag"] = { "a Nokk fireblade" },
        ["Fleawalker"] = { "a Nokk battleworg" },
        ["Sergeant Kharsk"] = { "a Nokk adjutant" },
        ["Sergeant Kveldulf"] = { "a Nokk sentinel" },
        ["Tarantis"] = { "a crevice spider" },
        ["Tutt"] = { "a bog turtle" }
    },

    [861] = { --Pal'Lomen
        ["Bonestripper"] = { "a hungry hotariton" },
        ["Charka"] = { "a Rallosian champion" },
        ["Cind the Kind"] = { "a Rallosian destroyer" },
        ["Crusher the Rusher"] = { "a Rallosian legionnaire" },
        ["Fernstalker"] = { "a clever puma" },
        ["General Dotal"] = { "a Rallosian adjudicator" },
        ["Queen Hotaria"] = { "a queensguard" },
        ["Tonnar Blevak"] = { "a rallosian archivist" },
        ["Violet Violence"] = { "a Rallosian cabalist" },
    },

    [862] = { -- The Hero's Forge
        ["Alloy"] = { "a forgebound worker" },
        ["Arcanaforged"] = { "a spiritforged wizard" },
        ["Battleforged"] = { "a spiritforged berserker" },
        ["Geomimus"] = { "a geolode" },
        ["Goliath Forge Frog"] = { "a forged frog" },
        ["Ingot"] = { "a forgebound inspector" },
        ["Kindleheart"] = { "a rekindled phoenix" },
        ["Terrastride"] = { "a summit guardian" },
        ["Valorforged"] = { "a spiritforged warrior" },
    },

    [865] = { -- Timorous Falls
        ["A Rallosian Lunatic"] = { "a rallosian zealot" },
        ["A Rallosian Sorcerer"] = { "a rallosian extremist" },
        ["Big Dipper"] = { "a timorous perch" },
        ["Bunion"] = { "a calloused woodsman" },
        ["Flariton"] = { "a parched corvid" },
        ["Horatio"] = { "an angry wasp" },
        ["Shoru"] = { "a fortified raptor" },
        ["SingleMalt"] = { "a worg howler" },
        ["The Dreaded Red Eye"] = { "a flying culex" },
        ["Ticktock"] = { "a vicious lashwhip" },
    },

    [864] = { -- Unkempt Woods
        ["Drillmaster Suja"] = { "a Rallosian trainer" },
        ["General Orrak"] = { "a Rallosian highlance" },
        ["Grenn Rustblade"] = { "a Rallosian swiftblade" },
        ["Honored Elder Skraiw"] = { "an aviak elder" },
        ["Oka"] = { "a basilisk stonegazer" },
        ["Sergeant Korsh"] = { "a Rallosian tactician" },
        ["Stinky"] = { "a skunk doe" },
        ["Tenderstump"] = { "a treant planter" },
    },

    --------- Beginning of NoS PH list ---------
    [855] = { -- Darklight Caverns
        ["Chromatic Widow Queen"] = { "an ethereal widow" },
        ["Eelworm"] = { "an overgrown nematode" },
        ["Geoxyle"] = { "a root reaper" },
        ["Kezhda the Frenzied"] = { "a spirit sapper" },
        ["Mycorrhizal Mutation"] = { "a spore stalker" },
        ["Rabid Rhizanthella"] = { "a prickly perennial" },
        ["Variegated Monstera"] = { "an aberrant blossom" },
    },

    [856] = { -- Deepshade
        ["Agaricusus"] = { "a hearty saprophyte" },
        ["Ayoaenae"] = { "an apathetic thespian" },
        ["Bavanjam"] = { "a spectral grizzly" },
        ["Drinil"] = { "a rowdy stand in" },
        ["Faceted Windra"] = { "a crystal medusa" },
        ["Psylopsybyl"] = { "a pungent stinkhorn" },
        ["Sehtab Mahlinee"] = { "a disgruntled stagehand" },
    },

    [857] = { -- Firefall Pass
        ["Bedrock Burrower"] = { "a Firefall hollower" },
        ["Diabo Xi Vesta"] = { "Qua Liako", "Qua Centien", "Qua Zethon" },
        ["Firefallizard"] = { "a cinderscale saurek" },
        ["Fowl Matriarch"] = { "a firefall falcon", "a soot-specked hawk" },
        ["Igneous Insect"] = { "a ravine roamer" },
        ["Rock Lobber"] = { "a fissure fiend" },
    },

    [853] = { -- Paludal Caverns
        ["Arly Golyeck"] = { "a recondite roughhouser" },
        ["Herachuel"] = { "a royal guardian" },
        ["Maricella Slithra"] = { "a recondite footpad" },
        ["Merrimore Ychansk"] = { "a recondite wanderer" },
        ["Toxiplax"] = { "a dead eyed shik`nar" },
        ["Vahlkamph"] = { "a fungal aberrant" },
    },

    [851] = { -- Ruins of Shadow Haven
        ["Brute"] = { "a toughened phlarg fiend" },
        ["Flail"] = { "spirit-touched scrap" },
        ["Mace"] = { "animated scrap" },
        ["Overgrowth"] = { "a contaminated digger" },
        ["Skitter"] = { "an elder shik`nar outcast" },
        ["Stone Chitin"] = { "a dour delver" },
        ["Velutipes"] = { "a sensate reishi" },
    },

    [854] = { -- Shadeweaver's Tangle
        ["Commander Esline"] = { "a Loda kai guard Commander" },
        ["Molten Wildfire"] = { "a painted elemental" },
        ["Scorched Cackling Bones"] = { "scorched bones" },
        ["Shak Dathor Overlord"] = { "a shak dathor swayer" },
        ["Sharp Claw"] = { "a mature hopper" },
        ["Stoneclaw Broodmother"] = { "a stoneclaw crawler" },
        ["Thorn Petal"] = { "a gloompetal thistle" }
    },

    [852] = { -- Shar Vahl, Divided
        ["Crimsonclaw"] = { "a rockhopper adolescent" },
        ["Geerot Stabgut"] = { "a grimling invader" },
        ["Gheg Gorespit"] = { "a grimling scout" },
        ["Kurati the Feral"] = { "a wrathful Sahtebi" },
        ["Tailfang"] = { "a scorpion elder" },
        ["Toraji, Korath`s Warder"] = { "an ancient skeleton" },
        ["Wiggle"] = { "a hungry xakra worm" },
    },

    ---------Beginning of ToL PH list---------
    [848] = { -- Basilica of Adumbration
        ["Congealed Shadow Mass"] = { "a tangible shadow" },
        ["Dark Agent of Luclin"] = { "a basilica secret keeper" },
        ["Gloomclaw"] = { "an obsidian taskmaster" },
        ["Irate Servant of Luclin"] = { "a shrewd abettor of luclin" },
        ["Itzal, Luclin`s Hunter"] = { "a tekuel" },
        ["Mistakenly Animated Salt Golem"] = { "an animated experiment" },
        ["Xetheg, Luclin`s Warden"] = { "a tekuel" }, -- TODO: verify
    },

    [849] = { -- Bloodfalls
        ["A Retainer of Shadow"] = { "a laborer of shadow" },
        ["Centien Xi Va Xakra"] = { "a war shade" },
        ["Coagulus"] = { "a viscous blood bag" },
        ["Cruor"] = { "a sanguineous blood beast" },
        ["Lady Constance"] = { "a nameless vampire" },
        ["Nikolas the Exiled"] = { "a lost vampire" },
        ["Pli Xin Laiko"] = { "Zun Xin Liako" },
    },

    [845] = { --Ka Vethan
        ["Centi Thall"] = { "Centi Atulus" },
        ["Diabo Tatrua"] = { "Gel`Temariel Centi" },
        ["Diabo Va Thall"] = { "Fer`Tatrua Centi" },
        ["Diabo Xi Va"] = { "Fer`Temariel Centi" },
        ["Diabo Xi Xin"] = { "Teka`Temariel Centi" },
        ["The Protector"] = { "a shade guardian" },
    },

    [843] = { -- Maiden's Eye
        ["Centien Rashen Xaui"] = { "Pli Torgarath Xi Vex" },
        ["Darkmeat"] = { "a luclin scavenger", "a luclin stalker" },
        ["Diabo Xi Akuel"] = { "a well-fed rockbreaker" },
        ["Lucca Brightfeld"] = { "a winged scavenger" },
        ["Namdrows"] = { "a mind burrower" },
        ["Quietus the Forgotten"] = { "an erased hero`s guard", "a lost shade", "a forlorn shade" },
        ["Temariel Xi Tetoracu"] = { "Dabo Xi Vereor" },
        ["Tess Zelinstein"] = { "a peckish vampyre", "a beaten vampyre" },
        ["Txiki"] = { "a gleeful miscreant" },
        ["Xenacious Von Deek"] = { "a rabid bat", "a repressed vampyre", "a pacified vampyre" },
    },

    [847] = { -- Shadow Valley
        ["a scorched terror"] = { "a gnarled terror" },
        ["a tenebrous slight"] = { "a tenebrous shadow" },
        ["an avaricious mass"] = { "an avenging mass" },
        ["an illusive dim"] = { "an illusive swarm" },
        ["Ander, Wolf of Shadows"] = { "a ruinous wolf" },
        ["Bynn the Tormented"] = { "an obscured shade" },
        ["Tearc, Shade Keeper"] = { "a remnant of shade", "an unsettled tumbler" },
    },

    [844] = { -- Umbral Plains
        ["Bloodwretch"] = { "a netherbian ripper" },
        ["Captain Resh Sogran"] = { "a fallen sergeant" },
        ["Fleshrot"] = { "a netherbian carrion" },
        ["Fyrthek Fior"] = { "a fyr jen keeper" },
        ["Gantru Shojralen"] = { "a gantru ralktran" },
        ["Nightfall"] = { "a dark shadow" },
        ["Rumblecrush"] = { "a hefty stone guardian" },
        ["Shak Dathor Warlord"] = { "a shak dathor keeper" },
        ["Sylra Fris"] = { "a syl ren keeper" },
        ["Telaris Xeturisun"] = { "Torgarath Renthais" },
    },

    [846] = { -- Vex Thal
        ["Diabo Xi Va Temariel"] = { "Kela Va" },
        ["Diabo Xi Xin Thall"] = { "Xin Thall" },
        ["Kaas Thox Xi Ans Dyek"] = { "Qua Kaas Thox" },
        ["Thall Va Kelun"] = { "Thall Xi Va" },
        ["Thall Xundraux Diabo"] = { "Kela Thall" },
        ["Thox Xakra"] = { "Raux Xakra" },
        ["Va Xakra"] = { "Kaas Xakra" },
    },

    ---------Beginning of CoV PH list---------
    [833] = { -- Cobalt Scar
        ["Morwenna Undertow"] = { "a neriad huntress" },
        ["Delmare Undertow"] = { "a neriad guard" },
        ["Pikebreath"] = { "a restless othmir" },
        ["Ol` Grinnin` Finley"] = { "a deepwater gnasher" },
        ["Desirae Fanfare"] = { "an alluring siren" },
        ["Octave Sforzando"] = { "any siren then cycle ends with", "a siren muse" },
        ["Skolskin Haeger"] = { "a protective ulthork" },
        ["Kirezelbough"] = { "any wyvern then cycle ends with", "a winged terror", "a wyvern" },
    },

    [832] = { -- Dragon Necropolis
        ["a massive dracoliche"] = { "a dragon construct" },
        ["a moon bat"] = { "a scavenger bat" },
        ["a ravenous entropy serpent"] = { "a decay serpent" },
        ["a restless warlord"] = { "a wandering Chetari" },
        ["a toxic phase spider"] = { "a phasing spider" },
        ["another great green slime"] = { "an amorphous blob" },
        ["Dustbinder Tarlin"] = { "a Chetari dustmaker" },
        ["Foulfang"] = { "a decay serpent" },
        ["Jaled Dar's trapped shade"] = { "must kill all ritualists to break the bond", "a trapped dracoliche" },
        ["Queen Kitlaa"] = { "a phasing spider" },
        ["restless Dominator Yisaki"] = { "a wandering Chetari" },
        ["restless Vaniki"] = { "a wandering Chetari" },
        ["restless Warmaster Ultvara"] = { "a wandering Chetari" },
        ["Seeker Larada"] = { "a Chetari explorer" },
    },

    [835] = { -- Skyshrine
        ["a blessed racnar"] = { "a convincing doomsayer" },
        ["Dagarn the Destroyer"] = { "a pretentious wurm" },
        ["Lord Koi'Doken"] = { "an onyx conspirator" },
        ["Professor Atkru"] = { "a tenured mentor" },
        ["Shoen the Fanatic"] = { "a subservient convert" },
        ["Templeton the Clear"] = { "a crystal abomination" },
        ["Ziglark Whisperwing"] = { "an obsidian believer" },
    },

    [831] = { -- The Sleeper's Tomb
        ["Kildrukaun the Ancient"] = { "a restless drakeen" },
        ["Milas An'Rev"] = { "a venerated sadist" },
        ["The Overseer Reborn"] = { "The Captain of the Guard", "Master of The Guard" },
        ["The Progenitor Reborn"] = { "The Progenitor" },
        ["Tjudawos the Ancient"] = { "a shimmering drakeen" },
        ["Ulessa the Insane"] = { "a wyvern sentinel" },
        ["Vyskudra the Ancient"] = { "a lonely drakeen" },
        ["Zeixshi'Kar the Ancient"] = { "a forgotten drakeen" },
    },

    [836] = { -- The Temple of Veeshan
        ["Dozekar the Cursed"] = { "a shimmering priest" },
        ["Feshlak"] = { "a scarlet sycophant" },
        ["Gozzrem"] = { "a pious martyr" },
        ["Ikatiar the Venom"] = { "a wyvern scholar" },
        ["Jorlleag"] = { "a distrusting devout" },
        ["Ktheek the Ripper"] = { "a sapphire devotee" },
        ["Lady Mirenilla"] = { "a shard hatchling" },
        ["Lord Vyemm"] = {
            "Cycle through all of the following",
            "a vile defender",
            "a vicious defender",
            "a vicious scholar",
            "a vicious warrior",
            "a vicious leader",
        },
    },

    [834] = { -- The Western Wastes
        ["a restless behemoth"] = { "a restless wurm" },
        ["Blasphemous Steel"] = { "an exiled efreeti" },
        ["Bliddlethliclaus"] = { "an exiled kedge" },
        ["Feltinth the Caring"] = { "a brood caretaker" },
        ["Miscreation the Timeless"] = { "a frosted dracholiche" },
        ["Pastletlith the Temperate"] = { "a brood hatchling" },
        ["Rildar Blackstone"] = { "a forgotten vanguard" },
        ["Shrapnel"] = { "a velious hound" },
    },

    ---------Beginning of ToV PH list---------
    [830] = { -- Crystal Caverns
        ["Crystal Grinder"] = { "a crystal skitterer" },
        ["Gem collector"] = { "a focus geonid" },
        ["Life Leech"] = { "a terror carver", "a hollow carver" },
        ["Queen Dracnia"] = { "a crystal purifier", "a drachnid retainer" },
    },

    [829] = { -- Kael Drakkel
        ["Black Fang"] = { "a frost giant gladiator" },
        ["Direfang"] = { "a restless direwolf" },
        ["Drendar Blackblade"] = { "a storm giant soldier" },
        ["Fjokar Frozenshard"] = { "a storm giant soldier" },
        ["Irrek Bloodfist"] = { "a storm giant soldier" },
        ["Kallis Stormcaller"] = { "a storm giant soldier" },
        ["Keldor Dek`Torek"] = { "a storm giant soldier" },
        ["Klraggek the Slayer"] = { "a storm giant soldier" },
        ["Velden Dragonbane"] = { "a storm giant soldier" },
        ["Vkjen Thunderslayer"] = { "a storm giant soldier" },
    },

    [824] = { -- Eastern Wastes
        ["a returned dracoliche"] = { "a restless dracoliche" },
        ["Bolman"] = { "a frozen fright" },
        ["Cadcane the Unmourned"] = { "a cold skeleton" },
        ["Coldears"] = { "a frosted mammoth" },
        ["Mahaha"] = { "a hypothermic ghoul" },
        ["Monolith the Unstoppable"] = { "an exiled sentry" },
        ["Servant of the Sleeper"] = { "a restless dracholiche" },
        ["Soulbinder Jorvok"] = { "a frozen sentry" },
        ["Tundra Jack"] = { "a tundra jack" },
        ["Vesagran"] = { "a frosted zombie" },
        ["Zburator the Damned"] = { "a hoarfrost cadaver" },
    },

    [827] = { -- The Great Divide
        ["a forgotten raid leader"] = { "a forgotten enforcer" },
        ["a tizmak augur"] = { "a shivering tizmak" },
        ["Blizzent"] = { "a shivering shardwurm" },
        ["Bloodmaw"] = { "a frosted kodiak" },
        ["Gerton Dumkin"] = { "a Coldain fighter" },
        ["Gorul Longshanks"] = { "a corrupted giant" },
        ["Laima Ratgur"] = { "a frigid coldain" },
        ["Loremaster Metiheib the Lost"] = { "a windchilled marrowbones" },
        ["Lost Squire of Narandi"] = { "a lost squire" },
        ["Nobles' Causeway Champion"] = { "a noble's causeway defender" },
        ["Rime Golem"] = { "a rime golem" },
        ["Rimecutter"] = { "a frosted kodiak" },
        ["Sister of the Spire"] = { "a sister of the spire" },
        ["Sverag, Strongarm of Rallos"] = { "a frost giant tactician" },
        ["Thosgromri Warmgranite"] = { "a frigid cadaver" },
    },

    [826] = { -- The Ry'Gorr Mines
        ["Ry`Gorr Herbalist"] = { "a Ry'Gorr apprentice" },
        ["Ry`Gorr Inspector"] = { "a restless Ry'Gorr foreman" },
    },

    [825] = { -- The Tower of Frozen Shadow
        ["a shrouded bat"] = { "a shrouded bat (labeled as rare)" },
        ["a skeleton sleeper"] = { "a shadowbone" },
        ["Amontehepna the Second"] = { "a frost mummy" },
        ["Ascendant Svartmane"] = { "a restless tutor" },
        ["Cara Omica"] = { "a zombie maid" },
        ["Dark Huntress"] = { "an undead dancer", "an undead musician" },
        ["D`dee the Chilled"] = { "a restless mummy" },
        ["Deacon Foels Tomorin"] = { "a drolvarg guard" },
        ["Malvus Darque"] = { "Spawns on death of the named:", "a shrouded bat" },
        ["Narmak Berreka"] = { "a possessed armor" },
        ["Vhal`Sera"] = { "a restless spectre" },
        ["Xalgoti"] = { "a returned shadow beast" },
        ["Zorglim the Dead"] = { "a disturbed student" },
    },

    [828] = { -- Velketor's Labyrinth
        ["a restless devourer"] = { "a restless spider" },
        ["a restless tarantula"] = { "a wandering arachnid" },
        ["a velium horror"] = { "a glaring gargoyle" },
        ["an icy torment"] = { "a living spire" },
        ["Bledrek"] = { "a living ice construct" },
        ["Kerdelb"] = { "a restless ice construct" },
        ["Marlek Icepaw"] = { "an undying kobold" },
        ["Neemzaq"] = { "a freezing shade" },
        ["Qabruh"] = { "an icy gargoyle" },
        ["Vorgak"] = { "a mindless orc" },
        ["Zarhbub Icepaw"] = { "a wandering icepaw" },
    },

    ---------Beginning of TBL PH list---------\
    [819] = { -- Aalishai: Palace of Embers
        ["Evasion Understanding Flow"] = { "an elemental of purest flame" },
        ["Final Blade Lord"] = { "a scoria golem" },
        ["Ghost Glass Bitter"] = { "a djinn scholar" },
        ["Ruby Icefall Blossom"] = { "a surf armor" },
        ["Shield Spirit`s Laugh"] = { "a flashfire phoenix" },
        ["Sixth Consuming Master"] = { "a vergerog soldier" },
        ["Steam Wave Slicer"] = { "a fire giant commander" },
        ["Stout Stone Beaten"] = { "a vekerchiki soldier" },
        ["Unconquering Sand Dirge"] = { "a duende emissary" },
        ["Venom of the Fallen Star"] = { "a flurry mephit" },
        ["Whispering Depths Sigh"] = { "a hraquis surgelord" },
        ["White Iron Rainbow"] = { "a brumeflight armor" },
    },

    [820] = { -- Empyr: Realms of Ash
        ["Ashes"] = { "a sputtering flameling" },
        ["Assassin of the Perfect Dusk"] = { "a fire giant knight" },
        ["Final Rainbow"] = { "a breeze mephit" },
        ["Flail"] = { "a fire snail" },
        ["Fluttering Ruby Prince"] = { "an efreeti soldier" },
        ["Iron Heart"] = { "an efreeti sodlier" },
        ["Mischief Darkheart"] = { "a jopal mercenary" },
        ["Shockstone"] = { "a butte armor" },
        ["Sister of the Invisible Heart"] = { "an ondine ambassador" },
        ["Stalwart Flicker"] = { "a pyrite armor" },
        ["The Burning Mist"] = { "an elemental of purest flame" },
        ["Wilting Flames"] = { "an aging lapillus lava spider" },
    },

    [821] = { -- Esianti: Palace of the Winds
        ["Blessed Wind"] = { "a djinn teacher" },
        ["Copper Star"] = { "a jopal warder" },
        ["Depth of Iron"] = { "a vekerchiki warder" },
        ["Iron Lance"] = { "a pyratic armor" },
        ["Jericog Merkin"] = { "a norrathian mage" },
        ["Leaping Eyes"] = { "an efreeti noble" },
        ["Rusted Stalactite"] = { "a cliff armor" },
        ["Sapphire Hammer"] = { "a breeze armor" },
        ["Seeping Gladness"] = { "a crest armor" },
        ["Sky Blade"] = { "a gusting mephit" },
        ["Veiled Sage"] = { "a djinn teacher" },
        ["Warrior`s Cleft"] = { "a triloun warder" },
    },

    [822] = { -- Mearatas: The Stone Demesne
        ["an ancient air warden"] = { "a breeze warden" },
        ["an ancient fire warden"] = { "a flame warden" },
        ["an ancient stone warden"] = { "a rock warden" },
        ["an ancient water warden"] = { "a wave warden" },
        ["Flowing Horizon Halo"] = { "a duende messenger" },
        ["Forsaken Cloud Sapphire"] = { "Spawns in the center of the zone. No PH" },
        ["Glaring Moon Void"] = { "Spawns in the center of the zone. No PH" },
        ["Platinum Rainbow Spire"] = { "Spawns in the center of the zone. No PH" },
        ["Radiant Amber Lotus"] = { "a lord of flame" },
        ["Tsunami Sol Blood"] = { "Spawns in the center of the zone. No PH" },
        ["Whispering Frost"] = { "an ondine servant" },
        ["Blistering Star"] = { "a wind lady", "a wind lord" },
    },

    [817] = { -- Plane of Smoke
        ["Dirge of Lost Horizons"] = { "a fading lord" },
        ["Savage Irony of Will"] = { "a true flame" },
        ["Silent Silken Song"] = { "a wasting breezewing" },
        ["Soothing Wings of Mist"] = { "a true wind" },
        ["Strength of Undefeated Starfall"] = { "a soot steed" },
        ["Wandering Spring Soul"] = { "a dispersing windlord" },
    },

    [818] = { -- Stratos: Zephyr's Flight
        ["Cloud_Iron_Lance"] = { "an abundant gale" },
        ["Daring Cloud Spear"] = { "a dusty mephit" },
        ["Dawnbreeze"] = { "a whirlweaver phoenix" },
        ["Dour Eighth Guardian"] = { "a dignified djinn" },
        ["Eastern Radiant Glance"] = { "a voluminous gale" },
        ["Glassbeak Stormbreaker"] = { "a windweaver phoenix" },
        ["Horizon of Destiny"] = { "a tempestuous gust" },
        ["Infinite Horizon Star"] = { "a billowing gale" },
        ["Silver Eyes Dread"] = { "a glorious djinn" },
        ["Starshine, Icebreaker"] = { "a brumebreeze armor" },
        ["Triumphal Still Sky"] = { "a grand djinn" },
        ["Wild Blossom Star's_Flight"] = { "an easterly mephit's_Flight" },
    },

    [823] = { --Chamber of Tears--No Achievements for this zone
    },

    [787] = { -- Gnome Memorial Mountain
        ["A Non-Standard Deviation"] = { "an iron legion climber" },
        ["Ambassador of Loving"] = { "a clockwork guardian" },
        ["Best Museum Security"] = { "a Security Officer" },
        ["Bloodmoon Chief Eclipse"] = { "a Bloodmoon darkheart" },
        ["Bloodmoon Howler Trolog"] = { "a Bloodmoon howler" },
        ["Breaker"] = { "a clockwork captain" },
        ["Consul of Cooperation"] = { "Heroic Adventure: Ironing out the Legion", "a lookout" },
        ["Fractured Sweeper"] = { "clockwork companion" },
        ["Grash, Bloodmoon Growler"] = { "Heroic Adventure: The Darkness Howls", "a Bloodmoon scrabbler" },
        ["Healer Prime"] = { "a clockwork healer" },
        ["Malfunctioning Iron Legion Hug"] = { "a gnomelike friend" },
        ["Master Mechanic"] = { "a clockwork lifter" },
        ["Repair for Pieces"] = { "an Iron Legion helper" },
        ["Tatters"] = { "a brave rat" },
    },

    ---------Beginning of RoS PH list---------
    [789] = { -- Sathir's Tomb
        ["a Kar`zok grave robber"] = { "a Krellnakor filcher", "a Fereth appraiser" },
        ["a Kar`zok infiltrator"] = { "a Krellnakor enforcer", "a Wulthan thief", "a Krellnakor scavenger", "an Arcron lifter" },
        ["Arisen Gloriant Kra`du"] = { "an Arisen steward", "an Elevated skeleton" },
        ["Xalgoz the Arisen"] = { "an Arisen ritualist", "an Exalted spirit" },
        ["Ancient Apparition"] = { "an arisen apparition" },
    },

    [792] = { -- Gorowyn
        ["Artikla, Fereth Despot"] = { "a Fereth commander" },
        ["Elkikatar"] = { "a Kar'Zok scourge" },
        ["Gnaw"] = { "a chokidai elder" },
        ["Head Boiler Akett"] = { "a soup boiler" },
        ["High Arcron Zeklor"] = { "an Arcron burner" },
        ["Hissilith, the Brittlebones"] = { "an enslaved skeleton" },
        ["Overlord Klerkon"] = { "a Krellnakor destroyer" },
        ["Overlord Teralov"] = { "a Krellnakor terror" },
        ["Overlord Tevik"] = { "a Krellnakor seeker" },
        ["Rekatok One-Eye"] = { "an aging pit fighter" },
        ["The Magmalisk"] = { "a hungry lavalisk" },
        ["Wulthan High Inquisitor Kraz"] = { "a Wulthan administrator" },
        ["Fereth Captain Ordran"] = { "a fereth captain" },
        ["Wulthan Elder Priest Ovun"] = { "a wulthan priest" },
    },

    [813] = { -- Howling Stones
        ["Deka the Reaper"] = { "a specter of the Arisen" },
        ["Embalming Goo"] = { "Arisen bones" },
        ["General V`Deers, the Arisen"] = { "an Arisen officer" },
        ["Nureya Arisen"] = { "a specter of the Arisen" },
        ["Shandral Arisen"] = { "an arisen convert" },
        ["The Arisen Admiral Tylix"] = { "a specter of the Arisen" },
        ["The Arisen Dragoon T`Vem"] = { "a specter of the Arisen" },
        ["The Arisen Dragoon T`Vex"] = { "Arisen bones" },
        ["The Great Sentinel"] = { "a specter of the Arisen" },
        ["The Underlord"] = { "a bottomless gnawer" },
        ["Tormented Adalora"] = { "a specter of the Arisen" },
        ["Vermistipus"] = { "a specter of the Arisen" },
        ["Arisen Fenistra"] = { "an Arisen ghost" },
        ["Arisen Mentor Sishallan"] = { "an Arisen mentor" },
    },

    [814] = { -- The Skyfire Mountains
        ["a feverish marauder"] = { "a zealot" },
        ["a rabid reveler"] = { "a brazen Chetari", "a drunken Chetari" },
        ["a scree-borne magmite"] = { "wrathful rubble", "a blackened tyro" },
        ["a supercharged tyro"] = { "a volatile effusion", "a stubborn magmite" },
        ["an Arcron researcher"] = { "a Krellnakor scout" },
        ["Ash Guardian Tolemak"] = { "a guardian wurm" },
        ["Chirurgeon Hemofax"] = { "an ashen scalpel", "an ashen cutter" },
        ["Dragoflux"] = { "a raging vortex" },
        ["Mawmun"] = { "a greedy gnawer" },
        ["Old Raspy"] = { "an old wurm" },
        ["Radiant Overseer Triluan"] = { "a radiant drake" },
        ["Rirwech the Fink"] = { "a suspicious Chetari", "a furtive Chetari" },
        ["Ritualist Bomoda"] = { "a grim cultist", "a grim chanter" },
        ["Shardstubble"] = { "a fractured magmite", "a fragile tyro" },
        ["Skrizix"] = { "an exotic chromedrac" },
        ["The Crimson Sentinel"] = { "an angry Arcron" },
        ["The Gatekeeper"] = { "a Krellnakor bodyguard", "a Krellnakor doorman" },
    },

    [815] = { -- The Overthere
        ["Banshee"] = { "a screeching chokidai" },
        ["Bloodstalker"] = { "a blood-stained stalker" },
        ["a bluff golem"] = { "a rocky cliff golem" },
        ["Drakis"] = { "a dreadful scorpikis" },
        ["Fang"] = { "a stonepeep cockatrice" },
        ["a grotesque succulent"] = { "a sickly succulent" },
        ["an iron sentinel"] = { "a rubble golem" },
        ["Janissary Virzak"] = { "a Wulthan Zealot" },
        ["a Kar`Zok lacerator"] = { "a Fereth procurator" },
        ["a majestic cockatrice"] = { "a stoneglint cockatrice" },
        ["Myrmidon Tundak"] = { "a Krellnakor officer" },
        ["Needle"] = { "a needle-covered succulent" },
        ["Observer Eyrzekla"] = { "a mysterious sarnak" },
        ["Rigelon the Watcher"] = { "a shifty scorpikis" },
        ["Saber"] = { "a raging rhino" },
        ["Arcron Thaumaturge Osellik"] = { "an arcron thaumaturge" },
        ["Flamescale Overlord Takarious"] = { "a Krellnakor overlord" },
    },

    [816] = { -- Veeshan's Peak
        ["Blood-Thirsty Racnar"] = { "a frenetic racnar" },
        ["Elder Azeron"] = { "an ancient flame protector" },
        ["Elder Ekron"] = { "1 hour and 45 minute timer" },
        ["Ellarr Stormcloud"] = { "1 hour and 45 minute timer" },
        ["Kluzen the Protector"] = { "1 hour and 45 minute timer" },
        ["Magma Basilisk"] = { "a magma basilisk" },
        ["Milyex Vioren"] = { "1 hour and 45 minute timer" },
        ["Qunard Ashenclaw"] = { "a primeval cinder skyclaw" },
        ["Travenro the Skygazer"] = { "1 hour and 45 minute timer" },
    },

    ---------Beginning of EoK PH list---------
    [800] = { -- Chardok
        ["Battle Master Ska`tu"] = { "a reanimated berserker", "a reanimated dragoon", "a reanimated partisan" },
        ["The Bridge Keeper"] = { "a bridge guardian" },
        ["Crackjaw"] = { "a starving beetle", "a frenzied beetle" },
        ["Deathfang"] = { "a chokidai bonecrusher", "a cholidai lacerater" },
        ["Dread Overseer Akalod"] = { "Heroic Adventure: Others' Things", "a weary overseer" },
        ["Dry Rot"] = { "a moldering fungusman" },
        ["Flight Master Hak`ouz"] = { "a flight coordinator" },
        ["Fractured Shard"] = { "a magic tear" },
        ["Grand Advisor Zum`uul"] = { "a Shai`din scribe" },
        ["Grand Herbalist Mak`ha"] = { "a Di`zok herb gardener", "a chokidai herbdigger" },
        ["Kennel Master Al`ele"] = { "a kennel mucker", "a kennel keeper" },
        ["Observer Aq`touz"] = { "a Di`zok watcher" },
        ["Overseer Dal`guur"] = { "a Di`zok foreman", "a Di`zok slavemaster" },
        ["Queen Velazul`s Aide"] = { "royal escort" },
        ["Royal Guard Kakator"] = { "Heroic Adventure: On Behest of the Emperor", "a weary royal guard" },
        ["Selrach`s Regent"] = { "royal guard" },
        ["Shai'din Warmaster Roh`ki"] = { "a Di`zok strategist" },
        ["The Sokokar Matron"] = { "a sokokar consort", "a sokokar welpling" },
        ["Watch Captain Hir`roul"] = { "a Di`zok watchman" },
    },

    [791] = { -- Frontier Mtns
        ["Belligerent Biarn"] = { "a Konikor drunk" },
        ["Bi`faak the Shadowwalker"] = { "a Drogan reveler" },
        ["Blooddrinker Furasza"] = { "a Syldon flamewarden" },
        ["Brute Herder Ar`shok"] = { "a Syldon agitator" },
        ["Corrupted Grove Guardian"] = { "a grove guardian" },
        ["Delirious Berserker"] = { "a Drogan berserker" },
        ["Drillmaster Mak`tak"] = { "a Syldon drill sergeant" },
        ["Flamewarden Zev`ran"] = { "a Syldon neophyte", "an experimental behemoth" },
        ["Flintikki Peltpile"] = { "a frontier bear" },
        ["Masterchef Ram`see"] = { "a Syldon chef" },
        ["Orechomper"] = { "a Legion miner" },
        ["Reese the Rhinopocalypse"] = { "a frontier poacher" },
        ["Spyhunter Zath`ran"] = { "a Syldon greenhorn" },
    },

    [793] = { -- Gates of Kor-Sha
        ["Chokidai Wardog"] = { "a chokidai mangler" },
        ["Corpsestalker"] = { "a mature stalker" },
        ["Hunter Gwalnex IV"] = { "a Sarnak trapper" },
        ["Overboss Kaznak"] = { "a Sarnak warlord" },
        ["Spiritmaster Tala'Tak"] = { "a Sarnak sage" },
    },

    [799] = { -- Korsha Laboratory
        ["Bonescale"] = { "a lurking stalker" },
        ["Cutter"] = { "a chokidai elder" },
        ["Darkness"] = { "an ectopic amygdalan" },
        ["Deathgazer"] = { "a lurking beetle" },
        ["Firedowser Uglabarg"] = { "a conscripted dirtcaster" },
        ["Glart Fink"] = { "a conscripted warrior" },
        ["Kar`zok Overlord"] = { "a Kar`zok warrior" },
        ["Mad Researcher"] = { "Heroic Adventure: Infiltration of Kor-Sha", "a dazed researcher" },
        ["Okara Klyseer"] = { "a Di`zok adherent" },
        ["Overlord Dralgan"] = { "a Di`zok myrmidon" },
        ["Rogue Monstrosity"] = { "Heroic Adventure: Mysteries of Kor-Sha", "a golem" },
        ["Screaming Tormentor"] = { "a luxated terror" },
        ["Sepulcher Curator"] = { "a crypt guard" },
        ["Stonespiked Guardian"] = { "a wary guard" },
        ["The Possessed"] = { "a conscripted spiritist" },
        ["Vakazon Viz`Daron"] = { "a Di`zok aruspex" },
    },

    [794] = { -- Lceanium
        ["A Drolvarg Captain"] = { "a drolvarg gnasher" },
        ["A Drolvarg Lord"] = { "a drolvarg ravisher" },
        ["Darg Hillock"] = { "a mountain giant brae" },
        ["Dread Drikat"] = { "a drachnid stinger" },
        ["Hunter Haltha"] = { "a mountain giant peak" },
        ["Kergag, the Mountain"] = { "a mountain giant lord" },
        ["Nightvenom"] = { "a venomous drachnid" },
        ["Slitherblade"] = { "a dread widow" },
        ["The Blazing Hen"] = { "a stoneglare cockatrice" },
        ["The Dreadland Wanderer"] = { "a greater spurbone" },
        ["The Lost Hunter"] = { "a rotting skeleton" },
        ["The Stone Dove"] = { "a calcifier cockatrice" },
        ["Tithnak Shadowhunter"] = { "a dire widow" },
        ["Yeti Matriarch"] = { "a huge tundra yeti" },
        ["Yeti Patriarch"] = { "a massive tundra yeti" },
    },

    [790] = { -- Scorched Woods
        ["Caradawg Gwyn"] = { "a majestic sureshot" },
        ["Carpenter Adomnan"] = { "a forest giant carpenter" },
        ["Cathal Paclock"] = { "a forest giant fury" },
        ["Gullerback Undying"] = { "an ancient tatterback" },
        ["Plaguebringer"] = { "an ancient plaguebone" },
        ["Searstinger"] = { "an immolator hornet" },
        ["Sovarak Klyseer"] = { "a Sarnak shadowknight" },
        ["Spirit of Incineration"] = { "a spirit of flame" },
        ["The Ore-mad Prophet"] = { "a burynai prophet" },
        ["Zakija"] = { "a wurm-scorched skeleton" },
    },

    [788] = { -- Temple of Droga
        ["Black Spot"] = { "a goblin slave" },
        ["Blood of Droga"] = { "a blightcaller bloodtender", "a blightcaller bloodtoiler" },
        ["Bore"] = { "mudman dredger" },
        ["Chief Dronan"] = { "Dronan bodyguard", "Dronan bodyshield" },
        ["Cook Eepvibles"] = { "a goblin cook" },
        ["Cook Jexnait"] = { "a devout goblin cook" },
        ["Home Master Kaziql"] = { "a homesafe goblin sentry" },
        ["Izisyl Peppershiv"] = { "a goblin caveshadow" },
        ["Jailor Muxfan"] = { "a goblin jailor", "a stalwart goblin jailor" },
        ["Master Kizzixik"] = { "a goblin slave master", "a goblin slave dealer" },
        ["Merchant Triala"] = { "Heroic Adventure: Goblins and Fools", "a goblin slinker" },
        ["Miner Groundfuse"] = { "a goblin dredger", "a stalwart goblin dredger" },
        ["Most Devout Sentry"] = { "a devout goblin sentry" },
        ["Overseer Vakov"] = { "a goblin taskmaster", "a hearty goblin taskmaster" },
        ["Sentry Rixzeel"] = { "an expert goblin sentry", "a tenacious goblin sentry" },
        ["Spirit Master Wigaue"] = { "a goblin fanatic" },
        ["Spiritwatcher Scrollhallow"] = { "a goblin mystic", "a goblin adept mystic" },
        ["War Leader Callex"] = { "a goblin forerunner sentry" },
        ["Whip Cracker Krassex"] = { "a goblin whip lord" },
    },

    ---------Beginning of TBM PH list---------
    [795] = { -- Crypt of Sul
        ["Bokon Revel the Reborn"] = { "an unliving hulk" },
        ["Citizen Pain"] = { "Heroic Adventure: To The Brave, Go The Spoils!", "a reserved worshiper" },
        ["Devourer of All"] = { "an insatiable fiend" },
        ["Grinder"] = { "Heroic Adventure: The Head of the Snake", "a faithblind hulk" },
        ["High Priestess Kal`vius"] = { "a high bokon" },
        ["Spine Eater"] = { "Heroic Adventure: The Bokon High Council", "a drooling ghoul" },
        ["The Watcher"] = { "a skeletal sentinel" },
    },

    [796] = { -- Crypt of Decay
        ["Abroan Drian"] = { "a corruptor knight" },
        ["Akkapan Adan"] = { "a bubonian warmaster" },
        ["Brightfire"] = { "a wary unicorn" },
        ["Feig Adan"] = { "a foulest pusling" },
        ["Fountainhead"] = { "a wellspring construct" },
        ["Grublus"] = { "Heroic Adventure: Lxavnom Labors", "a grumling" },
        ["Rusank"] = { "Heroic Adventure: Decay Decreased", "a pusling" },
        ["Seraphina"] = { "Heroic Adventure: Force the Forceful", "a seraph" },
        ["Xhut Adan"] = { "a dreadbone sage" },
    },

    [777] = { -- Sul Vius: Demiplane of Life
        ["Arsin the Blaze"] = { "Heroic Adventure: Under the Robe", "a ravenous citizen" },
        ["Commissioner Edrun"] = { "an overworked functionary" },
        ["Exalted Dromond"] = { "an honorable citizen" },
        ["Glorious Cistina"] = { "a gleeful citizen" },
        ["Guardian Jenat"] = { "a diligent guard" },
        ["Gurndal the Graceful"] = { "Heroic Adventure: We Make Our Own Rewards", "a venerated guard" },
        ["Mad Merchant Marv"] = { "a retired merchant" },
        ["Render"] = { "Heroic Adventure: The Handmaiden", "an enraged follower" },
        ["Terrance the Admired"] = { "a delighted citizen" },
        ["The Darkseer"] = { "an aloof bokon" },
        ["Vizier Albert"] = { "a doubtful functionary" },
    },

    [797] = { -- Sul Vius: Demiplane of Decay
        ["Emma, a True Believer"] = { "a worn administrator" },
        ["Eunice, Well-Wisher"] = { "a mournful peasant", "a burly cultist" },
        ["High Bokon Cleret"] = { "Heroic Adventure: Fate Rewards the Bold", "a grand bokon" },
        ["Master of the House"] = { "a retired salesperson" },
        ["Svea Haire"] = { "an impatient wanderer" },
        ["Tarris Ellarn"] = { "Heroic Adventure: Undead Underground", "a wandering official" },
        ["The Curator"] = { "a tireless sentinel" },
        ["The Perforator"] = { "Heroic Adventure: Deadline", "a mute citizen" },
        ["The Remnants of The Darkseer"] = { "an assistant to Darkseer" },
        ["The Sleepbringer"] = { "a tsetse eater", "a tsetse swarmborn" },
        ["Zikursch the Corrupt"] = { "an unpleasant bureaucrat" },
    },

    [798] = { -- Plane of Health
        ["Bhaly Adan"] = { "Heroic Adventure: Bane of Decay", "Unknown" },
        ["Bilemonger"] = { "Heroic Adventure: In Defense of Health", "a bubonian wartail" },
        ["Pestilent Warmaster"] = { "Heroic Adventure: In Defense of Health", "Unknown" },
        ["Prepusterous"] = { "Heroic Adventure: Defenders of the Faith", "a bubonian terror" },
        ["Putrid Brute"] = { "Heroic Adventure: In Defense of Health", "Unknown" },
        ["Vomitous"] = { "Heroic Adventure: In Defense of Health", "a bubonian wartai" },
    },

    -------------Beginning of TDS PH list-------------
    [778] = { -- Arx Mentis
        ["Bonemaw"] = { "a fearful scavenger magicae" },
        ["Caldarius"] = { "a worn arc worker" },
        ["Mayor Praetor Livio"] = { "a spent praetor noctis" },
        ["Mother Virgia"] = { "a frayed virga vitala" },
        ["Praetor Loricas the Hollow"] = { "Heroic Adventure: Shake the Citadel", "a fading steel worker" },
        ["Principal Indagator Gordianus"] = { "a bored indagatrix materia" },
        ["Principal Indagatrix Lucia"] = { "an irked indagator" },
        ["Principal Quastori Numicia"] = { "a tired praetor ledalus" },
        ["Principal Vicarum Nonia"] = { "Una jaded vicarum vitaiknown" },
        ["The Codex Libre"] = { "a torn libre vitala" },
    },

    [779] = { -- Brother Island
        ["Angry Alfred"] = { "an angry squawker", "a bothered squawker" },
        ["Lidia the Castaway"] = { "a regretful wanderer", "a vengeful wanderer" },
        ["Mulchmother"] = { "a voracious tasselvine" },
        ["Redstreak"] = { "an angry furthick", "a furthick charger" },
        ["South Point Latcher"] = { "a clipping razorlatch", "a snipping razorlatch" },
    },

    [782] = { -- Caverns of Endless Song
        ["Crista Faelorin"] = { "an enamored evoker" },
        ["Elera Shelwin"] = { "a razored temptress" },
        ["Elizabeth Ruffleberg"] = { "Heroic Adventure: Seductive Subterfuge", "a voiceless temptress" },
        ["Fire Eyes"] = { "a blazing evoker" },
        ["Kaevon Maelora"] = { "an enamored warden" },
        ["Katelyn Grubson"] = { "a singing banshee" },
        ["Neplin the Oceanlord"] = { "an ocean elemental" },
        ["Old Spirespine"] = { "an aged spirespine" },
        ["Reynald the Songweaver"] = { "a songweaver" },
        ["Sister of the Song"] = { "a song sister" },
        ["The Maestro of Endless Song"] = { "a song master" },
        ["Turebious the Tempted"] = { "a song warden" },
        ["Whitebelly"] = { "a scarred hammerhead" },
    },

    [781] = { -- Combine Dredge
        ["Frachessa the Feared"] = { "a hateful Doomscale wrathforged" },
        ["Fractureshell"] = { "a fractured regrua" },
        ["High Guard Vnayyanye"] = { "Heroic Adventure: Kedge Counterblow", "a restive guard" },
        ["Indagator Mortem Livianus"] = { "a timid indagator vocantem" },
        ["Necromaticus Abominatio"] = { "an abominatio elementaribus" },
        ["Praetor Ledalus Thaddaeus"] = { "a supurbus praetor lucem" },
        ["Pria the Penitent"] = { "a penitent Doomscale cultist" },
        ["Saevus Lapis Operarius"] = { "an inconstans lapis operarius" },
        ["Vicarum Spiritus Psyche"] = { "an inanimatum vicarum spiritus", "an inanimatum vicarum vitai" },
        ["Warleader Jocelyn"] = { "a warleader follower" },
    },

    [784] = { -- Degmar, the Lost Castle
        ["Commander Alast Degmar"] = { "Sub Commander Hob Stetson" },
        ["Enraged Spectral Reveler"] = { "an angry spectral reveler" },
        ["Frantic Smith"] = { "a confused smith" },
        ["Ghostly Guard"] = { "Heroic Adventure: Castle Relic", "a haunted Degmar guardian" },
        ["Horthin Blackbook"] = { "a dirty digger" },
        ["Psychotic Prisoner"] = { "a crazed prisoner" },
    },

    [780] = { -- Katta Castrum: Deluge
        ["Chief Librarian Lars"] = { "a shissar arbiter", "a shissar defiler" },
        ["Darkmud Keeper"] = { "a darkmud keeper", "a darkmud watcher" },
        ["Essence of the Deep"] = { "an essence vortex" },
        ["Thallus the Whip"] = { "a shissar taskmaster" },
        ["Vizat the Defiled"] = { "a shissar revenant" },
        ["Yulin the Flameweaver"] = { "a shissar flameweaver" },
    },

    [785] = { -- Tempest Temple
        ["Aquinus"] = { "an ocean caller" },
        ["Captain Johan"] = { "First Mate Parsons" },
        ["Nulian the Stormwarden"] = { "a storm champion" },
        ["Reefmaw"] = { "an enraged reef crawler" },
        ["Scalithid the Deepwalker"] = { "a deepwalker naga" },
        ["Serisaria"] = { "Heroic Adventure: Storm of Sorts", "a lost siren" },
        ["Serpentil"] = { "a coral serpent" },
        ["Stormrock"] = { "a tempest dervish" },
        ["Strangacul"] = { "an enraged rocksnapper" },
    },

    [783] = { -- Thuliasaur Island
        ["Blacksmith Thassis"] = { "a Thaell Ew master smith" },
        ["Cuisinier Sraskus"] = { "a tired Thaell Ew cook" },
        ["Deicoraxius"] = { "Heroic Adventure: A Fateful Arrival", "a bloodtear ebonwing" },
        ["Hemocoraxius"] = { "a bloodtear Ebonwing" },
        ["Plexipharia"] = { "an elder glistenwing" },
        ["Reginasaur"] = { "a tyrannosaurus matriarch" },
        ["Rexsaurkarus"] = { "Heroic Adventure: A Fateful Arrival", "an old tyrannosaurus" },
        ["Serthuliakar"] = { "Heroic Adventure: A Fateful Arrival", "a tired Thaell Ew hunter" },
        ["Tricerasaur"] = { "an old triceratops" },
        ["Visoracius"] = { "an elder raptor" },
    },

    ---------Beginning of CoTF PH list---------
    [776] = { -- Argin Hiz
        ["Ancient Corpse"] = { "a worn singedbones skeleton" },
        ["Captain Dalyn"] = { "an alert soldier" },
        ["Captain Nalia"] = { "an alert ember trooper" },
        ["Chamberlain Celain"] = { "a weary steward" },
        ["Chief Warden Varken"] = { "a gruff warden" },
        ["Councilor Grael"] = { "Mission: Rings of Fire", "a bored councilor" },
        ["Guardian Harell"] = { "a keeper of the hearth" },
        ["Inferno Vortex"] = { "Heroic Adventure: A Posthumous Proposition", "a trooper" },
        ["Magma Behemoth"] = { "a worn slag golem" },
        ["Master Sage Lowenn"] = { "a weary ember sage" },
    },

    [770] = { -- Bixie Warfront -- TODO: Add Bixie Warfront II
        ["Arachnox, the Dread Widow"] = { "Heroic Adventure: The Great Hunt", "an agitated widow" },
        ["a Bixie Guardian"] = { "Heroic Adventure: Assault the Main Hive", "a Bixie impaler" },
        ["Dreadmole"] = { "Heroic Adventure: Always Follow the Money", "a burrowing mole" },
        ["an Enraged Bixie Drone"] = { "Heroic Adventure: Espionage Starts at Home", "a wandering drone" },
        ["Monarch Deathwing"] = { "Heroic Adventure: Working Overtime", "a fluttering reaver" },
        ["Pollenix"] = { "Heroic Adventure: They're Everywhere", "a Bixie enforcer" },
        ["Princess Honeywing"] = { "Heroic Adventure: Jacyll's Jailbreak", "Unknown" },
        ["Tleroth, Mistress of the Web"] = { "Heroic Adventure: They've Gone Too Far This Time", "an arachnid harrower" },
    },

    [772] = { -- Ethernere Tainted West Karana -- TODO: Add Ethernere Tainted West Karana II
        ["Brodhas"] = { "a bandit foecrusher" },
        ["Crazed Scarecrow"] = { "an insane scarecrow" },
        ["Drezdal"] = { "an undead soldier" },
        ["Ethilen"] = { "a baneful soul" },
        ["Gelden"] = { "a gehien fleshcutter" },
        ["Grawrarawr"] = { "a lurking ursarachnid" },
        ["Guard Donlan"] = { "a traitorous guard" },
        ["Lava Mantle"] = { "a lavacrust strider" },
        ["Oklaric"] = { "an oragic mindpiercer" },
        ["Roon"] = { "Unknown-Timer?" },
        ["Shoon"] = { "Unknown-Timer?" },
        ["Skretch"] = { "a skirth boneshredder" },
        ["Soul Sifter"] = { "a soul taker" },
        ["Stix"] = { "a bandit gutpiercer" },
        ["The Requiest"] = { "a ritual executioner" },
        ["Torishal"] = { "a tirun overlord" },
        ["Wenteras the Ancient"] = { "a forest elder" },
    },

    [43] = { -- Neriak Fourth Gate -- TODO: Add Neriak Fourth Gate II
        ["Arch Lich Lyra D`Croix"] = { "a dark defiler" },
        ["Arch Mage X`Cubus"] = { "a diplomat" },
        ["Archon Kela G`Noir"] = { "a dark mender" },
        ["Dread Lord Javis Tolax"] = { "a dark reaver" },
        ["Entrancer R`Ker"] = { "an important guest" },
        ["Fleshweaver D`Syss"] = { "Isvan L`Dor" },
        ["Mass of Spite"] = { "a stonetalon" },
        ["Ryzok D`Tol`s Remains"] = { "an enraged skeleton" },
        ["Violet, Soul Drinker"] = { "a Darklight bat" },
        ["Xam, Koada`Dal Slayer"] = { "an off duty guard" },
    },

    [771] = { -- The Dead Hills -- TODO: Add Dead Hills II
        ["A Xulous Invader"] = { "Heroic Adventure: Artifacts of Great Importance", "a xulous scout" },
        ["Bloodsucker"] = { "Heroic Adventure: Into the Hills", "a large mosquito" },
        ["Dark Infector"] = { "Heroic Adventure: The Hills Are Alive", "an unrestful soul" },
        ["Deathcaller Xylok"] = { "Heroic Adventure: Scouting Ahead", "a xulous elite" },
        ["Dread Ghoul"] = { "Heroic Adventure: The Hills Are Alive", "an aggressive corpse" },
        ["Jattius Rattican"] = { "Heroic Adventure: Excavating an Answer", "Unknown" },
        ["Lieutenant Robert Ward"] = { "Heroic Adventure: Clearing a Path", "a skeletal myrmidon" },
        ["Marcelyn Sjobern"] = { "Heroic Adventure: Excavating an Answer", "a tireless crusader" },
        ["The Monstrous Minnow"] = { "Heroic Adventure: Death Peace", "a decaying minnow" },
        ["Oozoroze"] = { "Heroic Adventure: Clearing a Path", "Unknown" },
        ["Rat Packleader"] = { "Heroic Adventure: The Hills Are Alive", "a gangrenous rat" },
        ["Spirit of the Hills"] = { "Heroic Adventure: Excavating an Answer", "a lingering templar" },
        ["Squire Alan Wells"] = { "Heroic Adventure: The Descending Tower", "Unknown" },
        ["Squire Gordon Flock"] = { "Heroic Adventure: The Descending Tower", "Unknown" },
        ["Squire Thomas Olson"] = { "Heroic Adventure: The Descending Tower", "Unknown" },
        ["Vorovelze"] = { "Heroic Adventure: Clearing a Path", "A ghastly ivymaw" },
        ["Warpriest Poxxil"] = { "Heroic Adventure: Disrupting the Ritual", "a xulous elite" },
    },

    [773] = { --The Void --No achievements
    },

    [775] = { -- Tower of Rot
        ["Brexx Darkpaw"] = { "a frenzied gnoll" },
        ["Captain Nathan Flock"] = { "a cavalier of life" },
        ["Commander Kurt Ellis"] = { "a restless deceiver" },
        ["Corpseflower"] = { "a noxious deathcap" },
        ["Garath Sulfada"] = { "a hand of Sulfada" },
        ["Guardian Roger Macholeth"] = { "Heroic Adventure: Brendaleen's Scheme", "Macholeth's squire Sairia" },
        ["Mad Martyr"] = { "Mission: A Rotten Heart", "a scion of the tower" },
        ["The Forgotten Sapper"] = { "a furious miner" },
        ["The Lost Devourer"] = { "a bloated devourer" },
        ["Vicar Lucilia Belyea"] = { "a vicar of life" },
    },

    ---------Beginning of RoF PH list---------
    [760] = { --Chapterhouse of the Fallen
        ["A Lost Soul"] = { "a lost willow wisp", "an enraged willow wisp" },
        ["A Mournful Spirit"] = { "a lost soul" },
        ["Braintaster"] = { "a brain eating beetle" },
        ["Falhotep the Cursed"] = { "a brittle mummy" },
        ["Halstor Bonewalker"] = { "a necromancer initiate", "a necromancer neophyte" },
        ["Kaficus the Undying"] = { "a shambling zombie" },
        ["Plaguetooth"] = { "any type of rat" },
        ["Ralstok Plaguebone"] = { "a forgotten prisoner" },
        ["Sergeant Malorin"] = { "a defiled paladin of Marr" },
        ["Sir Raint"] = { "a defiled paladin of Marr", "a disgraced paladin of Marr" },
        ["The Flesheater"] = { "a hungry ghoul" },
    },

    [763] = { --Chelsith Reborn
        ["A Huge Mistake"] = { "a mistake" },
        ["The Undefeated Blade"] = { "Ring Event starting with:", "a worthy contender" },
        ["A Possessed Farseer"] = { "a visionary pupil" },
        ["A Successful Mistwielder"] = { "an experimenter" },
        ["Floppy Flick"] = { "a frustrated fisherman" },
        ["Glorig the Underdog"] = { "a defeated gladiator" },
        ["Gora The Gourdsmasher"] = { "a farm slave" },
        ["High Diabolist Dynengo"] = { "a willing sacrifice" },
        ["Silvi the Mistress"] = { "a groomed slave" },
        ["Sliggles the Sneak"] = { "an informant" },
        ["Swordmaster Karla"] = { "a sword tester" },
        ["The Hundred Hands of Blood"] = { "a tired torturer" },
    },

    [755] = { --East Wastes: Zeixshi-Kar's Awakening
        ["Boradain Glacierbane"] = { "a coldain skinner" },
        ["Chief Ry`Gorr"] = { "a Ry`Gorr centurion" },
        ["Corbin Blackwell"] = { "a coldain hunter" },
        ["Drummon Coldshanks"] = { "a coldain lookout" },
        ["Ekelng Thunderstone"] = { "a frost giant savage" },
        ["Firband the Black"] = { "a Ry`Gorr centurion" },
        ["Fjloaren Icebane"] = { "a frost giant savage" },
        ["Galrok the Cold"] = { "a coldain warrior" },
        ["Ghrek Squatnot"] = { "a frost giant captain" },
        ["Kurlok the Mad"] = { "a Ry`Gorr centurion" },
        ["Nightmane"] = { "a nightmare" },
        ["Tain Hammerfrost"] = { "a coldain missionary" },
        ["Tungo"] = { "a tundra mammoth" },
        ["Warden Bruke"] = { "a frost giant captain" },
        ["Yngaln the Frozen"] = { "a frost giant captain" },
    },

    [758] = { --Evantil, the Vile Oak
        ["A Bloated Toad"] = { "a poisonous frog", "a tree frog" },
        ["A Blob of Sap"] = { "vile sap" },
        ["Burntbark"] = { "a wandering sapling" },
        ["Clizik"] = { "a soldier ant", "a diligent ant" },
        ["Ruaabri"] = { "a fear howler" },
        ["Seedspitter"] = { "a fear blossom" },
        ["The Ant Queen"] = { "a filigent ant" },
        ["Thornmaw"] = { "a vine maw" },
        ["Uzrinar the Damned"] = { "a fruit hoarding ape", "an ape lookout", "an elder ape" },
        ["Yunaizarn"] = { "a famished goral" },
    },

    [759] = { --Grelleth's Palace
        ["Beast Caller Plakt"] = { "a creature keeper" },
        ["Cook Mul"] = { "a kitchen assistant" },
        ["Dark Ritualist Kopp"] = { "a Chateau bloodcaster" },
        ["Grelleth`s War Machine"] = { "a junkcrafter scavenger" },
        ["Junkcrafter Nint"] = { "a junkcrafter apprentice" },
        ["Palace Commander Eroll"] = { "an elite soldier" },
        ["Penkal the Filth Master"] = { "a sewer mage" },
        ["Polluter Slaunk"] = { "a rot shaman" },
        ["Rotblade Klonda"] = { "a Chateau defender" },
        ["Stitches"] = { "a grizzled tamed selyrah" },
        ["The Forgotten Murderer"] = { "a Chateau gravedigger" },
    },

    -- Fix all 3 Heart of Fear zones. They are combined into one big achievement ID.
    [765] = { --The Threshold
        ["Alsecht the Believer"] = { "an enraged believer" },
        ["Deathfist"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
        ["Harbinger Krask"] = { "an enraged harbinger" },
        ["Ocululor"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
        ["Ulzschanoth"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
        ["Ythan the Gutripper"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
    },

    [768] = { --The Rebirth
        ["A Hoary Gargoyle"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
        ["Enasni the Demented"] = { "an enraged mephit" },
        ["Glubbus the Fleshmelter"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
        ["Ixmilsh the Terrortangler"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
        ["Silandra the Cruel"] = { "an enraged harbinger" },
        ["Torflog the Impaler"] = { "an enraged harbinger" },
        ["Vizlix the Deceiver"] = { "an enraged shiverback" },
        ["Zixial the Scaremonger"] = { "an enraged harbinger" },
    },

    [769] = { --The Epicenter
        ["A Herald of Fear"] = { "an enraged spectre" },
        ["A Vision of Fear"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
        ["Grizelna the Mad"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
        ["Simira the Dreadwidow"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
        ["Soulhollow"] = { "an enraged" }, --any mob that starts with enraged.Goes by model type. Fix later
        ["Yilsme the Harbinger of Death"] = { "an enraged widow" },
    },

    [754] = { --Kael Drakkel: The King's Madness
        ["a diminutive kromrif"] = { "an upright kromrif" },
        ["a fey swarm"] = { "a fey delerium", "a fey uniter" },
        ["Derakor the Vindicator"] = { "a gaurdian of war" },
        ["Doljek the Insane"] = { "an unbalanced kromzek" },
        ["Evanescent Coronach"] = { "a fading dirge" },
        ["Fjeka"] = { "a Drakkel dire wolf" },
        ["Fjokar Frozenshard"] = { "a storm giant of nobility" },
        ["Gkrean Prophet of Tallon"] = { "High Priest of Tallon Zek" },
        ["Grungol the Eclipse"] = { "a penumbral coldain" },
        ["Kallis Stormcaller"] = { "a Protector of War" },
        ["Keldor Dek`Torek"] = { "a noble storm giant" },
        ["Kyenka"] = { "a visiting noble" },
        ["Pakjol the Hungry"] = { "a Drakkel dire wolf pup" },
        ["Reivaj the Battlerager"] = { "a frost giant berserker" },
        ["Semkak Prophet of Vallon"] = { "High Priest of Vallon Zek" },
        ["Slagheart"] = { "a scalding mistdragon" },
        ["The Avatar of War"] = { "3 mob ring event:", "Armor of War", "The Statue of Rallos Zek", "The Idol of Rallos Zek" },
        ["The Idol of Rallos Zek"] = { "3 mob ring event:", "Armor of War", "The Statue of Rallos Zek" },
        ["The Statue of Rallos Zek"] = { "3 mob ring event:", "Armor of War" },
        ["Yetarr"] = { "a visiting noble" },
    },

    [764] = { --Plane of Shadow
        ["A Thundering Tempest"] = { "a raging storm" },
        ["An Astral Wanderer"] = { "a wandering soul" },
        ["Darkstone"] = { "a grinning gargoyle" },
        ["Gloomshell"] = { "a shadowed seed beetle" },
        ["Kaas Thox"] = { "a pile of shadow" },
        ["Kela Rentha Xakra"] = { "a servant of shadow" },
        ["Nightwing"] = { "a bat" },
        ["Shakra Za"] = { "a shadowy lurker" },
        ["The Dark Lady"] = { "a mournful specter" },
        ["Volx Xi Xakra"] = { "corrupted akhevan" },
        ["Xal Zeth"] = { "an Akhevan vagabond" },
        ["Xi Dyn"] = { "an ancient construct" },
        ["Xorla Vor"] = { "a Senshali shadowblade" },
        ["Xundraux Xakra"] = { "Unknown" },
        ["Zel Kaxri"] = { "a corrupted akhevan" },
    },

    [752] = { --Shard's Landing
        ["Alpha Naeya"] = { "an elder naeya" },
        ["Banescale Serpent"] = { "a greater slatescale", "a greater ivyscale" },
        ["Cobalt"] = { "a plainsdweller guardian" },
        ["Cragbeak"] = { "a kangon verdantbeak" },
        ["Elsrop the Crazed"] = { "a forsaken speaker", "a forsaken overseer" },
        ["Iremaw"] = { "an elder prowler" },
        ["Pincerpest"] = { "a venomshell scarab" },
        ["Plaguespine"] = { "a corrupted coralspine" },
        ["Pyrebeak"] = { "an icebeak matriarch" },
        ["Rockspine"] = { "a worntooth matron" },
        ["Stonecoat"] = { "a frostcoat patriarch" },
        ["Vilefeaster"] = { "a dire plainskeeper" },
    },

    [757] = { --The Breeding Grounds
        ["A Vicious Hatchling"] = { "any egg in zone can spawn it", "a dragon egg" },
        ["Akyail"] = { "a fearwing watcher" },
        ["Charra"] = { "a magma fiend" },
        ["Edoth the Ancient"] = { "an ancient icewing" },
        ["Gosik"] = { "a flamewing guardian" },
        ["Iciclane"] = { "a frostwing" },
        ["King Itkari"] = { "a chetari defender" },
        ["Nefori"] = { "a flamewing protector" },
        ["Osalur"] = { "a flamewing defender" },
        ["Seros"] = { "a mature icewing" },
        ["Velishan"] = { "a terrorwing" },
        ["Zalifur"] = { "an ancient dracolich" },
    },

    [756] = { --The Crystal Caverns: Fragment of Fear
        ["A Crystal Lurker"] = { "a crystal webmaster" },
        ["A Dracnid Retainer"] = { "a crystal webspinner" },
        ["A Focus Gem"] = { "a geonid" },
        ["A Gem Collector"] = { "a geonid" },
        ["A Hollow Crystal"] = { "a hollow terror" },
        ["A Life Leech"] = { "an icy leech" },
        ["A Ry`Gorr Enforcer"] = { "a Ry`Gorr guard" },
        ["A Ry`Gorr Herbalist"] = { "a Ry`Gorr shaman" },
        ["A Ry`Gorr Inspector"] = { "a Ry`Gorr scout" },
        ["A Stalag Purifier"] = { "a pure terror" },
        ["A Terror Carver"] = { "an icy terror" },
        ["Fear Tainted Tentacle"] = { "a tentacle tormentor" },
        ["Foreman Rixact"] = { "a Ry`Gorr excavator" },
        ["Foreman Smason"] = { "a Ry`Gorr prospector" },
        ["Kreztik"] = { "a velium crawler" },
        ["Overseer Grydon"] = { "a Ry`Gorr overseer" },
        ["Pit Boss Torgud"] = { "a lazy orc" },
        ["Prospector Wersan"] = { "a Ry`Gorr digger" },
        ["Queen Dracnia"] = { "a regal crawler" },
    },

    [753] = { --Valley of King Xorbb
        ["Body of the Many"] = { "a darkbody golem" },
        ["Companion of the Dead"] = { "a deadfiend goblin" },
        ["Corpsehide"] = { "a thickhide crocodile" },
        ["Deepcore"] = { "a core elemental" },
        ["Facenibbler"] = { "a longfang rat" },
        ["Facet of Fear"] = { "a multifacet hydra" },
        ["Frothtooth"] = { "a rabid bear" },
        ["Gruden the Pulverizer"] = { "a bruiser minotaur" },
        ["Ixyl the Claymaster"] = { "a clayborn muddite" },
        ["Kalken`s Bloody Bones"] = { "a scarred skeleton" },
        ["Krondal"] = { "a warrior minotaur" },
        ["Living Shard"] = { "a lifeshard hydra" },
        ["Mindseep"] = { "a nullmind mephit" },
        ["Ritualist Blezon"] = { "a ritualtalker goblin" },
        ["Shroomdeath"] = { "a deadcaller sporali" },
        ["Stormwheel"] = { "a cloudburst whirlwind" },
        ["Terrorfist"] = { "a terror golem" },
        ["The Visionary"] = { "a farsighted eye" },
        ["Tunnel Slither"] = { "a tunnel snake" },
        ["Worker`s Champion"] = { "a subservient goblin" },
        ["Xolok the Blind"] = { "a clouded eye" },
        ["Xorlex the Seer"] = { "a focused eye" },
    },

    ---------Beginning of VoA PH list---------
    [724] = { -- Argath
        ["Armor of the Dead"] = { "a steel hurricane" },
        ["Bane of Argath"] = { "a plated slaughterer" },
        ["Breath of Ryken"] = { "an exhalation" },
        ["Blades of Forgotten Heroes"] = { "living blades" },
        ["Blademaster of the Order"] = { "a Blade Regulant of Erillion" },
        ["Burnmaster of the Pillars"] = { "a dark deathcaller" },
        ["Core of the Mountain"] = { "molten steel" },
        ["Emissary Drucifel"] = { "a footsoldier of erillion" },
        ["Felsalath"] = { "a wind tamer" },
        ["Gravemaster of the Pillars"] = { "a dark spellrazer" },
        ["Husk of Starvation"] = { "a hungry thief" },
        ["Illdaeras Tear"] = { "molten steel", "a steel cyclone" },
        ["Interrogator Galectes"] = { "a Blade Guide of Erillion" },
        ["Kaledor the Tide Turner"] = { "a Blade Regulant of Erillion" },
        ["Kalkek"] = { "a wind tamer" },
        ["Keramar the Naeya"] = { "an abandoned naeya" },
        ["Legendary Swords"] = { "empowered blades" },
        ["Reviler of Argath"] = { "an Argathian defector" },
        ["Seed of Battle"] = { "living steel" },
        ["Shards of Battle"] = { "a steel hurricane" },
        ["Shieldbearer of the Gods"] = { "a plated soldier" },
        ["Tactician Krucidon"] = { "a Blade Overseer of Erillion" },
        ["The Collector"] = { "a greedy looter" },
        ["Vigorous Turncoat"] = { "an Argathian traitor" },
    },

    [728] = { -- Beast Domain
        ["A Twisted Strangler"] = { "an okiina vinethrasher" },
        ["An Ancient Selyrah"] = { "a braxi fungus seeker" },
        ["Blightwing"] = { "a ravenous wyvern" },
        ["Bonecracker"] = { "a goral leafstalker" },
        ["Bonecruncher"] = { "a grendlaen pouncer" },
        ["Bopo"] = { "a loathsome ape" },
        ["Deathglider"] = { "a monstrious wyvern" },
        ["Deathleaper"] = { "a rampaging wyvern" },
        ["Deathsquirm"] = { "a fierce wyvern" },
        ["Elder Gotikan"] = { "a domain hunter" },
        ["Jorth Hunter of Beasts"] = { "a domain hunter" },
        ["Karn the Hunter"] = { "an alaran wilder" },
        ["King Rex"] = { "a giant binaesa" },
        ["Maw Lurker"] = { "a lashtail crocodile" },
        ["Nighthowl"] = { "a naeya scavenger" },
        ["Nightleaper"] = { "a goral hunter" },
        ["Ribcrusher"] = { "a stealthy grendlaen" },
        ["Slaughter"] = { "an izon" },
        ["Stonebark"] = { "a braxi swiftrunner" },
        ["Stranglefang"] = { "a terrible raptor" },
        ["Swiftwind"] = { "a bloodthirsty wyvern" },
        ["Tangledeath"] = { "an okiina vinethrasher" },
        ["Thundercut"] = { "a braxi" },
        ["Thunderpunch"] = { "a filthy ape" },
        ["Willowcrush"] = { "an izon rootgrabber" },
    },

    [732] = { -- Erillion, City of Bronze
        ["A Rabid Selyrah"] = { "a wild selyrah" },
        ["A Raging Braxi"] = { "a wild braxi" },
        ["Archon Kinafu"] = { "an archon" },
        ["Archon Norandi"] = { "an archon" },
        ["Blacksmith Julandi"] = { "an industrious blacksmith" },
        ["Bloodclaw"] = { "a feral grendlaen" },
        ["Carnifex Korum"] = { "a carnifex" },
        ["Citizen Jlane"] = { "a citizen" },
        ["Citizen Julazir"] = { "a faithful citizen" },
        ["Citizen Silaindi"] = { "an honest citizen" },
        ["Cook Goranan"] = { "a cook", "a busy cook", "a tired cook" },
        ["Deathsqueak"] = { "a diseased oashim" },
        ["Fuandir the Master Potter"] = { "a potter" },
        ["Guard Horlian"] = { "a guard" },
        ["Guard Tuankod"] = { "a dutiful guard" },
        ["Guard Tulzix"] = { "a guard" },
        ["Guggles"] = { "a diseased oashim" },
        ["The Record Master"] = { "a record keeper" },
    },
    
    [734] = { -- East Sepulcher
    --No Achievements for this zone
    },

    [730] = { -- Pillars of Alra
        ["an unusual creature"] = { "selyrah's and frog's" }, --TODO: Fix exact names
        ["Cysivir the Constructor"] = { "an essence keeper" },
        ["Il`Valrikar the Purifier"] = { "an essence purifier" },
        ["Ivrikdal the Infuser"] = { "any of the static alaran models" }, --TODO: Fix exact names
        ["Korellister the Stoic"] = { "ardent scholar", "a student of Erion" },
        ["Opholonas the Harvester"] = { "a light harvester" },
        ["Peacekeeper of Anriella"] = { "any mob in the Pillar of Nature" },
        ["Peacekeeper of Erion"] = { "any mob in the Pillar of Light" },
        ["Peacekeeper of Fal`Kaa"] = { "any mob in the Pillar of Shadow" },
        ["Peacekeeper of Melretia"] = { "any mob in the Pillar of Arcane" },
        ["Soliadal the Timid"] = { "a manatender" },
        ["The Ut`len Depthkeeper"] = { "an ut`len flaremind" },
        ["Tonmek the Mind-Drainer"] = { "a mana harvester" },
        ["Tsianvar the Studious"] = { "a pensive scholar" },
        ["V`Dralk the Construct of Shade"] = { "a greater blistering shade" },
        ["Vak`Ridel the Shadowcaller"] = { "any sitting alaran" },
        ["Varinyr the Construct of Life"] = { "a greater life-essence" },
        ["Wreliard the Arctender"] = { "an arcane essencegazer" },
    },

    [729] = { -- Resplendent Temple
        ["A Prismatic Selyrah"] = { "a colorful selyrah" },
        ["Advisor Enaris"] = { "a temple aide" },
        ["Afton the Cleanser"] = { "a nitore cleanser" },
        ["Ambassador Khorin"] = { "a nitore liason" },
        ["An Animated Servant"] = { "an animated corpse" },
        ["An Ivory Serpent"] = { "an albino serpent" },
        ["Arms Master Hegul"] = { "an armed guard" },
        ["Chancellor Mardis"] = { "a nitore apprentice" },
        ["Chief Recruiter Joceil"] = { "a Nitore neophyte" },
        ["Cijerst, Lord of Decay"] = { "a filthy swinetor" },
        ["Gisette"] = { "a grazing braxi" },
        ["Grimlop"] = { "a diseased hopper" },
        ["Groundskeeper Areut"] = { "a groundskeeper" },
        ["High Guard Alsera"] = { "a nitore watcher" },
        ["High Priest Nelori"] = { "a nitore priest" },
        ["Hiqork the Putrid"] = { "a putrid swinetor" },
        ["King Piqiorn"] = { "an Ulork noble" },
        ["King Zarq"] = { "a piq`a noble" },
        ["Larsena the Lunatic"] = { "a nitore worshipper" },
        ["Miggles"] = { "a tame goral" },
        ["Pledgemaster Oeslik"] = { "a devoted pledge" },
        ["Summoner Sirqo"] = { "a swinetor summoner" },
        ["The Rat Queen"] = { "a diseased rat" },
        ["The Slothlord"] = { "a sloth cube" },
        ["Ungimar"] = { "a hostile goral" },
    },

    [727] = { -- Rubak Oseka, Temple of the Sea
        ["Curate Zlinair"] = { "a priest" },
        ["Evangelizer Runarn"] = { "an acolyte" },
        ["Holy Ophidian"] = { "a coral snake" },
        ["Sacred Ophidian"] = { "a coral snake" },
        ["Slorn the Holy"] = { "a zealot" },
        ["Templar Razkin"] = { "an acolyte" },
        ["Tiuanid the Faithful"] = { "a priest" },
        ["Zealot of Oseka"] = { "a zealot" },
    },

    [726] = { -- Sarith, City of Tides
        ["Assassin Thale"] = { "an Orator's army assassin" },
        ["Battlemage Resk"] = { "an Orator's army archmage" },
        ["Bishop Kyzer"] = { "an Orator's army bishop" },
        ["Captain Dahlena"] = { "an Orator's army commander" },
        ["Dark Mage Naxin"] = { "an Orator's army dark mage" },
        ["Death Knight Sharris"] = { "an Orator's army death knight" },
        ["Kaneida"] = { "a grizzled war beast" },
        ["Lieutenant Vasko"] = { "a Sarith guardsman veteran" },
        ["Life Knight Jasul"] = { "an Orator's army life knight" },
        ["Master Trainer Ganelin"] = { "an Orator's master beast trainer" },
        ["Ocean Mage Rettun"] = { "an Orator's army nature mage" },
        ["Oseka`s Chosen Ikallis"] = { "an Oseka's Chosen defender" },
        ["Primal Mage Mollens"] = { "an Orator's army primal mage" },
        ["Sarith`s Guardian"] = { "a sarith tidal guardian" },
        ["Sea Ranger Huren"] = { "an Orator's army ranger" },
        ["Tactician Perak"] = { "an Orator's army strategist" },
        ["The Giant Crab"] = { "a king crab" },
        ["The Kraken"] = { "a large squid" },
        ["The Megaladon"] = { "a great white shark" },
        ["Tidalmage Narens"] = { "a Sarith tidalmage master" },
    },

    [733] = { -- Sepulcher of Order
        ["Agralta"] = { "thelara alsa ril of Alra" },
        ["Alsara the Ansel Ereth"] = { "a departed thelasa" },
        ["Bonemeal"] = { "a denuded ser thel" },
        ["Champion of the Triumvirate"] = { "a protector of alsa thel" },
        ["Clampgrit"] = { "a starving raptor" },
        ["Eldanum of the Ser Alsa"] = { "an ereth of law" },
        ["Excrucidator"] = { "brutalizer of alsa thelara" },
        ["Gleaming Tricor"] = { "a sublime tricrystal" },
        ["Paleodontis"] = { "a fortified tideshell" },
        ["Primordial Steel"] = { "	a zephyr of steel" },
        ["Spernal"] = { "a wind liege" },
        ["Tegleth"] = { "a blade mentor of alsa thelara" },
        ["Tendros"] = { "a dense mound" },
        ["The Dark"] = { "an aspect of darkness" },
        ["The Exalted Ser Alsa Thel"] = { "any of the telmiran model mobs" }, --TODO: Fix exact names
        ["Kelkos the Berserk"] = { "a conqueror of Kolos" },
        ["Master Arcania"] = { "arcane magic caster" },
        ["Master Illum"] = { "light magic caster" },
        ["Ryken's Boast"] = { "a hurricane of truth", "a whirlwind of sophistry" },
        ["Shadow of the Domain"] = { "a trapper of Kolos" },
        ["The Vine Tender"] = { "a warden of lunanyn", "a farmer of Lunanyn" },
        ["Word Lord"] = { "philosopher of Ryken", "sophist of Ryken" },
        ["Deepblade"] = { "a myrmidon of Oseka" },
        ["Mindlock"] = { "golem models" }, --TODO: Fix exact names
        ["The Chosen"] = { "an alsa thelara nonpareil", "an alsa thelara conquerer" },
        ["The Cleaner"] = { "thelesa of Ladrys", "high thelesa of Ladrys" },
        ["The Digger"] = { "a worshipper of decay", "a fouled warrior" },
        ["Wavecrasher"] = { "ser alsa hadal", "ser alsa thel hadal" },
    },

    [725] = { -- Valley of Lunanyn
        ["an angry mob leader"] = { "a farmer" },
        ["Archon Haerin"] = { "a trooper" },
        ["Enraged Fertility Spirit"] = { "a farmer" },
        ["Hungry Spirit"] = { "a farmer" },
        ["Lancer Archon Gaoril"] = { "an impaler" },
        ["Moonshade"] = { "	a tired farmer" },
        ["Nareneth, the Heart Tree"] = { "a mosstrooper" },
        ["Overgrown Dung Beetle"] = { "a farmer" },
        ["Supply Archon Tergat"] = { "a ranger" }, --TODO: not verified
        ["The Moonflower"] = { "a farmer" },
        ["Aethra the Mad"] = { "a mature oashim" },
        ["Aggrieved Fertility Spirit"] = { "a mature oashim" },
        ["Arth, Village Guardian"] = { "a wraith of Arelis" },
        ["Blood-gorged Huntsman"] = { "a huntsman" },
        ["Bloodborn Spirit"] = { "a mature oashim", "a huntsman" },
        ["Bloodstalker"] = { "a ferocious grendlaen" },
        ["Elsha the Mournful"] = { "a lingering shade" },
        ["Ker Reega"] = { "a vile reega" },
        ["Krongar the Enrager"] = { "a rallosian defector" },
        ["Lor Reega"] = { "a nefarious reega" },
        ["Oashim Progenitor"] = { "a mature oashim" },
        ["Ranger Archon Daetas"] = { "an impaler", "a soldier", "a trooper" },
        ["Taer Reega"] = { "a nefarious reega" },
        ["The Battlesteel Dead"] = { "a mature oashim", "an oashim" },
        ["Trooper Archon Feht"] = { "a trooper" },
        ["Urash, Specter of Death"] = { "a mature oashim" },
    },

    [731] = { -- Windsong Sanctuary
        ["A Fleetfooted Braxi"] = { "a haze jumper" },
        ["Breezeglider"] = { "a fluttering kangon" },
        ["Riffmaz the Flute Master"] = { "a soundless devotee" },
        ["Saduulj Tsepir"] = { "a soundless devotee" },
        ["Stormcaller"] = { "a haze jumper" },
        ["The Conductor"] = { "a soundless devotee" },
        ["The Forlorn Drummer"] = { "a soundless devotee" },
        ["The Hornmaster"] = { "a soundless devotee" },
        ["The Windrunner"] = { "a fluttering kangon" },
        ["Unvoiced Brute"] = { "a silent guardian" },
    },

    [735] = { -- West Sepulcher
    -- No Achievements for this zone
    },

    ---------Beginning of HoT PH list---------
    [709] = { -- Al'Kabor's Nightmare
        ["a berserk mammoth"] = { "an enraged mammoth" },
        [" a drachnid bloodknight"] = { "a drachnid knight" },
        ["Drenz"] = { "an ice goblin raider" },
        ["a drolvarg captain"] = { "a drolvarg lieutenant" },
        ["Emperor Crush"] = { "a crushbone strategist" },
        ["General Jyleel"] = { "a high elf sentry" },
        ["Graster"] = { "a snow orc scout" },
        ["Heartwood Master"] = { "a wood elf seer" },
        ["Jenni Hollowfield"] = { "a halfling guard" },
        ["Mooto"] = { "a Runnyeye thief" },
        ["a mountain giant patriarch"] = { "an angry mountain giant" },
        ["Plaguebone Overlord"] = { "a lurid plaguebone" },
        ["Princess Klaknak"] = { "a klaknak guard" },
        ["Queen Klaknak"] = { "a klaknak guard" },
        ["Winfrey the Mad"] = { "a crazed halfling" },
        ["Zyren Shadowriver"] = { "a wood elf warden" },
    },

    [706] = { -- Erudin Burning
        ["Algot the Deathshaper"] = { "a heretic death dabbler" },
        ["Brutus"] = { "a ravenous dock rat" },
        ["Damar the Overseer"] = { "a heretic ravager" },
        ["Femurstack"] = { "a bone golem terrorizer", "a bone golem horror", "a bone golem tormentor" },
        ["Garnak Pryphan"] = { "a heretic brute", "a heretic fell warden" },
        ["Handar Prentius"] = { "a Terris Thule apostle" },
        ["Kanah the Heartslicer"] = { "a heretic brute" },
        ["Maggotscalp"] = { "a skeleton sentry" },
        ["The Tome-Eater"] = { "a burning tome whirlwind" },
        ["Vindel the Ripper"] = { "a Terris-Thule apostle" },
    },

    [711] = { -- Fear Itself
        ["Ancient Dracoliche"] = { "a shadowed bleeder", "a shadowed fiend", "a shadowed phantasm", "a shadowed wraith" },
        ["Argendev"] = { "an amygdalan guard" },
        ["Decrepit Warder"] = { "a decrepit toad" },
        ["Deranged Toad"] = { "a decrepit toad" },
        ["Dread"] = { "a delirious boogeyman", "a delirious samhain" },
        ["Dyalgem"] = { "an amygdalan guard" },
        ["Engorged Spinechiller"] = { "a spinechiller widow" },
        ["Essence of Terror"] = { "a terror wraith" },
        ["Fright"] = { "an amygdalan soldier" },
        ["Giant Phoboplasm"] = { "a curious phoboplasm" },
        ["Irak Altil"] = { "a putrid fiend" },
        ["Ireblind Imp"] = { "an enraged scareling" },
        ["Iron Fist"] = { "an enraged frightfinger" },
        ["Katerra the Anguished"] = { "an anguished fiend" },
        ["Mastelyn"] = { "an amygdalan guard" },
        ["Mindleech"] = { "a mindless bleeder" },
        ["Nightmare of Thule"] = { "a fearful nightmare" },
        ["Odium"] = { "a boogeyman lurker" },
        ["Possessed Samhain"] = { "a delirious samhain" },
        ["Rerekalen"] = { "an amygdalan guard" },
        ["Shakare"] = { "a bitter gorgon" },
        ["Tempest Reaver"] = { "a delirious samhain" },
        ["Terror"] = { "an amygdalan soldier" },
        ["Twisted Tormentor"] = { "a vile tormentor" },
        ["Undaleen"] = { "an amygdalan guard" },
        ["Undead Shiverback"] = { "an enraged shiverback" },
        ["Wraith of a Shissar"] = { "a bitter gorgon" },
        ["Zykean"] = { "an enraged glarelord" },
    },

    [701] = { -- House of Thule
        ["Bonecracker"] = { "a frightening skeleton" },
        ["Darnor the Terror Lord"] = { "a vile bone crafter" },
        ["Dreameater"] = { "a shivering haunt" },
        ["Dreamslayer"] = { "a dreadful bone golem" },
        ["The Executioner"] = { "a horror guard" },
        ["Executioner Brand"] = { "a terror guard" },
        ["Fearhowler"] = { "a rotdog fearfinder" },
        ["Fearsniffer"] = { "a rotdog fearstalker" },
        ["Ganborn"] = { "a frightening skeleton" },
        ["Gibbering Haunt"] = { "a frightening skeleton" },
        ["Giblets"] = { "a rotdog fearsniffer" },
        ["Gristle"] = { "a rotdog fearsmeller" },
        ["Isabeaux Darkdreamer"] = { "a vile bone crafter" },
        ["Nightmare Golem"] = { "a frightful bone golem" },
        ["Nightmare Widow"] = { "a fright spinner" },
        ["Nightscale"] = { "a worrisome snake" },
        ["Old Rusty"] = { "a fright guard" },
        ["Shaman Jorg"] = { "a nightmarish guard" },
        ["Sleepeater"] = { "a sleepeating cube" },
    },

    [702] = { -- House of Thule, Upper Floors
        ["Bloodmane"] = { "a dripping blood elemental" },
        ["Bodabas"] = { "a bloodthirsty beast" },
        ["Icefang"] = { "a hungry beast" },
        ["Icy Devourer"] = { "an icy ooze" },
        ["Nightfang"] = { "a funnelweb leaper" },
        ["Rotticus"] = { "a filthy rotdog" },
        ["Spitecrawler"] = { "a nightmarish centipede" },
        ["Swirling Fog Elemental"] = { "a drifting fog elemental" },
    },

    [710] = { -- Miragul's Nightmare
        ["Bloodfeather"] = { "a darkshadow raven" },
        ["Fearstalker"] = { "a mournful shade" },
        ["Foeslicer"] = { "an ancient guardian" },
        ["Gilibus the Unseen"] = { "an unseen warrior" },
        ["Iglum the Deformed"] = { "a darkbone golem" },
        ["Shadowlord Gixblat"] = { "a darkshadow mephit" },
        ["Sotor the Unmerciful"] = { "a shadowed golem" },
        ["Soul Taster"] = { "a silent shadow" },
    },

    [713] = { -- Miragul's Phylactery
        --No Achievements for this zone
    },

    [707] = { -- Morell's Castle
        ["Bielaisk"] = { "a shellscale guard" },
        ["Bishop the Scorned"] = { "a scorned marauder" },
        ["Chief Maeder"] = { "a hoofed guardian" },
        ["The Constructor"] = { "an idle hand" },
        ["Daelai"] = { "an enchanted mare" },
        ["Dreamweaver"] = { "a dream drake" },
        ["Esmeralda the Vengeful"] = { "a vengeful marauder" },
        ["Feral Jackrabbit"] = { "a rabid rabbit" },
        ["Forest Phantasm"] = { "a night terror" },
        ["Gezriela"] = { "a decrepit confectioner" },
        ["Gnarlvine"] = { "a tangled hedgewalker" },
        ["Greeta"] = { "a crazed candy hoarder" },
        ["Guardian Ather"] = { "a dutiful defender" },
        ["Hans"] = { "a crazed candy hoarder" },
        ["Nesseun"] = { "a water serpent" },
        ["Omander the Devoted"] = { "a devoted guard" },
        ["Oruff the Seer"] = { "a forest protector" },
        ["The Puppeteer"] = { "a marionette" },
        ["Redmur the Dreamlancer"] = { "an enraged sandman" },
        ["Seawitch Persion"] = { "a seawitch" },
        ["Silbacle"] = { "a shellscale guard" },
        ["Songstress Laioni"] = { "a singing siren" },
        ["Speckles"] = { "a speckled hare" },
        ["Wisp of Hope"] = { "a daydream" },
        ["Zerkelos the Damned"] = { "a dream devourer" },
    },

    [708] = { -- Sanctum Somnium
        ["a bladedancer guardian"] = { "a master guardian" },
        ["a bright warden"] = { "a tower warden sergeant" },
        ["a flesheating beetle"] = { "a hungry scavenger beetle" },
        ["a giant warlord"] = { "a giant warrior veteran" },
        ["a goblin raid leader"] = { "a goblin raider captain" },
        ["a lifeweaver servant"] = { "a personal servant" },
        ["a psychotic leprechaun"] = { "a strange leprechaun" },
        ["a shadow warden"] = { "a tower warden sergeant" },
        ["a shieldbearer guardian"] = { "a master guardian" },
        ["a soulmage servant"] = { "a personal servant" },
        ["a spellsword guardian"] = { "a master guardian" },
        ["a spellward servant"] = { "a personal servant" },
        ["an arcane warden"] = { "a tower warden sergeant" },
        ["an infected rat"] = { "a filthy rabid rat" },
        ["Archmagus Erlen"] = { "a royal archmage" },
        ["Archmagus Nesalie"] = { "a royal archmage" },
        ["Conjurer Nallen"] = { "a dark ritualist expert" },
        ["Demonologist Sharra"] = { "a dark occulist researcher" },
        ["Dream Destroyer"] = { "a dream shade figment" },
        ["Executor Bashka"] = { "a dark occulist researcher" },
        ["High Priest Casmion"] = { "a royal high priest" },
        ["High Priest Darsia"] = { "a royal high priest" },
        ["Knight Captain Elena"] = { "a royal knight errant" },
        ["Knight Captain Rosch"] = { "a royal knight errant" },
        ["Larrow the Demented"] = { "a deranged beggar" },
        ["Master Thief Quentin"] = { "a strange leprechaun" },
        ["Rites Master Lorett"] = { "a dark ritualist expert" },
        ["The Beast King"] = { "a shadowy dark beast" },
        ["The Dream Collector"] = { "a dream phantom illusion" },
    },

    [700] = { -- The Feerrott (B)
        ["Blackbone"] = { "a bloodbathed skeleton", "a bloodbone skeleton" },
        ["Bouncer Captain Grak"] = { "Bouncer Flerb", "Bouncer Hurd" },
        ["Diggory the Traveler"] = { "a deceased traveler" },
        ["Donna the Explorer"] = { "a waterlogged explorer" },
        ["Enraged Gorilla Patriarch"] = { "an angry gorilla patriarch" },
        ["Expedition Leader Krupp"] = { "a restless spirit" },
        ["Fearful Specter"] = { "a bloodbone lich", "a lingering revenant" },
        ["Festerback"] = { "a decaying gorilla" },
        ["Huetzin the Brute"] = { "a lizardman thug" },
        ["The Leaper"] = { "a stalking crawler" },
        ["Malice"] = { "a corrupt orbweaver" },
        ["Patches"] = { "a ravenous rotdog" },
        ["Sable"] = { "a sinuous adder" },
        ["Sentinel Quilaztli"] = { "a frenzied Tae Ew" },
        ["Shaman Ixchell"] = { "a lizardman visionary" },
        ["Tanglewolf Alpha"] = { "a tanglewolf hunter" },
        ["Temilotzin the Zealot"] = { "a dedicated Tae Ew" },
        ["Terror Unleashed"] = { "a frightful spirit" },
        ["Vermilion"] = { "a deadly viper" },
        ["Voracious Feeder"] = { "a frenzied feeder" },
        ["Watcher Yaotl"] = { "a lizardman watcher" },
        ["Whitepaw"] = { "a tanglefang huntress" },
        ["Xiucozcatl the Feared"] = { "a bloody Tae Ew ritualist" },
    },

    [703] = { -- The Grounds
        ["Agraena"] = { "a forlorn bone golem" },
        ["Andrevas"] = { "an obedient servant" },
        ["Angry Wasp"] = { "a truculent wasp" },
        ["Arenrhaed"] = { "a forlorn bone golem" },
        ["Beget Cube"] = { "a mad mulch cube" },
        ["Biunahde"] = { "a bitter treant" },
        ["Chaotic Heap"] = { "a petulant heap" },
        ["Compost Cube"] = { "a mad mulch cube" },
        ["Croakem"] = { "a wicked thornfrog" },
        ["Distraught Heap"] = { "a petulant heap" },
        ["Grigoran"] = { "an obedient servant" },
        ["Helias"] = { "a disgruntled aquadervish" },
        ["Kijaemz"] = { "a bitter treant" },
        ["Minadra"] = { "a bixie guard" },
        ["Patch Guardian"] = { "a putrified peponnite" },
        ["Pelias"] = { "a disgruntled aquadervish" },
        ["Raze"] = { "a mangy rotdog" },
        ["Rend"] = { "a mangy rotdog" },
        ["Riggbit"] = { "a wicked thornfrog" },
        ["Slynassin"] = { "an aggresive snake" },
        ["Venilinam"] = { "an aggresive snake" },
        ["Vile Wasp"] = { "a truculent wasp" },
        ["Vicious Gourd"] = { "a putrified peponnite" },
        ["Zonoraz"] = { "a bixie guard" },
    },

    [704] = { -- The Library
        ["Archivist Herrdar"] = { "a languid poetry teacher" },
        ["Ardull the Watcher"] = { "an ethereal watcher" },
        ["Chronicler Cerro"] = { "a corporeal scholarly researcher" },
        ["Compendium of Nightmares"] = { "an unusual tome" },
        ["Curator Majda"] = { "a curious custodian" },
        ["Head Librarian Matilda"] = { "a dutiful librarian" },
        ["Professor Glumb"] = { "a lonely librarian" },
        ["Tome of the Fallen"] = { "a dusty codex" },
    },

    [705] = { -- The Well
        ["Death Stinger"] = { "a feldark scorpion" },
        ["Death Spider"] = { "a feldark spider" },
        ["Doom Snake"] = { "a bold cave viper" },
    },

    ---------Beggining of SoF PH list---------
    [442] = { -- Dragonscale Hills
        ["Arachnotron"] = { "a spiderwork scavenger" },
        ["Bloodbeak"] = { "a cursed crow" },
        ["Captain of the Leafguard"] = { "a Darkvine" },
        ["Chief Thundragon"] = { "Spawns every 10 min 40 sec" },
        ["Click-o-nik"] = { "a clockwork overseer" },
        ["Delilah Windrider"] = { "Unknown" },
        ["Diddle D"] = { "a clockwork overseer" },
        ["Dungore"] = { "a doombug scavenger" },
        ["Elder Krunggar Whiptail"] = { "a minotaur weaponsmaster", "a minotaur furyblade" },
        ["Fiddle D"] = { "a clockwork overseer" },
        ["Gillipuzz"] = { "dragonscale_hills_12" },
        ["King Mustef"] = { "a frisky shadowcat" },
        ["Leafrot"] = { "dragonscale_hills_14" },
        ["Mad MX"] = { "a clockwork overseer" },
        ["Strawshanks"] = { "a blighted scarecrow" },
        ["Tangler Timbleton"] = { "dragonscale_hills_17" },
        ["Ton o`Tin"] = { "dragonscale_hills_18" },
        ["Witchkin"] = { "a dragonscale viper" },
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

    [395] = { -- Blightfire Moors
        ["a marsh creeper"] = { "a briar thorn" },
        ["an advance scout"] = { "an advance scout" },
        ["Cliffstalker"] = { "a slashclaw cub", "a young slashclaw" },
        ["Dragoneater"] = { "a sporali decomposer" },
        ["Duskfall"] = { "a ghostpack huntress", "a ghostpack stalker", "a ghostpack howler" },
        ["Ezzerak the Engineer"] = { "Ezzerak the Engineer" },
        ["Mossback"] = { "Mossback" },
        ["Plaguebringer"] = { "an ancient plaguebone" },
        ["Skycore"] = { "a ridge watcher" },
        ["Thunderwood"] = { "Thunderwood" },
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

    [397] = { -- Goru'Kar Mesa
        ["Anghel"] = { "a Minohten satyr" },
        ["Aurelia"] = { "a napaea windstriker" },
        ["Craita"] = { "an oread stonehide" },
        ["Fantoma"] = { "a mesa alpha wolf" },
        ["Florenta"] = { "a dryad tender", "a dryad maiden", "a dryad windweaver", "a dryad protector" },
        ["Ghita"] = { "a Minohten satyr" },
        ["Glasson"] = { "Quest Only: Hanook #2: Oh No!" },
        ["Incinspaianjen"] = { "a dark widow" },
        ["Ionela"] = { "a potamide maiden", "a potamide matron", "a potamide noble", "a potamide protector", "a potamide retainer" },
        ["Latham"] = { "60 minute timer" },
        ["Mal"] = { "a murkwater ooze" },
        ["Manunchi"] = { "a windwillow wisp" },
        ["Nemarsarpe"] = { "a diamondback snake" },
        ["Plasa"] = { "a harpy hunter" },
        ["Refugiu"] = { "a rotwood strangler" },
        ["Sandu"] = { "a Tuffein satyr" },
        ["Schelet"] = { "a lingering dryad" },
        ["Tarsiit Movila"] = { "a rotwood tangleweed" },
        ["Ternsmochin"] = { "a lost rotwood" },
        ["Uriasarpe"] = { "a ring snake" },
        ["Ursalua"] = { "a mesa bear", "a mesa mother bear" },
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

    [399] = { -- The Steppes
        ["Chef Gudez"] = { "any Darkfell", "a Darkfell archer", "a Darkfell captain", "a darkfell elite", "a Darkfell gnoll", "a Darkfell guard" },
        ["Deathfang"] = { "a mature wasp spider" },
        ["Firebelly the Cook"] = { "a Stonemight" },
        ["Gruet Longsight"] = { "any Darkfell", "a Darkfell archer", "a Darkfell captain", "a darkfell elite", "a Darkfell gnoll", "a Darkfell guard" },
        ["Gruntor the Mad"] = { "a hill giant" },
        ["Hesmire Farflight"] = { "a guardian of the grove" },
        ["High Shaman Firglum"] = { "a Darkfell elder", "a Darkfell shaman" },
        ["Hunter Borty"] = { "Unknown" },
        ["Hunter Groppa"] = { "Unknown" },
        ["Littlebiter the Skinchanger"] = { "a Stonemight elder" },
        ["Midnight"] = { "a Steppes leopard" },
        ["Nanertak"] = { "Unknown" },
        ["Oldbones"] = { "a dire wolf", "a hill giant", "A stone viper", "A brown bear" },
        ["Skurl"] = { "a Stonemight veteran", "a Stonemight elder" },
        ["Sneaktalker Gizdor"] = { "any Darkfell", "a Darkfell archer", "a Darkfell captain", "a darkfell elite", "a Darkfell gnoll", "a Darkfell guard" },
        ["Splotchy"] = { "any Stonemight" },
        ["Tarbelly the Wanderer"] = { "multiple types" },
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
local function getPlaceholders(namedMob, zoneID)
    if not namedMob then
        return {}
    end

    if not zoneID then
        -- Fallback: search all zones if no zoneID provided
        for _, zoneMobs in pairs(ph_list) do
            if zoneMobs[namedMob] then
                local phs = zoneMobs[namedMob]
                -- Ensure we always return a table
                if type(phs) == "table" then
                    return phs
                end
            end
        end
        return {}
    end

    local zonePHList = ph_list[zoneID]
    if not zonePHList then
        return {}
    end

    local phs = zonePHList[namedMob]
    -- Ensure we always return a table
    if type(phs) == "table" then
        return phs
    end

    return {}
end

-- Function to check if a mob is a placeholder for any named mob in a zone
local function isPlaceholder(mobName, zoneID)
    if not mobName then
        return false, nil, nil
    end

    if not zoneID then
        -- Search all zones
        for zone, zoneMobs in pairs(ph_list) do
            if type(zoneMobs) == "table" then
                for namedMob, placeholders in pairs(zoneMobs) do
                    if type(placeholders) == "table" then
                        for _, ph in ipairs(placeholders) do
                            if type(ph) == "string" and mobName:lower() == ph:lower() then
                                return true, namedMob, zone
                            end
                        end
                    end
                end
            end
        end
        return false, nil, nil
    end

    local zonePHList = ph_list[zoneID]
    if not zonePHList or type(zonePHList) ~= "table" then
        return false, nil, nil
    end

    for namedMob, placeholders in pairs(zonePHList) do
        if type(placeholders) == "table" then
            for _, ph in ipairs(placeholders) do
                if type(ph) == "string" and mobName:lower() == ph:lower() then
                    return true, namedMob, zoneID
                end
            end
        end
    end
    return false, nil, nil
end

-- Function to get all named mobs in a zone
local function getNamedMobsInZone(zoneID)
    if not zoneID then
        return {}
    end

    local zonePHList = ph_list[zoneID]
    if not zonePHList or type(zonePHList) ~= "table" then
        return {}
    end

    local namedMobs = {}
    for mobName, _ in pairs(zonePHList) do
        if type(mobName) == "string" then
            table.insert(namedMobs, mobName)
        end
    end
    return namedMobs
end

return {
    getPlaceholders = getPlaceholders,
    isPlaceholder = isPlaceholder,
    getNamedMobsInZone = getNamedMobsInZone,
    ph_list = ph_list -- Export the full table if needed
}
