-- v1.1
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
        --[770] = 2177071, --Hunter of Bixie Warfront II          Bixie Warfront=bixiewarfront
        [788] = 2478880, --Hunter of The Temple of Droga        Temple of Droga=drogab
        [791] = 2479180, --Hunter of Frontier Mountains         Frontier Mountains=frontiermtnsb
        [796] = 2379680, --Hunter of the Crypt of Decay         Crypt of Decay=codecayb
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
        ["SoR"] = {
            {id = 879, name = function() return getZoneDisplayName(879) end, shortname = "candlemakers"},
            {id = 880, name = function() return getZoneDisplayName(880) end, shortname = "embattledpogrowth"},
            {id = 881, name = function() return getZoneDisplayName(881) end, shortname = "arcstoneruins"},
            {id = 882, name = function() return getZoneDisplayName(882) end, shortname = "ruinedrelic"},
            {id = 883, name = function() return getZoneDisplayName(883) end, shortname = "vortex"},
            {id = 884, name = function() return getZoneDisplayName(884) end, shortname = "spite"},
        },
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
            {id = 770, name = function() return getZoneDisplayName(770) end, shortname = "bixiewarfront"},
            {id = 772, name = function() return getZoneDisplayName(772) end, shortname = "ethernere"},
            {id = 43, name = function() return getZoneDisplayName(43) end, shortname = "neriakd"},
            {id = 771, name = function() return getZoneDisplayName(771) end, shortname = "deadhills"},
            {id = 773, name = function() return getZoneDisplayName(773) end, shortname = "thevoidh"},
            {id = 775, name = function() return getZoneDisplayName(775) end, shortname = "towerofrot"},
        },
        ["RoF"] = {
            {id = 760, name = function() return getZoneDisplayName(760) end, shortname = "chapterhouse"},
            {id = 763, name = function() return getZoneDisplayName(763) end, shortname = "chelsithreborn"},
            {id = 755, name = function() return getZoneDisplayName(755) end, shortname = "eastwastesshard"},
            {id = 758, name = function() return getZoneDisplayName(758) end, shortname = "eviltree"},
            {id = 759, name = function() return getZoneDisplayName(759) end, shortname = "grelleth"},
            {id = 769, name = function() return getZoneDisplayName(769) end, shortname = "heartoffearc"},
            {id = 768, name = function() return getZoneDisplayName(768) end, shortname = "heartoffearb"},
            {id = 765, name = function() return getZoneDisplayName(765) end, shortname = "heartoffear"},
            {id = 754, name = function() return getZoneDisplayName(754) end, shortname = "kaelshard"},
            {id = 764, name = function() return getZoneDisplayName(764) end, shortname = "poshadow"},
            {id = 752, name = function() return getZoneDisplayName(752) end, shortname = "shardslanding"},
            {id = 757, name = function() return getZoneDisplayName(757) end, shortname = "breedinggrounds"},
            {id = 756, name = function() return getZoneDisplayName(756) end, shortname = "crystalshard"},
            {id = 753, name = function() return getZoneDisplayName(753) end, shortname = "xorbb"},
        },
        ["VoA"] = {
            {id = 724, name = function() return getZoneDisplayName(724) end, shortname = "argath"},
            {id = 728, name = function() return getZoneDisplayName(728) end, shortname = "beastdomain"},
            {id = 732, name = function() return getZoneDisplayName(732) end, shortname = "cityofbronze"},
            {id = 734, name = function() return getZoneDisplayName(734) end, shortname = "eastsepulcher"},
            {id = 730, name = function() return getZoneDisplayName(730) end, shortname = "pillarsalra"},
            {id = 729, name = function() return getZoneDisplayName(729) end, shortname = "resplendent"},
            {id = 727, name = function() return getZoneDisplayName(727) end, shortname = "rubak"},
            {id = 726, name = function() return getZoneDisplayName(726) end, shortname = "sarithcity"},
            {id = 733, name = function() return getZoneDisplayName(733) end, shortname = "sepulcher"},
            {id = 725, name = function() return getZoneDisplayName(725) end, shortname = "arelis"},
            {id = 735, name = function() return getZoneDisplayName(735) end, shortname = "westsepulcher"},
            {id = 731, name = function() return getZoneDisplayName(731) end, shortname = "windsong"},
        },
        ["HoT"] = {
            {id = 709, name = function() return getZoneDisplayName(709) end, shortname = "alkabormare"},
            {id = 706, name = function() return getZoneDisplayName(706) end, shortname = "fallen"},
            {id = 711, name = function() return getZoneDisplayName(711) end, shortname = "thuledream"},
            {id = 701, name = function() return getZoneDisplayName(701) end, shortname = "thulehouse1"},
            {id = 702, name = function() return getZoneDisplayName(702) end, shortname = "thulehouse2"},
            {id = 710, name = function() return getZoneDisplayName(710) end, shortname = "miragulmare"},
            {id = 713, name = function() return getZoneDisplayName(713) end, shortname = "phylactery"},
            {id = 707, name = function() return getZoneDisplayName(707) end, shortname = "morellcastle"},
            {id = 708, name = function() return getZoneDisplayName(708) end, shortname = "somnium"},
            {id = 700, name = function() return getZoneDisplayName(700) end, shortname = "feerrott2"},
            {id = 703, name = function() return getZoneDisplayName(703) end, shortname = "housegarden"},
            {id = 704, name = function() return getZoneDisplayName(704) end, shortname = "thulelibrary"},
            {id = 705, name = function() return getZoneDisplayName(705) end, shortname = "well"},
        },
        ["UF"] = {
            {id = 485, name = function() return getZoneDisplayName(485) end, shortname = "arthicrex"},
            {id = 492, name = function() return getZoneDisplayName(492) end, shortname = "brellsarena"},
            {id = 480, name = function() return getZoneDisplayName(480) end, shortname = "brellsrest"},
            {id = 490, name = function() return getZoneDisplayName(490) end, shortname = "brellstemple"},
            {id = 481, name = function() return getZoneDisplayName(481) end, shortname = "fungalforest"},
            {id = 484, name = function() return getZoneDisplayName(484) end, shortname = "shiningcity"},
            {id = 495, name = function() return getZoneDisplayName(495) end, shortname = "dragoncrypt"},
            {id = 487, name = function() return getZoneDisplayName(487) end, shortname = "lichencreep"},
            {id = 488, name = function() return getZoneDisplayName(488) end, shortname = "pellucid"},
            {id = 491, name = function() return getZoneDisplayName(491) end, shortname = "convorteum"},
            {id = 483, name = function() return getZoneDisplayName(483) end, shortname = "coolingchamber"},
            {id = 486, name = function() return getZoneDisplayName(486) end, shortname = "foundation"},
            {id = 482, name = function() return getZoneDisplayName(482) end, shortname = "underquarry"},
            {id = 489, name = function() return getZoneDisplayName(489) end, shortname = "stonesnake"},
            {id = 493, name = function() return getZoneDisplayName(493) end, shortname = "weddingchapel"},
        },
        ["SoD"] = {
            {id = 456, name = function() return getZoneDisplayName(456) end, shortname = "oldkithicor"},
            {id = 471, name = function() return getZoneDisplayName(471) end, shortname = "discordtower"},
            {id = 474, name = function() return getZoneDisplayName(474) end, shortname = "olddranik"},
            {id = 478, name = function() return getZoneDisplayName(478) end, shortname = "oldfieldofboneb"},
            {id = 454, name = function() return getZoneDisplayName(454) end, shortname = "oldkaesorab"},
            {id = 453, name = function() return getZoneDisplayName(453) end, shortname = "oldkaesoraa"},
            {id = 470, name = function() return getZoneDisplayName(470) end, shortname = "discord"},
            {id = 476, name = function() return getZoneDisplayName(476) end, shortname = "korascian"},
            {id = 466, name = function() return getZoneDisplayName(466) end, shortname = "oceangreenhills"},
            {id = 467, name = function() return getZoneDisplayName(467) end, shortname = "oceangreenvillage"},
            {id = 468, name = function() return getZoneDisplayName(468) end, shortname = "oldblackburrow"},
            {id = 472, name = function() return getZoneDisplayName(472) end, shortname = "oldbloodfield"},
            {id = 457, name = function() return getZoneDisplayName(457) end, shortname = "oldcommons"},
            --{id = 452, name = function() return getZoneDisplayName(452) end, shortname = "oldfieldofbone"},
            {id = 455, name = function() return getZoneDisplayName(455) end, shortname = "oldkurn"},
            {id = 477, name = function() return getZoneDisplayName(477) end, shortname = "rathechamber"},
            {id = 469, name = function() return getZoneDisplayName(469) end, shortname = "bertoxtemple"},
            {id = 473, name = function() return getZoneDisplayName(473) end, shortname = "precipiceofwar"},
            {id = 475, name = function() return getZoneDisplayName(475) end, shortname = "toskirakk"},
        },
        ["SoF"] = {
            {id = 445, name = function() return getZoneDisplayName(445) end, shortname = "bloodmoon"},
            {id = 449, name = function() return getZoneDisplayName(449) end, shortname = "cryptofshade"},
            {id = 446, name = function() return getZoneDisplayName(446) end, shortname = "crystallos"},
            {id = 442, name = function() return getZoneDisplayName(442) end, shortname = "dragonscale"},
            {id = 451, name = function() return getZoneDisplayName(451) end, shortname = "dragonscaleb"},
            {id = 436, name = function() return getZoneDisplayName(436) end, shortname = "mechanotus"},
            {id = 441, name = function() return getZoneDisplayName(441) end, shortname = "gyrospirez"},
            {id = 440, name = function() return getZoneDisplayName(440) end, shortname = "gyrospireb"},
            {id = 444, name = function() return getZoneDisplayName(444) end, shortname = "hillsofshade"},
            {id = 443, name = function() return getZoneDisplayName(443) end, shortname = "lopingplains"},
            {id = 437, name = function() return getZoneDisplayName(437) end, shortname = "mansion"},
            {id = 439, name = function() return getZoneDisplayName(439) end, shortname = "shipworkshop"},
            {id = 438, name = function() return getZoneDisplayName(438) end, shortname = "steamfactory"},
            {id = 447, name = function() return getZoneDisplayName(447) end, shortname = "guardian"},
        },
        ["TBS"] = {
            {id = 422, name = function() return getZoneDisplayName(422) end, shortname = "barren"},
            {id = 428, name = function() return getZoneDisplayName(428) end, shortname = "blacksail"},
            {id = 427, name = function() return getZoneDisplayName(427) end, shortname = "deadbone"},
            {id = 424, name = function() return getZoneDisplayName(424) end, shortname = "jardelshook"},
            {id = 418, name = function() return getZoneDisplayName(418) end, shortname = "atiiki"},
            {id = 416, name = function() return getZoneDisplayName(416) end, shortname = "kattacastrum"},
            {id = 429, name = function() return getZoneDisplayName(429) end, shortname = "maidensgrave"},
            {id = 425, name = function() return getZoneDisplayName(425) end, shortname = "monkeyrock"},
            {id = 430, name = function() return getZoneDisplayName(430) end, shortname = "redfeather"},
            {id = 420, name = function() return getZoneDisplayName(420) end, shortname = "silyssar"},
            {id = 421, name = function() return getZoneDisplayName(421) end, shortname = "solteris"},
            {id = 426, name = function() return getZoneDisplayName(426) end, shortname = "suncrest"},
            {id = 417, name = function() return getZoneDisplayName(417) end, shortname = "thalassius"},
            {id = 423, name = function() return getZoneDisplayName(423) end, shortname = "buriedsea"},
            {id = 419, name = function() return getZoneDisplayName(419) end, shortname = "zhisza"},
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
            {id = 202, name = function() return getZoneDisplayName(202) end, shortname = "poknowledge"},
            {id = 752, name = function() return getZoneDisplayName(752) end, shortname = "chambersb"},
        }
    }

    -- Expansion display order
    local combo_items = { "SoR","ToB", "LS", "NoS", "ToL", "CoV", "ToV", "TBL", "RoS", "EoK", "TBM", "TDS", "CoTF", "RoF", "VoA",
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
