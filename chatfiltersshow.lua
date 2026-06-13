-- v1.1
---@type Mq
local mq = require('mq')
--- @type ImGui
require('ImGui')
--- @type BL
local BL = require('biggerlib')

local OptionsToHide = {
    1, -- AA Ability Reuse
    --2, -- Achievement Links
    3, -- Achievements (Others)
    4, -- Achievements (You)
    --5, -- Aggro Meter Labels - Low
    --6, -- Aggro Meter Labels - Most
    --7, -- Aggro Meter Labels - Warning
    --8, -- Auction
    --9, -- Auction echo
    --10, -- Auras (Others)
    --11, -- Auras (You)
    --12, -- Bad Words
    13, -- Bard Songs
    14, -- Bard Songs on Pets
    --15, -- Broadcasts
    --16, -- Can't Use Command Warning
    17, -- Combat Abilities / Disciplines (Others)
    18, -- Combat Abilities / Disciplines (You)
    19, -- Combat Ability Reuse
    20, -- Damage Over Time
    21, -- Damage Shields
    --22, -- Damage Shields (Others)
    --23, -- Damage Shields (You Attacking)
    --24, -- Damage Shields (You Defending)
    --25, -- Death Notification - NPCs
    --26, -- Death Notification - Other PCs
    --27, -- Death Notification - You
    --28, -- Death Text (NPCs)
    --29, -- Default Text
    --30, -- Destroyed Items
    --31, -- Dialog [Response] Links
    --32, -- Dice Roll (/random) - Group / Raid
    --33, -- Dice Roll (/random) - Mine
    --34, -- Dice Roll (/random) - Others
    35, -- Direct Damage (Other Critical Hits)
    36, -- Direct Damage (Others)
    37, -- Direct Damage (Your Critical Hits)
    --38, -- Direct Damage (Yours)
    39, -- DoTs (Other Critical Hits)
    40, -- DoTs (Others)
    --41, -- DoTs (You Being Hit)
    42, -- DoTs (Your Critical Hits)
    --43, -- DoTs (Yours)
    --44, -- Emote
    --45, -- Emote echo
    --46, -- Encounter Lock Attackable
    --47, -- Encounter Lock Unattackable
    48, -- Environmental Damage (Others)
    --49, -- Environmental Damage (Yours)
    --50, -- Event Messages
    --51, -- Experience Messages
    --52, -- Faction Links
    --53, -- Faction Messages
    54, -- Fellowship Chat
    55, -- Focus Effects
    --56, -- Food and Drink Messages
    --57, -- Group
    --58, -- Group / Raid Role Messages
    --59, -- Group echo
    --60, -- Guild
    --61, -- Guild echo
    --62, -- Guild messages
    63, -- Heal Over Time
    64, -- Heals (Other Critical Heals)
    65, -- Heals (Others)
    --66, -- Heals (Your Critical Heals)
    67, -- Heals (Yours)
    68, -- Heals Received
    --69, -- Hotbutton Cooldown Overlay
    --70, -- Item Links
    --71, -- Item Speech
    --72, -- Item Stat Negative
    --73, -- Item Stat Positive
    --74, -- Locked Inventory Slots
    --75, -- Loot Messages
    --76, -- Melee Warnings
    77, -- Mercenary Messages
    --78, -- Merchant Buy/Sell
    --79, -- Merchant Offer Price
    --80, -- Money Splits
    81, -- My Pet Hits
    --82, -- My Pet Melee
    83, -- My Pet Misses
    --84, -- NPC Enrage
    --85, -- NPC Flurry
    --86, -- NPC Rampage
    --87, -- NPC Spells
    --88, -- NPC dialogue to you
    --89, -- OOC
    --90, -- OOC echo
    91, -- Other damage other
    --92, -- Other hits you
    93, -- Other miss other
    94, -- Other misses you
    95, -- Others Hits (Critical)
    --96, -- Others spells
    97, -- PC Spells
    --98, -- Pet Crits
    --99, -- Pet Rampage/Flurry
    --100, -- Pet Responses
    101, -- Pet Spells
    102, -- Proc Spells (Begin Casting)
    103, -- PvP Messages
    --104, -- Raid Say
    --105, -- Raid Victory Messages
    --106, -- Say
    --107, -- Say echo
    --108, -- Shout
    --109, -- Shout echo
    --110, -- Skills
    111, -- Spam
    112, -- Spell Damage
    --113, -- Spell Emotes
    114, -- Spell Failures (Others)
    --115, -- Spell Failures (Yours)
    116, -- Spell Overwritten (Beneficial)
    117, -- Spell Overwritten (Detrimental)
    --118, -- Spell worn off
    --119, -- Spells
    120, -- Stun messages
    --121, -- System Messages
    --122, -- Taunt Messages
    --123, -- Tell
    --124, -- Tell echo
    --125, -- Who slash command results
    --126, -- Yell for help
    --127, -- You hit other
    128, -- You miss other
    --129, -- Your Flurry
    130 -- Your Hits (Critical)
}

-- List(i,k) explanation:
-- i is the row index, so each "AA Ability Reuse" "Achievements (Others)" etc
-- k is data of the row, k == 1 is the text ("AA ability Reuse") and 3 is the filter "Show" "Hide"
--local optionsListRoot = mq.TLO.Window("OptionsWindow").Child("ONP_ChatSettingsList")
--local childList = optionsListRoot.List(1, 1)
-- /notify OptionsWindow ONP_ChatSettingsList listselect 1 -- gets AA Reuse selected

for _, chatFilterIndex in ipairs(OptionsToHide) do
    -- Select a filter
    local filterBeingHidden = mq.TLO.Window("OptionsWindow/ONP_ChatSettingsList").List(chatFilterIndex, 1)
    BL.info("Hiding: %s", filterBeingHidden)
    mq.cmdf("/notify OptionsWindow ONP_ChatSettingsList listselect %d", chatFilterIndex)
    mq.delay(100)
    -- 1 IS HIDE, 2 IS SHOW
    -- Set the HIDE option
    mq.cmdf("/notify OptionsWindow ONP_FilterComboBox listselect 2", chatFilterIndex)
    mq.delay(100)
end
