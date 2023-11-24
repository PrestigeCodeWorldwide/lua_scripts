-- Forward declarations for referenced types
global record userdata end

-- Declaration of the 'mq' global record
global record Mq
  TLO: TLO
  imgui: IMGUI
  configDir: string
  luaDir: string
  moduleDir: string
  cmd: function(...: {string})
  cmdf: function(command: string, ...: {any})
  delay: function(delayValue: number | string, condition: nil | function(): boolean)
  gettime: function(): number
  join: function(...: {string}): string
  exit: function()
  bind: function(command: string, callback: function())
  unbind: function(command: string)
  event: function(name: string, matcherText: string, callback: function())
  unevent: function(name: string)
  doevents: function(name: string | nil)
  flushevents: function(name: string|nil)
  FindTextureAnimation: function(name: string): textureanimation
  getAllSpawns: function(): {spawn}
  getFilteredSpawns: function(predicate: function(spawn: spawn): boolean): {spawn}
  gettype: function(type: any): mqtype
  NumericLimits_Float: function(): number, number
end

global printf: function(format: string, ...: any): string

-- Primitives
global type MQBoolean = function(): boolean
global type MQInt = function(): integer
global type MQFloat = function(): number
global type MQString = function(): string

global enum BooleanString
   "TRUE"
   "FALSE"
end

global enum NoPetString
   "NO PET"
end

-- IMGUI record declaration
global record IMGUI
  init: function(name: string, render: function())
  exists: function(name: string): boolean
  destroy: function(name: string)
end

-- TLO record declaration
global record TLO
  Achievement: Achievement
  AdvLoot: AdvLoot
  AdvPath: AdvPath
  Alias: function(name: string): boolean
  AltAbility: altability
  Bandolier: function(name: string): bandolier
  Corpse: corpse | function(): corpse | nil
  Cursor: MQItem
  DisplayItem: function(): MQItem
  DoorTarget: MQSwitch
  DynamicZone: dynamiczone
  Event: any
  EverQuest: everquest
  Familiar: any
  Float: float
  FPS: userdata
  FrameLimiter: framelimiter | function(): string
  Friends: userdata
  GameTime: time
  Ground: ground | function(): Ground
  Group: group
  GroupLeader: any
  GroupLeaderName: any
  If: any
  Illusion: any
  Ini: any
  Int: any
  InvSlot: any
  Irc: any
  ItemTarget: ground
  LastSpawn: any
  LineOfSight: function(query: string): boolean
  Lua: Lua
  Macro: Macro
  MacroQuest: macroquest
  Math: MQmath
  Me: MQCharacter
  Menu: any
  Mercenary: mercenary
  Merchant: MQMerchant  
  Pet: pet
  PointMerchant: any
  Raid: raid
  Range: range
  Select: function(target: string, {string}): integer
  SelectedItem: item
  String: any
  SubDefined: any
  Switch: MQSwitch
  SwitchTarget: any
  Target: MQTarget
  Task: function(index: integer | nil): task | nil
  Time: time
  Type: function(type: string): mqtype
  Window: function(name: string): MQWindow

  Alert: function(): string
  Alert: function(id: integer): alert
  Bool: function()
  NearestSpawn: function(index: integer, filter: string): MQSpawn
  NearestSpawn: function(filter: string): MQSpawn
  FindItem: function(id: integer): MQItem
  FindItem: function(name: string): MQItem
  FindItemBank: function(id: integer): MQItem
  FindItemBank: function(name: string): MQItem
  FindItemCount: function(id: integer): MQInt
  FindItemCount: function(name: string): MQInt
  FindItemBankCount: function(id: integer): MQInt
  FindItemBankCount: function(name: string): MQInt
  Heading: function(degrees: integer): heading
  Heading: function(y: integer, x: integer): heading
  Heading: function(north: integer, west: integer): heading
  Plugin: function(index: integer): plugin
  Plugin: function(name: string): plugin
  Spawn: function(id: integer): MQSpawn
  Spawn: function(filter: string): MQSpawn
  GroundItemCount: function(filter: nil|string): integer
  Mount: function(index: integer|string): keyringitem
  
  SpawnCount: function(filter: string): MQInt
  Spell: function(id: integer): MQSpell
  Spell: function(name: string): MQSpell
  Skill: function(number: integer): skill
  Skill: function(name: string): skill
  
  Zone: MQZone | function(identifier: integer | string | nil): MQZone  
end

--TLO = {} as TLO


-- Cmd record definition
global record Cmd
  afk: function()
  alt: function()
  anon: function()
  autoinventory: function()
  cast: function()
  destroy: function()
  doability: function()
  echo: function()
  face: function()
  keypress: function()
  nav: function()
  removebuff: function()
  stand: function()
  target: function()
end

global record achievement
  Completed: MQBoolean
  Description: MQString
  Hidden: MQBoolean
  IconID: MQInt
  ID: MQInt
  Index: MQInt
  Locked: MQBoolean
  Name: MQString
  ObjectiveCount: MQInt
  Open: MQBoolean
  Points: MQInt
  State: MQString

  -- Function declarations
  Objective: function(description: string | integer): achievement -- Replace 'achievementobj' with the actual return type
  Link: function(name: string | nil): string
  CompletedTime: function(): number -- Replace 'time' with the actual return type
end

global record achievementcat
  ID: MQInt
  Name: MQString
  Description: MQString
  AchievementByIndex: function(index: integer): achievement
  AchievementCount: MQInt
  CategoryByIndex: function(index: integer): integer
  CategoryCount: MQInt
  Points: MQInt
  CompletedAchievements: MQInt
  TotalAchievements: MQInt
  ImageTextureName: MQString
  Index: MQInt

  Achievement: function(id_or_name: integer | string): achievement
  Category: function(id_or_name: integer | string): achievementcat
end

global record achievementobj
  ID: MQInt
  Description: MQString
  Count: MQInt
  RequiredCount: MQString
  Completed: MQBoolean
  Index: MQInt
end

global record advlootitem
  AlwaysGreed: MQBoolean
  AlwaysNeed: MQBoolean
  AutoRoll: MQBoolean
  Corpse: MQSpawn
  Greed: MQBoolean
  IconID: MQInt
  ID: MQInt
  Index: MQInt
  Name: MQString
  Need: MQBoolean
  Never: MQBoolean
  No: MQBoolean
  NoDrop: MQBoolean
  StackSize: MQInt
