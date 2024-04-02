--Written by KingArthur

local mq = require("mq")

local SMezSong = mq.TLO.Spell('Slumber of Suja').RankName()
local SMezGem = mq.TLO.Me.Gem(SMezSong)

local function StopDPS()
    mq.cmd('/mqp on')
    mq.delay(100)
    mq.cmd('/boxr pause')
    mq.delay(1000)
    mq.cmd('/twist off')
    while mq.TLO.Me.Casting.ID() do
      mq.delay(500)
    end 
end

local function StartDPS()
  mq.cmd('/mqp off')
  mq.delay(100)
  mq.cmd('/boxr unpause')
end

local function ResumeDPS()
   mq.cmd('/mqp off')
   mq.delay(100)
   mq.cmd('/boxr unpause')
   mq.delay(1000)
end

local function TarNPC(npcid)
 if mq.TLO.Target.ID() ~= npcid then
       mq.cmdf('/tar id %s', npcid)
       mq.delay(1000)
       while mq.TLO.Target.BuffsPopulated() ~= true do
         mq.delay(200)
       end
    end
end   

local function SingSMez()
  mq.cmdf('/twist once %s', SMezGem)
  mq.delay(4000)
  mq.cmd('/echo SMez on %s for Calming Stones', mq.TLO.Target.Name())
end

while true do
  for i=1,4 do
    if mq.TLO.NearestSpawn(i..',npc smirk los').ID() and mq.TLO.NearestSpawn(i..',npc smirk los').Animation() ~= 110 then
      mq.delay(100)
      TarNPC(mq.TLO.NearestSpawn(i..',npc smirk los').ID())
        if mq.TLO.Target.Name.Find('smirk')() then
          StopDPS()
          SingSMez()------------------------------------------------------------------------------------------------------------------------------------------------------
          StartDPS()
      end
    end
  end 
    mq.delay(10)
end