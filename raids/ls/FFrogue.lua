---@type Mq
local mq = require('mq')
---@type BL
local BL = require('biggerlib')

local archerName = "a Rallosian archer"
while true do
    local spawn = mq.TLO.Spawn(archerName)
    local spawnId = spawn.ID()
    local alreadyInCombatWithArcher = false
    --see if i'm in combat with an archer already
    if mq.TLO.Me.Combat() then
        local target = mq.TLO.Target
        if BL.NotNil(target) and BL.NotNil(target())then           
            local targetName = target.CleanName()
            if targetName == archerName then
                alreadyInCombatWithArcher = true
            end
        end
    end
    
    if BL.NotNil(spawn) and BL.NotNil(spawnId) and spawnId > 0 and not alreadyInCombatWithArcher then
        BL.cmd.ChangeAutomationModeToManual()
        BL.TargetAndNavTo(archerName)
        mq.cmd("/attack on")
    end
    
    
    if BL.IsNil(spawn) or BL.IsNil(spawnId) or spawnId < 1 then
        BL.cmd.ChangeAutomationModeToChase()
    end
    
    mq.delay(1000)
end