end

global record alert
  Size: MQInt
  List: function(index: integer): alertlist
end

global record alertlist
  AlertList: MQInt
  bAlert: MQBoolean
  bAura: MQBoolean
  bBanker: MQBoolean
  bBanner: MQBoolean
  bCampfire: MQBoolean
  bDps: MQBoolean
  bExactName: MQBoolean
  bFellowship: MQBoolean
  bGM: MQBoolean
  bGroup: MQBoolean
  bHealer: MQBoolean
  bKnight: MQBoolean
  bKnownLocation: MQBoolean
  bLFG: MQBoolean
  bLight: MQBoolean
  bLoS: MQBoolean
  bMerchant: MQBoolean
  bNamed: MQBoolean
  bNearAlert: MQBoolean
  bNoAlert: MQBoolean
  bNoGroup: MQBoolean
  bNoGuild: MQBoolean
  bNoPet: MQBoolean
  bNotNearAlert: MQBoolean
  BodyType: MQString
  bRaid: MQBoolean
  bSlower: MQBoolean
  bSpawnID: MQBoolean
  bTank: MQBoolean
  bTargetable: MQBoolean
  bTargNext: MQBoolean
  bTargPrev: MQBoolean
  bTrader: MQBoolean
  bTributeMaster: MQBoolean
  Class: MQString
  FRadius: MQInt
  FromSpawnID: MQInt
  GuildID: MQInt
  Light: MQString
  MaxLevel: MQInt
  MinLevel: MQInt
  Name: MQString
  NearAlertList: MQInt
  NoAlertList: MQInt
  NotID: MQInt
  NotNearAlertList: MQInt
  PlayerState: MQInt
  Race: MQString
  Radius: MQInt
  SortBy: MQInt
  Spawn: MQSpawn
  SpawnID: MQInt
  SpawnType: MQInt
  xLoc: MQInt
  yLoc: MQInt
  ZRadius: MQInt
end

global record altability
  AARankRequired: MQFloat
  CanTrain: MQBoolean
  Cost: MQFloat
  Description: MQString
  ID: MQInt
  Index: MQFloat
  MaxRank: MQFloat
  MinLevel: MQFloat
  MyReuseTime: MQFloat
  Name: MQString
  NextIndex: MQFloat
  PointsSpent: MQFloat
  Passive: MQBoolean
  RequiresAbility: MQAltAbility
  Rank: MQFloat
  RequiresAbilityPoints: MQFloat
  ReuseTime: MQFloat
  ShortName: MQString
  Spell: MQSpell
  Type: MQFloat
end

global record argb
  A: MQFloat
  R: MQFloat
  G: MQFloat
  B: MQFloat
  Int: MQInt
  ToString: MQString
end

global record array
  -- Deprecated fields
  Dimensions: integer -- Deprecated
  Size: integer -- Deprecated
  ToString: string -- Deprecated
end

global record augtype
  Empty: MQBoolean
  Infusable: MQBoolean
  Item: MQItem
  Name: MQString
  Slot: MQInt
  Solvent: MQInt
  Type: MQInt
  Visible: MQBoolean
end

global record auratype
  ID: MQInt
  Name: MQString
  SpawnID: MQInt
end

global record bandolier
  Active: MQBoolean
  Index: MQInt
  Item: function(index: integer): bandolieritem
  Name: MQString

  Activate: function()
end

global record bandolieritem
  IconID: MQInt
  ID: MQInt
  Name: MQString
end

global record body
  ID: integer
  Name: string
  ToString: string
end

global record bool
  ToString: MQString
end

global record buff -- Inherits from spell
  Counters: MQFloat
  Dar: MQFloat
  Duration: number
  ID: MQInt
  Level: MQFloat
  Mod: MQFloat
  Spell: MQSpell
  ToString: MQString
  Remove: function()
end

global record cachedbuff -- Inherits from spell
  CasterName: MQString
  Caster: MQString
  Count: MQInt
  Duration: integer
  OriginalDuration: MQInt
  Slot: MQInt
  Spell: MQSpell
  SpellID: MQInt
  Staleness: number | function(): number
end

