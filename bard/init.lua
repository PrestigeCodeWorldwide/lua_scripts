--- @type Mq
local mq = require('mq')
--- @type ImGui
require 'ImGui'

local commands = require('interface.commands')
local config = require('interface.configuration')
local ui = require('interface.ui')
--local tlo = require('interface.tlo')
local logger = require('utils.logger')
local loot = require('utils.lootutils')
local movement = require('utils.movement')
local timer = require('utils.timer')
local ability = require('ability')
local common = require('common')
local constants = require('constants')
local mode = require('mode')
local state = require('state')

local zen = {}

local routines = {'assist','buff','camp','conditions','cure','debuff','events','heal','mez','pull','tank'}
for _,routine in ipairs(routines) do
    zen[routine] = require('routines.'..routine)
    zen[routine].init(zen)
end

local function init()
    -- Initialize class specific functions
    zen.class = require('classes.'..state.class)
    zen.class.init(zen)
    zen.events.initClassBasedEvents()
    ability.init(zen)

    -- Initialize binds
    mq.cmd('/squelch /djoin zen')
    commands.init(zen)

    -- Initialize UI
    ui.init(zen)

    state.currentZone = mq.TLO.Zone.ID()
    state.subscription = mq.TLO.Me.Subscription()
    common.setSwapGem()
    config.loadIgnores()

    if state.emu then
        mq.cmd('/hidecorpse looted')
    else
        mq.cmd('/hidecorpse alwaysnpc')
    end
    mq.cmd('/multiline ; /pet ghold on')
    mq.cmd('/squelch /stick set verbflags 0')
    mq.cmd('/squelch /plugin melee unload noauto')
    mq.cmd('/squelch /rez accept on')
    mq.cmd('/squelch /rez pct 90')
    mq.cmd('/squelch /assist off')
    mq.cmd('/squelch /autofeed 5000')
    mq.cmd('/squelch /autodrink 5000')
    mq.cmdf('/setwintitle %s (Level %s %s)', mq.TLO.Me.CleanName(), mq.TLO.Me.Level(), state.class)

    --tlo.init(zen)
end

---Check if the current game state is not INGAME, and exit the script if it is.
---Otherwise, update state for the current loop so we don't have to go to the TLOs every time.
local function updateLoopState()
    if mq.TLO.MacroQuest.GameState() ~= 'INGAME' then
        print(logger.logLine('Not in game, stopping zen.'))
        mq.exit()
    end
    state.actionTaken = false
    state.loop = {
        PctHPs = mq.TLO.Me.PctHPs(),
        PctMana = mq.TLO.Me.PctMana(),
        PctEndurance = mq.TLO.Me.PctEndurance(),
        ID = mq.TLO.Me.ID(),
        Invis = mq.TLO.Me.Invis(),
        PetName = mq.TLO.Me.Pet.CleanName(),
        TargetID = mq.TLO.Target.ID(),
        TargetHP = mq.TLO.Target.PctHPs(),
        PetID = mq.TLO.Pet.ID()
    }
end

---Reset assist/tank ID and turn off attack if we have no target or are targeting a corpse
---If targeting a corpse, also clear target unless its a healer
local clearTargetTimer = timer:new(5000)
local function checkTarget()
    local targetType = mq.TLO.Target.Type()
    if not targetType or targetType == 'Corpse' then
        state.assistMobID = 0
        state.tankMobID = 0
        if mq.TLO.Me.Combat() or mq.TLO.Me.AutoFire() then
            mq.cmd('/multiline ; /attack off; /autofire off;')
        end
        if targetType == 'Corpse' then
            if clearTargetTimer.start_time == 0 then
                -- clearing target in 3 seconds
                clearTargetTimer:reset()
            elseif clearTargetTimer:timerExpired() then
                mq.cmd('/squelch /mqtarget clear')
                clearTargetTimer:reset(0)
            end
        elseif clearTargetTimer.start_time ~= 0 then
            clearTargetTimer:reset(0)
        end
    elseif targetType == 'Pet' or targetType == 'PC' then
        state.assistMobID = 0
        state.tankMobID = 0
        if mq.TLO.Stick.Active() then
            mq.cmd('/squelch /stick off')
        end
        if mq.TLO.Me.Combat() then mq.cmd('/attack off') end
    end
end

local function checkFD()
    if mq.TLO.Me.Feigning() and (not constants.fdClasses[state.class] or not state.didFD) then
        mq.cmd('/stand')
    end
end

