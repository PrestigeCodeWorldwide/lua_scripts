---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

BL.info("\arPrepping Boxes for raid")

mq.cmd("/cwtna usepetweapons off")
mq.cmd("/timed 1 /cwtna selfpetweaponsonly off")
mq.cmd("/timed 5 /pet inventory destroy primary")
mq.cmd("/timed 10 /pet inventory destroy secondary")
mq.cmd("/timed 20 /blockspell add pet 16287 16528 46212 65378 32376 63747 16525 6278 3290 64145 61421 16329 49719 49713 64105 63063 63033 11538 49278 61566 66969 68131 67005 68022 67011 67677")
mq.cmd("/timed 25 /blockspell remove pet 61568") -- Nights Perpetual Terror, otherwise chain casts
mq.cmd("/timed 5 /cwtna burnalways off")
mq.cmd("/timed 10 /cwtna burnallnamed off")
mq.cmd("/timed 15 /cwtna autoassistat 99")
mq.cmd("/timed 20 /cwtna aoecount 99")
mq.cmd("/timed 21 /cwtna burncount 99")
mq.cmd("/timed 22 /cwtna chasedistance 60")
mq.cmd("/timed 23 /cwtna usemangling off")

mq.cmd("/cwtna usealliance on")
mq.cmd("/cwtna forcealliance on")
mq.cmd("/cwtna useaoe off")
mq.cmd("/cwtna usedeflection off") -- SK
mq.cmd("/cwtna usebeza off")
mq.cmd("/cwtna usedotsnare off")
mq.cmd("/cwtna usepetweapons off") -- Shm
mq.cmd("/cwtna xtargethealnpc on")
mq.cmd("/cwtna usextargethealing on")
mq.cmd("/cwtna usecannispell off")
mq.cmd("/cwtna pettaunttoggle off")

mq.delay(3000) -- approximate last /timed timer in ms
BL.info("\agDone prepping for raid!")
