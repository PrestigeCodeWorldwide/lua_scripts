
local mq = require('mq')
local os = require('os')

local lyricArray =  {
    "Touched tenderly.",
    "Where will you be?",
    "Dreaming with me.",
    "Please,",
    "everybody, hear the music.",
    "When she and I split ways,",
    "it felt like the end of my days.",
    "Until I suddenly,",
    "suddenly realized",
    "this life was better off alone.",
    "Solitude was the best gift you ever gave me.",
    "Ol' Nilipus hailed from Misty Thicket.",
    "Where'er he smelled Jumjum he'd pick it.",
    "The halflings grew cross",
    "when their profits were lost,",
    "screamin', 'Where is that brownie?  I'll kick it!'",
    "Another night, in eternal darkness.",
    "Time bleeds like a wound that's lost all meaning.",
    "It's a long winter in the swirling chaotic void.",
    "This is my torture,",
    "my pain and suffering!",
    "Pinch me, O' Death. . .", 
    "simple test"
}

local function perform(line)
    local max = table.getn(lyricArray)
    for i = 1,max, 1
    do
        if string.find(line, lyricArray[i], 1, true) then
            --mq.delay('15s') -- add short delay to allow toon to run to next NPC
            mq.cmdf('/say %s', lyricArray[i+1])
        end
    end
end

local function navNpc(line, name)
    print(name)
    mq.cmdf('/tar %s', name)
    mq.delay(200)
    mq.cmd('/nav target')
end

mq.event('approachHim', "#1# recites a line of his song and beckons for you to approach him and sing the next line.", navNpc)
mq.event('approachHer', "#1# recites a line of her song and beckons for you to approach her and sing the next line.", navNpc)

for i = 1,table.getn(lyricArray), 1
do
    mq.event('perform_' .. tostring(i), lyricArray[i], perform)    
end

local function mainLoop()
    print('starting performer')
    while true do
        mq.doevents()
        mq.delay(50)
    end
end

mainLoop()
