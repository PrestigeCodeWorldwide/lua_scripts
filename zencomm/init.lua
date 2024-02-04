--- Allow setting dannet mode outside of individual commands
--- /zc mode group|raid|all
--- /zc [else] --- This will send whatever via /dgga /dgra /dg based on mode
--- /ze -- This is the "everyone else" version based on mode

---@type Mq
local mq = require("mq")
local BL = require("biggerlib")

-- How to make this more enum-ly?
local Modes = {
    Group = 1,    
    All = 2,
    Raid = 3,    
}

-- Reverse lookup table so you can use Modes[1] to get "Group", Modes[2] to get "All", and Modes[3] to get "Raid"
for k, v in pairs(Modes) do
    Modes[v] = k
    Modes[string.lower(k)] = v -- ghetto kludge to make it work for lower case too
end

local currentMode = Modes.All

local function zcmodeHandler(...)
    local args = { ... }

    local mode = table.concat(args, " ")
    -- mode here can be strings group|all|raid how can i associate them with the enum above?   i want to change currentMode to match the string input
    if Modes[mode] then
        currentMode = Modes[mode]
        BL.info("Set new ZennComm mode to %s", mode)
    else
        BL.warn("Invalid mode")
    end
    
end
mq.bind("/zcmode param", zcmodeHandler)

local function allHandler(...)
    local args = { ... }
    
    local commPhrase = table.concat(args, " ")
    
    if currentMode == Modes.Group then
        mq.cmd("/dgga " .. commPhrase)
    elseif currentMode == Modes.All then
        mq.cmd("/dg " .. commPhrase)        
    elseif currentMode == Modes.Raid then
        mq.cmd("/dgra " .. commPhrase)    
    end

end
mq.bind("/zc param", allHandler)

local function exceptHandler(...)
    local args = { ... }

    local commPhrase = table.concat(args, " ")

    if currentMode == Modes.Group then
        mq.cmd("/dgge " .. commPhrase)
    elseif currentMode == Modes.All then
        mq.cmd("/dge " .. commPhrase)
    elseif currentMode == Modes.Raid then
        mq.cmd("/dgre " .. commPhrase)
    end
end
mq.bind("/ze param", exceptHandler)

BL.info("ZenComm - use /zmode group|all|raid, /zc, /ze")

while true do
    mq.delay(5143)
end