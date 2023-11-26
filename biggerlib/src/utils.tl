-- Generates an iterator that increments from i to to by inc
-- @param i integer
-- @param to integer
-- @param inc integer
-- @return function
local function range(i: integer, to: integer, inc: integer): function
    if i == nil then
        return nil -- range(--[[ no args ]]) -> return "nothing" to fail the loop in the caller
    end
    
    if to == nil then
        to = i
        i = to == 0 and 0 or (to > 0 and 1 or -1)
    end
    
    -- 0 -> 0 with any inc would never iterate
    inc = inc or (i < to and 1 or -1)
    
    -- step back (once) before we start
    i = i - inc
    return function(): integer
        if i == to then
            return nil
        end
        i = i + inc
        return i
    end
end

return range