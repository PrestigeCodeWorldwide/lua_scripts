package = "Biggerlib"
version = "1.0-1"
source = {
   url = "..." -- We don't have one yet
}
description = {
   summary = "MQ Library",
   detailed = [[
      Prestige
   ]],
   homepage = "http://...", -- We don't have one yet
   license = "Unlicense" -- or whatever you like
}
dependencies = {
   "lua >= 5.1, < 5.4"
   -- If you depend on other rocks, add them here
}
build = {
   type = "builtin",   
   modules = {
     option = "dist/option.lua",
	 logger = "dist/logger.lua",
	 lume = "dist/lume.lua",
	 utils = "dist/utils.lua",
	 zenarray = "dist/zenarray.lua"
   }
}