---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

BL.info("Prepping pets for raid")
mq.cmd(
    "/multiline ; /mag usepetweapons off ; /timed 1 /mag selfpetweaponsonly off ; /timed 5 /pet inventory destroy primary; /timed 10 /pet inventory destroy secondary ; /timed 20 /blockspell add pet 16287 16528 46212 65378 32376 63747 16525 6278 3290 64145 61421 16329 49719 49713 64105 63063 63033 11538 49278 61566 66969 68131 67005 68022 67011 67677"
)

mq.delay(4000)
BL.info("Done blocking pet buffs")

