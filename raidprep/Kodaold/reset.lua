---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

local function RunCommand(cmd)
    mq.cmd(cmd)
    mq.delay(100)
end

BL.info("\arResetting Plugin Config for POST-RAID group content!")

RunCommand("/dgza /timed 20 /blockspell remove pet 16287 16528 46212 65378 32376 63747 16525 6278 3290 64145 61421 16329 49719 49713 64105 63063 63033 11538 49278 61566 66969 68131 67005 68022 67011 67677 61568")

RunCommand("/tribute personal off")
RunCommand("/trophy personal off")

RunCommand("/cwtn burnalways off")
RunCommand("/cwtn burnallnamed on")
RunCommand("/cwtn autoassistat 100")
RunCommand("/cwtn useaoe on")
RunCommand("/cwtn burncount 4")
RunCommand("/cwtn chasedistance 10")
RunCommand("/cwtn campradius 60")

RunCommand("/cwtn usealliance off")

-- Cleric
RunCommand("/squelch /clr usemelee on")
RunCommand("/squelch /clr usenuke on")
RunCommand("/squelch /clr battlemode on")
RunCommand("/squelch /clr usestick on")

-- Shaman
RunCommand("/squelch /shm usemelee on")
RunCommand("/squelch /shm loadout 1")
RunCommand("/squelch /shm usecannispell off")
RunCommand("/squelch /shm usenuke on")
RunCommand("/squelch /shm usedot on")
RunCommand("/squelch /shm usepet on")
RunCommand("/pet notaunt")

-- SK
RunCommand("/squelch /shd aoecount 2")
RunCommand("/squelch /shd usedeflection off")
RunCommand("/squelch /shd usedisruption on")
RunCommand("/squelch /shd usebeza on")
RunCommand("/squelch /shd usedotsnare off")

-- Brd
RunCommand("/squelch /brd useswarm on")

-- Ench
RunCommand("/squelch /enc usedoppleganger on")

-- Mage/bst/nec-only settings...we'll use /cwtn to catch all of, has no effect on anyone else
RunCommand("/squelch /cwtn usepetweapons on")      -- Disable pet weapon summoning for group
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

BL.info("\agDone resetting for group content!")
