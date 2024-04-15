local mq = require('mq')

local setaapct = 0
local maxaa = 0

local maxexpacaa = {
    TOV = {BER=41162, BRD=41325, BST=49004, CLR=41100, DRU=43822, ENC=43203, MAG=46750, MNK=41747, NEC=49659, PAL=45872, RNG=46252, ROG=40825, SHD=51848, SHM=51947, WAR=35191, WIZ=43833,},
    COV = {BER=45752, BRD=44105, BST=54084, CLR=45180, DRU=52787, ENC=46493, MAG=51340, MNK=45637, NEC=53836, PAL=51182, RNG=50807, ROG=44775, SHD=57833, SHM=57882, WAR=38634, WIZ=48578,},
    TOL = {BER=53102, BRD=49885, BST=62519, CLR=52840, DRU=62347, ENC=53195, MAG=59398, MNK=52347, NEC=61446, PAL=60015, RNG=58987, ROG=51778, SHD=67223, SHM=67902, WAR=44630, WIZ=56641,},
    NOS = {BER=58082, BRD=52135, BST=67274, CLR=57590, DRU=69582, ENC=56705, MAG=63875, MNK=56732, NEC=66006, PAL=65052, RNG=63837, ROG=55240, SHD=72588, SHM=74377, WAR=47012, WIZ=61893,},
}

local function maxSupportExpansion()
    local maxExpansionNumber = 29
    for i = maxExpansionNumber, 26, -1 do
      if mq.TLO.Me.HaveExpansion(i)() then
        return i
      end
    end
    return 0
  end



local function condition()
    local level = mq.TLO.Me.Level()
    local maxlevel = mq.TLO.Me.MaxLevel()
    local exppct = mq.TLO.Me.PctExp()
    local exppctint = mq.TLO.Me.PctExp.Int()
    local exppctint1 = mq.TLO.Me.PctExp.Int() + 1
    local aapct = mq.TLO.Me.PctExpToAA()
    local aapoints = mq.TLO.Me.AAPoints()
    local aapointsassigned = mq.TLO.Me.AAPointsAssigned()
    local myMaxExpansion = maxSupportExpansion() -- returns 26, 27, 28 or 29
    --local myMaxExpansion = 27 --For Testing Purposes
    local myclass = mq.TLO.Me.Class.ShortName()

    if myMaxExpansion == 26 then
        maxaa = maxexpacaa.TOV[myclass]
    end    
        
    if myMaxExpansion == 27 then
        maxaa = maxexpacaa.COV[myclass]
    end    
    
    if myMaxExpansion == 28 then
        maxaa = maxexpacaa.TOL[myclass]
    end    
    
    if myMaxExpansion == 29 then
        maxaa = maxexpacaa.NOS[myclass]
    end    
    
     
    
    if level ~= maxlevel and aapct > 0 then
        setaapct = 0
        return true
    end
    if level == maxlevel and
        aapointsassigned < maxaa and
        exppct > 10 and
        exppct <= 99.98 and
        exppctint ~= aapct then
            setaapct = exppctint
        return true
    end
    if level == maxlevel and
        aapointsassigned < maxaa and
        exppct > 99.98 and 
        exppctint1 ~= aapct then
            setaapct = exppctint1
        return true
    end
    if level == maxlevel and
        aapointsassigned == maxaa and
        aapoints <229 then
            setaapct = exppctint1
        return true
    end
    if level == maxlevel and
        aapointsassigned == maxaa and
        aapoints >=230 then
            setaapct = 0
        return true
    end
    return false
end

local function action()
    if setaapct == 0 then
        mq.cmd('/alt off')
    else
        mq.cmdf('/alt on %s', setaapct)
    end
end

return {condfunc=condition, actionfunc=action}