global record character -- Inherits from spawn
  AAExp: MQFloat
  AAPoints: MQFloat
  AAPointsSpent: MQFloat
  AAPointsTotal: MQFloat
  AAVitality: MQFloat
  AccuracyBonus: MQFloat
  ActiveDisc: MQSpell
  ActiveFavorCost: MQFloat
  AltTimerReady: MQBoolean
  AGI: MQFloat
  AggroLock: MQSpawn
  AmIGroupLeader: MQBoolean
  AssistComplete: MQBoolean
  AttackBonus: MQFloat
  AttackSpeed: MQFloat
  AutoFire: MQBoolean
  AvoidanceBonus: MQFloat
  BardSongPlaying: MQBoolean
  BaseSTR: MQInt
  BaseSTA: MQInt
  BaseCHA: MQInt
  BaseDEX: MQInt
  BaseINT: MQInt
  BaseAGI: MQInt
  BaseWIS: MQInt
  BoundLocation: MQString
  Buyer: MQBoolean
  CanMount: MQBoolean
  CareerFavor: MQFloat
  Cash: MQFloat
  CashBank: MQFloat
  CHA: MQFloat
  Charmed: MQString
  Chronobines: MQFloat
  ClairvoyanceBonus: MQFloat
  Combat: MQBoolean
  CombatEffectsBonus: MQFloat
  CombatState: MQString
  Copper: MQFloat
  CopperBank: MQFloat
  Corrupted: MQSpell
  CountBuffs: MQFloat
  CountersCurse: MQFloat
  CountersDisease: MQFloat
  CountersPoison: MQFloat
  CountSongs: MQFloat
  Counters: MQFloat
  CurrentEndurance: MQFloat
  CurrentFavor: MQFloat
  CurrentHPs: MQFloat
  CurrentMana: MQFloat
  CurrentWeight: MQFloat
  Cursed: MQSpell
  DamageShieldBonus: MQFloat
  DamageShieldMitigationBonus: MQFloat
  Dar: MQFloat
  Diseased: MQString
  DEX: MQFloat
  Dotted: MQString
  DoTShieldBonus: MQFloat
  Doubloons: MQFloat
  Downtime: integer
  Drunk: MQFloat
  EbonCrystals: MQFloat
  EnduranceBonus: MQFloat
  EnduranceRegen: MQFloat
  EnduranceRegenBonus: MQFloat
  Exp: MQFloat
  ExpansionFlags: MQFloat
  Faycites: MQFloat
  Fellowship: MQFellowship
  FreeBuffSlots: MQFloat
  Gold: MQFloat
  GoldBank: MQFloat
  Grouped: MQBoolean
  GroupLeaderExp: MQFloat
  GroupLeaderPoints: MQFloat
  GroupList: MQString
  GroupSize: MQFloat
  GukEarned: MQFloat
  GuildID: MQFloat
  Haste: MQFloat
  HealAmountBonus: MQFloat
  HeroicAGIBonus: MQFloat
  HeroicCHABonus: MQFloat
  HeroicDEXBonus: MQFloat
  HeroicINTBonus: MQFloat
  HeroicSTABonus: MQFloat
  HeroicSTRBonus: MQFloat
  HeroicWISBonus: MQFloat
  HPBonus: MQFloat
  HPRegen: MQFloat
  HPRegenBonus: MQFloat
  Hunger: MQFloat
  ID: MQFloat
  InInstance: MQBoolean
  INT: MQFloat
  Invulnerable: MQString
  LADelegateMA: MQFloat
  LADelegateMarkNPC: MQFloat
  LAFindPathPC: MQFloat
  LAHealthEnhancement: MQFloat
  LAHealthRegen: MQFloat
  LAHoTT: MQFloat
  LAInspectBuffs: MQFloat
  LAManaEnhancement: MQFloat
  LAMarkNPC: MQFloat
  LANPCHealth: MQFloat
  LAOffenseEnhancement: MQFloat
  LASpellAwareness: MQFloat
  LargestFreeInventory: MQFloat
  LastZoned: number
  LDoNPoints: MQFloat
  Level: MQFloat
  ManaBonus: MQFloat
  ManaRegen: MQFloat
  ManaRegenBonus: MQFloat
  MaxBuffSlots: MQFloat
  MaxEndurance: MQFloat
  MaxHPs: MQFloat
 MaxMana: MQFloat
  Mercenary: MQMercenary
  MercenaryStance: MQString
  Mezzed: MQString
  MirEarned: MQFloat
  MMEarned: MQFloat
  Moving: MQBoolean
  Name: MQString
  NumGems: MQFloat
  NumBagSlots: MQInt
  Orux: MQFloat
  PctAAExp: MQFloat
  PctAAVitality: MQFloat
  PctAggro: MQFloat
  PctEndurance: MQFloat
  PctExp: MQFloat
  PctGroupLeaderExp: MQFloat
  PctHPs: MQFloat
  PctMana: MQFloat
  PctRaidLeaderExp: MQFloat
  PctVitality: MQFloat
  Phosphenes: MQFloat
  Phosphites: MQFloat
  Platinum: MQFloat
  PlatinumBank: MQFloat
  PlatinumShared: MQFloat
  Poisoned: MQString
  RadiantCrystals: MQFloat
  RaidLeaderExp: MQFloat
  RaidLeaderPoints: MQFloat
  RangedReady: MQBoolean
  RujEarned: MQFloat
  Running: MQBoolean
  SecondaryPctAggro: MQFloat
  SecondaryAggroPlayer: MQSpawn
  ShieldingBonus: MQFloat
  Shrouded: MQBoolean
  Silenced: MQBuff
  Silver: MQFloat
  SilverBank: MQFloat
  Sit: function()
  Spawn: spawn
  SpellInCooldown: MQBoolean
  SpellDamageBonus: MQFloat
  SpellRankCap: MQFloat
  SpellShieldBonus: MQFloat
  STA: MQFloat
  Stand: function()
  StopCast: function()
  STR: MQFloat
  StrikeThroughBonus: MQFloat
  Stunned: MQBoolean
  StunResistBonus: MQFloat
  Subscription: MQString
  SubscriptionDays: MQFloat
  Surname: MQString
  svChromatic: MQFloat
  svCold: MQFloat
  svCorruption: MQFloat
  svDisease: MQFloat
  svFire: MQFloat
  svMagic: MQFloat
  svPoison: MQFloat
  svPrismatic: MQFloat
  TakEarned: MQFloat
  TargetOfTarget: MQTarget
  Thirst: MQFloat
  Trader: MQBoolean
  TributeActive: MQBoolean
  TributeTimer: integer
  UseAdvancedLooting: MQBoolean
  WIS: MQFloat
  Vitality: MQFloat
  ZoneBound: MQZone
  ZoneBoundX: function(): integer
  ZoneBoundY: function(): integer
  ZoneBoundZ: function(): integer
end

global record character
  Ability: function(name_or_index: string | integer): integer | string
  
  AbilityReady: function(name_or_index: string | integer): MQBoolean
  AltAbility: function(name_or_index: string | integer): altability
  AltAbilityReady: function(name_or_index: string | integer): MQBoolean
  AltAbilityTimer: function(name_or_index: string | integer): integer
  AltCurrency: function(name: string): integer
  Aura: function(name_or_index: string | integer): MQSpell
  Bank: function(slot: integer): MQItem
  Book: function(name_or_slot: string | integer): integer | spell
  BoundLocation: function(bindPointIndex: integer): worldlocation
  Buff: function(name_or_slotNumber: string | integer): MQBuff
  CombatAbility: function(name_or_index: string | integer): integer | MQSpell
  CombatAbilityReady: function(name_or_index: string | integer): boolean
  CombatAbilityTimer: function(name_or_index: string | integer): integer
  FreeInventory: function(minSize: integer | nil): integer
  Gem: function(name_or_gemSlot: string | integer): integer | MQSpell
  GemTimer: function(name_or_gemSlot: string | integer): ticks
  GroupMarkNPC: function(index: integer): spawn
  HaveExpansion: function(expansionNumber: integer): boolean
   Inventory: function(name_or_slotNumber: string | integer): MQItem
  ItemReady: function(name: string): MQBoolean
  Language: function(name_or_languageNumber: string | integer): integer | string
  LanguageSkill: function(language: integer): integer
  PetBuff: function(name_or_slotNumber: string | integer): MQBuff
  GroupAssistTarget: function(): spawn
  RaidAssistTarget: function(index: integer): spawn
  RaidMarkNPC: function(index: integer): spawn
  Skill: function(name_or_skillId: string | integer): integer
  SkillCap: function(name_or_skillId: string | integer): integer
  Song: function(name_or_slotNumber: string | integer): MQBuff
  SpellReady: function(name_or_slotNumber: string | integer): MQBoolean
  XTAggroCount: function(n: integer | nil): integer
  XTarget: function(): integer
  XTarget: function(index: integer): xtarget
