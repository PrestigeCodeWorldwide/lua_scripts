---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

BL.info("\arResetting Plugin Config for POST-RAID group content!")

mq.cmd("/cwtna usepetweapons on")
mq.cmd("/timed 1 /cwtna selfpetweaponsonly off")
mq.cmd("/timed 5 /pet inventory destroy primary")
mq.cmd("/timed 10 /pet inventory destroy secondary")
mq.cmd(
"/timed 20 /blockspell remove pet 16287 16528 46212 65378 32376 63747 16525 6278 3290 64145 61421 16329 49719 49713 64105 63063 63033 11538 49278 61566 66969 68131 67005 68022 67011 67677")
mq.cmd("/timed 15 /cwtna autoassistat 99")
mq.cmd("/timed 20 /cwtna aoecount 3")
mq.cmd("/timed 21 /cwtna burncount 99")
mq.cmd("/timed 22 /cwtna chasedistance 10")

mq.cmd("/cwtna usealliance off")
mq.cmd("/cwtna forcealliance off")
mq.cmd("/cwtna useaoe on")
mq.cmd("/cwtn useglyph off")        -- DPS uses glyph automatically on burns, but NOT driver/tank, note the /cwtn not /cwtnA
mq.cmd("/cwtna usedeflection off") -- SK
mq.cmd("/cwtna usepetweapons on") -- Shm

mq.delay(3000) -- approximate last /timed timer in ms

BL.info("\agDone resetting for group content!")
