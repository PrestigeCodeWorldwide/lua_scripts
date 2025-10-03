-- Zone data for Hunterhood
local function createZoneData(mq)
    local zoneMap = {
        [58]  = 105880,  --Hunter of Crushbone                  Clan Crusbone=crushbone
        [66]  = 106680,  --Hunter of The Ruins of Old Guk       The Reinforced Ruins of Old Guk=gukbottom
        [73]  = 107380,  --Hunter of the Permafrost Caverns     Permafrost Keep=permafrost
        [81]  = 258180,  --Hunter of The Temple of Droga        The Temple of Droga=droga
        [87]  = 208780,  --Hunter of The Burning Wood           The Burning Woods=burningwood
        [89]  = 208980,  --Hunter of The Ruins of Old Sebilis   The Reinforced Ruins of Old Sebilis=sebilis
        [108] = 250880,  --Hunter of Veeshan's Peak             Veeshan's Peak=veeshan
        [207] = 520780,  --Hunter of Torment, the Plane of Pain Plane of Torment=potorment
        [455] = 1645560, --Hunter of Kurn's Tower               Kurn's Tower=oldkurn
        [318] = 908300,  --Hunter of Dranik's Hollows           Dranik's Hollows (A)=dranikhollowsa
        [319] = 908300,  --Hunter of Dranik's Hollows           Dranik's Hollows (B)=dranikhollowsb
        [320] = 908300,  --Hunter of Dranik's Hollows           Dranik's Hollows (C)=dranikhollowsc
        [328] = 908600,  --Hunter of Catacombs of Dranik        Catacombs of Dranik (A)=dranikcatacombsa
        [329] = 908600,  --Hunter of Catacombs of Dranik        Catacombs of Dranik (B)=dranikcatacombsb
        [330] = 908600,  --Hunter of Catacombs of Dranik        Catacombs of Dranik (C)=dranikcatacombsc
        [331] = 908700,  --Hunter of Sewers of Dranik           Sewers of Dranik (A)=draniksewersa
        [332] = 908700,  --Hunter of Sewers of Dranik           Sewers of Dranik (B)=draniksewersb
        [333] = 908700,  --Hunter of Sewers of Dranik           Sewers of Dranik (C)=draniksewersc
        [700] = 1870060, --Hunter of The Feerrott               The Feerrott=Feerrott2
        [772] = 2177270, --Hunter of West Karana (Ethernere)    Ethernere Tainted West Karana=ethernere
        [76]  = 2320180, --Hunter of the Plane of Hate: Broken Mirror  Plane of hate Revisited=hateplane
        [788] = 2478880, --Hunter of The Temple of Droga        Temple of Droga=drogab
        [791] = 2479180, --Hunter of Frontier Mountains         Frontier Mountains=frontiermtnsb
        [800] = 2480080, --Hunter of Chardok                    Chardok=chardoktwo
        [813] = 2581380, --Hunter of The Howling Stones         Howling Stones=charasistwo
        [814] = 2581480, --Hunter of The Skyfire Mountains      Skyfire Mountains=skyfiretwo
        [815] = 2581580, --Hunter of The Overthere              The Overthere=overtheretwo
        [816] = 2581680, --Hunter of Veeshan's Peak             Veeshan's Peak=veeshantwo
        [824] = 2782480, --Hunter of The Eastern Wastes         The Eastern Wastes=eastwastestwo
        [825] = 2782580, --Hunter of The Tower of Frozen Shadow The Tower of Frozen Shadow=frozenshadowtwo
        [826] = 2782680, --Hunter of The Ry`Gorr Mines          The Ry`Gorr Mines=crystaltwoa
        [827] = 2782780, --Hunter of The Great Divide           The Great Divide=greatdividetwo
        [828] = 2782880, --Hunter of Velketor's Labyrinth       Velketor's Labyrinth=velketortwo
        [829] = 2782980, --Hunter of Kael Drakkel               Kael Drakkel=kaeltwo
        [830] = 2783080, --Hunter of Crystal Caverns            Crystal Caverns=crystaltwob
        [831] = 2807601, --Hunter of The Sleeper's Tomb         The Sleeper's Tomb=sleepertwo
        [832] = 2807401, --Hunter of Dragon Necropolis          Dragon Necropolis=necropolistwo
        [833] = 2807101, --Hunter of Cobalt Scar                Cobalt Scar=cobaltscartwo
        [834] = 2807201, --Hunter of The Western Wastes         The Western Wastes=westwastestwo
        [835] = 2807501, --Hunter of Skyshrine                  Skyshrine=skyshrinetwo
        [836] = 2807301, --Hunter of The Temple of Veeshan      The Temple of Veeshan=templeveeshantwo
        [843] = 2908100, --Hunter of Maiden's Eye               Maiden's Eye=maidentwo
        [844] = 2908200, --Hunter of Umbral Plains              Umbral Plains=umbraltwo
        [846] = 2908400, --Hunter of Vex Thal                   Vex Thal=vexthaltwo
        [847] = 2908500, --Hunter of Shadow Valley              zone name has an extra space
    }

    local function getZoneDisplayName(zoneID)
        return mq.TLO.Zone(zoneID).Name() or "Unknown Zone"
    end

    -- Expansion zone lists
    local zone_lists = {
        ["ToB"] = {
            {id = 872, name = function() return getZoneDisplayName(872) end, shortname = "aureatecovert"},
            {id = 870, name = function() return getZoneDisplayName(870) end, shortname = "hodstock"},
            {id = 874, name = function() return getZoneDisplayName(874) end, shortname = "puissance"},
            {id = 875, name = function() return getZoneDisplayName(875) end, shortname = "gildedspire"},
            {id = 873, name = function() return getZoneDisplayName(873) end, shortname = "harbingerscradle"},
            {id = 871, name = function() return getZoneDisplayName(871) end, shortname = "toe"},
        },
        ["LS"] = {
            {id = 860, name = function() return getZoneDisplayName(860) end, shortname = "ankexfen"},
            {id = 859, name = function() return getZoneDisplayName(859) end, shortname = "laurioninn"},
            {id = 863, name = function() return getZoneDisplayName(863) end, shortname = "moorsofnokk"},
            {id = 861, name = function() return getZoneDisplayName(861) end, shortname = "pallomen"},
            {id = 862, name = function() return getZoneDisplayName(862) end, shortname = "herosforge"},
            {id = 865, name = function() return getZoneDisplayName(865) end, shortname = "timorousfalls"},
            {id = 864, name = function() return getZoneDisplayName(864) end, shortname = "unkemptwoods"},
        },
        ["NoS"] = {
            {id = 855, name = function() return getZoneDisplayName(855) end, shortname = "darklightcaverns"},
            {id = 856, name = function() return getZoneDisplayName(856) end, shortname = "deepshade"},
            {id = 857, name = function() return getZoneDisplayName(857) end, shortname = "firefallpass"},
            {id = 853, name = function() return getZoneDisplayName(853) end, shortname = "paludaltwo"},
            {id = 851, name = function() return getZoneDisplayName(851) end, shortname = "shadowhaventwo"},
            {id = 854, name = function() return getZoneDisplayName(854) end, shortname = "shadeweavertwo"},
            {id = 852, name = function() return getZoneDisplayName(852) end, shortname = "sharvahltwo"},
        },
        ["ToL"] = {
            {id = 848, name = function() return getZoneDisplayName(848) end, shortname = "basilica"},
            {id = 849, name = function() return getZoneDisplayName(849) end, shortname = "bloodfalls"},
            {id = 845, name = function() return getZoneDisplayName(845) end, shortname = "akhevatwo"},
            {id = 843, name = function() return getZoneDisplayName(843) end, shortname = "maidentwo"},
            {id = 847, name = function() return getZoneDisplayName(847) end, shortname = "shadowvalley"},
            {id = 844, name = function() return getZoneDisplayName(844) end, shortname = "umbraltwo"},
            {id = 846, name = function() return getZoneDisplayName(846) end, shortname = "vexthaltwo"},
        },
        ["CoV"] = {
            {id = 833, name = function() return getZoneDisplayName(833) end, shortname = "cobaltscartwo"},
            {id = 832, name = function() return getZoneDisplayName(832) end, shortname = "necropolistwo"},
            {id = 835, name = function() return getZoneDisplayName(835) end, shortname = "skyshrinetwo"},
            {id = 831, name = function() return getZoneDisplayName(831) end, shortname = "sleepertwo"},
            {id = 836, name = function() return getZoneDisplayName(836) end, shortname = "templeveeshantwo"},
            {id = 834, name = function() return getZoneDisplayName(834) end, shortname = "westwastestwo"},
        },
        ["ToV"] = {
            {id = 830, name = function() return getZoneDisplayName(830) end, shortname = "crystaltwob"},
            {id = 829, name = function() return getZoneDisplayName(829) end, shortname = "kaeltwo"},
            {id = 824, name = function() return getZoneDisplayName(824) end, shortname = "eastwastestwo"},
            {id = 827, name = function() return getZoneDisplayName(827) end, shortname = "greatdividetwo"},
            {id = 826, name = function() return getZoneDisplayName(826) end, shortname = "crystaltwoa"},
            {id = 825, name = function() return getZoneDisplayName(825) end, shortname = "frozenshadowtwo"},
            {id = 828, name = function() return getZoneDisplayName(828) end, shortname = "velketortwo"},
        },
        ["TBL"] = {
            {id = 819, name = function() return getZoneDisplayName(819) end, shortname = "aalishai"},
            {id = 820, name = function() return getZoneDisplayName(820) end, shortname = "empyr"},
            {id = 821, name = function() return getZoneDisplayName(821) end, shortname = "esianti"},
            {id = 822, name = function() return getZoneDisplayName(822) end, shortname = "mearatas"},
            {id = 817, name = function() return getZoneDisplayName(817) end, shortname = "trialsofsmoke"},
            {id = 818, name = function() return getZoneDisplayName(818) end, shortname = "stratos"},
            {id = 823, name = function() return getZoneDisplayName(823) end, shortname = "chamberoftears"},
            {id = 787, name = function() return getZoneDisplayName(787) end, shortname = "gnomemtn"},
        },
        ["RoS"] = {
            {id = 789, name = function() return getZoneDisplayName(789) end, shortname = "charasisb"},
            {id = 792, name = function() return getZoneDisplayName(792) end, shortname = "gorowyn"},
            {id = 813, name = function() return getZoneDisplayName(813) end, shortname = "charasistwo"},
            {id = 814, name = function() return getZoneDisplayName(814) end, shortname = "skyfiretwo"},
            {id = 815, name = function() return getZoneDisplayName(815) end, shortname = "overtheretwo"},
            {id = 816, name = function() return getZoneDisplayName(816) end, shortname = "veeshantwo"},
        },
        ["EoK"] = {
            {id = 800, name = function() return getZoneDisplayName(800) end, shortname = "chardoktwo"},
            {id = 791, name = function() return getZoneDisplayName(791) end, shortname = "frontiermtnsb"},
            {id = 793, name = function() return getZoneDisplayName(793) end, shortname = "korshaext"},
            {id = 799, name = function() return getZoneDisplayName(799) end, shortname = "korshaexttwo"},
            {id = 794, name = function() return getZoneDisplayName(794) end, shortname = "lceanium"},
            {id = 790, name = function() return getZoneDisplayName(790) end, shortname = "scorchedwoods"},
            {id = 788, name = function() return getZoneDisplayName(788) end, shortname = "drogab"},
        },
        ["TBM"] = {
            {id = 795, name = function() return getZoneDisplayName(795) end, shortname = "cosul"},
            {id = 796, name = function() return getZoneDisplayName(796) end, shortname = "codecayb"},
            {id = 777, name = function() return getZoneDisplayName(777) end, shortname = "exalted"},
            {id = 797, name = function() return getZoneDisplayName(797) end, shortname = "exaltedb"},
            {id = 798, name = function() return getZoneDisplayName(798) end, shortname = "pohealth"},
        },
        ["TDS"] = {
            {id = 778, name = function() return getZoneDisplayName(778) end, shortname = "arxmentis"},
            {id = 779, name = function() return getZoneDisplayName(779) end, shortname = "brotherisland"},
            {id = 782, name = function() return getZoneDisplayName(782) end, shortname = "endlesscaverns"},
            {id = 781, name = function() return getZoneDisplayName(781) end, shortname = "dredge"},
            {id = 784, name = function() return getZoneDisplayName(784) end, shortname = "degmar"},
            {id = 780, name = function() return getZoneDisplayName(780) end, shortname = "kattacastrumb"},
            {id = 785, name = function() return getZoneDisplayName(785) end, shortname = "tempesttemple"},
            {id = 783, name = function() return getZoneDisplayName(783) end, shortname = "thuliasaur"},
        },
        ["CoTF"] = {
            {id = 776, name = function() return getZoneDisplayName(776) end, shortname = "arginhiz"},
            {id = 777, name = function() return getZoneDisplayName(777) end, shortname = "chambersb"},
        },
        ["RoF"] = {
            {id = 815, name = function() return getZoneDisplayName(815) end, shortname = "chambersa"},
            {id = 816, name = function() return getZoneDisplayName(816) end, shortname = "chambersb"},
        },
        ["VoA"] = {
            {id = 815, name = function() return getZoneDisplayName(815) end, shortname = "chambersa"},
            {id = 816, name = function() return getZoneDisplayName(816) end, shortname = "chambersb"},
        },
        ["HoT"] = {
            {id = 815, name = function() return getZoneDisplayName(815) end, shortname = "chambersa"},
            {id = 816, name = function() return getZoneDisplayName(816) end, shortname = "chambersb"},
        },
        ["UF"] = {
            {id = 815, name = function() return getZoneDisplayName(815) end, shortname = "chambersa"},
            {id = 816, name = function() return getZoneDisplayName(816) end, shortname = "chambersb"},
        },
        ["SoD"] = {
            {id = 815, name = function() return getZoneDisplayName(815) end, shortname = "chambersa"},
            {id = 816, name = function() return getZoneDisplayName(816) end, shortname = "chambersb"},
        },
        ["SoF"] = {
            {id = 815, name = function() return getZoneDisplayName(815) end, shortname = "chambersa"},
            {id = 816, name = function() return getZoneDisplayName(816) end, shortname = "chambersb"},
        },
        ["TBS"] = {
            {id = 815, name = function() return getZoneDisplayName(815) end, shortname = "chambersa"},
            {id = 816, name = function() return getZoneDisplayName(816) end, shortname = "chambersb"},
        },
        ["TSS"] = {
            {id = 406, name = function() return getZoneDisplayName(406) end, shortname = "ashengate"},
            {id = 398, name = function() return getZoneDisplayName(398) end, shortname = "roost"},
            {id = 395, name = function() return getZoneDisplayName(395) end, shortname = "moors"},
            {id = 394, name = function() return getZoneDisplayName(394) end, shortname = "crescent"},
            {id = 405, name = function() return getZoneDisplayName(405) end, shortname = "direwind"},
            {id = 402, name = function() return getZoneDisplayName(402) end, shortname = "frostcrypt"},
            {id = 397, name = function() return getZoneDisplayName(397) end, shortname = "mesa"},
            {id = 400, name = function() return getZoneDisplayName(400) end, shortname = "icefall"},
            {id = 396, name = function() return getZoneDisplayName(396) end, shortname = "stonehive"},
            {id = 403, name = function() return getZoneDisplayName(403) end, shortname = "sunderock"},
            {id = 399, name = function() return getZoneDisplayName(399) end, shortname = "steppes"},
            {id = 401, name = function() return getZoneDisplayName(401) end, shortname = "valdeholm"},
            {id = 404, name = function() return getZoneDisplayName(404) end, shortname = "vergalid"},
        },
        ["Debug"] = {
            {id = 751, name = function() return getZoneDisplayName(751) end, shortname = "guildhall3_int"},
            {id = 752, name = function() return getZoneDisplayName(752) end, shortname = "chambersb"},
        }
    }

    -- Expansion display order
    local combo_items = { "ToB", "LS", "NoS", "ToL", "CoV", "ToV", "TBL", "RoS", "EoK", "TBM", "TDS", "CoTF", "RoF", "VoA",
        "HoT", "UF", "SoD", "SoF", "TBS", "TSS", "Debug" }

    return {
        zoneMap = zoneMap,
        zone_lists = zone_lists,
        combo_items = combo_items,
        getZoneDisplayName = getZoneDisplayName
    }
end

return {
    create = createZoneData
}
