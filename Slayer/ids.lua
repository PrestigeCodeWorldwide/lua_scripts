--v1.1
---@type Mq
local mq = require("mq")

-- All Slayer Achievement IDs and Names (11000000-11000179)
local ACHIEVEMENT_IDS = {
    [11000000] = "Megadeath",
    [11000001] = "A Force of Nature",
    [11000002] = "Highly Decorated",
    [11000003] = "Progressive",
    [11000004] = "Doesn't Play Well With Others",
    [11000005] = "Don't Bug Me",
    [11000006] = "I Hate Snakes!",
    [11000007] = "Pesticide",
    [11000008] = "We Are Dead!",
    [11000009] = "Strange Weather",
    [11000010] = "The Zookeeper",
    [11000011] = "Swordfishmermaid",
    [11000012] = "Orc Stomp!",
    [11000013] = "Ugly Creature Near My Feet...",
    [11000014] = "BBBBBAAAARRRKKKK!!!!!",
    [11000015] = "Puttin' On The Dog",
    [11000016] = "It's Alive!",
    [11000017] = "Plants Concrete and Stone",
    [11000018] = "Here Be Dragons!",
    [11000019] = "Might They Be Giants?",
    [11000020] = "Legendary Creatures",
    [11000021] = "Planes, Trains and Element-iles",
    [11000022] = "A Sight for Sore Eyes",
    [11000023] = "Domo Arigato",
    [11000024] = "Foreign Affair",
    [11000025] = "Invaders In a Strange Land",
    [11000026] = "Your God Has Found You Lacking",
    [11000027] = "Table Flipper",
    [11000028] = "I'm a People Person!",
    [11000029] = "What Keeps Mankind Alive?",
    [11000030] = "Three Letter Word for Dead...",
    [11000031] = "Short People",
    [11000032] = "Simple Folk of Ykesha",
    [11000033] = "Bounced!",
    [11000034] = "Mostly Kunzar",
    [11000035] = "Catnipped In Bud",
    [11000036] = "Amphibicide",
    [11000037] = "Rats!",
    [11000038] = "Eight Legs Are Better Than One!",
    [11000039] = "The Hounds",
    [11000040] = "The Cat's Pajamas",
    [11000041] = "Bird Flew",
    [11000042] = "Monkey Business",
    [11000043] = "I'm Boared!",
    [11000044] = "Orc Kill!",
    [11000045] = "Me Thinks That You'll Be Good to Eat!",
    [11000046] = "Gnolling is Half Battle",
    [11000047] = "Kobolded Killer",
    [11000048] = "Gooooooooooooooolem!",
    [11000049] = "Drawing Life From a Stone",
    [11000050] = "Living Stone I presume?",
    [11000051] = "Herbicide",
    [11000052] = "Dragonbane",
    [11000053] = "You Call That a Dragon?",
    [11000054] = "A Giant Problem",
    [11000055] = "Shorter People",
    [11000056] = "Slayer of Mystical Horses",
    [11000057] = "It's Plane to See",
    [11000058] = "Breakdown Dead Ahead",
    [11000059] = "Natives of Velious",
    [11000060] = "Natives of Luclin",
    [11000061] = "Natives of Taelosia",
    [11000062] = "Natives of Kuua",
    [11000063] = "Natives of Alaris",
    [11000064] = "Such Anguish",
    [11000065] = "Oh Humanity!",
    [11000066] = "Barbarous",
    [11000067] = "Hardly Erudite of You",
    [11000068] = "Drackity Drak",
    [11000069] = "Wood You Could You?",
    [11000070] = "Highly Uncivilized",
    [11000071] = "Love Will Teir Them Apart",
    [11000072] = "Now .49999%",
    [11000073] = "It Was Called Tunaria",
    [11000074] = "Axe Me No Questions",
    [11000075] = "Dainy It's Cold Outside",
    [11000076] = "Fuzzyfeet",
    [11000077] = "A Clockwork Gnome",
    [11000078] = "Here's Yer Grozmok",
    [11000079] = "Get Stupid",
    [11000080] = "Icky!",
    [11000081] = "Why Kylong faces?",
    [11000082] = "Good Luck, Bad Guk",
    [11000083] = "It's a Frog Eat Frog World",
    [11000084] = "Rrrribit!",
    [11000085] = "Moonkitty",
    [11000086] = "Not a Kerran World!",
    [11000087] = "Bat Country!",
    [11000088] = "Rat Killer",
    [11000089] = "Armadilloed and Dangerous",
    [11000090] = "It Stinks!",
    [11000091] = "Bunnyslayer",
    [11000092] = "You Dirty Ratman!",
    [11000093] = "Of Micelike Men",
    [11000094] = "Badger, Badger, Badger...",
    [11000095] = "Beetlemania",
    [11000096] = "Leechy Keen",
    [11000097] = "Corathus!",
    [11000098] = "Army Ants",
    [11000099] = "Shoo fly!",
    [11000100] = "Get Broom!",
    [11000101] = "A Web of Lies",
    [11000102] = "Fury of Soriz",
    [11000103] = "Snake in the Grass",
    [11000104] = "A Bone to Pick With You",
    [11000105] = "Stake Dinner",
    [11000106] = "Hide Your Brains!",
    [11000107] = "Mummy Dearest",
    [11000108] = "Ghoul On the Hill",
    [11000109] = "Round of Applause",
    [11000110] = "Ghosts of Frostfell Past",
    [11000111] = "50 Shades...",
    [11000112] = "Suit up!",
    [11000113] = "New Tricks",
    [11000114] = "Got Your Tongue?",
    [11000115] = "Featherbrained Plan",
    [11000116] = "Better Get a Barrel",
    [11000117] = "Bear With Me",
    [11000118] = "The Elephant in the Room",
    [11000119] = "Overthere in Wastes",
    [11000120] = "These Boots Were Made For...",
    [11000121] = "Guess You Didn't Like Turtles",
    [11000122] = "What Has Science Done!?",
    [11000123] = "Have You Seen My Bucket?",
    [11000124] = "Seacow!",
    [11000125] = "A Molkor?",
    [11000126] = "Sealephant",
    [11000127] = "A Horse of Course",
    [11000128] = "Plenty of Fish In the Sea",
    [11000129] = "Why So Crabby?",
    [11000130] = "Orc Weapons, Your Blood Will Spill!",
    [11000131] = "New Frontiers",
    [11000132] = "The More You Gnoll!",
    [11000133] = "World Warrens Three",
    [11000134] = "Alliz Tae Ew",
    [11000135] = "Sarnak Slayer",
    [11000136] = "Don't Be Shellfish!",
    [11000137] = "Innoruuk's Gift",
    [11000138] = "A Fallen Empire",
    [11000139] = "You Can Call Me Alaran",
    [11000140] = "Re-Extinction",
    [11000141] = "Aquatic Allure",
    [11000142] = "I Said Argyle!",
    [11000143] = "You're Not Scaring Anyone",
    [11000144] = "Lumberer",
    [11000145] = "Mushroom Hunting",
    [11000146] = "Stop Dragon This Out",
    [11000147] = "Quit Dragon Your Heels",
    [11000148] = "You Keep Dragon Me Into This",
    [11000149] = "A Small Giant Problem",
    [11000150] = "Fairicide",
    [11000151] = "For Hive!",
    [11000152] = "Jumjummery",
    [11000153] = "Self Centaured",
    [11000154] = "You're Faunny",
    [11000155] = "Amazing!",
    [11000156] = "No Vacancy",
    [11000157] = "Half Man, Half Scorpion, Half Lion",
    [11000158] = "Puzzling",
    [11000159] = "My Golden Boots",
    [11000160] = "Imp-atient",
    [11000161] = "Elementary",
    [11000162] = "Spin Me Right Round",
    [11000163] = "They Call Me Riftseeker",
    [11000164] = "Terrorible Tentacles",
    [11000165] = "Denizens of Fear",
    [11000166] = "Insatiable",
    [11000167] = "You Look Lovely",
    [11000168] = "Eye See What You Did There!",
    [11000169] = "Goo-dness Gracious!",
    [11000170] = "Cubic",
    [11000171] = "Gnome Tested, Steamwork Approved!",
    [11000172] = "Discord Sounds Out of Tune",
    [11000173] = "Shadows of Lxanvom",
    [11000174] = "Spider-Bear",
    [11000175] = "Reader's Die Jest",
    [11000176] = "Witch Mount?",
    [11000177] = "Dino-sore!",
    [11000178] = "In Your Eyes",
    [11000179] = "Terror from the Stars"
}

