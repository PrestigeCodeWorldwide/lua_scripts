local mq = require('mq')
local os = require('os')

local sister = ""
local answer = ""
local ask = ""

local channel = ""
local resetTimer = 0
local answerTimer = 0
local sisters = {
    ['Althea'] = "",
    ['Brenda'] = "",
    ['Christine'] = ""
}
local sisterAsk = {
    ['Althea'] = "",
    ['Brenda'] = "",
    ['Christine'] = ""
}
local mySister = ""
local channelName = ""
local openGui = true
local shouldDrawGui = true
local paused = false
local distance = 30
local haveResponded = false;

local sisterList = {[1]='Althea',Althea=1,[2]='Brenda',Brenda=2,[3]='Christine',Christine=3}

 ----------------------------------------------------------
 ------------   Draw UI
 ----------------------------------------------------------
 local function validateDistance(distance)
    if distance < 15 or distance > 300 then return false end
    return true
end

local function checkDistance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local function validateChaseRole(role)
    if not ROLES[role] then return false end
    return true
end

 local function drawComboBox(resultvar, options)
    if ImGui.BeginCombo('My Sister', resultvar) then
        for _,j in ipairs(options) do
            if ImGui.Selectable(j, j == resultvar) then
                resultvar = j
            end
        end
        ImGui.EndCombo()
    end
    return resultvar
end

local function sistersUi()
    if not openGui or mq.TLO.MacroQuest.GameState() ~= 'INGAME' then return end
    openGui, shouldDrawGui = ImGui.Begin('Sisters', openGui)
    if shouldDrawGui then
        if paused then
            if ImGui.Button('Resume') then
                paused = false
            end
        else
            if ImGui.Button('Pause') then
                paused = true
                mq.cmd('/squelch /nav stop')
            end
        end
        ImGui.PushItemWidth(100)
        mySister = drawComboBox(mySister, sisterList)
        local tmpDistance = ImGui.InputInt('Chase Distance', distance)
        ImGui.PopItemWidth()
        if validateDistance(tmpDistance) then
            distance = tmpDistance
        end
    end
    ImGui.End()
end
mq.imgui.init('Sisters', sistersUi)

 ----------------------------------------------------------
 ------------   Chase
 ----------------------------------------------------------
local function doChase()
    local chaseSpawn = mq.TLO.Spawn('npc ="'..mySister..'"')
    if paused then return end
    if mq.TLO.Me.Hovering() or mq.TLO.Me.AutoFire() or mq.TLO.Me.Combat() or (mq.TLO.Me.Casting() and mq.TLO.Me.Class.ShortName() ~= 'BRD') or mq.TLO.Stick.Active() then return end
    local meX = mq.TLO.Me.X()
    local meY = mq.TLO.Me.Y()
    local chaseX = chaseSpawn.X()
    local chaseY = chaseSpawn.Y()
    if not chaseX or not chaseY then return end
    if checkDistance(meX, meY, chaseX, chaseY) > distance then
        if not mq.TLO.Nav.Active() and mq.TLO.Navigation.PathExists(string.format('spawn npc ="%s"', chaseSpawn.CleanName())) then
            mq.cmdf('/nav spawn npc ="%s" | dist=10 log=off', chaseSpawn.CleanName())
        end
    end
end

 ----------------------------------------------------------
 ------------   Answer if we have the info.
 ----------------------------------------------------------
 local function answerIfAble()
    if haveResponded then return end
    if mySister == "" then return end
    local ask = sisterAsk[mySister]
    if ask == "" then return end
    answer = sisters[ask]
    if answer == "" then return end
    mq.cmdf("/echo [Sisters] ANSWER = %s", answer)

    mq.cmdf("/target %s", mySister)
    mq.delay("1s")
    mq.cmdf("/say %s", answer)
    haveResponded = true
    -- macro would clear mySister variable here, but why?
