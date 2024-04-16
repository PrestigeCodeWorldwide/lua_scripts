--[[
Usage
=====

In its simplest form, create a standalone state machine using:

```lua
local machine = require('statemachine')

local fsm = machine.create({
  initial = 'green',
  events = {
    { name = 'warn',  from = 'green',  to = 'yellow' },
    { name = 'panic', from = 'yellow', to = 'red'    },
    { name = 'calm',  from = 'red',    to = 'yellow' },
    { name = 'clear', from = 'yellow', to = 'green'  }
}})
```

... will create an object with a method for each event:

 * fsm:warn()  - transition from 'green' to 'yellow'
 * fsm:panic() - transition from 'yellow' to 'red'
 * fsm:calm()  - transition from 'red' to 'yellow'
 * fsm:clear() - transition from 'yellow' to 'green'

along with the following members:c

 * fsm.current   - contains the current state
 * fsm.currentTransitioningEvent - contains the current event that is in a transition.
 * fsm:is(s)     - return true if state `s` is the current state
 * fsm:can(e)    - return true if event `e` can be fired in the current state
 * fsm:cannot(e) - return true if event `e` cannot be fired in the current state

Multiple 'from' and 'to' states for a single event
==================================================

If an event is allowed **from** multiple states, and always transitions to the same
state, then simply provide an array of states in the `from` attribute of an event. However,
if an event is allowed from multiple states, but should transition **to** a different
state depending on the current state, then provide multiple event entries with
the same name:

```lua
local machine = require('statemachine')

local fsm = machine.create({
  initial = 'hungry',
  events = {
    { name = 'eat',  from = 'hungry',                                to = 'satisfied' },
    { name = 'eat',  from = 'satisfied',                             to = 'full'      },
    { name = 'eat',  from = 'full',                                  to = 'sick'      },
    { name = 'rest', from = {'hungry', 'satisfied', 'full', 'sick'}, to = 'hungry'    },
}})
```

This example will create an object with 2 event methods:

 * fsm:eat()
 * fsm:rest()

The `rest` event will always transition to the `hungry` state, while the `eat` event
will transition to a state that is dependent on the current state.

>> NOTE: The `rest` event could use a wildcard '*' for the 'from' state if it should be
allowed from any current state.

>> NOTE: The `rest` event in the above example can also be specified as multiple events with
the same name if you prefer the verbose approach.

Callbacks
=========

4 callbacks are available if your state machine has methods using the following naming conventions:

 * onbefore**event** - fired before the event
 * onleave**state**  - fired when leaving the old state
 * onenter**state**  - fired when entering the new state
 * onafter**event**  - fired after the event

You can affect the event in 3 ways:

 * return `false` from an `onbeforeevent` handler to cancel the event.
 * return `false` from an `onleavestate` handler to cancel the event.
 * return `ASYNC` from an `onleavestate` or `onenterstate` handler to perform an asynchronous state transition (see next section)

For convenience, the 2 most useful callbacks can be shortened:

 * on**event** - convenience shorthand for onafter**event**
 * on**state** - convenience shorthand for onenter**state**

In addition, a generic `onstatechange()` callback can be used to call a single function for _all_ state changes:

All callbacks will be passed the same arguments:

 * **self**
 * **event** name
 * **from** state
 * **to** state
 * _(followed by any arguments you passed into the original event method)_

Callbacks can be specified when the state machine is first created:

```lua
local machine = require('statemachine')

local fsm = machine.create({
  initial = 'green',
  events = {
    { name = 'warn',  from = 'green',  to = 'yellow' },
    { name = 'panic', from = 'yellow', to = 'red'    },
    { name = 'calm',  from = 'red',    to = 'yellow' },
    { name = 'clear', from = 'yellow', to = 'green'  }
  },
  callbacks = {
    onpanic =  function(self, event, from, to, msg) print('panic! ' .. msg)    end,
    onclear =  function(self, event, from, to, msg) print('thanks to ' .. msg) end,
    ongreen =  function(self, event, from, to)      print('green light')       end,
    onyellow = function(self, event, from, to)      print('yellow light')      end,
    onred =    function(self, event, from, to)      print('red light')         end,
  }
})

fsm:warn()
fsm:panic('killer bees')
fsm:calm()
fsm:clear('sedatives in the honey pots')
...
```

Additionally, they can be added and removed from the state machine at any time:

```lua
fsm.ongreen       = nil
fsm.onyellow      = nil
fsm.onred         = nil
fsm.onstatechange = function(self, event, from, to) print(to) end
```

or
```lua
function fsm:onstatechange(event, from, to) print(to) end
```

Asynchronous State Transitions
==============================

Sometimes, you need to execute some asynchronous code during a state transition and ensure the
new state is not entered until your code has completed.

A good example of this is when you transition out of a `menu` state, perhaps you want to gradually
fade the menu away, or slide it off the screen and don't want to transition to your `game` state
until after that animation has been performed.

You can now return `ASYNC` from your `onleavestate` and/or `onenterstate` handlers and the state machine
will be _'put on hold'_ until you are ready to trigger the transition using the new `transition(eventName)`
method.

If another event is triggered during a state machine transition, the event will be triggered relative to the
state the machine was transitioning to or from. Any calls to `transition` with the cancelled async event name
will be invalidated.

During a state change, `asyncState` will transition from `NONE` to `[event]WaitingOnLeave` to `[event]WaitingOnEnter`,
looping back to `NONE`. If the state machine is put on hold, `asyncState` will pause depending on which handler
you returned `ASYNC` from.

Example of asynchronous transitions:

```lua
local machine = require('statemachine')
local manager = require('SceneManager')

local fsm = machine.create({

  initial = 'menu',

  events = {
    { name = 'play', from = 'menu', to = 'game' },
    { name = 'quit', from = 'game', to = 'menu' }
  },

  callbacks = {

    onentermenu = function() manager.switch('menu') end,
    onentergame = function() manager.switch('game') end,

    onleavemenu = function(fsm, name, from, to)
      manager.fade('fast', function()
        fsm:transition(name)
      end)
      return fsm.ASYNC -- tell machine to defer next state until we call transition (in fadeOut callback above)
    end,

    onleavegame = function(fsm, name, from, to)
      manager.slide('slow', function()
        fsm:transition(name)
      end)
      return fsm.ASYNC -- tell machine to defer next state until we call transition (in slideDown callback above)
    end,
  }
})
```

If you decide to cancel the async event, you can call `fsm.cancelTransition(eventName)`

Initialization Options
======================

How the state machine should initialize can depend on your application requirements, so
the library provides a number of simple options.

By default, if you dont specify any initial state, the state machine will be in the `'none'`
state and you would need to provide an event to take it out of this state:

```lua
local machine = require('statemachine')

local fsm = machine.create({
  events = {
    { name = 'startup', from = 'none',  to = 'green' },
    { name = 'panic',   from = 'green', to = 'red'   },
    { name = 'calm',    from = 'red',   to = 'green' },
}})

print(fsm.current) -- "none"
fsm:startup()
print(fsm.current) -- "green"
```

If you specify the name of your initial event (as in all the earlier examples), then an
implicit `startup` event will be created for you and fired when the state machine is constructed.

```lua
local machine = require('statemachine')

local fsm = machine.create({
  inital = 'green',
  events = {
    { name = 'panic',   from = 'green', to = 'red'   },
    { name = 'calm',    from = 'red',   to = 'green' },
}})
print(fsm.current) -- "green"
```
]]