-- Helper function to get achievement name by ID
local function getAchievementName(id)
    return ACHIEVEMENT_IDS[id] or "Unknown Achievement"
end

-- Helper function to get all achievement IDs (sorted)
local function getAllAchievementIDs()
    local ids = {}
    for id, _ in pairs(ACHIEVEMENT_IDS) do
        table.insert(ids, id)
    end
    table.sort(ids)
    return ids
end

-- Helper function to get achievement IDs with first 4 fixed and rest sorted alphabetically
local function getAchievementIDsCustomOrder()
    local allIDs = getAllAchievementIDs()
    local result = {}
    
    -- Keep first 4 achievements in their original order
    for i = 1, math.min(4, #allIDs) do
        table.insert(result, allIDs[i])
    end
    
    -- Sort remaining achievements alphabetically by name
    local remaining = {}
    for i = 5, #allIDs do
        table.insert(remaining, allIDs[i])
    end
    
    table.sort(remaining, function(a, b)
        return ACHIEVEMENT_IDS[a] < ACHIEVEMENT_IDS[b]
    end)
    
    -- Add sorted remaining achievements
    for _, id in ipairs(remaining) do
        table.insert(result, id)
    end
    
    return result
end

-- Export the achievement data
return {
    ACHIEVEMENT_IDS = ACHIEVEMENT_IDS,
    getAchievementName = getAchievementName,
    getAllAchievementIDs = getAllAchievementIDs,
    getAchievementIDsCustomOrder = getAchievementIDsCustomOrder
}
