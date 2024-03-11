---@type Mq
local mq = require('mq')
--- @type ImGui
require('ImGui')

local BL = require('biggerlib')
local Paused = false

local myClass = mq.TLO.Me.Class.ShortName()
local IAmDPS = false
local IAmTank = false
local IAmHealer = false
local tankdebuff = 'Grim Aura'
local dpsdebuff = 'Withering Limbs'
local healerdebuff = 'Withering Faith'

local function init()
	--get my class and cache it to see what potion to use
	if
		myClass == 'NEC'
		or myClass == 'MAG'
		or myClass == 'BST'
		or myClass == 'NEC'
		or myClass == 'MNK'
		or myClass == 'ROG'
		or myClass == 'RNG'
		or myClass == 'BER'
		or myClass == 'BRD'
	then
		IAmDPS = true
	end
	if
		myClass == 'WAR'
		or myClass == 'SHD'
	then
		IAmTank = true
	end
	if
		myClass == 'SHM'
		or myClass == 'DRU'
		or myClass == 'CLR'
	then
		IAmHealer = true
	end
end

local function dealwithtankdebuff()

	if IAmTank and BL.IHaveBuff(tankdebuff) then
		mq.cmd('/useitem Distillate of Immunization VI')
		-- we are a tank  with the debuff, we've cured it.
	
	end
end

local function dealwithhealerdebuff()
	
	if IAmHealer and BL.IHaveBuff(healerdebuff) then
		mq.cmd('/useitem Distillate of Immunization XV')
		-- we are a healer  with the debuff, we've cured it.
	end
end

local function dealwithdmgdebuff()
	if IAmDPS and BL.IHaveBuff(dpsdebuff) then
		mq.cmd('/useitem Distillate of Immunization XII')
		-- we are a dps with the debuff, we've cured it.
	end
end

local function mainLoop()
	-- Everyone needs to cure themselves very specifically
	dealwithtankdebuff()
	dealwithhealerdebuff()
	dealwithdmgdebuff()
end

------------------------------- Execution -------------------------------

init()
while true do
	if not Paused then 
		mainLoop()
	end
	mq.delay(50)
end
