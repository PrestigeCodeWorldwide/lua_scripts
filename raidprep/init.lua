---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

BL.info("\arPrepping Boxes for raid")

-- Auto accept group / auto accept rez 90%
mq.cmd("/plugin autoaccept load")
mq.cmd("/timed 10 /autoaccept add ${Me.Name}")
mq.cmd("/timed 15 /autoaccept save")
mq.cmd("/rez accept on")
mq.cmd("/rez pct 90")

-- Turn off pet taunt for classes whose plugin doesn't offer that choice, like ench/shm
mq.cmd("/pet notaunt")

-- Pet weapons destroy
mq.cmd("/timed 5 /pet inventory destroy primary")
mq.cmd("/timed 10 /pet inventory destroy secondary")

-- Block procs on pets
mq.cmd("/timed 20 /blockspell add pet 16287 16528 46212 65378 32376 63747 16525 6278 3290 64145 61421 16329 49719 49713 64105 63063 63033 11538 49278 61566 66969 68131 67005 68022 67011 67677")
mq.cmd("/timed 25 /blockspell remove pet 61568") -- Nights Perpetual Terror, otherwise chain casts, might be useless now that its changed 

-- Tribute enable
mq.cmd("/tribute personal on")
mq.cmd("/trophy personal on")

-- Generic CWTN settings
mq.cmd("/timed 5 /cwtn burnalways off")
mq.cmd("/timed 10 /cwtn burnallnamed off")
mq.cmd("/timed 15 /cwtn autoassistat 99")
mq.cmd("/timed 18 /cwtn useaoe on")
mq.cmd("/timed 21 /cwtn burncount 99")
mq.cmd("/timed 22 /cwtn chasedistance 10")

-- Cleric
mq.cmd("/squelch /clr usemelee off")
mq.cmd("/squelch /clr usenuke off")
mq.cmd("/squelch /clr battlemode off")
mq.cmd("/squelch /clr usestick on")

-- Shaman
mq.cmd("/squelch /shm usemelee off")
mq.cmd("/squelch /shm loadout 0")
mq.cmd("/squelch /shm usecannispell off")
mq.cmd("/squelch /shm usenuke off")
mq.cmd("/squelch /shm usedot off")
mq.cmd("/squelch /shm usepet off")

-- SK
mq.cmd("/squelch /shd aoecount 99")
mq.cmd("/squelch /shd usedeflection off")
mq.cmd("/squelch /shd usedisruption on")
mq.cmd("/squelch /shd usebeza off")
mq.cmd("/squelch /shd usedotsnare off")

-- Brd
mq.cmd("/squelch /brd useswarm off")

-- Ench
mq.cmd("/squelch /enc usedoppleganger off")

-- Mage/bst/nec-only settings...we'll use /cwtn to catch all of, has no effect on anyone else
mq.cmd("/squelch /cwtn usepetweapons off") -- Disable pet weapon summoning for group
mq.cmd("/squelch /cwtn selfpetweaponsonly off") -- And for self
mq.cmd("/squelch /cwtn pettaunttoggle off")
mq.cmd("/squelch /cwtn usepetshrink on")

-- Zrk
mq.cmd("/squelch /ber usemangling on")
mq.cmd("/squelch /ber usefrenzied off") -- roots for duration

-- Healers in general can all do this since it doesn't do anything if you don't put npc on xtar
mq.cmd("/squelch /cwtn xtargethealnpc on")
mq.cmd("/squelch /cwtn usextargethealing on")

mq.delay(5000) -- approximate last /timed timer in ms
mq.cmd("/g Done prepping for raid!")
