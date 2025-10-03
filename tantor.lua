local mq = require('mq')

local function main()
	print('Tantor lua starting')
	suc_ret = false
	duck_ret = false
	while true do
		mq.doevents()
		mq.delay('1s')
	end
end

local tantor_chase_call = function (line, arg1)
	print("tantor chase has been called")
	if arg1 ~= tostring(mq.TLO.Me.Name) then return end
	suc_ret = false
	mq.cmd.docommand("/" .. tostring(mq.TLO.Me.Class.ShortName), 'pause', 'on')
	mq.cmd.mqp('on')
	mq.cmd.docommand("/attack off")
	mq.cmd.docommand("/target clear")
	mq.cmd.docommand('/nav', 'recordwaypoint', 'tmpcamp', 'tmp camp')
	mq.delay('1s')
	mq.cmd.nav('loc', '-443', '-1091', '-43')
	mq.delay('2s')
	print("end of first nav")
	while tostring(mq.TLO.Me.Moving) == "TRUE" or tostring(mq.TLO.Me.Stunned) == "TRUE" do
		print("Moving/Stunned while")
		mq.delay('1s')
	end
	mq.cmd.docommand("/face fast heading 270")
	mq.cmd.docommand("/circle on 200")
	mq.delay('2s')
	mq.doevents(flush)
	chase_count = 0
	while chase_count < 90 do
		mq.delay('1s')
		chase_count = chase_count + 1
		print("Checking Success")
		print(chase_count)
		print(suc_ret)
		mq.doevents(Tantor_Success)
		print(suc_ret)
		if suc_ret then break end
	end
	mq.cmd.docommand("/" .. tostring(mq.TLO.Me.Class.ShortName), 'pause', 'off')
	mq.cmd.mqp('off')
	mq.cmd.docommand('/nav', 'waypoint', 'tmpcamp')
	chase_count = 0
	suc_ret = false
	return
end

local tantor_chase_return = function (line)
	print("chase returning")
	suc_ret = true
	return
end


local tantor_rock_call = function (line, arg1)
	print("tantor rock throw has been called")
	if arg1 ~= tostring(mq.TLO.Me.Name) then return end
	duck_ret = false
	mq.cmd.docommand("/" .. tostring(mq.TLO.Me.Class.ShortName), 'pause', 'on')
	mq.cmd.docommand("/" .. tostring(mq.TLO.Me.Class.ShortName), 'autostandonduck', 'off')
	mq.cmd.mqp('on')
	mq.cmd.docommand("/attack off")
	mq.cmd.docommand("/target clear")
	mq.cmd.docommand("/twist off")
	mq.delay('1s')
	duck_count = 0
	if tostring(mq.TLO.Me.State) == "STAND" then
		print("DUCK, DUCK, DUCK, GOOSE")
		mq.cmd('/keypress DUCK')
	end
	while duck_count < 45 do
		mq.delay('1s')
		if tostring(mq.TLO.Me.State) == "STAND" then
			print("DUCK, DUCK, DUCK, GOOSE")
			mq.cmd('/keypress DUCK')
		end
		duck_count = duck_count + 1
		print("Checking Success")
		print(duck_count)
		print(duck_ret)
		mq.doevents(Tantor_Rock_Success)
		print(duck_ret)
		if duck_ret == true then break end
	end
	if tostring(mq.TLO.Me.State) == "DUCK" then
		print("DUCK, DUCK, DUCK, GOOSE")
		mq.cmd('/keypress DUCK')
	end
	mq.cmd.docommand("/" .. tostring(mq.TLO.Me.Class.ShortName), 'pause', 'off')
	mq.cmd.mqp('off')
	duck_count = 0
	duck_ret = false
	return
end

local tantor_rock_return = function (line)
	print("duck returning")
	duck_ret = true
	return
end

mq.event('Tantor_Chase', "Tantor roars, pointing its trunk at #1#.", tantor_chase_call)
mq.event('Tantor_Chase_Success', "Tantor gives up the chase.", tantor_chase_return)
mq.event('Tantor_Rock', "Tantor grabs a rock with its trunk and turns toward #1#.", tantor_rock_call)
mq.event('Tantor_Rock_Success', "A rock whizzes over the head of its intended target.", tantor_rock_return)

main()