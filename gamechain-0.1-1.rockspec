package = "gamechain"
version = "0.1-1"
source = {
   url = "git+https://github.com/jspahrsummers/gamechain.git"
}
description = {
   summary = "Embeddable blockchain library for low-latency P2P multiplayer games",
   homepage = "https://github.com/jspahrsummers/gamechain",
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
      ["gamechain.block"] = "gamechain/lua/block.lua",
      ["gamechain.blockchain"] = "gamechain/lua/blockchain.lua",
      ["gamechain.clock"] = "gamechain/lua/clock.lua",
      ["gamechain.consensus"] = "gamechain/lua/consensus.lua",
      ["gamechain.hash"] = "gamechain/lua/hash.lua",
      ["gamechain.message"] = "gamechain/lua/message.lua",
      ["gamechain.networker"] = "gamechain/lua/networker.lua",
      ["gamechain.node"] = "gamechain/lua/node.lua",
      ["gamechain.opcode"] = "gamechain/lua/opcode.lua",
      ["gamechain.privatekey"] = "gamechain/lua/privatekey.lua",
      ["gamechain.publickey"] = "gamechain/lua/publickey.lua",
      ["gamechain.timer"] = "gamechain/lua/timer.lua",
      ["gamechain.tohex"] = "gamechain/lua/tohex.lua",
      ["gamechain.wallet"] = "gamechain/lua/wallet.lua"
   }
}
