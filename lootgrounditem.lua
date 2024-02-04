local mq = require("mq")
local BL = require("biggerlib")



local searchRadius = " radius 9999"
local itemName = "Glob of Vile Bile"
local groundItem = mq.TLO.Ground.Search(itemName .. searchRadius)

if BL.IsNil(groundItem()) then
    BL.info("Item not found")
else
    local groundID = groundItem.ID()
    local groundX = groundItem.X()
    local groundY = groundItem.Y()
    local groundZ = groundItem.Z()
    
    BL.info(
        "Ground item Spawned! %s with ID %s, Position: <%d, %d, %d>",
        groundItem or "NILNILNIL",
        tostring(groundID or "NOID"),
        groundX or -9876,
        groundY or -9865,
        groundZ or -9854
    )
    
    BL.info("Nav to ground item")
    -- Move driver to the item and wait until nav'd there, boxes should be on /chase
    mq.cmdf("/nav locxyz %d %d %d", groundX, groundY, groundZ)
    BL.WaitForNav()
    
    groundItem.Grab()
    mq.delay(1000)
    if mq.TLO.Cursor() == nil then
        BL.warn("Cursor is nil, so I couldn't grab the item!")
        mq.cmd("/g Cursor is nil, so I couldn't grab the item!")
        mq.delay(1000)
    else
        mq.cmd("/g Cursor is not nil, so I grabbed the item!")
        mq.delay(1000)
        mq.cmd("/autoinventory")
        mq.cmd("/rs CLICK VILE BILE READY")
    end
end

BL.warn("LOOT GROUND ITEM ENDED")
