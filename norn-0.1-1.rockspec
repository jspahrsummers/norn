package = "norn"
version = "0.1-1"
source = {
   url = "git+https://github.com/jspahrsummers/norn.git"
}
description = {
   summary = "Embeddable blockchain library for low-latency P2P multiplayer games",
   homepage = "https://github.com/jspahrsummers/norn",
   license = "MIT",
   maintainer = "Justin Spahr-Summers <justin@jspahrsummers.com>"
}
dependencies = {
   "lua ~> 5.2",
   "date ~> 2.1.3",
   "lunajson ~> 1.2",
   "basexx ~> 0.4",
}
build = {
   type = "builtin",
   modules = {
      ["norn.block"] = "norn/lua/block.lua",
      ["norn.blockchain"] = "norn/lua/blockchain.lua",
      ["norn.clock"] = "norn/lua/clock.lua",
      ["norn.consensus"] = "norn/lua/consensus.lua",
      ["norn.functional"] = "norn/lua/functional.lua",
      ["norn.logging"] = "norn/lua/logging.lua",
      ["norn.message"] = "norn/lua/message.lua",
      ["norn.node"] = "norn/lua/node.lua",
      ["norn.opcode"] = "norn/lua/opcode.lua",
      ["norn.timer"] = "norn/lua/timer.lua",
      ["norn.tohex"] = "norn/lua/tohex.lua",
      ["norn.wallet"] = "norn/lua/wallet.lua",
   }
}
