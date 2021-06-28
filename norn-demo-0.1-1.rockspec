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
}
build = {
   type = "builtin",
   modules = {
      ["norn.demo"] = "norn-demo/lua/main.lua",
      ["norn.demo.networker"] = "norn-demo/lua/networker.lua",
   }
}
