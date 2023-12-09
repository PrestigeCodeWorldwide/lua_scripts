@build:
    tl build	
    find ./src -name "*.lua" -exec cp {} ./dist \;
    

@test: build
    cd test && busted test_suite.lua
	
@watch: build 
	modd #see modd.conf
	
@sync:
    rsync -av --delete --exclude='.git' /home/kc/workspace/macroquest/RGLauncher/lua/zen/biggerlib /mnt/g/Games/EQHax/RGLauncherTest/lua/zen/biggerlib

@buildWindows: 
	wsl --exec cd /mnt/g/games/eqhax/rglaunchertest/lua/zen/biggerlib/ && tl build
	
@buildLuaRocksModule:
	luarocks make --tree ./builtrock biggerlib-1.0-1.rockspec