end

global record class
  CanCast: MQBoolean
  ClericType: MQBoolean
  DruidType: MQBoolean
  HealerType: MQBoolean
  ID: MQInt
  MercType: MQBoolean
  Name: MQString
  NecromancerType: MQBoolean
  PureCaster: MQBoolean
  ShamanType: MQBoolean
  ShortName: MQString
end

global record corpse -- Inherits from spawn
  Items: MQFloat
  Open: MQBoolean

  Item: function(name_or_index: string | integer): MQItem
end

global record currentzone
  Dungeon: boolean
  Gravity: MQFloat
  ID: number
  Indoor: boolean
  MaxClip: MQFloat
  MinClip: MQFloat
  Name: string
  NoBind: boolean
  Outdoor: boolean
  ShortName: string
  SkyType: number
  Type: number
  FOgOnOff: number
  ToString: string
end

global record deity
  ID: number
  Name: string
  Team: string
  ToString: string
end

global record dynamiczone
  InRaid: function(): boolean
  Leader: function(): dzmember
  LeaderFlagged: MQBoolean
  MaxMembers: MQInt
  Members: MQInt
  MinMembers: MQInt
  Name: MQString
  
  Member: function(id_or_name: string | integer): dzmember
  Timer: function(id_or_name: string | integer): dztimer
end

global record dzmember
  Flagged: boolean
  Name: string
  Status: string
  ToString: string
end

global record dztimer
  ExpeditionName: MQString
  EventName: MQString
  Timer: function(): timestamp
  EventID: MQInt
end

global record event
  List: string
  Triggered: integer
  ToString: string
end

global record everquest
  GameState: MQString
  LoginName: MQString
  Server: MQString
  LastCommand: MQString
  LastTell: MQString
  Running: MQInt
  MouseX: MQInt
  MouseY: MQInt
  Ping: MQInt
  LClickedObject: MQBoolean
  WinTitle: MQString
  PID: MQInt
  PPriority: MQInt
  ChatChannels: MQInt
  ChatChannel: function(channel: integer): string
  ViewportX: MQInt
  ViewportY: MQInt
  ViewportXMax: MQInt
  ViewportYMax: MQInt
  ViewportXCenter: MQInt
  ViewportYCenter: MQInt
  ScreenMode: MQInt
  LayoutCopyInProgress: MQBoolean
  LastMouseOver: function(): window
  CharSelectList: MQInt
  CurrentUI: MQString
  IsDefaultUILoaded: MQBoolean
  HWND: MQInt
  Foreground: MQBoolean
  ValidLoc: function(coordinates: string): boolean
  Path: MQString
end

global record evolving
  ExpPct: MQFloat
  ExpOn: MQBoolean
  Level: MQInt
  MaxLevel: MQInt
  ToString: MQString
end

global record fellowship
  Campfire: MQBoolean
  CampfireDuration: ticks | function(): ticks
  CampfireX: MQFloat
  CampfireY: MQFloat
  CampfireZ: MQFloat
  CampfireZone: MQZone
  ID: MQInt
  Leader: MQString
  Member: function(): fellowshipmember
  Members: MQInt
  MotD: MQString
  ToString: MQString
end

global record fellowshipmember
  Class: function(): class
  Level: MQInt
  LastOn: function(): ticks
  Name: MQString
  Zone: MQZone
  ToString: MQString
end

global record float
  Deci: string
  Centi: string
  Int: number
  Milli: string
  Precision: string
  ToString: string
end

global record framelimiter
  BackgroundFPS: MQFloat
  ClearScreen: MQBoolean
  CPU: MQFloat
  Enabled: MQBoolean
  ForegroundFPS: MQFloat
  MinSimulationFPS: MQFloat
  RenderFPS: MQFloat
  SaveByChar: MQBoolean
  SimulationFPS: MQFloat
  Status: MQString
end

global record friends
  ToString: MQString

  Friend: function(name_or_index: string | integer): boolean | string
end

global record ground
  ID: MQInt
  Distance: MQFloat
  X: MQFloat
  Y: MQFloat
  Z: MQFloat
  Heading: MQHeading
  Name: MQString
  HeadingTo: MQHeading
  LineOfSight: MQBoolean
  DisplayName: MQFloat
  Distance3D: MQFloat
  SubID: MQInt
  ZoneID: MQInt
  First: MQGround
  Last: MQGround
  Next: MQGround
  Prev: MQGround
  DoFace: function()
  DoTarget: function()
  Grab: function()
  W: MQFloat
  N: MQFloat
  U: MQFloat
  ToString: MQString
end

global record group
  AnyoneMissing: MQBoolean
  CasterMercCount: MQFloat
  Cleric: MQString
  GroupSize: MQFloat
  HealerMercCount: MQFloat
  Injured: function(amount: integer): MQInt
  Leader: MQGroupMember
  LowMana: function(amount: integer): MQInt
  MainAssist: MQGroupMember
  MainTank: MQGroupMember
  MarkNpc: MQGroupMember
  MasterLooter: MQGroupMember
  MeleeMercCount: MQFloat
  Members: MQFloat
  MercenaryCount: MQFloat
  MouseOver: MQString
  Offline: MQBoolean
  OtherZone: MQBoolean
  Puller: MQGroupMember
  TankMercCount: MQFloat
  ToString: MQString

  Member: function(index_or_name: string | integer): MQGroupMember
end

global record groupmember -- Inherits from spawn
  Index: MQFloat
  Leader: MQBoolean
  Level: MQFloat
  MainAssist: MQBoolean
  MainTank: MQBoolean
  Mercenary: MQBoolean
  Name: MQString
  Offline: MQBoolean
  OtherZone: MQBoolean
  Present: MQBoolean
  Puller: MQBoolean
  Spawn: spawn
  ToString: MQString
