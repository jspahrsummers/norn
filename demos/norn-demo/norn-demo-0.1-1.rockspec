package = "norn-demo"
version = "0.1-1"
source = {
   url = "git+https://github.com/jspahrsummers/norn.git"
}
description = {
   homepage = "https://github.com/jspahrsummers/norn",
   license = "MIT",
   maintainer = "Justin Spahr-Summers <justin@jspahrsummers.com>"
}
dependencies = {
   "norn",
   "luaossl >= 20200709",
}
build = {
   type = "builtin",
   modules = {
      ["norn.demo"] = "lua/main.lua",
      ["norn.demo.crypto"] = "lua/crypto.lua",
      ["norn.demo.networker"] = "lua/networker.lua",
   }
}
