package = "gamechain-demo"
version = "0.1-1"
source = {
   url = "git+https://github.com/jspahrsummers/gamechain.git"
}
description = {
   homepage = "https://github.com/jspahrsummers/gamechain",
   license = "MIT",
   maintainer = "Justin Spahr-Summers <justin@jspahrsummers.com>"
}
dependencies = {
   "gamechain",
}
build = {
   type = "builtin",
   modules = {
      ["gamechain.demo"] = "gamechain-demo/lua/main.lua",
   }
}
