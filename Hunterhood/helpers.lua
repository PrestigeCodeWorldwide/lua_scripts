local mq = require 'mq'

local helpers = {}

function helpers.groupNeedsInvis()
    local groupSize = mq.TLO.Group.GroupSize() or 0
    printf("\\ayDEBUG: Checking group invis - Group size: %d", groupSize)
    
    local membersNeedingInvis = 0
    local totalMembersChecked = 0
    
    -- First check the script runner
    local myInvis = mq.TLO.Me.Invis()
    printf("\\ayDEBUG: Checking self (%s) - Invis: %s", mq.TLO.Me.Name() or "Unknown", tostring(myInvis))
    
    if myInvis ~= nil then
        totalMembersChecked = totalMembersChecked + 1
        if myInvis == false then
            printf("\\ayDEBUG: I am not invisible")
            membersNeedingInvis = membersNeedingInvis + 1
        end
    else
        printf("\\ayDEBUG: Can't see my own invis status")
    end
    
    -- Then check other group members if in a group
    if groupSize > 1 then
        for i = 1, groupSize do
            local member = mq.TLO.Group.Member(i)
            if member() and member.ID() ~= mq.TLO.Me.ID() then  -- Skip self
                local memberName = member.Name() or "Unknown"
                printf("\\ayDEBUG: Checking member %s", memberName)
                
                local isInvis = member.Invis()
                if isInvis ~= nil then
                    totalMembersChecked = totalMembersChecked + 1
                    printf("\\ayDEBUG: Member %s - Invis: %s", memberName, tostring(isInvis))
                    
                    if isInvis == false then
                        printf("\\ayDEBUG: Member %s is not invisible", memberName)
                        membersNeedingInvis = membersNeedingInvis + 1
                    end
                else
                    printf("\\ayDEBUG: Skipping %s - can't see invis status", memberName)
                end
            end
        end
    end
    
    printf("\\ayDEBUG: %d of %d checked members need invisibility", membersNeedingInvis, totalMembersChecked)
    return membersNeedingInvis > 0
end

return helpers
