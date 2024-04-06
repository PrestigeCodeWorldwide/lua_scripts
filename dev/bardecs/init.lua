--- @type Mq
local mq = require('mq')
--- @type ImGui
require('ImGui')
local BL = require("biggerlib")
require('utils.log')
local ECS = require('ECS')
local World, System, Query = ECS.World, ECS.System, ECS.Query

----------------------------------------------------------------------------------------------

--local Health = ECS.Component(100)
local QuestGiver = ECS.Component({ name = 'a worrisome shade', id = 5033 })


local isInAcid = Query.Filter(function()
	return true -- it's wet season
end)

-- I believe task makes it run earlier each frame than process
local UpdateStateSystem = System('task', Query.All(QuestGiver))

function UpdateStateSystem:Update()
	local state = self.world:Res('state')	
end

local InAcidSystem = System('process', Query.All(Health, Position, isInAcid()))

function InAcidSystem:Update()
	for i, entity in self:Result():Iterator() do
		local health = entity[Health]
		health.value = health.value - 0.01
		print('Health: ' .. health.value)
	end
end

function InAcidSystem:Initialize(config)
	BL.info('Initializing InAcidSystem with config: %s', tostring(config or 'NONE'))
end





local function initSettings(world)
    local state = {
        paused = false,
        myClass = mq.TLO.Me.Class.ShortName(),
		currentZoneId = mq.TLO.Zone.ID(),
	}
    world:AddResource(state, 'state')
	-- world:Res('state') -- getter reminder
end

-- Create a new system InitWorldSystem that converts oldbard/init.lua's init function to an ECS system like InAcidSystem

----- Perform world update. When registered, the LoopManager will invoke World Update for each step in the sequence.
-----@param world World ECS World to update
-----@param step string 'process' | 'transform' | 'render'
-----@param now number
local function ECSUpdate(world, step, now)
	print('Calling world update')
	world:Update(step, now)
end

--local ent = world:Entity(Position.New({ x = 5 }), Health.New())
--local entity = world:Entity(
--	Position({ x = 5 }),
--	Health.New()
--)



local function runMainLoop()
	local world = World()
	-- REMINDER ITS world: NOT world.
	-- world:AddSystem(InAcidSystem)
	initSettings(world)
	while true do
		mq.delay(1000)
		local now = mq.gettime()
		ECSUpdate(world, 'process', now)
	end
end

--return main

runMainLoop()
