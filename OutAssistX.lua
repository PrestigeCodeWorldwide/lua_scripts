--[[
OutAssist.lua [v.1.1] - By Neophys at RedGuides

Commands:
- /oa active -- Toggles script active or inactive
- /oa assist <name> -- Set the Character to assist 
- /oa assistat <number> -- Assist at this HP%  (Default: 70)
- /oa cwtn -- Toggles script to use CWTN plugin for BST or BER
- /oa help|? -- displays the help output
- /oa rtc|return -- toggles return to start point on or off
]]--

local mq = require("mq")

local function IsPluginLoaded(plugin)
    return mq.TLO.Plugin(plugin).IsLoaded()
end

local cordX = mq.TLO.Me.X()
local cordY = mq.TLO.Me.Y()
local cordZ = mq.TLO.Me.Z()
local ShortClass = mq.TLO.Me.Class.ShortName()
local MobHPAssist = 98
local AssistPC = nil
local LoopActive = true
local ReturnToStart = false
local useCWTN = false


local function configureCWTN()
    --print(string.format('\ay [\atOutside Assist\ay] CWTN is \ag%s\ay - Configuring \ag%s',useCWTN, plugin))
    --if not (IsPluginLoaded(plugin)) then
    --    mq.cmd(string.format("/plugin %s load",plugin))
    --end
    --mq.cmd(string.format("/%s mode manual", ShortClass))
    mq.cmd(string.format("/%s AutoAssistAt 98", ShortClass))
    mq.cmd(string.format("/%s CampRadius 30", ShortClass))
    mq.cmd(string.format("/%s pause off", ShortClass))
end
local function disableCWTN() 
    if IsPluginLoaded(plugin) then
        print(string.format('\ay [\atOutside Assist\ay] CWTN is \ag%s\ay - Pausing \ag%s',useCWTN, plugin))
        mq.cmd(string.format("/%s pause on", ShortClass))
    end
end
local function print_help()
    print('\ay[\atOutside Assist\ay]\aw -- Available Commands:')
    print('\t\ag/oa active \ay- Toggle on and off')
    print('\t\ag/oa help|? \ay- Shows this ')
    print('\t\ag/oa assist <Name> \ay- assist this character ')    
    print('\t\ag/oa assistat <number> \ay- assist at this HP% (default: 98)')
    print('\t\ag/oa cwtn \ay- Toggle CWTN on and off')
    print('\t\ag/oa return|rts \ay- Toggle CWTN on and off')
    print('\t\aw Current settings:')   
    print(string.format('\t\agAssisting:\ay %s',AssistPC))
    print(string.format('\t\agAssist at :\ay %s',MobHPAssist))
    print(string.format('\t\agActive:\ay %s',LoopActive))
end
local function outsideassist_cmds(...)
    local args = {...}
    local key = args[1]
    local val = args[2]
    if key == 'help' or key == '?' then
        print_help()
    elseif key == 'active' then
        if LoopActive then
            LoopActive = false
            print('\ay [\atOutside Assist\ay] Script status: \ag stopped')
        else
            LoopActive = true
            print('\ay [\atOutside Assist\ay] Script status: \ag running')
        end
    elseif key == 'returntostart' or key == 'rts'  or key == 'return' then
        if ReturnToStart then
            ReturnToStart = false
            print('\ay [\atOutside Assist\ay] Return to Start: \ag stopped')
        else
            ReturnToStart = true
            print('\ay [\atOutside Assist\ay] Return to Start: \ag running')
        end
    elseif key == 'assist' then
        if val then
            AssistPC = string.lower(val) 
            print(string.format('\ay [\atOutside Assist\ay] Assisting toon: \ag%s', AssistPC))
        else
            print('\ay [\atOutside Assist\ay]\ar Value is missing for AssistPC')
        end
    elseif key == 'assistat' then
        if val then
            MobHPAssist = tonumber(val)
            print(string.format('\ay [\atOutside Assist\ay] Assisting %s at \ag%i', AssistPC, MobHPAssist))
        else
            print('\ay [\atOutside Assist\ay]\ar Value is missing for MobHPAssist')
        end
    elseif key == 'cwtn' then
        if useCWTN then
            useCWTN = false
            print('\ay [\atOutside Assist\ay] Use CWTN: \ag False')
            disableCWTN()
        else
            useCWTN = true
            print('\ay [\atOutside Assist\ay] Use CWTN : \ag True')
            configureCWTN()
        end
    end
end
mq.bind('/oa', outsideassist_cmds)

local luaArguments = {...}
--if luaArguments[1] then
--    AssistPC = luaArguments[1]
--    print(string.format('\ay [\atOutside Assist\ay] Assisting toon: \ag%s', AssistPC))
--end
AssistPC = "Kodajii"

local function in_range(org_number, new_number, distance)
    local negdistance = org_number - distance
    local posDistance = org_number + distance
    if new_number >= negdistance and new_number <= posDistance then
        return true
    else
        return false
    end
end



--if CWTNPlugins[ShortClass] and useCWTN then
    --print(string.format('\ay [\atOutside Assist\ay] Class is \ag%s\ay, configuring \ag%s\ay for manual',ShortClass,CWTNPlugins[ShortClass]))
    configureCWTN()
--elseif not (useCWTN) then
--    disableCWTN()
--end

mq.cmd("/attack off")
while true
do 
    if mq.TLO.MacroQuest.GameState() == 'INGAME' and LoopActive and AssistPC ~= nil  then
        mq.cmd(string.format("/assist %s",AssistPC))
            if mq.TLO.Target() then
                
                local mob_hp = mq.TLO.Target.PctHPs()
                local mob_distance = mq.TLO.Target.Distance3D()
                if mob_hp < MobHPAssist then  
                    if mob_distance > 20 then
                        mq.cmd("/squelch /nav target distance=15")
                    else
                        mq.cmd("/stick snaproll front 10")
                    end 
                    mq.cmd("/attack on")
                end
            else
                if ReturnToStart then
                    mq.cmd(string.format("/squelch /nav locxyz %i %i  distance=25", cordX,cordY))
                end
                mq.cmd(string.format("/assist %s",AssistPC))
            end
    end
    mq.delay(200)
end

