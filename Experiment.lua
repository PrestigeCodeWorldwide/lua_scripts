-- version 0.06
-- Accompanying script for Offtank.lua, does nothing but make sure group role isn't set to MT
-- and gives MTs something to run
---@type Mq
local mq = require('mq')
--- @type ImGui
--require('ImGui')

local PackageMan = require('mq/PackageMan')
local BL = PackageMan.Require('mq-biggerlib')

BL.cmd.pauseAutomation()
