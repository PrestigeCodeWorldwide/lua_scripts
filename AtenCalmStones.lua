local mq = require("mq")
local BL = require("biggerlib")

BL.info("AtenCalmStones v1.0 Started")

local SMezSong = mq.TLO.Spell('Slumber of Suja').RankName()
local SMezGem = nil
if SMezSong then
  SMezGem = mq.TLO.Me.Gem(SMezSong)
end

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
  if SMezGem then
    mq.cmdf('/twist once %s', SMezGem)
    mq.delay(4000)
    mq.cmd('/echo SMez on %s for Calming Stones', mq.TLO.Target.Name())
  end
end

while true do
  for i=1,4 do
    local npcSpawn = mq.TLO.NearestSpawn(i..',npc smirk')
    if npcSpawn.ID() and npcSpawn.Animation() ~= 110 then  -- Animation 110 is mezzed
      mq.delay(100)
      TarNPC(npcSpawn.ID())
      if mq.TLO.Target() and mq.TLO.Target.Name() and mq.TLO.Target.Name():find('smirk') then
        StopDPS()
        SingSMez()
        ResumeDPS()
        break
      end
    end
  end 
  mq.delay(100)
end