end

 ----------------------------------------------------------
 ------------   DumpVars 
 ----------------------------------------------------------
 local function dumpVars()
    print("=== VARIABLES ===")
    print("Althea = " .. sisters["Althea"])
    print("Brenda = " .. sisters["Brenda"])
    print("Christine = " .. sisters["Christine"])
    print("AltheaAsk = " .. sisterAsk["Althea"])
    print("BrendaAsk = " .. sisterAsk["Brenda"])
    print("ChristineAsk = " .. sisterAsk["Christine"])
    print("MySister = " .. mySister)
 end

 ----------------------------------------------------------
 ------------   WHO IS EACH SISTER ASKING FOR ?
 ----------------------------------------------------------
local function whatAltheaUpTo(line, she)
    mq.cmdf("/echo [Sisters] %s asking for Althea", she)
    sisterAsk[she] = "Althea"
    dumpVars()
    answerIfAble()
end

local function whatBrendaUpTo(line, she)
    mq.cmdf("/echo [Sisters] %s asking for Brenda", she)
    sisterAsk[she] = "Brenda"
    dumpVars()
    answerIfAble()
end

local function whatCristineUpTo(line, she)
    mq.cmdf("/echo [Sisters] %s asking for Christine", she)
    sisterAsk[she] = "Christine"
    dumpVars()
    answerIfAble()
end

 ----------------------------------------------------------
 ------------   WHAT IS OUR SISTER DOING ?
 ----------------------------------------------------------
local function sisterSetText(line, she, text)
    -- If I overhear a different sister, I don't want to respond
    if mySister ~= she then return end
    mq.cmdf("/echo [Sisters] %s = %s", she, text)
    mq.cmdf("%s %s = %s",channel, she, text)
    sisters[she] = text
    dumpVars()
    answerIfAble()
end

 ----------------------------------------------------------
 ------------   FIGURE OUT WHAT IS BEING SAID IN CHANNEL
 ----------------------------------------------------------
local function figureItOut(line, who, said, what)
    local s = ""
    local t = ""
    mq.cmdf("/echo [Sisters-FromChannel] '%s' '%s'", said, what)

    if string.sub(said,1,1) == "A" then s ='Althea' end
    if string.sub(said,1,1) == "B" then s = 'Brenda' end
    if string.sub(said,1,1) == "C" then s = 'Christine' end

    -- Hard part figure out which phrase
    if string.find(line, "CONSPIRING") then
        t = "CONSPIRING"
    elseif string.find(line, "CRYING QUI") then 
        t = "CRYING QUIETLY"
    elseif string.find(line, "DEAD RAT") then 
        t = "DEAD RAT"
    elseif string.find(line, "DIARY") then 
        t = "DIARY"
    elseif string.find(line, "LETTER OPEN") then 
        t = "LETTER OPENER"
    elseif string.find(line, "POISONOUS SUBSTANCE") then 
        t = "POISONOUS SUBSTANCE"
    elseif string.find(line, "SABOTAG") then 
        t = "SABOTAGING"
    elseif string.find(line, "SCOPIN") then 
        t = "SCOPING"
    elseif string.find(line, "SPYING") then 
        t = "SPYING"
    elseif string.find(line, "WOODEN STAKE") then 
        t = "WOODEN STAKE"
    end

    -- If we found both sister and phrase - save info

    if s ~= "" and t ~= "" then
        sisters[s] = t
        dumpVars()
    end

   answerIfAble()

end

 ----------------------------------------------------------
 ------------   Ask For Info
 ----------------------------------------------------------
local function askForInfo()
    answerTimer = "2m"
    answerIfAble()
    if mySister == "" then return end
    if sisterAsk[mySister] == "" then return end

    mq.cmdf("echo [Sisters] Need %s", sisterAsk[mySister])
    answerTimer = "30s"
end


 ----------------------------------------------------------
 ------------   Reset Stuff
 ----------------------------------------------------------
