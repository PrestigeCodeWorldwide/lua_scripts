---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

BL.info("\arPrepping Boxes for raid")

mq.cmd("/dgza /plugin autoaccept load")
mq.cmd("/timed 10 /dgza /autoaccept add ${Me.Name}")
mq.cmd("/timed 15 /dgza /autoaccept save")

mq.cmd("/dgza /timed 5 /pet inventory destroy primary")
mq.cmd("/dgza /timed 10 /pet inventory destroy secondary")

mq.cmd("/dgza /timed 20 /blockspell add pet 16287 16528 46212 65378 32376 63747 16525 6278 3290 64145 61421 16329 49719 49713 64105 63063 63033 11538 49278 61566 66969 68131 67005 68022 67011 67677")
mq.cmd("/dgza /timed 25 /blockspell remove pet 61568") -- Nights Perpetual Terror, otherwise chain casts

mq.cmd("/timed 5 /cwtna burnalways off")
mq.cmd("/timed 10 /cwtna burnallnamed off")
mq.cmd("/timed 15 /cwtna autoassistat 99")
mq.cmd("/timed 18 /cwtna useaoe on")
mq.cmd("/timed 20 /shd aoecount 99")
mq.cmd("/timed 21 /cwtna burncount 99")
mq.cmd("/timed 22 /cwtna chasedistance 10")
mq.cmd("/timed 23 /cwtna usemangling on")
mq.cmd("/dga /tribute personal on")
mq.cmd("/dga /trophy personal on")

mq.cmd("/dgza /enc usedoppleganger off")
mq.cmd("/dgza /clr usemelee off")      
mq.cmd("/dgza /dru usemelee off")
mq.cmd("/dgza /shm usemelee off")
mq.cmd("/dgza /shm usecannispell off")
mq.cmd("/dgza /shd usedeflection off")   
mq.cmd("/dgza /shd usebeza off")
mq.cmd("/dgza /shd usedotsnare off")
mq.cmd("/dgza /brd useswarm off")

mq.cmd("/cwtna usepetweapons off") -- Mage/bst/nec
mq.cmd("/cwtna selfpetweaponsonly off") -- mage
mq.cmd("/cwtna usepetshrink on")      -- Mage/bst/nec

mq.cmd("/cwtna xtargethealnpc on")
mq.cmd("/cwtna usextargethealing on")
mq.cmd("/cwtna pettaunttoggle off")

mq.delay(3000) -- approximate last /timed timer in ms
BL.info("\agDone prepping for raid!")
