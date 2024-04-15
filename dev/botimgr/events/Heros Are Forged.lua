local mq = require('mq')

local function event_handler(line, nameOne, nameTwo)
    if nameOne == mq.TLO.Me.CleanName() then
        mq.cmdf('/%s mode 0', mq.TLO.Me.Class.ShortName())
        mq.cmd('/mqp on')
        mq.cmd('/twist off')
        local duration = 35 -- seconds
        local start_time = os.clock()
        while os.clock() - start_time < duration do
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameOne == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1095 399 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameOne == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1041 374 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameOne == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1000 330 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameOne == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -989 270 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameOne == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1048 209 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameOne == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1097 230 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameOne == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1157 307 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
        end
        if mq.TLO.Group.Member(mq.TLO.Me).MainTank() then
            mq.cmdf('/%s mode 8', mq.TLO.Me.Class.ShortName())
            mq.cmd('/mqp off')
        else
            mq.cmdf('/%s mode 2', mq.TLO.Me.Class.ShortName())
            mq.cmd('/mqp off')
        end
    elseif nameTwo == mq.TLO.Me.CleanName() then
        mq.cmdf('/%s mode 0', mq.TLO.Me.Class.ShortName())
        mq.cmd('/mqp on')
        mq.cmd('/twist off')
        local duration = 70 -- seconds
        local start_time = os.clock()
        while os.clock() - start_time < duration do
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameTwo == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1095 399 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameTwo == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1041 374 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameTwo == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1000 330 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameTwo == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -989 270 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameTwo == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1048 209 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameTwo == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1097 230 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
            local time_remaining = duration - (os.clock() - start_time)
            if time_remaining > 3 then
                printf(time_remaining)
                if nameTwo == mq.TLO.Me.CleanName() then
                    mq.cmd('/nav locxyz -1157 307 197')
                end
                mq.delay('3s')
            elseif time_remaining < 3 then
                break
            end
        end
        if mq.TLO.Group.Member(mq.TLO.Me).MainTank() then
            mq.cmdf('/%s mode 8', mq.TLO.Me.Class.ShortName())
            mq.cmd('/mqp off')
        else
            mq.cmdf('/%s mode 2', mq.TLO.Me.Class.ShortName())
            mq.cmd('/mqp off')
        end
    end

end

return {eventfunc=event_handler}