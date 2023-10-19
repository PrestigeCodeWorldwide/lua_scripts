---@type Mq
local mq = require('mq')
local class = require('classes.classbase')
local common = require('common')
local state = require('state')

function class.init(_aqo)
    class.classOrder = {'assist', 'aggro', 'mash', 'burn', 'recover', 'buff', 'rest', 'rez'}
    class.initBase(_aqo, 'rog')

    class.initClassOptions()
    class.loadSettings()
    class.initDPSAbilities(_aqo)
    class.initBurns(_aqo)
    class.initBuffs(_aqo)

    class.useCommonListProcessor = true
end

function class.initClassOptions()
    class.addOption('USEEVADE', 'Evade', true, nil, 'Hide and backstab on engage', 'checkbox', nil, 'UseEvade', 'bool')
end

function class.initDPSAbilities(_aqo)
    table.insert(class.DPSAbilities, common.getSkill('Kick', {conditions=_aqo.conditions.withinMeleeDistance}))
    table.insert(class.DPSAbilities, common.getSkill('Backstab', {conditions=_aqo.conditions.withinMeleeDistance}))
    table.insert(class.DPSAbilities, common.getAA('Twisted Shank', {conditions=_aqo.conditions.withinMeleeDistance}))
    table.insert(class.DPSAbilities, common.getBestDisc({'Assault', {conditions=_aqo.conditions.withinMeleeDistance}}))
    table.insert(class.DPSAbilities, common.getAA('Ligament Slice', {conditions=_aqo.conditions.withinMeleeDistance}))
end

function class.initBurns(_aqo)
    table.insert(class.burnAbilities, common.getAA('Rogue\'s Fury'))
    --table.insert(class.burnAbilities, common.getBestDisc({'Poison Spikes Trap'}))
    table.insert(class.burnAbilities, common.getBestDisc({'Duelist Discipline'}))
    table.insert(class.burnAbilities, common.getBestDisc({'Deadly Precision Discipline'}))
    table.insert(class.burnAbilities, common.getBestDisc({'Frenzied Stabbing Discipline'}))
    table.insert(class.burnAbilities, common.getBestDisc({'Twisted Chance Discipline'}))
    table.insert(class.burnAbilities, common.getAA('Fundament: Third Spire of the Rake'))
    table.insert(class.burnAbilities, common.getAA('Dirty Fighting'))
end

function class.initBuffs(_aqo)
    table.insert(class.combatBuffs, common.getAA('Envenomed Blades'))
    table.insert(class.combatBuffs, common.getBestDisc({'Brigand\'s Gaze', 'Thief\'s Eyes'}))
    table.insert(class.combatBuffs, common.getItem('Fatestealer', {CheckFor='Assassin\'s Taint'}))
    table.insert(class.selfBuffs, common.getAA('Sleight of Hand'))
    table.insert(class.selfBuffs, common.getItem('Faded Gloves of the Shadows', {CheckFor='Strike Poison'}))
end

function class.beforeEngage()
    if class.isEnabled('USEEVADE') and not mq.TLO.Me.Combat() and mq.TLO.Target.ID() == state.assistMobID then
        mq.cmd('/doability Hide')
        mq.delay(100)
        mq.cmd('/doability Backstab')
    end
end

function class.aggroClass()
    if mq.TLO.Me.AbilityReady('hide') then
        if mq.TLO.Me.Combat() then
            mq.cmd('/attack off')
            mq.delay(1000, function() return not mq.TLO.Me.Combat() end)
        end
        mq.cmd('/doability hide')
        mq.delay(500, function() return mq.TLO.Me.Invis() end)
        mq.cmd('/attack on')
    end
end

return class