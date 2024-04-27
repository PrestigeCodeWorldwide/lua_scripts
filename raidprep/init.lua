---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

local function RunCommand(cmd)
    mq.cmd(cmd)
    mq.delay(250)
end

BL.info("\arPrepping Boxes for raid")

-- Auto accept group / auto accept rez 90%
RunCommand("/plugin autoaccept load")
RunCommand("/autoaccept add ${Me.Name}")
RunCommand("/autoaccept save")
RunCommand("/rez accept on")
RunCommand("/rez pct 90")

-- Turn off pet taunt for classes whose plugin doesn't offer that choice, like ench/shm
RunCommand("/pet notaunt")

-- Pet weapons destroy
RunCommand("/pet inventory destroy primary")
RunCommand("/pet inventory destroy secondary")

-- Block procs on pets
RunCommand(
"/blockspell add pet 16287 16528 46212 65378 32376 63747 16525 6278 3290 64145 61421 16329 49719 49713 64105 63063 63033 11538 49278 61566 66969 68131 67005 68022 67011 67677")
RunCommand("/timed 20 /blockspell remove pet 61568") -- Nights Perpetual Terror, otherwise chain casts, might be useless now that its changed
RunCommand('/blockspell add me 67100') -- Rogue trickery effect

-- Tribute enable
RunCommand("/tribute personal on")
RunCommand("/trophy personal on")

-- Generic CWTN settings
RunCommand("/cwtn burnalways off")
RunCommand("/cwtn burnallnamed off")
RunCommand("/cwtn autoassistat 99")
RunCommand("/cwtn useaoe on")
RunCommand("/cwtn burncount 99")
RunCommand("/cwtn chasedistance 10")

-- Cleric
RunCommand("/squelch /clr usemelee off")
RunCommand("/squelch /clr usenuke off")
RunCommand("/squelch /clr battlemode off")
RunCommand("/squelch /clr usestick on")

-- Shaman
RunCommand("/squelch /shm usemelee off")
RunCommand("/squelch /shm loadout 0")
RunCommand("/squelch /shm usecannispell off")
RunCommand("/squelch /shm usenuke off")
RunCommand("/squelch /shm usedot off")
RunCommand("/squelch /shm usepet off")

-- SK
RunCommand("/squelch /shd aoecount 99")
RunCommand("/squelch /shd usedeflection off")
RunCommand("/squelch /shd usedisruption on")
RunCommand("/squelch /shd usebeza off")
RunCommand("/squelch /shd usedotsnare off")

-- Brd
RunCommand("/squelch /brd useswarm off")

-- Ench
RunCommand("/squelch /enc usedoppleganger off")

-- Mage/bst/nec-only settings...we'll use /cwtn to catch all of, has no effect on anyone else
RunCommand("/squelch /cwtn usepetweapons off")      -- Disable pet weapon summoning for group
RunCommand("/squelch /cwtn selfpetweaponsonly off") -- And for self
RunCommand("/squelch /cwtn pettaunttoggle off")
RunCommand("/squelch /cwtn usepetshrink on")

-- Zrk
RunCommand("/squelch /ber usemangling on")
RunCommand("/squelch /ber usefrenzied off") -- roots for duration

-- Healers in general can all do this since it doesn't do anything if you don't put npc on xtar
RunCommand("/squelch /cwtn xtargethealnpc on")
RunCommand("/squelch /cwtn usextargethealing on")

mq.delay(1000) -- approximate last /timed timer in ms
RunCommand("/g Done prepping for raid!")
