@build:
    tl build

@test: build
    cd test && busted test_suite.lua
	
@watch: build 
	modd #see modd.conf
	