end

global record heading
  Clock: MQFloat
  Degrees: MQFloat
  DegreesCCW: MQFloat
  Name: MQString
  ShortName: MQString
end

global record int
  Float: MQFloat
  Hex: string
  Reverse: number
  ToString: string
end

global record invslot
  ID: MQInt
  Item: MQItem
  Name: MQString
  Pack: MQInvSlot
  Slot: MQInt
  ToString: MQString
end

global record item
  AC: MQFloat
  AGI: MQFloat
  Accuracy: MQFloat
  Attack: MQFloat
  Attuneable: MQBoolean
  AugRestrictions: MQFloat
  Augs: MQFloat
  AugSlot: function(slot: integer): augtype
  AugSlot1: MQFloat
  AugSlot2: MQFloat
  AugSlot3: MQFloat
  AugSlot4: MQFloat
  AugSlot5: MQFloat
  AugType: MQFloat
  Avoidance: MQFloat
  BuyPrice: MQFloat
  CastTime: MQFloat
  CHA: MQFloat
  Charges: MQFloat
  Clairvoyance: MQFloat
  Class: MQString
  Classes: MQFloat
  Clicky: itemspell
  CombatEffects: MQFloat
  Container: MQFloat
  DamageShieldMitigation: MQFloat
  DamShield: MQFloat
  Deity: MQString
  Deities: MQFloat
  DEX: MQFloat
  DMGBonusType: MQString
  DoTShielding: MQFloat
  EffectType: MQString
  Endurance: MQFloat
  EnduranceRegen: MQFloat
  Evolving: evolving
  FreeStack: MQFloat
  Haste: MQFloat
  HealAmount: MQFloat
  HeroicAGI: MQFloat
  HeroicCHA: MQFloat
  HeroicDEX: MQFloat
  HeroicINT: MQFloat
  HeroicSTA: MQFloat
  HeroicSTR: MQFloat
  HeroicSvCold: MQFloat
  HeroicSvCorruption: MQFloat
  HeroicSvDisease: MQFloat
  HeroicSvFire: MQFloat
  HeroicSvMagic: MQFloat
  HeroicSvPoison: MQFloat
  HeroicWIS: MQFloat
  HP: MQFloat
  HPRegen: MQFloat
  Icon: MQFloat
  ID: MQFloat
  InstrumentMod: MQFloat
  INT: MQFloat
  InvSlot: MQFloat
  Item: item
  ItemDelay: MQFloat
  ItemLink: function(clickable: string|nil): MQString
  Items: MQFloat
  ItemSlot: MQFloat
  ItemSlot2: MQFloat
  Inspect: function()
  LDoNTheme: MQString
  Lore: MQBoolean
  Magic: MQBoolean
  Mana: MQFloat
  ManaRegen: MQFloat
  MaxPower: MQFloat
  MerchQuantity: MQFloat
  Name: MQString
  NoDrop: MQBoolean
  NoRent: MQBoolean
  Power: MQFloat
  Purity: MQFloat
  Race: MQString
  Races: MQFloat
  RequiredLevel: MQFloat
  SellPrice: MQFloat
  Shielding: MQFloat
  Size: MQFloat
  SizeCapacity: MQFloat
  Spell: MQSpell
  SpellDamage: MQFloat
  SpellShield: MQFloat
  STA: MQFloat
  Stack: MQFloat
  Stacks: MQFloat
  Stackable: MQBoolean
  StackCount: MQFloat
  StackSize: MQFloat
  STR: MQFloat
  StrikeThrough: MQFloat
  StunResist: MQFloat
  svCold: MQFloat
  svCorruption: MQFloat
  svDisease: MQFloat
  svFire: MQFloat
  svMagic: MQFloat
  svPoison: MQFloat
  Timer: ticks
  TimerReady: MQFloat
  Tradeskills: MQBoolean
  Type: MQString
  Tribute: MQFloat
  Value: MQFloat
  Weight: MQFloat
  WIS: MQFloat
  Worn: itemspell | function(): itemspell
  WornSlot: invslot | MQBoolean
  WornSlots: MQFloat
  ToString: MQString
end

global record itemfilterdata
  AutoRoll: function(): boolean
  Greed: function(): boolean
  IconID: MQInt
  ID: MQInt
  Name: function(): string
  Need: function(): boolean
  Never: function(): boolean
  Types: MQInt
end

global record itemspell
  CastTime: timestamp
  EffectiveCasterLevel: MQInt
  EffectType: MQInt
  MaxCharges: MQInt
  OverrideDescription: MQString
  OverrideName: MQString
  ProcRate: MQInt
  RecastType: MQInt
  RequiredLevel: MQInt
  Spell: MQSpell
  SpellID: MQInt
  TimerID: MQInt
end

global record keyring
  Count: MQInt
  Stat: function(): keyringitem
end

global record keyringitem
  Index: MQInt
  Item: MQItem
  Name: MQString
end

global record LuaInfo
  PID: MQInt
  Name: MQString
  Path: MQString
  Arguments: MQString
  StartTime: MQString
  EndTime: MQString
  ReturnCount: MQInt
  Return: function(index: integer): string
  Status: MQString
end

global record Lua
  PIDs: MQString
  Dir: MQString
  Turbo: MQInt
  RequirePaths: MQString
  CRequirePaths: MQString
  Script: function(pid: integer): LuaInfo
end

global record Macro
  CurCommand: MQString
  CurLine: MQFloat
  CurSub: MQString
  isOuterVariable: MQBoolean
  isTLO: MQBoolean
  MemUse: MQFloat
  Name: MQString
  Params: MQFloat
  Paused: MQBoolean
  Return: MQString
  RunTime: MQFloat
  StackSize: MQFloat
  Undeclared: function()
  Variable: function(name: string): int | boolean | function(): any
end