local function reset()
    haveResponded = false
    resetTimer = 60
    answerTimer = 1
    sisters = {
        ['Althea'] = "",
        ['Brenda'] = "",
        ['Christine'] = ""
    }
    sisterAsk = {
        ['Althea'] = "",
        ['Brenda'] = "",
        ['Christine'] = ""
    }
end

 ----------------------------------------------------------
 ------------   Rather than reset for trigger , do it once using a timer
 ----------------------------------------------------------
local function moveReset(line, she)
    if mySister ~= she then return end
    print("moving, resetting")
    resetTimer = 5
    reset()
end

 ----------------------------------------------------------
 ------------   Get Channel -- From SymScripts MCS
 ----------------------------------------------------------
 local function getChannel(line)
    local a = 0

    --s = "Channels: 1=General(371), 2=Rogue(29), 3=Housing(40), 4=toaster(2)"
    for k, v in string.gmatch(line, "(%w+)=(%w+)") do
      if v == channelName then a = k end
    end

    if a == 0 then
      print("Could not find channel defaulting to group")
      channel = "/g"
      return
    end

    channel = "/" .. a
    print("Channel set to: " .. channel)
end

--Althea is carving a block of wood, using a whittling blade to fashion a sharp WOODEN STAKE. 
 ----------------------------------------------------------
 ------------   10 SISTER TRIGGERS
 ----------------------------------------------------------
mq.event('one', "#1# is #2# with several werewolves, whispering and motioning towards the rooms of the other Sisters.", sisterSetText)
mq.event('two', "#1# glances around the room to ensure the other Sisters are nowhere in sight, then slips a #2# under the bed pillow.", sisterSetText)
mq.event('three', "#1# is carving a block of wood, using a whittling blade to fashion a sharp #2#.", sisterSetText)
mq.event('four', "#1# uses a small chisel to hammer a crack into another Sister's coffin, #2# it.", sisterSetText)
mq.event('five', "#1# is surreptitiously watching the other Sisters, #2# on them.", sisterSetText)
mq.event('six', "#1# is murmuring to herself while obsessively sharpening an ornate #2#.", sisterSetText)
mq.event('seven', "#1# is wandering the back halls, #2# out the occupants in the various guest rooms.", sisterSetText)
mq.event('eight', "#1# is sulking, burying her face in the bedsheets while #2#.", sisterSetText)
mq.event('nine', "#1# gingerly dabs a #2# onto the rim of one of the other Sister's wine goblets.", sisterSetText)
mq.event('ten', "#1# is flipping through the pages of a #2#, which is obviously not her own.  It must belong to one of the other Wailing Sisters.", sisterSetText)
mq.event('whoAskedForA', "#1# says, 'Did you find out?  What is Althea up to?'", whatAltheaUpTo)
mq.event("whoAskedForB", "#1# says, 'Did you find out what Brenda is up to?'", whatBrendaUpTo)
mq.event("whoAskedForC", "#1# says, 'What is Christine up to?'", whatCristineUpTo)
mq.event("getChannel", "Channels: #*#", getChannel)
mq.event("reset", "#1# prepares to head elsewhere.", moveReset)
 
 ----------------------------------------------------------
 ------------   MAIN --- START HERE
 ----------------------------------------------------------
mySister = "Althea"
local args = {...}
if args[1] then
    channelName = args[1]
    mq.cmd("/list")
else
    mq.cmd("/echo /lua run sisters CHANNELNAME")
    mq.cmd("/echo And, be in the channel!!")
end

mq.event("channel", "#1# tells " .. channelName .. ":#*#, '#2# #3#'", figureItOut)

reset()
resetTimer = 1000
mq.cmd("/mqclear")
mq.cmd("/echo Starting Wailing Sisters Script")

local function mainLoop()
    while true do
        mq.doevents()
        if (resetTimer == 0) then reset() end
        if (answerTimer == 0) then askForInfo() end
        doChase()
        mq.delay(50)
    end
end
 
 mainLoop()