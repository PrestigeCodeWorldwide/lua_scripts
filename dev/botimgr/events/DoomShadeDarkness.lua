local mq = require('mq')
local BL = require('biggerlib')
-- Locs specific to this event: DoomShadeDarkness
local locs = {
  { 191, 86, -46 },  -- Darkness 1 on map... 1 in array
  { -30, 48, -45},   -- Darkness 2 on map... 2 in array  
  { -132, -99, -47 }, -- Darkness 3 on map... 3 in array   
}

BL.cmd.setRngSeedFromPlayerPosition()
-- Event trigger in LEM is #*#sends shadows at #1#.#*#
local function event_handler(line, somenames)
    if not mq.TLO.Zone.ShortName() == 'umbraltwo_raid' then return end   
  	    
     if BL.nameListIncludesMe(somenames) then  
    
         -- Place the names in array 
         local names = BL.parseAllNames(somenames)    
        
      BL.cmd.pauseAutomation()       
      BL.cmd.removeZerkerRootDisc()				     
      
     
      local myname = mq.TLO.Me.CleanName()
      -- Get loc to run to based on order called
      for i in pairs(names) do
        if names[i] == myname then
          print(i)
          print(names[i])           
          print("Running to: " .. locs[i][1]  .. ", " .. locs[i][2] .. ", " .. locs[i][3])
          mq.cmdf('/nav locxyz %d %d %d', locs[i][1], locs[i][2], locs[i][3])                    
        end
      end         
        
      mq.delay(15000)
      BL.cmd.returnToRaidMainAssist()
      BL.cmd.resumeAutomation()
   end
end      

return {eventfunc=event_handler}