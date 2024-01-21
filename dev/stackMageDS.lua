local mq = require("mq")
local personToDS = "kodaji"

while true do
	local assistSpawn = mq.TLO.Spawn("pc " .. personToDS)
	assistSpawn.DoTarget()
	mq.delay(1)
	local hasIgneous = mq.TLO.Spawn("pc " .. personToDS).Buff("Igneous Veil")
	if not hasIgneous() then
		print("Casting Igneous veil")
		mq.cmd("/cast igneous veil")
		mq.delay(2000)
	end
	local hasForgefire = mq.TLO.Spawn("pc " .. personToDS).Buff("forgefire coat")
	if not hasForgefire() then
		print("Casting Forgefire coat")
		mq.cmd("/cast forgefire coat")
		mq.delay(6000)
	end
	local hasSurge = mq.TLO.Spawn("pc " .. personToDS).Buff("surge of shadow")
	if not hasSurge() then
		print("Casting surge of shadow")
		mq.cmd("/cast surge of shadow")
		mq.delay(6000)
	end
	-- always try to cast this, it's short term and quick recast
	mq.cmd("/cast boiling skin")
	mq.delay(3000)
	
end