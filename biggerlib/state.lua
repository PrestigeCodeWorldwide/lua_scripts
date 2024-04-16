---@type Mq
local mq = require('mq')
local Log = require('biggerlib.Log')
---@type ImGui
local ImGui = require('ImGui')

---@class ScriptState
---@field Paused boolean
---@field DirtyFlag boolean


local ScriptState = {}
ScriptState.__index = ScriptState