global record macroquest
  BuildDate: MQString
  BuildName: MQString
  ChatChannel: MQBoolean
  ChatChannels: MQFloat
  Error: MQString
  GameState: MQString
  LastCommand: MQString
  LastTell: MQString
  LClickedObject: MQBoolean
  LoginName: MQString
  MouseX: MQFloat
  MouseY: MQFloat
  MQ2DataError: MQString
  Path: function(relativePath: (nil | string)): string
  Ping: MQFloat
  Running: MQFloat
  Server: MQString
  SyntaxError: MQString
  ViewportX: MQFloat
  ViewportXCenter: MQFloat
  ViewportXMax: MQFloat
  ViewportY: MQFloat
  ViewportYCenter: MQFloat
  ViewportYMax: MQFloat
  ToString: MQString
end

global record MQmath
  Abs: function(number: number): MQFloat
  Acos: function(degrees: number): MQFloat
  Asin: function(degrees: number): MQFloat
  Atan: function(degrees: number): MQFloat
  Cos: function(degrees: number): MQFloat
  Dec: number
  Hex: string
  Not: number
  Rand: number
  Sin: function(degrees: number): MQFloat
  Sqrt: MQFloat
  Tan: function(degrees: number): MQFloat
  ToString: string

  Distance: function(coordinates: string): MQFloat
  Calc: function(expression: string): MQFloat
end

global record mercenary
  AAPoints: MQInt
  Stance: MQString
  State: MQString
  StateID: MQInt
  Index: MQString
  ToString: MQString
end

global record merchant
  Buy: function(num_of_items: integer)
  Full: MQBoolean
  Item: MQItem
  Items: MQFloat
  ItemsReceived: MQBoolean
  Markup: MQFloat
  Open: MQBoolean
  OpenWindow: function()
  SelectedItem: MQItem
  SelectItem: function(item: string)
  Sell: function(num_of_items: integer)
  ToString: MQBoolean
end

global record pet 
  Combat: MQBoolean
  Ghold: MQBoolean
  Hold: MQBoolean
  ReGroup: MQBoolean
  Stance: MQString
  Stop: MQBoolean
  Target: MQSpawn
  Taunt: MQBoolean
  Focus: MQBoolean
  ID: MQInt
  Buff: function(buffname_or_slotnumber: string | integer): integer | string
  BuffDuration: function(buffname_or_slotnumber: string | integer): integer
end

global record plugin
  Name: MQString
  Version: MQFloat
  IsLoaded: MQBoolean
  ToString: MQString
end

global record race
  ID: MQInt
  Name: MQString
  ToString: MQString
end

global record raid
  AverageLevel: MQInt
  Invited: MQBoolean
  Leader: MQRaidMember
  Locked: MQBoolean
  
  Looter: function(): MQInt
  LootType: MQInt
  MasterLooter: MQRaidMember
  Members: MQInt
  Target: MQRaidMember
  TotalLevels: MQInt
  ToString: MQString
  Member: function(name_or_index: string | integer): raidmember  
  MainAssist: function(index: integer): raidmember
end

global record raidmember
  Class: class
  Group: number
  GroupLeader: boolean
  Level: number
  Looter: boolean
  Name: string
  RaidLeader: boolean
  Spawn: MQSpawn
  ToString: string
end

global record range
  Between: function(n: integer, range: string): boolean
  Inside: function(n: integer, range: string): boolean
end

global record skill
  Activated: MQBoolean
  AltTimer: MQBoolean
  ID: MQInt
  MinLevel: MQInt
  Name: MQString
  ReuseTime: MQFloat
  SkillCap: MQInt
  StartingSkill: MQInt
  ToString: MQString
end

global record spawn
  AARank: MQFloat
  AATitle: MQString
  ActorDef: MQString
  Address: MQFloat
  AFK: MQBoolean
  Aggressive: MQBoolean
  Animation: MQFloat
  Anonymous: MQBoolean
  Assist: MQBoolean
  AssistName: MQString
  bAlwaysShowAura: MQBoolean
  bBetaBuffed: MQBoolean
  Binding: MQBoolean
  Blind: MQFloat
  Body: body
  bShowHelm: MQBoolean
  bStationary: MQBoolean
  bTempPet: MQBoolean
  Buyer: MQBoolean
  bWaitingForPort: MQBoolean
  CachedBuffCount: MQFloat
  CanSplashLand: MQBoolean
  Casting: MQSpell
  CeilingHeightAtCurrLocation: MQFloat
  Class: class
  CleanName: MQString
  CollisionCounter: MQInt
  CombatSkillTicks: any
  ConColor: MQString
  ContractorID: MQInt
  CorpseDragCount: MQInt
  CurrentEndurance: MQFloat
  CurrentHPs: MQFloat
  CurrentMana: MQFloat
  Dead: MQBoolean
  Deity: deity
  DisplayName: MQString
  Distance: MQFloat
  Distance3D: MQFloat
  DistanceN: MQFloat
  DistancePredict: MQFloat
  DistanceU: MQFloat
  DistanceW: MQFloat
  DistanceX: MQFloat
  DistanceY: MQFloat
  DistanceZ: MQFloat
  DraggingPlayer: MQBoolean
  DragNames: MQString
  DoAssist: function()
  DoFace: function()
  DoTarget: function()
  Ducking: MQBoolean
  Equipment: function(slot_or_name: integer | string): MQFloat
  EQLoc: MQString
  FD: function(): number
  FeetWet: MQBoolean
  Feigning: MQBoolean
  Following: MQSpawn
  Fleeing: MQBoolean
  FloorZ: MQFloat
  Gender: MQString
  GM: MQBoolean
  GMRank: MQFloat
  GroupLeader: MQBoolean
  Guild: MQString
  GuildStatus: MQString
  Heading: heading
  HeadingTo: heading
  HeadingToLoc: heading
  Height: MQFloat
  Holding: MQFloat
  HoldingAnimation: MQInt
  Hovering: MQBoolean
  ID: MQFloat
  InPvPArea: function(): number
  Invis: function(option: string | integer | nil): MQBoolean -- Options: ANY/0 NORMAL/1 UNDEAD/2 ANIMAL/3 SOS/4
  Invited: MQBoolean
  Inviter: MQString
  IsBerserk: MQBoolean
  IsPassenger: MQBoolean
  IsSummoned: MQBoolean
  LastCastNum: MQFloat
  LastCastTime: MQFloat
  Level: MQFloat
  DoLeftClick: function()
  Levitating: MQBoolean
  LFG: MQBoolean
  Light: MQString
  LineOfSight: MQBoolean
  Linkdead: MQBoolean
  Loc: MQString
  LocYX: MQString
  LocYXZ: MQString
  Look: MQFloat
  Mark: MQFloat
  Master: MQSpawn
  MaxEndurance: MQFloat
  MaxHPs: MQFloat
  MaxMana: MQFloat
  MaxRange: MQFloat
  MaxRangeTo: MQFloat
  MercID: MQInt
  Mount: MQSpawn
  Moving: MQBoolean
  MQLoc: MQString
  Name: MQString
  Named: MQBoolean
  NearestSpawn: MQSpawn
  Next: MQSpawn
  Owner: MQSpawn
  Prev: MQSpawn
  Pet: MQPet
  PctHPs: MQFloat
  PlayerState: MQFloat
  Primary: MQFloat
  pTouchingSwitch: MQFloat
  Race: race
  Roleplaying: MQBoolean
  Secondary: MQFloat
  SeeInvis: MQFloat
  Sitting: MQBoolean
  Sneaking: MQBoolean
  SpawnStatus: MQFloat
  Speed: MQFloat
  Standing: MQBoolean
  StandState: MQFloat
  State: MQString
  Stunned: MQBoolean
  Stuck: MQBoolean
  Suffix: MQString
  Surname: MQString
  Targetable: MQBoolean
  TargetOfTarget: MQTarget
  TimeBeenDead: MQFloat
  Title: MQString
  Trader: MQBoolean
  Type: MQString
  Underwater: MQBoolean
  X: MQFloat
  Y: MQFloat
  Z: MQFloat
  N: MQFloat
  W: MQFloat
  U: MQFloat
  E: MQFloat
  S: MQFloat
  D: MQFloat
  FindBuff: function(predicate: string): MQSpell
  Aggresive: MQBoolean
