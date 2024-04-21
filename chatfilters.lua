---@type Mq
local mq = require('mq')
--- @type ImGui
require('ImGui')
--- @type BL
local BL = require('biggerlib')

local OptionsToHide = {
    13, -- bard songs
    14,
    17,
    18,
    20, -- DoT
    21,
    22,
    23,
    24, -- DS (You defending)
    35, -- DD Other crit hits
    36,
    37,
    39,
    40,
    42,
    48,
    63, 64, 65,
    80, 82,
    90, -- other damage other
    92, 93, 94, 96, 100, 101, 111, 126, 128
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
    mq.cmdf("/notify OptionsWindow ONP_FilterComboBox listselect 1", chatFilterIndex)
    mq.delay(100)
end

