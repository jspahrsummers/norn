package = "verdhandi-demo"
version = "0.1-1"
source = {
   url = "git+https://github.com/jspahrsummers/verdhandi.git"
}
description = {
   homepage = "https://github.com/jspahrsummers/verdhandi",
   license = "MIT",
   maintainer = "Justin Spahr-Summers <justin@jspahrsummers.com>"
}
dependencies = {
   "verdhandi",
}
build = {
   type = "builtin",
   modules = {
      ["verdhandi.demo"] = "verdhandi-demo/lua/main.lua",
   }
}
