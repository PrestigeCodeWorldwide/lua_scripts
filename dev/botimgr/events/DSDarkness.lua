local mq = require('mq')
local os = require('os')
local my_class = mq.TLO.Me.Class.ShortName()

-- Constants
MIN_X = 150
MAX_X = 300
MIN_Y = 150
MAX_Y = 300

-- Variables  
local my_x = mq.TLO.Me.X()
local my_y= mq.TLO.Me.Y()
local my_z = -46

function resetLocs()
   my_x = mq.TLO.Me.X()
   my_y= mq.TLO.Me.Y()
end

function randLocs()     
    -- offset os time with the loc of character to get a different seed
    math.randomseed(os.time() * my_x / my_y);
    -- get the x and y of the character to run to from current x and y location
    my_x = math.random(MIN_Y + my_y, MAX_Y + my_y)    
    my_y = math.random(MIN_X + my_x, MAX_X + my_x)                  
    print("Moving to location: " .. my_x .. " " .. " " .. my_y .. " " .. my_z)
    -- nav to location
    --mq.cmd('/nav locyxz ' .. my_y .. '  ' .. my_x .. '  ' .. my_z)
    resetLocs() 
end

local function findNearestPC() 
    local n = 2
    local nearest = mq.TLO.NearestSpawn(n)
    while nearest.Type() ~= "PC" do
        n = n + 1
        nearest = mq.TLO.NearestSpawn(n)
        mq.delay(100)
    end
    return nearest
end

local function runAwayFromOthers() 
    local nearestSpawn = findNearestPC()
    print(nearestSpawn)

    while nearestSpawn.Distance() < 150 do
        mq.cmdf('/face fast away loc %s, %s, %s', nearestSpawn.X(), nearestSpawn.Y(), nearestSpawn.Z())
        mq.cmd("/keypress forward hold")
        mq.delay(100)
        nearestSpawn = findNearestPC()
        print(nearestSpawn)
        mq.cmd("/timed 10 /keypress forward")
    end
end

local function event_handler(line, name)
    if not mq.TLO.Zone.ShortName() == 'umbraltwo_raid' then return end
    if name == mq.TLO.Me.CleanName() then       
        if my_class == 'BER' and mq.TLO.Me.ActiveDisc.Name() == mq.TLO.Spell('Frenzied Resolve Discipline').RankName() then
            mq.cmd('/stopdisc')
        end
        mq.cmd('/boxr Pause')
        mq.cmd('/twist stop')
        mq.cmd('/attack off')

        randLocs() -- nav to hopefully a random, unique location
        while mq.TLO.Nav.Active() do -- wait till I get there before continuing next command
            mq.delay(100)
        end

        runAwayFromOthers() -- make sure no other PC is within 150'
        mq.delay(3000) --should probably replace this with a complete timer to know when to run back

        mq.cmd('/nav spawn pc ='..mq.TLO.Raid.MainAssist.Name())
        mq.cmd('/boxr Unpause')
        mq.cmd('/twist start')
    end
end

return {eventfunc=event_handler}