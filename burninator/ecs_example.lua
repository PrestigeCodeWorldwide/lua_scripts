--- @type Mq
local mq = require('mq')
--- @type ImGui
require('ImGui')

local fun = require('fun')
local ECS = require('zenbard.ecs.init')
local System, Query = ECS.System, ECS.Query

--- Defines the possible states of a step in a game engine.
---@class Step
---@field process string Runs at the top of each frame
---@field transform string Runs after physics sim
---@field render string Runs AFTER rendering
local Step = {
	process = 'process',
	transform = 'transform',
	render = 'render',
}

--- Color helper function -- on state is green, off state is red
local function color(val)
	if val == 'on' then
		val = '\agon'
	elseif val == 'off' then
		val = '\aroff'
	end
	return val
end

local Position = ECS.Component({
	x = 0,
	y = 0,
	z = 0,
})

-- the same as:
-- ECS.Component({ value = 0.1 })
local Acceleration = ECS.Component(0.1)

local PositionLogSystem = System(
	Step.process,
	2,
	Query.All(Position, Acceleration),
	function(self, Time)
		self:Result():ForEach(function(entity)
			local pos = entity[Position]

			local msg = 'Entity with ID: %d has Position = {x: %0.2f, y: %0.2f, z: %0.2f}'
			--print(msg:format(entity.id, pos.x, pos.y, pos.z))
		end)
	end
)

local MovableSystem = System('process', 1, Query.All(Acceleration, Position))

-- This method will be called on all frames by default.
function MovableSystem:Update(Time)
	local delta = Time.DeltaFixed

	-- Iterate through all entities in the query
	for i, entity in self:Result():Iterator() do
		local acceleration = entity:Get(Acceleration).value

		local position = entity[Position]
		position.x = position.x + acceleration * delta
		position.y = position.y + acceleration * delta
		position.z = position.z + acceleration * delta
	end
end

local world = ECS.World()
world:AddSystem(PositionLogSystem)
world:AddSystem(MovableSystem)

local entity1 = world:Entity(Position())

local entity2 = world:Entity(Position({ x = 5 }), Acceleration(1))

--- Perform world update. When registered, the LoopManager will invoke World Update for each step in the sequence.
---@param world World ECS World to update
---@param step Step beginning of frame| after physics | before render
---@param now number
local function ECSUpdate(world, step, now)
	print('Calling world update')
	world:Update(step, now)
end

for _k, a in fun.range(3) do
	print(a)
end

while true do
	mq.delay(50)
	local now = mq.gettime()
	ECSUpdate(world, Step.process, now)
end
