---@type Mq
local mq = require("mq")
---@type BL
local BL = require("biggerlib")

local CharacterMover = {}

-- Locations and scripts for each toon - update these coordinates and script names as needed
local toon_locations = {
    ["Neaweiani"] = {x = -49.0, y = 157.0, z = -12.65, script = "buffbot"},
    ["Faelaex"] = {x = -49.0, y = 153.0, z = -12.65, script = "buffbot"},
    ["Kildavenya"] = {x = -49.0, y = 149.0, z = -12.65, script = "buffbot"},
    ["Amisra"] = {x = -49.0, y = 145.0, z = -12.65, script = "buffbot"},
    ["Strateg"] = {x = -49.0, y = 141.0, z = -12.65, script = "buffbot"},
    ["Nikbuse"] = {x = -49.0, y = 137.0, z = -12.65, script = "buffbot"},
    ["Ringles"] = {x = -49.0, y = 133.0, z = -12.65, script = "buffbot"},
    ["Conjunctivitus"] = {x = -49.0, y = 129.0, z = -12.65, script = "buffbot"}
}

-- Move current toon to their location, wait for nav, then run their script
function CharacterMover.moveToAndRun()
    local current_toon = mq.TLO.Me.Name()
    print(string.format("Current toon: %s", current_toon))
    
    local location = toon_locations[current_toon]
    
    if not location then
        print(string.format("No location defined for toon: %s", current_toon))
        print("Available toons in table:")
        for name, _ in pairs(toon_locations) do
            print(string.format("  - %s", name))
        end
        return
    end
    
    -- Pause the plugin
    mq.cmdf("/boxr pause")
    print("Plugin paused!")
    mq.delay(500)

    -- Drop Lev
    mq.cmd("/removelev")
    print("Lev Dropped!")
    mq.delay(500)   

    -- Pet Leave
    mq.cmd("/pet leave")
    print("Pet Left!")
    mq.delay(500)   

    -- Disconnect from BCS
    mq.cmd("/bccmd disconnect")
    print("BCS disconnected!")
    mq.delay(500)

    -- Remove Bard Speed
    mq.cmd("/removebuff Selo's Accelerato")
    print("Bard Speed Off")
    mq.delay(500)

    -- Move to target location
    mq.cmdf("/nav loc %f %f %f", location.x, location.y, location.z)
    print(string.format("%s moving to (%.1f, %.1f, %.1f)", current_toon, location.x, location.y, location.z))
    mq.delay(500)
    
    -- Wait for navigation to complete
    BL.WaitForNav()
    print("Navigation complete!")
    mq.delay(500)
    
    -- Face north (heading 0 degrees)
    mq.cmdf("/face fast 0")
    print("Facing north!")
    mq.delay(500)
    
    -- Run the specified macro for this toon
    mq.cmdf("/mac %s", location.script)
    print(string.format("Running macro: %s", location.script))
end

-- Auto-run when script is loaded
CharacterMover.moveToAndRun()

return CharacterMover