local machine = {}
machine.__index = machine

local NONE = "none"
local ASYNC = "async"

local function call_handler(handler, params)
	if handler then
		return handler(unpack(params))
	end
end

local function create_transition(name)
	local can, to, from, params

	local function transition(self, ...)
		if self.asyncState == NONE then
			can, to = self:can(name)
			from = self.current
			params = { self, name, from, to, ... }

			if not can then
				return false
			end
			self.currentTransitioningEvent = name

			local beforeReturn = call_handler(self["onbefore" .. name], params)
			local leaveReturn = call_handler(self["onleave" .. from], params)

			if beforeReturn == false or leaveReturn == false then
				return false
			end

			self.asyncState = name .. "WaitingOnLeave"

			if leaveReturn ~= ASYNC then
				transition(self, ...)
			end

			return true
		elseif self.asyncState == name .. "WaitingOnLeave" then
			self.current = to

			local enterReturn = call_handler(self["onenter" .. to] or self["on" .. to], params)

			self.asyncState = name .. "WaitingOnEnter"

			if enterReturn ~= ASYNC then
				transition(self, ...)
			end

			return true
		elseif self.asyncState == name .. "WaitingOnEnter" then
			call_handler(self["onafter" .. name] or self["on" .. name], params)
			call_handler(self["onstatechange"], params)
			self.asyncState = NONE
			self.currentTransitioningEvent = nil
			return true
		else
			if string.find(self.asyncState, "WaitingOnLeave") or string.find(self.asyncState, "WaitingOnEnter") then
				self.asyncState = NONE
				transition(self, ...)
				return true
			end
		end

		self.currentTransitioningEvent = nil
		return false
	end

	return transition
end

local function add_to_map(map, event)
	if type(event.from) == "string" then
		map[event.from] = event.to
	else
		for _, from in ipairs(event.from) do
			map[from] = event.to
		end
	end
end

function machine.create(options)
	assert(options.events)

	local fsm = {}
	setmetatable(fsm, machine)

	fsm.options = options
	fsm.current = options.initial or "none"
	fsm.asyncState = NONE
	fsm.events = {}

	for _, event in ipairs(options.events or {}) do
		local name = event.name
		fsm[name] = fsm[name] or create_transition(name)
		fsm.events[name] = fsm.events[name] or { map = {} }
		add_to_map(fsm.events[name].map, event)
	end

	for name, callback in pairs(options.callbacks or {}) do
		fsm[name] = callback
	end

	return fsm
end

function machine:is(state)
	return self.current == state
end

function machine:can(e)
	local event = self.events[e]
	local to = event and event.map[self.current] or event.map["*"]
	return to ~= nil, to
end

function machine:cannot(e)
	return not self:can(e)
end

function machine:todot(filename)
	local dotfile = io.open(filename, "w")
	dotfile:write("digraph {\n")
	local transition = function(event, from, to)
		dotfile:write(string.format("%s -> %s [label=%s];\n", from, to, event))
	end
	for _, event in pairs(self.options.events) do
		if type(event.from) == "table" then
			for _, from in ipairs(event.from) do
				transition(event.name, from, event.to)
			end
		else
			transition(event.name, event.from, event.to)
		end
	end
	dotfile:write("}\n")
	dotfile:close()
end

function machine:transition(event)
	if self.currentTransitioningEvent == event then
		return self[self.currentTransitioningEvent](self)
	end
end

function machine:cancelTransition(event)
	if self.currentTransitioningEvent == event then
		self.asyncState = NONE
		self.currentTransitioningEvent = nil
	end
end

machine.NONE = NONE
machine.ASYNC = ASYNC

return machine
