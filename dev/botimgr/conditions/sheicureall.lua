local mq = require('mq')
local library = require('lem.library')

local itemname = 'Seaport Cure-All'
local buffname = 'Venomous Touch of Vinitras'

---@return boolean @Returns true if the action should fire, otherwise false.
local function condition()
    return mq.TLO.FindItem(itemname)() and
        mq.TLO.Me.Buff(buffname)() and
        not mq.TLO.Me.Casting()
end

local function action()
    mq.cmdf('/useitem "%s"', itemname)
end

return {condfunc=condition, actionfunc=action}