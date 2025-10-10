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
    ["Xetheg, Luclin's Warden"] = {  -- TODO: verify
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
    ["a massive dracoliche"] = {
        "a dragon construct"
    },
    ["a moon bat"] = {
        "a scavenger bat"
    },
    ["a ravenous entropy serpent"] = {
        "a decay serpent"
    },
    ["a restless warlord"] = {
        "a wandering Chetari"
    },
    ["a toxic phase spider"] = {
        "a phasing spider"
    },
    ["another great green slime"] = {
        "an amorphous blob"
    },
    ["Dustbinder Tarlin"] = {
        "a Chetari dustmaker"
    },
    ["Foulfang"] = {
        "a decay serpent"
    },
    ["Jaled Dar's trapped shade"] = {
        "must kill all ritualists to break the bond ",
        "a trapped dracoliche"
    },
    ["Queen Kitlaa"] = {
        "a phasing spider"
    },
    ["restless Dominator Yisaki"] = {
        "a wandering Chetari"
    },
    ["restless Vaniki"] = {
        "a wandering Chetari"
    },
    [" restless Warmaster Ultvara"] = {
        "a wandering Chetari"
    },
    ["Seeker Larada"] = {
        "a Chetari explorer"
    },

    --Skyshrine
    ["a blessed racnar"] = {
        "a convincing doomsayer"
    },
    ["Dagarn the Destroyer"] = {
        "a pretentious wurm"
    },
    ["Lord Koi'Doken"] = {
        "an onyx conspirator"
    },
    ["Professor Atkru"] = {
        "a tenured mentor"
    },
    ["Shoen the Fanatic"] = {
        "a subservient convert"
    },
    ["Templeton the Clear"] = {
        "a crystal abomination"
    },
    ["Ziglark Whisperwing"] = {
        "an obsidian believer"
    },

    --The Sleeper's Tomb
    ["Kildrukaun the Ancient"] = {
        "a restless drakeen"
    },
    ["Milas An'Rev"] = {
        "a venerated sadist"
    },
    ["The Overseer Reborn"] = {
        "The Captain of the Guard",
        "Master of The Guard"
    },
    ["The Progenitor Reborn"] = {
        "The Progenitor"
    },
    [" Tjudawos the Ancient"] = {
        "a shimmering drakeen"
    },
    ["Ulessa the Insane"] = {
        "a wyvern sentinel"
    },
    ["Vyskudra the Ancient"] = {
        "a lonely drakeen"
    },
    ["Zeixshi'Kar the Ancient"] = {
        "a forgotten drakeen"
    },

    --The Temple of Veeshan
    ["Dozekar the Cursed"] = {
        "a shimmering priest"
    },
    ["Feshlak"] = {
        "a scarlet sycophant"
    },
    ["Gozzrem"] = {
        "a pious martyr"
    },
    ["Ikatiar the Venom"] = {
        "a wyvern scholar"
    },
    ["Jorlleag"] = {
        "a distrusting devout"
    },
    ["Ktheek the Ripper"] = {
        "a sapphire devotee"
    },
    ["Lady Mirenilla"] = {
        "a shard hatchling"
    },
    ["Lord Vyemm"] = {
        "Cycle through all of the following",
        "a vile defender",
        "a viscious defender",
        "a vicious scholar",
        "a vicious warrior",
        "a vicious leader",
    },

    --The Western Wastes
    ["a restless behemoth"] = {
        "a restless wurm"
    },
    ["Blasphemous Steel"] = {
        "an exiled efreeti"
    },
    ["Bliddlethliclaus"] = {
        "an exiled kedge"
    },
    ["Feltinth the Caring"] = {
        "a brood caretaker"
    },
    ["Miscreation the Timeless"] = {
        "a frosted dracholiche"
    },
    ["Pastletlith the Temperate"] = {
        "a brood hatchling"
    },
    ["Rildar Blackstone"] = {
        "a forgotten vanguard"
    },
    ["Shrapnel"] = {
        "a velious hound"
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
    ["Black Fang"] = {
        "a frost giant gladiator"
    },
    ["Direfang"] = {
        "a restless direwolf"
    },
    ["Drendar Blackblade"] = {
        "a storm giant soldier"
    },
    ["Fjokar Frozenshard"] = {
        "a storm giant soldier"
    },
    ["Irrek Bloodfist"] = {
        "a storm giant soldier"
    },
    ["Kallis Stormcaller"] = {
        "a storm giant soldier"
    },
    ["Keldor Dek`Torek"] = {
        "a storm giant soldier"
    },
    ["Klraggek the Slayer"] = {
        "a storm giant soldier"
    },
    ["Velden Dragonbane"] = {
        "a storm giant soldier"
    },
    ["Vkjen Thunderslayer"] = {
        "a storm giant soldier"
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
    ["a shrouded bat"] = {
        "a shrouded bat(labeled as rare)"
    },
    ["a skeleton sleeper"] = {
        "a shadowbone"
    },
    ["Amontehepna the Second"] = {
        "a frost mummy"
    },
    [" Ascendant Svartmane"] = {
        "a restless tutor"
    },
    ["Cara Omica"] = {
        "a zombie maid"
    },
    ["Dark Huntress"] = {
        "an undead dancer",
        "an undead musician"
    },
    ["D`dee the Chilled"] = {
        "a restless mummy"
    },
    ["Deacon Foels Tomorin"] = {
        "a drolvarg guard"
    },
    ["Malvus Darque"] = {
        "Spawns on death of the named:",
        "a shrouded bat"
    },
    ["Narmak Berreka"] = {
        "a possessed armor"
    },
    ["Vhal`Sera"] = {
        "a restless spectre"
    },
    ["Xalgoti"] = {
        "a returned shadow beast"
    },
    ["Zorglim the Dead"] = {
        "a disturbed student"
    },

    --Velketor's Labyrinth
    ["a restless devourer"] = {
        "a restless spider"
    },
    ["a restless tarantula"] = {
        "a wandering arachnid"
    },
    ["a velium horror"] = {
        "a glaring gargoyle"
    },
    ["an icy torment"] = {
        "a living spire"
    },
    ["Bledrek"] = {
        "a living ice construct"
    },
    ["Kerdelb"] = {
        "a restless ice construct"
    },
    [" Marlek Icepaw"] = {
        "an undying kobold"
    },
    ["Neemzaq"] = {
        "a freezing shade"
    },
    ["Qabruh"] = {
        "an icy gargoyle"
    },
    ["Vorgak"] = {
        "a mindless orc"
    },
    ["Zarhbub Icepaw"] = {
        "a wandering icepaw"
    },

    ---------Beginning of TBL PH list---------\
    --Aalishai: Palace of Embers
    ["Evasion Understanding Flow"] = {
        "an elemental of purest flame"
    },
    ["Final Blade Lord"] = {
        "a scoria golem"
    },
    ["Ghost Glass Bitter"] = {
        "a djinn scholar"
    },
    ["Ruby Icefall Blossom"] = {
        "a surf armor"
    },
    ["Shield Spirit`s Laugh"] = {
        "a flashfire phoenix"
    },
    ["Sixth Consuming Master"] = {
        "a vergerog soldier"
    },
    ["Steam Wave Slicer"] = {
        "a fire giant commander"
    },
    ["Stout Stone Beaten"] = {
        "a vekerchiki soldier"
    },
    ["Unconquering Sand Dirge"] = {
        "a duende emissary"
    },
    ["Venom of the Fallen Star"] = {
        "a flurry mephit"
    },
    ["Whispering Depths Sigh"] = {
        "a hraquis surgelord"
    },
    [" White Iron Rainbow"] = {
        "a brumeflight armor"
    },

    --Empyr: Realms of Ash
    ["Ashes"] = {
        "a sputtering flameling"
    },
    ["Assassin of the Perfect Dusk"] = {
        "a fire giant knight"
    },
    ["Final Rainbow"] = {
        "a breeze mephit"
    },
    ["Flail"] = {
        "a fire snail"
    },
    ["Fluttering Ruby Prince"] = {
        "an efreeti soldier"
    },
    ["Iron Heart"] = {
        "an efreeti sodlier"
    },
    ["Mischief Darkheart"] = {
        "a jopal mercenary"
    },
    ["Shockstone"] = {
        "a butte armor"
    },
    ["Sister of the Invisible Heart"] = {
        "an ondine ambassador"
    },
    ["Stalwart Flicker"] = {
        "a pyrite armor"
    },
    ["The Burning Mist"] = {
        "an elemental of purest flame",
    },
    ["Wilting Flames"] = {
        "an aging lapillus lava spider"
    },

    --Esianti: Palace of the Winds
    ["Blessed Wind"] = {
        "a djinn teacher"
    },
    ["Copper Star"] = {
        "a jopal warder"
    },
    [" Depth of Iron"] = {
        "a vekerchiki warder"
    },
    ["Iron Lance"] = {
        "a pyratic armor"
    },
    ["Jericog Merkin"] = {
        "a norrathian mage"
    },
    ["Leaping Eyes"] = {
        "an efreeti noble"
    },
    ["Rusted Stalactite"] = {
        "a cliff armor"
    },
    ["Sapphire Hammer"] = {
        "a breeze armor"
    },
    ["Seeping Gladness"] = {
        "a crest armor"
    },
    ["Sky Blade"] = {
        "a gusting mephit"
    },
    ["Veiled Sage"] = {
        "a djinn teacher"
    },
    ["Warrior`s Cleft"] = {
        "a triloun warder"
    },

    --Mearatas: The Stone Demesne
    ["an ancient air warden"] = {
        "a breeze warden"
    },
    ["an ancient fire warden"] = {
        "a flame warden"
    },
    ["an ancient stone warden"] = {
        "a rock warden"
    },
    [" an ancient water warden"] = {
        "a wave warden"
    },
    [" Flowing Horizon Halo"] = {
        "	a duende messenger"
    },
    ["Forsaken Cloud Sapphire"] = {
        "Spawns in the center of the zone. No PH"
    },
    ["Glaring Moon Void"] = {
        "Spawns in the center of the zone. No PH"
    },
    ["Platinum Rainbow Spire"] = {
        "Spawns in the center of the zone. No PH"
    },
    ["Radiant Amber Lotus"] = {
        "a lord of flame"
    },
    ["Tsunami Sol Blood"] = {
        "Spawns in the center of the zone. No PH"
    },
    ["Whispering Frost"] = {
        "an ondine servant"
    },
    ["Blistering Star"] = {
        "a wind lady",
        "a wind lord"
    },

    --Plane of Smoke
    ["Dirge of Lost Horizons"] = {
        "a fading lord"
    },
    ["Savage Irony of Will"] = {
        "a true flame"
    },
    ["Silent Silken Song"] = {
        "a wasting breezewing"
    },
    ["Soothing Wings of Mist"] = {
        "a true wind"
    },
    ["Strength of Undefeated Starfall"] = {
        "a soot steed"
    },
    ["Wandering Spring Soul"] = {
        "a dispersing windlord"
    },

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

    --Chamber of Tears--No Achievements for this zone

    --Gnome Memorial Mountain
    ["A Non-Standard Deviation"] = {
        "an iron legion climber"
    },
    ["Ambassador of Loving"] = {
        "a clockwork guardian"
    },
    ["Best Museum Security"] = {
        "a Security Officer"
    },
    ["Bloodmoon Chief Eclipse"] = {
        "a Bloodmoon darkheart"
    },
    ["Bloodmoon Howler Trolog"] = {
        "a Bloodmoon howler"
    },
    ["Breaker"] = {
        "a clockwork captain"
    },
    ["Consul of Cooperation"] = {
        "Heroic Adventure: Ironing out the Legion",
        "a lookout"
    },
    ["Fractured Sweeper"] = {
        "clockwork companion"
    },
    ["Grash, Bloodmoon Growler"] = {
        "Heroic Adventure: The Darkness Howls",
        "a Bloodmoon scrabbler"
    },
    ["Healer Prime"] = {
        "a clockwork healer"
    },
    ["Malfunctioning Iron Legion Hug"] = {
        "a gnomelike friend"
    },
    ["Master Mechanic"] = {
        "a clockwork lifter"
    },
    ["Repair for Pieces"] = {
        "an Iron Legion helper"
    },
    ["Tatters"] = {
        "a brave rat"
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
    ["Deka the Reaper"] = {
        "a specter of the Arisen"
    },
    ["Embalming Goo"] = {
        "Arisen bones"
    },
    ["General V`Deers, the Arisen"] = {
        "an Arisen officer"
    },
    ["Nureya Arisen"] = {
        "a specter of the Arisen"
    },
    ["Shandral Arisen"] = {
        "an arisen convert"
    },
    ["The Arisen Admiral Tylix"] = {
        "a specter of the Arisen"
    },
    ["The Arisen Dragoon T`Vem"] = {
        "a specter of the Arisen"
    },
    ["The Arisen Dragoon T`Vex"] = {
        "Arisen bones"
    },
    ["The Great Sentinel"] = {
        "a specter of the Arisen"
    },
    ["The Underlord"] = {
        "a bottomless gnawer"
    },
    [" Tormented Adalora"] = {
        "a specter of the Arisen"
    },
    ["Vermistipus"] = {
        "a specter of the Arisen"
    },
    ["Arisen Fenistra"] = {
        "an Arisen ghost"
    },
    ["Arisen Mentor Sishallan"] = {
        "an Arisen mentor"
    },

    --The Skyfire Mountains
    ["a feverish marauder"] = {
        "a zealot"
    },
    ["a rabid reveler"] = {
        "a brazen Chetari",
        "a drunken Chetari"
    },
    ["a scree-borne magmite"] = {
        "wrathful rubble",
        "a blackened tyro"
    },
    ["a supercharged tyro"] = {
        "a volatile effusion",
        "a stubborn magmite"
    },
    ["an Arcron researcher"] = {
        "a Krellnakor scout"
    },
    ["Ash Guardian Tolemak"] = {
        "a guardian wurm"
    },
    ["Chirurgeon Hemofax"] = {
        "an ashen scalpel",
        "an ashen cutter"
    },
    ["Dragoflux"] = {
        "a raging vortex"
    },
    ["Mawmun"] = {
        "a greedy gnawer"
    },
    ["Old Raspy"] = {
        "an old wurm"
    },
    ["Radiant Overseer Triluan"] = {
        "a radiant drake"
    },
    ["Rirwech the Fink"] = {
        "a suspicious Chetari",
        "a furtive Chetari"
    },
    ["Ritualist Bomoda"] = {
        "a grim cultist",
        "a grim chanter"
    },
    ["Shardstubble"] = {
        "a fractured magmite",
        "a fragile tyro"
    },
    ["Skrizix"] = {
        "an exotic chromedrac"
    },
    ["The Crimson Sentinel"] = {
        "an angry Arcron",
    },
    ["The Gatekeeper"] = {
        "a Krellnakor bodyguard",
        "a Krellnakor doorman"
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
    ["Blood-Thirsty Racnar"] = {
        "a frenetic racnar"
    },
    ["Elder Azeron"] = {
        "an ancient flame protector"
    },
    ["Elder Ekron"] = {
        "1 hour and 45 minute timer"
    },
    ["Ellarr Stormcloud"] = {
        "1 hour and 45 minute timer"
    },
    ["Kluzen the Protector"] = {
        "1 hour and 45 minute timer"
    },
    ["Magma Basilisk"] = {
        "a magma basilisk"
    },
    ["Milyex Vioren"] = {
        "1 hour and 45 minute timer"
    },
    ["Qunard Ashenclaw"] = {
        "a primeval cinder skyclaw"
    },
    ["Travenro the Skygazer"] = {
        "1 hour and 45 minute timer"
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
    ["Chokidai Wardog"] = {
        "a chokidai mangler"
    },
    ["Corpsestalker"] = {
        "a mature stalker"
    },
    ["Hunter Gwalnex IV"] = {
        "a Sarnak trapper"
    },
    ["Overboss Kaznak"] = {
        "a Sarnak warlord"
    },
    ["Spiritmaster Tala'Tak"] = {
        "a Sarnak sage"
    },

    --Korsha Labratory
    ["Bonescale"] = {
        "a lurking stalker"
    },
    ["Cutter"] = {
        "a chokidai elder"
    },
    ["Darkness"] = {
        "an ectopic amygdalan"
    },
    ["Deathgazer"] = {
        "a lurking beetle"
    },
    ["Firedowser Uglabarg"] = {
        "a conscripted dirtcaster"
    },
    ["Glart Fink"] = {
        "a conscripted warrior"
    },
    ["Kar`zok Overlord"] = {
        "a Kar`zok warrior"
    },
    ["Mad Researcher"] = {
        "Heroic Adventure: Infiltration of Kor-Sha",
        "a dazed researcher"
    },
    ["Okara Klyseer"] = {
        "a Di`zok adherent"
    },
    [" Overlord Dralgan"] = {
        "a Di`zok myrmidon"
    },
    ["Rogue Monstrosity"] = {
        "Heroic Adventure: Mysteries of Kor-Sha",
        "a golem"
    },
    ["Screaming Tormentor"] = {
        "a luxated terror"
    },
    ["Sepulcher Curator"] = {
        "a crypt guard"
    },
    ["Stonespiked Guardian"] = {
        "a wary guard"
    },
    ["The Possessed"] = {
        "a conscripted spiritist"
    },
    ["Vakazon Viz`Daron"] = {
        "a Di`zok aruspex"
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
    ["Caradawg Gwyn"] = {
        "a majestic sureshot"
    },
    ["Carpenter Adomnan"] = {
        "a forest giant carpenter"
    },
    ["Cathal Paclock"] = {
        "a forest giant fury"
    },
    ["Gullerback Undying"] = {
        "an ancient tatterback"
    },
    ["Plaguebringer"] = {
        "an ancient plaguebone"
    },
    ["Searstinger"] = {
        "an immolator hornet"
    },
    ["Sovarak Klyseer"] = {
        "a Sarnak shadowknight"
    },
    ["Spirit of Incineration"] = {
        "a spirit of flame"
    },
    ["The Ore-mad Prophet"] = {
        "a burynai prophet"
    },
    ["Zakija"] = {
        "a wurm-scorched skeleton"
    },

    --Temple of Droga
    ["Black Spot"] = {
        "a goblin slave"
    },
    ["Blood of Droga"] = {
        "a blightcaller bloodtender",
        "a blightcaller bloodtoiler"
    },
    ["Bore"] = {
        "mudman dredger"
    },
    ["Chief Dronan"] = {
        "Dronan bodyguard",
        "Dronan bodyshield"
    },
    ["Cook Eepvibles"] = {
        "a goblin cook"
    },
    ["Cook Jexnait"] = {
        "a devout goblin cook"
    },
    ["Home Master Kaziql"] = {
        "a homesafe goblin sentry"
    },
    ["Izisyl Peppershiv"] = {
        "a goblin caveshadow"
    },
    ["Jailor Muxfan"] = {
        "a goblin jailor",
        "a stalwart goblin jailor"
    },
    ["Master Kizzixik"] = {
        "a goblin slave master",
        "a goblin slave dealer"
    },
    ["Merchant Triala"] = {
        "Heroic Adventure: Goblins and Fools",
        "a goblin slinker"
    },
    ["Miner Groundfuse"] = {
        "a goblin dredger",
        "a stalwart goblin dredger"
    },
    ["Most Devout Sentry"] = {
        "a devout goblin sentry"
    },
    ["Overseer Vakov"] = {
        "a goblin taskmaster",
        "a hearty goblin taskmaster"
    },
    ["Sentry Rixzeel"] = {
        "a expert goblin sentry",
        "a tenacious goblin sentry"
    },
    ["Spirit Master Wigaue"] = {
        "a goblin fanatic"
    },
    ["Spiritwatcher Scrollhallow"] = {
        "a goblin mystic",
        "a goblin adept mystic"
    },
    ["War Leader Callex"] = {
        "a goblin forerunner sentry"
    },
    ["Whip Cracker Krassex"] = {
        "a goblin whip lord"
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

    --Crypt of Decay
    ["Abroan Drian"] = {
        "a corruptor knight"
    },
    ["Akkapan Adan"] = {
        "a bubonian warmaster"
    },
    ["Brightfire"] = {
        "a wary unicorn"
    },
    ["Feig Adan"] = {
        "a foulest pusling"
    },
    ["Fountainhead"] = {
        "a wellspring construct"
    },
    ["Grublus"] = {
        "Heroic Adventure: Lxavnom Labors",
        "a grumling"
    },
    ["Rusank"] = {
        "Heroic Adventure: Decay Decreased",
        "a pusling"
    },
    ["Seraphina"] = {
        "Heroic Adventure: Force the Forceful",
        "a seraph"
    },
    ["Xhut Adan"] = {
        "a dreadbone sage"
    },

--Sul Vius: Demiplane of Life
    ["Arsin the Blaze"] = {
        "Heroic Adventure: Under the Robe",
        "a ravenous citizen"
    },
    ["Commissioner Edrun"] = {
        "an overworked functionary"
    },
    ["Exalted Dromond"] = {
        "an honorable citizen"
    },
    ["Glorious Cistina"] = {
        "a gleeful citizen"
    },
    ["Guardian Jenat"] = {
        "a diligent guard"
    },
    ["Gurndal the Graceful"] = {
        "Heroic Adventure: We Make Our Own Rewards",
        "a venerated guard"
    },
    ["Mad Merchant Marv"] = {
        "a retired merchant"
    },
    ["Render"] = {
        "Heroic Adventure: The Handmaiden",
        "an enraged follower"
    },
    ["Terrance the Admired"] = {
        "a delighted citizen"
    },
    ["The Darkseer"] = {
        "an aloof bokon"
    },
    ["Vizier Albert"] = {
        "a doubtful functionary"
    },

--Sul Vius: Demiplane of Decay
    ["Emma, a True Believer"] = {
        "a worn administrator"
    },
    ["Eunice, Well-Wisher"] = {
        "a mournful peasant",
        "a burly cultist"
    },
    ["High Bokon Cleret"] = {
        "Heroic Adventure: Fate Rewards the Bold",
        "a grand bokon"
    },
    ["Master of the House"] = {
        "a retired salesperson"
    },
    ["Svea Haire"] = {
        "an impatient wanderer"
    },
    ["Tarris Ellarn"] = {
        "Heroic Adventure: Undead Underground",
        "a wandering official"
    },
    ["The Curator"] = {
        "a tireless sentinel"
    },
    ["The Perforator"] = {
        "Heroic Adventure: Deadline",
        "a mute citizen"
    },
    ["The Remnants of The Darkseer"] = {
        "an assistant to Darkseer"
    },
    ["The Sleepbringer"] = {
        "a tsetse eater",
        "a tsetse swarmborn"
    },
    ["Zikursch the Corrupt"] = {
        "an unpleasant bureaucrat"
    },

--Plane of Health
    ["Bhaly Adan"] = {
        "Heroic Adventure: Bane of Decay",
        "Unknown"
    },
    ["Bilemonger"] = {
        "Heroic Adventure: In Defense of Health",
        "a bubonian wartail"
    },
    ["Pestilent Warmaster"] = {
        "Heroic Adventure: In Defense of Health",
        "Unknown"
    },
    ["Prepusterous"] = {
        "Heroic Adventure: Defenders of the Faith",
        "a bubonian terror"
    },
    ["Putrid Brute"] = {
        "Heroic Adventure: In Defense of Health",
        "Unknown"
    },
    ["Vomitous"] = {
        "Heroic Adventure: In Defense of Health",
        "a bubonian wartai"
    },

-------------Beginning of TDS PH list-------------
---Arx Mentis
    ["Arx_Mentis"] = {
        "Unknown"
    },

    --Brother Island
    ["Brother_Island"] = {
        "Unknown"
    },

    --Caverns of Endless Song
    ["Caverns_of_Endless_Song"] = {
        "Unknown"
    },

    --Combine Dredge
    ["Combine_Dredge"] = {
        "Unknown"
    },
    
    --Degmar, the Lost Castle
    ["Degmar_the_Lost_Castle"] = {
        "Unknown"
    },
    
    --Katta Castrum: Deluge
    ["Katta_Castrum_Deluge"] = {
        "Unknown"
    },
    
    --Tempest Temple
    ["Tempest_Temple"] = {
        "Unknown"
    },
    
    --Thuliasaur Island
    ["Thuliasaur_Island"] = {
        "Unknown"
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
