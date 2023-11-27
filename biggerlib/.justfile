@build:
    tl build	
    find ./src -name "*.lua" -exec cp {} ./ \;
    

@test: build
    cd test && busted test_suite.lua
	
@watch: build 
	modd #see modd.conf
	
sync:
    rsync -av --delete --exclude='.git' /home/kc/workspace/macroquest/RGLauncher/lua/zen /mnt/g/Games/EQHax/RGLauncherTest/lua/zen
	