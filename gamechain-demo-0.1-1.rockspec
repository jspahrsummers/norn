package = "gamechain-demo"
version = "0.1-1"
source = {
   url = "git+https://github.com/jspahrsummers/mmo-blockchain.git"
}
description = {
   homepage = "https://github.com/jspahrsummers/mmo-blockchain",
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
