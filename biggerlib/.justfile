@build:
    tl build

@test: build
    cd test && busted test.lua
	
@watch: build 
	modd #see modd.conf
	