---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

BL.info("\arResetting Plugin Config for POST-RAID group content!")

mq.cmd(
"/dgza /timed 20 /blockspell remove pet 16287 16528 46212 65378 32376 63747 16525 6278 3290 64145 61421 16329 49719 49713 64105 63063 63033 11538 49278 61566 66969 68131 67005 68022 67011 67677 61568")

mq.cmd("/tribute personal off")
mq.cmd("/trophy personal off")

mq.cmd("/timed 5  /cwtn burnalways off")
mq.cmd("/timed 10 /cwtn burnallnamed on")
mq.cmd("/timed 15 /cwtn autoassistat 100")
mq.cmd("/timed 18 /cwtn useaoe on")
mq.cmd("/timed 21 /cwtn burncount 4")
mq.cmd("/timed 22 /cwtn chasedistance 10")
mq.cmd("/timed 23 /cwtn campradius 60")

mq.cmd("/cwtn usealliance off")

-- Cleric
mq.cmd("/squelch /clr usemelee on")
mq.cmd("/squelch /clr usenuke on")
mq.cmd("/squelch /clr battlemode on")
mq.cmd("/squelch /clr usestick on")

-- Shaman
mq.cmd("/squelch /shm usemelee on")
mq.cmd("/squelch /shm loadout 1")
mq.cmd("/squelch /shm usecannispell off")
mq.cmd("/squelch /shm usenuke on")
mq.cmd("/squelch /shm usedot on")
mq.cmd("/squelch /shm usepet on")
mq.cmd("/timed 30 /pet notaunt")

-- SK
mq.cmd("/squelch /shd aoecount 2")
mq.cmd("/squelch /shd usedeflection off")
mq.cmd("/squelch /shd usedisruption on")
mq.cmd("/squelch /shd usebeza on")
mq.cmd("/squelch /shd usedotsnare off")

-- Brd
mq.cmd("/squelch /brd useswarm on")

-- Ench
mq.cmd("/squelch /enc usedoppleganger on")

-- Mage/bst/nec-only settings...we'll use /cwtn to catch all of, has no effect on anyone else
mq.cmd("/squelch /cwtn usepetweapons on")      -- Disable pet weapon summoning for group
mq.cmd("/squelch /cwtn selfpetweaponsonly off") -- And for self
mq.cmd("/squelch /cwtn pettaunttoggle off")
mq.cmd("/squelch /cwtn usepetshrink on")

-- Zrk
mq.cmd("/squelch /ber usemangling on")
mq.cmd("/squelch /ber usefrenzied off") -- roots for duration

-- Healers in general can all do this since it doesn't do anything if you don't put npc on xtar
mq.cmd("/squelch /cwtn xtargethealnpc on")
mq.cmd("/squelch /cwtn usextargethealing on")


mq.delay(3000) -- approximate last /timed timer in ms

BL.info("\agDone resetting for group content!")