end

global record spell
  AERange: MQFloat
  CastOnAnother: MQString
  CastOnYou: MQString
  CastTime: timestamp
  Category: MQString
  CategoryID: MQInt
  CounterType: MQString
  CounterNumber: MQInt
  Duration: ticks
  DurationValue1: ticks
  FizzleTime: timestamp
  GemIcon: MQInt
  HastePct: MQFloat
  ID: MQInt
  IsSkill: MQBoolean
  IsSwarmSpell: MQBoolean
  Level: MQInt
  Location: MQFloat
  Mana: MQInt
  EnduranceCost: MQInt
  MyCastTime: timestamp
  MyRange: MQFloat
  Name: MQString
  NumEffects: MQInt
  PushBack: MQFloat
  Range: MQFloat
  Rank: MQInt
  RankName: MQString
  RecastTime: MQFloat
  RecoveryTime: timestamp
  ResistAdj: MQInt
  ResistType: MQString
  Skill: MQString
  SlowPct: MQFloat
  SpellIcon: MQInt
  SpellType: MQString
  Beneficial: MQBoolean
  Stacks: MQBoolean
  StacksSpawn: function(id: integer): MQBoolean
  StacksPet: MQBoolean
  StacksTarget: MQBoolean
  StacksWith: MQBoolean
  StacksWithDiscs: MQBoolean
  Subcategory: MQString
  SubcategoryID: MQInt
  NewStacks: MQBoolean
  TargetType: MQString
  WearOff: MQString
  ToString: MQString
  WillStack: function(name: string): boolean
  ReagentCount: function(index: integer): MQInt
  ReagentID: function(index: integer): MQInt
  Attrib: function(index: integer): integer
  Trigger: function(index: integer): MQSpell
  Base: function(index: integer): integer
  Base2: function(index: integer): integer
  Max: function(index: integer): integer
  HasSPA: function(spa: integer): MQBoolean
end

global record switch
  D: MQFloat
  DefaultHeading: heading
  DefaultN: MQFloat
  DefaultU: MQFloat
  DefaultW: MQFloat
  DefaultX: MQFloat
  DefaultY: MQFloat
  DefaultZ: MQFloat
  Distance: MQFloat
  Heading: heading
  HeadingTo: heading
  ID: number
  LineOfSight: boolean
  N: MQFloat
  Name: string
  Open: boolean
  ToString: string
  W: MQFloat
  X: MQFloat
  Y: MQFloat
  Z: MQFloat
end

global record target
  Aego: MQCachedBuff
  AggroHolder: MQSpawn
  Beneficial: MQCachedBuff
  BuffDuration: timestamp | function(val: string | integer): timestamp
  BuffsPopulated: MQBoolean
  Brells: MQString
  Charmed: MQCachedBuff
  Clarity: MQCachedBuff
  Corrupted: MQCachedBuff
  Cursed: MQCachedBuff
  Crippled: MQCachedBuff
  Diseased: MQCachedBuff
  Dotted: MQCachedBuff
  DSed: MQCachedBuff
  Focus: MQCachedBuff
  Growth: MQCachedBuff
  Hasted: MQCachedBuff
  HybridHP: MQCachedBuff
  Maloed: MQCachedBuff
  Mezzed: MQCachedBuff
  Poisoned: MQCachedBuff
  Pred: MQCachedBuff
  Rooted: MQCachedBuff
  Regen: MQCachedBuff
  RevDSed: MQCachedBuff
  SE: MQCachedBuff
  Shining: MQCachedBuff
  Skin: MQCachedBuff
  Slowed: MQCachedBuff
  Snared: MQCachedBuff
  Strength: MQCachedBuff
  SV: MQCachedBuff
  Symbol: MQCachedBuff
  Tashed: MQCachedBuff
  ToString: MQString
end

-- Define 'Objective' as a separate record if not already defined
global record TaskObjective
  Instruction: string
  Status: string
  Zone: string
end

-- 'task' record with the 'Objective' field as a type
global record task
  Index: MQString
  Objective: TaskObjective
  CurrentCount: number
  RequiredCount: number
  Optional: boolean
  RequiredItem: string
  RequiredSkill: string
  RequiredSpell: string
  DZSwitchID: number
  ID: number
  Step: string
  Select: string
  Title: string
  Timer: ticks
  Members: number
  Member: function(index_or_name: string | integer): taskmember
  Leader: string
  WindowIndex: number
  Type: string
end

