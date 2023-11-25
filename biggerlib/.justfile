@build:
    tl build

@test: build
    cd test && busted test.lua