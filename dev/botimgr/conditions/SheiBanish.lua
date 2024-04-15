---@type Mq
---@type ImGui

local mq = require('mq')

local required_zone = 'akhevatwo_mission'
local bane_mob_name = 'datiar xi tavuelim'

local banes = {
    BRD={name='Slumber of the Diabo',type='spell'},
    CLR={name='Blessed Chains',type='aa'},
    ENC={name='Beguiler\'s Banishment',type='aa'},
    Pal={name='Shackles of Tunare',type='aa'},
    SHM={name='Virulent Paralysis',type='aa'},
    Nec={name='Pestilent Paralysis',type='aa'},
    DRU={name='Paralytic Spores',type='aa'},
    RNG={name='Grasp of Sylvan Spirits',type='aa'},
}

local function StopDPS()
    mq.cmd('/squelch /mqp on')
    mq.delay(10)
    if mq.TLO.Me.Class.ShortName() == 'BRD' then
        mq.cmd('/squelch /twist off')
        mq.delay(10)
        mq.cmd('/squelch /stopsong')
        mq.delay(10)
    end
    --mq.cmd('/attack off')  ... maybe deactivate attack but save state to reactivate at StartDps
    --mq.delay(10)
    mq.cmd('/squelch /boxr pause')
    mq.delay(10)
    while mq.TLO.Me.Casting.ID() do
       mq.delay(200)
    end
end

local function ResumeDPS()
   mq.cmd('/squelch /mqp off')
   mq.delay(10)
   if mq.TLO.Me.Class.ShortName() == 'BRD' then
    mq.cmd('/squelch /twist on')
    mq.delay(10)
   end
   mq.cmd('/squelch /boxr unpause')
   mq.delay(10)
end

local function on_load()
    if mq.TLO.Zone.ShortName() ~= required_zone then return end
    local bane = banes[mq.TLO.Me.Class.ShortName()]
    local Spellname = mq.TLO.Spell(bane.name).RankName()
    if bane and bane.type == 'spell' then
        if mq.TLO.Me.Gem(Spellname)() and mq.TLO.Me.Gem(Spellname)() > 0 then return end  -- Should be memmed already
        StopDPS()
        mq.cmdf('/memspell 13 "%s"', Spellname)
        mq.delay('4s')
        mq.TLO.Window('SpellBookWnd').DoClose()
        ResumeDPS()
    end
end

---@return boolean @Returns true if the action should fire, otherwise false.
local function condition()
    return mq.TLO.Zone.ShortName() == required_zone and mq.TLO.SpawnCount(('%s npc'):format(bane_mob_name))() > 0
end

local function target_bane_mob()
    if mq.TLO.Target.CleanName() ~= bane_mob_name then
        mq.cmdf('/mqtar %s npc', bane_mob_name)
        mq.delay(50)
    end
end

local function cast(spell)
    mq.cmdf('/cast %s', spell.RankName())
    mq.delay(50+spell.MyCastTime())
end

local function use_aa(aa)
    mq.cmdf('/alt activate %s', aa.ID())
    mq.delay(50+aa.Spell.CastTime())
end

local function bane_ready(bane)
    if bane.type == 'spell' then
        return mq.TLO.Me.SpellReady(bane.name) and not mq.TLO.Me.Casting()
    elseif bane.type == 'aa' then
        return mq.TLO.Me.AltAbilityReady(bane.name) and not mq.TLO.Me.Casting()
    end
end

local function action()
    local my_class = mq.TLO.Me.Class.ShortName()
    local bane = banes[my_class]
    -- if not a bane class, return
    if not bane then return end
    -- if bane ability isn't ready, return
    if my_class ~= 'BRD' and not bane_ready(bane) then return end
    StopDPS()
    target_bane_mob()
    if bane.type == 'spell' then
        cast(mq.TLO.Spell(bane.name))
    else
        use_aa(mq.TLO.Me.AltAbility(bane.name))
    end
    while mq.TLO.Me.Casting() do
        mq.doevents()
        mq.delay(50)
    end
    ResumeDPS()
end

return {onload=on_load, condfunc=condition, actionfunc=action}