---@type Mq
local mq = require('mq')
local BL = require('biggerlib')

BL.info("SheiBane script v1.0 loaded.")
BL.warn("untested as of 11-07-2025. Reminder to test when MQ is back up.")

local bane_mob_name = 'datiar xi tavuelim'

local banes = {
    BRD = {
        { name = 'Slumber of Suja', type = 'spell' },
    },
    CLR = {
        { name = 'Blessed Chains', type = 'aa' },
    },
    ENC = {
        { name = 'Beguiler\'s Banishment', type = 'aa' },
        { name = 'Chaotic Conundrum', type = 'spell' },
        { name = 'Beam of Slumber', type = 'aa' },
        { name = 'Beguiler\'s Directed Banishment', type = 'aa' },
    },
    PAL = {
        { name = 'Shackles of Tunare', type = 'aa' },
    },
    SHM = {
        { name = 'Virulent Paralysis', type = 'aa' },
    },
    NEC = {
        { name = 'Pestilent Paralysis', type = 'aa' },
        { name = 'Shackle', type = 'spell' },
    },
    DRU = {
        { name = 'Paralytic Spray', type = 'aa' },
        { name = 'Vinelash Assault', type = 'spell' },
        { name = 'Paralytic Spores', type = 'aa' },
    },
    RNG = {
        { name = 'Vinelash Assault', type = 'spell' },
        { name = 'Flusterbolt', type = 'spell' },
        { name = 'Grasp of Sylvan Spirits', type = 'aa' },
        { name = 'Blusterbolt', type = 'spell' },
    },
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
    mq.cmd('/squelch /boxr pause')
    mq.delay(10)
    while mq.TLO.Me.Casting() do
        mq.delay(100)
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

local function memSpell(spellName)
    local spell = mq.TLO.Spell(spellName)
    if not spell() then
        BL.error("Invalid spell name: " .. tostring(spellName))
        return false
    end

    local rankName = spell.RankName()
    if not rankName then
        BL.error("Could not get rank name for spell: " .. tostring(spellName))
        return false
    end

    local gem = mq.TLO.Me.Gem(rankName)
    if gem() and gem() > 0 then return true end

    StopDPS()
    mq.cmdf('/memspell 14 "%s"', rankName)
    mq.delay('4s')
    mq.TLO.Window('SpellBookWnd').DoClose()
    ResumeDPS()
    return true
end

local function targetBaneMob()
    if mq.TLO.Target.CleanName() ~= bane_mob_name then
        mq.cmdf('/target id %d', mq.TLO.Spawn(('NPC %s'):format(bane_mob_name)).ID())
        mq.delay(500, function() return mq.TLO.Target.ID() ~= nil end)
        if mq.TLO.Target.ID() then
            mq.cmd('/face fast')
            mq.delay(50)
        end
    end
end

local function castBane()
    local myClass = mq.TLO.Me.Class.ShortName()
    local classBanes = banes[myClass]
    if not classBanes then return false end

    -- Try each bane until one is successful
    for _, bane in ipairs(classBanes) do
        -- Check if this bane is ready
        local isReady = false
        if bane.type == 'spell' then
            isReady = mq.TLO.Me.SpellReady(bane.name)()
            -- If spell isn't memmed, try to mem it
            if not mq.TLO.Me.Gem(bane.name)() then
                memSpell(bane.name)
                isReady = mq.TLO.Me.SpellReady(bane.name)()
            end
        else
            isReady = mq.TLO.Me.AltAbilityReady(bane.name)()
        end

        if isReady and not mq.TLO.Me.Casting() then
            StopDPS()
            targetBaneMob()

            if bane.type == 'spell' then
                mq.cmdf('/cast "%s"', bane.name)
            else
                mq.cmdf('/alt activate %s', mq.TLO.Me.AltAbility(bane.name).ID())
            end

            mq.delay(100, function() return mq.TLO.Me.Casting() end)
            while mq.TLO.Me.Casting() do
                mq.delay(100)
            end

            ResumeDPS()
            return true
        end
    end

    return false
end

-- Main loop
while true do
    BL.checkChestSpawn("a_shadowed_chest")

    -- Check if any bane mobs are up
    if mq.TLO.SpawnCount(('NPC %s'):format(bane_mob_name))() > 0 then
        BL.info("%s detected! Attempting to bane...", bane_mob_name)
        castBane()
    end

    mq.doevents()
    mq.delay(100)
end