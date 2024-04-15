local mq = require('mq')
local os = require('os')
local BL = require('biggerlib')
-- Locs specific to this event: DoomShadeVirul
local locs = {
    { -99, -310 , -49 }, -- Viral 4 on map... 1 in array
    { 89, -435, -44 }, -- Viral 5 on map... 2 in array  
    { 318, -362, -44 }, -- Viral 6 on map... 3 in array  
    { 399, -184, -52 }, -- Viral 7 on map... 4 in array  
    { 353, -11, -47 } -- Viral 8 on map... 5 in array   
  }	

  -- This is the amout of time (ms) to delay before running back.
local DELAY = 24000

  local function delayTillSafeSpot()
    local val = true
      print("Navigating to safe spot.")
      while(val) do
        -- this TLO returns userdata instead of bool so it was always truthy
        if tostring(mq.TLO.Nav.Active) == "TRUE" then
          mq.delay(1000)
        else
          val = false
        end        
      end
      print("You reached the safe spot.")
  end
  
  local function waitAtSafeSpotCountdown()
    for i = 1, DELAY / 1000 do
      print('Return in ' .. i)
      mq.delay(1000)
    end
  end


-- Event trigger in LEM is #*#Doomshade curses #1#.#*#
-- Note that #1# will be a variable number of names separated by commas (or not)
local function event_handler(line, somenames)          
    local firsttime = os.clock()
    if not mq.TLO.Zone.ShortName() == 'umbraltwo_raid' then return end   
  	    
    if BL.nameListIncludesMe(somenames) then     
		         
        BL.cmd.pauseAutomation()       
				BL.cmd.removeZerkerRootDisc()				     
				
         -- Place the names in array 
        local names = BL.parseAllNames(somenames) 

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
       
        delayTillSafeSpot()
        waitAtSafeSpotCountdown()
				        
				BL.cmd.returnToRaidMainAssist()
			  BL.cmd.resumeAutomation()
    end
end

return {eventfunc=event_handler}