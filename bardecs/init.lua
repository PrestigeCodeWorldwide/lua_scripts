--- @type Mq
local mq = require("mq")
--- @type ImGui
require("ImGui")

require("utils.log")
local ECS = require("ECS")
local World, System, Query = ECS.World, ECS.System, ECS.Query

----------------------------------------------------------------------------------------------

local Health = ECS.Component(100)
local Position = ECS.Component({ x = 0, y = 0 })

local isInAcid = Query.Filter(function()
	return true -- it's wet season
end)

local InAcidSystem = System("process", Query.All(Health, Position, isInAcid()))

function InAcidSystem:Update()
	for i, entity in self:Result():Iterator() do
		local health = entity[Health]
		health.value = health.value - 0.01
		print("Health: " .. health.value)
	end
end

function InAcidSystem:Initialize(config)
	--print("Initializing InAcidSystem with config: " .. tostring(config or "NONE"))
	info("Initializing InAcidSystem with config: %s", tostring(config or "NONE"))
	warn("This is a warning")
	error("This is an ERROR")
	debug("This is debug")
	trace("This is trace")

	info("Using Dump")
	dump(Position)
end

local world = World()
-- REMINDER ITS world: NOT world.
world:AddSystem(InAcidSystem)
--local world = World()

local ent = world:Entity(Position.New({ x = 5 }), Health.New())
--local entity = world:Entity(
--	Position({ x = 5 }),
--	Health.New()
--)

-- Create a new system InitWorldSystem that converts oldbard/init.lua's init function to an ECS system like InAcidSystem

----- Perform world update. When registered, the LoopManager will invoke World Update for each step in the sequence.
-----@param world World ECS World to update
-----@param step string 'process' | 'transform' | 'render'
-----@param now number
local function ECSUpdate(world, step, now)
	print("Calling world update")
	world:Update(step, now)
end

local function runMainLoop()
	while true do
		mq.delay(1000)
		local now = mq.gettime()
		ECSUpdate(world, "process", now)
	end
end

--return main

runMainLoop()
