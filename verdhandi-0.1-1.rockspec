package = "verdhandi"
version = "0.1-1"
source = {
   url = "git+https://github.com/jspahrsummers/verdhandi.git"
}
description = {
   summary = "Embeddable blockchain library for low-latency P2P multiplayer games",
   homepage = "https://github.com/jspahrsummers/verdhandi",
   license = "MIT",
   maintainer = "Justin Spahr-Summers <justin@jspahrsummers.com>"
}
dependencies = {
   "lua ~> 5.2",
   "date ~> 2.1.3",
   "lua-cjson == 2.1.0",
   "luaossl >= 20200709",
}
build = {
   type = "builtin",
   modules = {
      ["verdhandi.block"] = "verdhandi/lua/block.lua",
      ["verdhandi.blockchain"] = "verdhandi/lua/blockchain.lua",
      ["verdhandi.clock"] = "verdhandi/lua/clock.lua",
      ["verdhandi.consensus"] = "verdhandi/lua/consensus.lua",
      ["verdhandi.functional"] = "verdhandi/lua/functional.lua",
      ["verdhandi.hash"] = "verdhandi/lua/hash.lua",
      ["verdhandi.message"] = "verdhandi/lua/message.lua",
      ["verdhandi.networker"] = "verdhandi/lua/networker.lua",
      ["verdhandi.node"] = "verdhandi/lua/node.lua",
      ["verdhandi.opcode"] = "verdhandi/lua/opcode.lua",
      ["verdhandi.privatekey"] = "verdhandi/lua/privatekey.lua",
      ["verdhandi.publickey"] = "verdhandi/lua/publickey.lua",
      ["verdhandi.timer"] = "verdhandi/lua/timer.lua",
      ["verdhandi.tohex"] = "verdhandi/lua/tohex.lua",
   }
}
