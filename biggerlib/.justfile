@build:
    tl build

@test: build
    cd test && lua test.lua