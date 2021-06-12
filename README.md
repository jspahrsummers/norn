# gamechain
Embeddable blockchain library for low-latency P2P multiplayer games

## Getting started

[LuaRocks](https://luarocks.org/) is used to manage dependencies and versioning.

Once LuaRocks is [installed](https://github.com/luarocks/luarocks/wiki/Download), run the following from the repository's folder:

```sh
luarocks make --local gamechain-0.*
```

This will install the library for your user only.

The demo can also be installed the same way:

```sh
luarocks make --local gamechain-demo-*
```

… then run like so:

```sh
lua -l gamechain.demo
```

### Running tests

Tests are written using [Busted](http://olivinelabs.com/busted/), which is not installed via the project rockspecs:

```sh
luarocks install --local busted
busted
```

## Lua version

Targeting [Lua 5.2](http://www.lua.org/manual/5.2/), for compatibility with [MoonSharp](https://www.moonsharp.org/).
