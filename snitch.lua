local mq = require('mq')
local BL = require('biggerlib')

local ScriptState = {
	IAmTank = false,
	MyName = "",
	SnitchEchoRepeatDelay = 15000,
}

local function InitClass()
	local class = mq.TLO.Me.Class.ShortName():upper()
	ScriptState.IAmTank =
		class == "SHD"
		or class == "WAR"
		or class == "PAL"
	ScriptState.MyName = mq.TLO.Me.CleanName()
end

local function IsTankRoleOn()
	if not ScriptState.IAmTank then return end
	
	local maintankrole = mq.TLO.Group.MainTank
	if BL.IsNil(maintankrole) then
		return
	end
	BL.dump(maintankrole)
	BL.dump(maintankrole())
	if maintankrole.Name() == ScriptState.MyName then
		mq.cmd("/rs I'm a tank and my GROUP TANK ROLE is on!")
	end
end

local function AmIGroupLeader()
	if not ScriptState.IAmTank then return end
	
	local leader = mq.TLO.Group.Leader
	if BL.IsNil(leader) then
		return
	end
	if leader.Name() == ScriptState.MyName then
		mq.cmd("/rs I'm a tank and I am GROUP LEADER!")
	end
end

local function IsCWTNTankModeOn()
	if BL.IsNil(mq.TLO.CWTN) then return end
	
	if mq.TLO.CWTN.Mode() == "Tank" then
		mq.cmd("/rs My CWTN Plugin is set to TANK MODE!")
	end
end

local function IsUseAOEOn()
	if BL.IsNil(mq.TLO.CWTN) then return end
	if mq.TLO.CWTN.UseAOE() then
		mq.cmd("/rs My CWTN Plugin is set to USE AOE!")
	end
end

local function IsAoeCountTooLow()
	if BL.IsNil(mq.TLO.CWTN) then return end
	if mq.TLO.CWTN.AoECount() < 99 then
		mq.cmd("/rs My CWTN Plugin is set AOE COUNT BELOW 99!")
	end
end

local function ConfigureAutoRezzing()
	mq.cmd("/squelch /rez accept on")
	mq.delay(500)
	mq.cmd("/squelch /rez pct 89")
	mq.delay(500)
	mq.cmd("/squelch /rez delay 1")
	mq.delay(500)
	BL.info("Enabled Auto Rez Accept")
end

----------------------------------------------------------------------------
InitClass()
ConfigureAutoRezzing()
while true do
	--check i have tank role
	IsTankRoleOn()
	--check i'm group leader
	AmIGroupLeader()
	-- check cwtn mode
	IsCWTNTankModeOn()
	-- check i don't have useAOE on
	IsUseAOEOn()
	-- check aoecount < 99
	IsAoeCountTooLow()
	mq.delay(ScriptState.SnitchEchoRepeatDelay)
end