global record taskmember
  Name: MQString
  Leader: MQBoolean
  Index: MQInt
end

global record textureanimation
  SetTextureCell: function(self: textureanimation, id: integer)
end

global record ticks
  Hours: MQInt
  Minutes: MQInt
  Seconds: MQInt
  TotalMinutes: MQInt
  TotalSeconds: MQInt
  Ticks: MQInt
  Time: MQString
  TimeHMS: MQString
  ToString: MQString
end

global record time
  Date: MQString
  Day: MQInt
  DayOfWeek: MQInt
  Hour: MQInt
  Minute: MQInt
  Month: MQInt
  Night: MQBoolean
  Second: MQInt
  SecondsSinceMidnight: MQFloat
  Time12: MQString
  Time24: MQString
  Year: MQInt
  ToString: MQString
end

global record timer
  OriginalValue: MQInt
  Value: MQInt
  ToString: MQString
end

global record timestamp
  Hours: MQInt
  Minutes: MQInt
  Seconds: MQInt
  TimeHMS: MQString
  Time: MQString
  TotalMinutes: MQInt
  TotalSeconds: MQInt
  Raw: MQFloat
  Float: MQFloat
  Ticks: MQInt
  ToString: MQString
end

global record mqtype
  Name: MQString
  ToString: MQString
  Member: function(id_or_name: integer | string): string | integer
end

global record window
  BGColor: argb
  Checked: MQBoolean
  Children: MQBoolean
  Enabled: MQBoolean
  FirstChild: MQWindow
  GetCurSel: function(): integer
  Height: MQFloat
  Highlighted: MQBoolean
  HisTradeReady: MQBoolean
  HScrollMax: MQFloat
  HScrollPos: MQFloat
  HScrollPct: MQFloat
  Items: MQFloat
  Minimized: MQBoolean
  MouseOver: MQBoolean
  MyTradeReady: MQBoolean
  Name: MQString
  Next: MQWindow
  Open: MQBoolean
  Parent: MQWindow
  ScreenID: MQString
  Siblings: MQBoolean
  Style: MQFloat
  Text: MQString
  Tooltip: MQString
  Type: MQString
  VScrollMax: MQFloat
  VScrollPct: MQFloat
  VScrollPos: MQFloat
  Width: MQFloat
  X: MQFloat
  Y: MQFloat
  ToString: MQBoolean

  Child: function(name: string): MQWindow
  DoClose: function()
  DoOpen: function()
  LeftMouseDown: function()
  LeftMouseHeld: function()
  LeftMouseHeldUp: function()
  LeftMouseUp: function()
  RightMouseDown: function()
  RightMouseHeld: function()
  RightMouseHeldUp: function()
  RightMouseUp: function()
  Select: function()

  -- Overloaded List function
  List: function(nthItem_or_text: integer | string, column: integer | nil): string | integer
end

global record worldlocation
  ID: MQInt
  Heading: MQFloat
  Zone: MQZone
  X: MQFloat
  Y: MQFloat
  Z: MQFloat
end

global record xtarget 
  ID: MQInt
  Name: MQString
  PctAggro: MQFloat
  TargetType: MQString
  ToString: MQString
end


global record zone
  ID: MQInt
  Name: MQString
  ShortName: MQString
  ToString: MQString
end


-- Userdata
global type MQAltAbility = altability | function(): string | nil
global type MQBuff = buff | function(): string | nil
global type MQCachedBuff = cachedbuff | function(): string | nil
global type MQCharacter = character | function(): string | nil
global type MQFellowship = fellowship | function(): BooleanString
global type MQGround = ground | function(): string | nil
global type MQGroupMember = groupmember | function(): string | nil
global type MQHeading = heading | function(): string | nil
global type MQInvSlot = invslot | function(): string | nil
global type MQItem = item | function(): string | nil
global type MQMerchant = merchant | function(): string | nil
global type MQMercenary = mercenary | function(): string | nil
global type MQPet = pet | function(): string | nil
global type MQRaidMember = raidmember | function(): string | nil
global type MQSpawn = spawn | function(): string | nil
global type MQSpell = spell | function(): string | nil
global type MQSwitch = switch | function(): string | nil
global type MQTarget = target | function(): string | nil
global type MQWindow = window | function(): BooleanString
global type MQZone = zone | function(): string | nil

global record Achievement
  -- As a class instance
  class: AchievementClass
  -- As an achievement manager type
  manager: achievementmgr
  -- Function to find an achievement by name
  findByName: function(name: string): Achievement
  -- Function to find an achievement by ID
  findById: function(id: integer): Achievement
end
global record achievementmgr
  -- Assuming specific properties or methods for 'achievementmgr'
end

global record AchievementClass
  -- Assuming specific properties or methods for the 'Achievement' class
end

TLO.Achievement = {} as Achievement

global record AdvLoot
  Filter: function(itemId: integer): itemfilterdata
  LootInProgress: function(): boolean
  PCount: MQInt
  PList: function(index: integer): advlootitem
  PWantCount: MQInt
  SCount: MQInt
  SList: function(index: integer): advlootitem
  SWantCount: MQInt
end
TLO.AdvLoot = {} as AdvLoot

global record AdvPath
  Active: MQBoolean
  Fleeing: MQBoolean
  Following: MQBoolean
  Paused: MQBoolean
  Playing: MQBoolean
  Pulling: MQBoolean
  Recording: MQBoolean
  WaitingWarp: MQBoolean
  Length: MQFloat
  CustomPaths: MQInt
  Idle: MQInt
  NextWaypoint: MQInt
  State: MQInt
  Status: MQInt
  Waypoints: MQInt
  Monitor: MQSpawn
  CheckPoint: MQString
  CustomSearch: MQString
  Direction: MQString
  Flag1: MQString
  Flag2: MQString
  Flag3: MQString
  Flag4: MQString
  Flag5: MQString
  Flag6: MQString
  Flag7: MQString
  Flag8: MQString
  Flag9: MQString
  Path: MQString

  X: function(name_or_waypoint: string | integer): string
  Y: function(name_or_waypoint: string | integer): string
  Z: function(name_or_waypoint: string | integer): string
end

TLO.AdvPath = {} as AdvPath

global record Ground
  Search: function(filter: string): MQGround
end

TLO.Ground = {} as Ground


