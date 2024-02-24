local mq            = require('mq')
local Set           = require('mq.set')
local animSpellGems = mq.FindTextureAnimation('A_SpellGems')
local ICONS         = require('mq.Icons')
local ICON_SIZE     = 20
local BL            = require("biggerlib")

--- @type groupmember|nil
local groupHealer   = nil

local function FindGroupHealer()
    for i = 1, mq.TLO.Group.Members() do
        local member = mq.TLO.Group.Member(i)
        --groupMembers[i] = member
        if member.Class.HealerType() then
            groupHealer = member
        end
    end
    return groupHealer
end

local function IsHealerDead()
    if groupHealer == nil then
        BL.warn("No healer found in group")
        return false
    end
    return groupHealer.Spawn:Dead()
end




while true do

end