---Remove harmful buffs such as lich if HP is getting low, regardless of paused state
local torporLandedInCombat = false
local function buffSafetyCheck()
    if state.class == 'nec' and state.loop.PctHPs < 40 and zen.class.spells.lich then
        mq.cmdf('/removebuff %s', zen.class.spells.lich.Name)
    end
    if not torporLandedInCombat and mq.TLO.Me.Song('Transcendent Torpor')() and mq.TLO.Me.CombatState() == 'COMBAT' then
        torporLandedInCombat = true
    end
    if torporLandedInCombat and mq.TLO.Me.CombatState() ~= 'COMBAT' and mq.TLO.Me.Song('Transcendent Torpor')() then
        mq.cmdf('/removebuff "Transcendent Torpor"')
        torporLandedInCombat = false
    end
    if state.class == 'mnk' and mq.TLO.Me.PctHPs() < config.get('HEALPCT') and mq.TLO.Me.AbilityReady('Mend')() then
        mq.cmd('/doability mend')
    end
end

local lootMyCorpseTimer = timer:new(5000)
local function doLooting()
    local myCorpse = mq.TLO.Spawn('pccorpse '..mq.TLO.Me.CleanName()..'\'s corpse radius 100')
    if myCorpse() and lootMyCorpseTimer:timerExpired() then
        lootMyCorpseTimer:reset()
        myCorpse.DoTarget()
        if mq.TLO.Target.Type() == 'Corpse' then
            mq.cmd('/keypress CONSIDER')
            mq.delay(500)
            mq.doevents('eventCannotRez')
            if state.cannotRez then
                state.cannotRez = nil
                mq.cmd('/corpse')
                movement.navToTarget(nil, 10000)
                if (mq.TLO.Target.Distance3D() or 100) > 10 then return end
                loot.lootMyCorpse()
                state.actionTaken = true
                return
            end
        end
    end
    if config.get('LOOTMOBS') and (mq.TLO.Me.CombatState() ~= 'COMBAT' or config.get('LOOTCOMBAT')) and not state.pullStatus then
        state.actionTaken = loot.lootMobs(1)
        if state.lootBeforePull then state.lootBeforePull = false end
    end
end

local fsm = {}
function fsm.IDLE()
    
end
function fsm.TANK_SCAN()
    zen.tank.findMobToTank()
end
function fsm.TANK_ENGAGE() end
function fsm.PULL_SCAN() end
function fsm.PULL_APPROACH() end
function fsm.PULL_ENGAGE() end
function fsm.PULL_RETURN() end
function fsm.PULL_WAIT() end

function fsm.processState()
    return fsm[state.currentState]()
end

local function handleStates()
    -- Async state handling
    --if state.looting then loot.lootMobs() return true end
    --if state.selling then loot.sellStuff() return true end
    --if state.banking then loot.bankStuff() return true end
    if not state.handleTargetState() then return true end
    if not state.handlePositioningState() then return true end
    if not state.handleMemSpell() then return true end
    if not state.handleCastingState() then return true end
    if not state.handleQueuedAction() then return true end
end

local function main()
    init()

    local debugTimer = timer:new(3000)
    -- Main Loop
    while true do
        if state.debug and debugTimer:timerExpired() then
            logger.debug(logger.flags.zen.main, 'Start Main Loop')
            debugTimer:reset()
        end

        mq.doevents()
        updateLoopState()
        buffSafetyCheck()
        if not state.paused and common.inControl() then
            if not handleStates() then
                zen.camp.cleanTargets()
                checkTarget()
                if not state.loop.Invis and not common.isBlockingWindowOpen() then
                    -- do active combat assist things when not paused and not invis
                    checkFD()
                    common.checkCursor()
                    if state.emu then
                        doLooting()
                    end
                    if not state.actionTaken then
                        zen.class.mainLoop()
                    end
                    mq.delay(50)
                else
                    -- stay in camp or stay chasing chase target if not paused but invis
                    local pet_target_id = mq.TLO.Pet.Target.ID() or 0
                    if mq.TLO.Pet.ID() > 0 and pet_target_id > 0 then mq.cmd('/pet back') end
                    zen.camp.mobRadar()
                    if (mode:isTankMode() and state.mobCount > 0) or (mode:isAssistMode() and zen.assist.shouldAssist()) or mode:getName() == 'huntertank' then mq.cmd('/makemevis') end
                    zen.camp.checkCamp()
                    common.checkChase()
                    common.rest()
                    mq.delay(50)
                end
            end
        else
            if state.loop.Invis then
                -- if paused and invis, back pet off, otherwise let it keep doing its thing if we just paused mid-combat for something
                local pet_target_id = mq.TLO.Pet.Target.ID() or 0
                if mq.TLO.Pet.ID() > 0 and pet_target_id > 0 then mq.cmd('/pet back') end
            end
            if config.get('CHASEPAUSED') then
                common.checkChase()
            end
            mq.delay(500)
        end
        -- broadcast some buff and poison/disease/curse state around netbots style
        zen.buff.broadcast()
    end
end

main()