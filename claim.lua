--| claim.lua :: SonicZentropy 
--| Version 1.0
--| Claims any un-claimed collections in your inventory.
local mq = require("mq")	

local function Main()
	
    local pack = 0
    local MaxInvSlots = 10
    
	if mq.TLO.Cursor.ID() then
        mq.cmd("/autoinv")
    end
    mq.cmd("/keypress OPEN_INV_BAGS")
    mq.delay(3000)
    mq.cmd("/echo Claiming Un-Claimed Collectibles in your inventory")

    for Bag = MaxInvSlots, 1, -1 do
        if mq.TLO.InvSlot(pack .. Bag).Item.Container() then
            -- Check to make sure we won't go over max AA
            local currentAA = mq.TLO.Me.AAPoints()
            
            if currentAA > 500 then
                mq.cmd("/echo You have " .. currentAA .. " AA points, which is over the max of 200. Stopping the claim process.")
                return
            end
        
            -- Open next bag
            if not mq.TLO.Window("Pack" .. Bag).Open then
                mq.cmd("/itemnotify pack" .. Bag .. " rightmouseup")
            end
            -- Click the collectibles in the bag we opened
            for Slot = mq.TLO.InvSlot(pack .. Bag).Item.Container(), 1, -1 do
                if mq.TLO.InvSlot(pack .. Bag).Item.Collectible() then
                    --mq.cmd("/itemnotify in pack" .. Bag .. " " .. Slot .. " rightmouseup")
                    mq.cmd("/echo WOULD BE DOING /itemnotify in pack" .. Bag .. " " .. Slot .. " rightmouseup")
                    mq.delay(250)
                else
                    print("Not a collectible")
                end
            end
        end
    end
    
    if mq.TLO.Cursor.ID() then
        mq.cmd("/autoinv")
    end
    mq.cmd("/keypress CLOSE_INV_BAGS")
    mq.cmd("/echo Finished Claiming Collections")

end

Main()
mq.cmd("/echo claim.lua ended.")