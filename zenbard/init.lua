--- @type Mq
local mq = require('mq')
--- @type ImGui
require 'ImGui'

local ECS = require("ecs")
local System, Query = ECS.System, ECS.Query

--- Defines the possible states of a step in a game engine.
---@class Step
---@field process string Runs at the top of each frame
---@field transform string Runs after physics sim
---@field render string Runs AFTER rendering
local Step = {
	process = "process",
	transform = "transform",
	render = "render"
}

local Position = ECS.Component({
	x = 0, y = 0, z = 0
})

-- ECS.Component({ value = 0.1 })
local Acceleration = ECS.Component(0.1)

local PositionLogSystem = ECS.System("process", 2, ECS.Query.All(Position), function(self, Time)
	-- Iterate through all entities in the query
	self:Result():ForEach(function(entity)
		-- Access the `Position` component in the current entity
		local pos = entity[Position]

		local msg = "Entity with ID: %d has Position = {x: %0.2f, y: %0.2f, z: %0.2f}"
		print(msg:format(entity.id, pos.x, pos.y, pos.z))
	end)
end)

local SystemDemo = ECS.System("process", 1)

local world = ECS.World();
world:AddSystem(PositionLogSystem)

local entity1 = world:Entity(Position())

local entity2 = world:Entity(
	Position({ x = 5 }),
	Acceleration(1)
)

local entity3 = world:Entity(
	Position.New({ x = 5 }),
	Acceleration.New(1)
)

local entity4 = world:Entity(
	Position({ x = 5 }),
	Acceleration({ value = 1 })
)

local entity5 = world:Entity()
entity5[Position] = { y = 5 }
entity5:Set(Acceleration())

local entity6 = world:Entity()
entity6[Position] = Position()
entity6:Set(Acceleration())

--- Perform world update. When registered, the LoopManager will invoke World Update for each step in the sequence.
---@param world World ECS World to update
---@param step string 'process' | 'transform' | 'render'
---@param now number
local function ECSUpdate(world, step, now)
	print("Calling world update")
	world:Update(step, now)
end

while true do
	mq.delay(50)
	local now = mq.gettime()
	ECSUpdate(world, Step.process, now)
end
