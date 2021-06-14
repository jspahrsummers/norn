# gamechain ![Lua 5.2.4](https://img.shields.io/badge/lua-5.2.4-blue)

_gamechain_ provides [blockchain](https://en.wikipedia.org/wiki/Blockchain) infrastructure for peer-to-peer multiplayer games, allowing players to coordinate game state without any central authority.

This library implements _only the infrastructure_ and is designed to be embedded into a game—it is neither a client or server for an existing blockchain network! Customized, game-specific logic is meant to be added on top, making it actually come alive.

> **NOTE:** This library is just a proof of concept right now, and is not ready to be used in production games.

## Is this a cryptocurrency?

**Emphatically no. This library implements a blockchain in the "[distributed ledger](https://en.wikipedia.org/wiki/Distributed_ledger)" sense only, and is _not secure enough to transact real funds_.**

Some aspects of the blockchain implementation will seem related to cryptocurrency, like the reference to "wallets," "balances," and "spending," but _this refers to in-game currency only_, with no real-world monetary value.

The library's [design philosophy](#why-a-new-blockchain) emphasizes gaming capabilities over true security. Funds may be lost or altered at any time, network forks may be trivially possible, etc. Do not transact real money using this library!

## Why Lua?

[Lua](http://www.lua.org/) is one of the smallest, easiest-to-embed scripting languages—and very popular in gaming for exactly these reasons.

Although we miss out on the safety of static type-checking, and despite a [much smaller package ecosystem](https://luarocks.org/) than some other languages, Lua has bindings for basically every language & platform used to build games. The goal is for _gamechain_ to be trivially embeddable, and to give the game on top maximum latitude to use it as it sees fit.

_gamechain_ targets [Lua 5.2](http://www.lua.org/manual/5.2/), for compatibility with the [MoonSharp](https://www.moonsharp.org/) interpreter (which, if you're building a game in [Unity](https://unity.com/), you may find useful!).

## Why a new blockchain implementation?

Most existing blockchains are built to transact cryptocurrencies (i.e., _money_), and their designs work toward this goal by prioritizing security, consistency, and correctness over everything else. In many implementations, block confirmations (when something is confirmed by the blockchain to have actually happened) can take minutes, or even hours.

These concerns are all important for games too, but real-time gaming requires _low latency_ above all else. Most multiplayer games are slightly unpredictable (e.g., due to player ping differences) and have some incidence of cheating. Although neither effect is desirable, players will tolerate these consequences if it means that actions are mostly "instant."

Security- and cryptocurrency-focused blockchains _have_ been occasionally combined with gaming, but these applications generally look like one of the following:
* _Paying to run the game itself_ using a distributed virtual machine (like Ethereum)
* Games that use cryptocurrency for microtransactions
* Turn-based games that aren't latency-sensitive

These aren't good benchmarks for real-time multiplayer gaming. _gamechain_ is intended to implement peer-to-peer synchronization for real-time games that are mostly played client-side (e.g., on desktops, consoles, or phones).

More flexible blockchain implementations do exist, including [eosio](https://eos.io/) and [Hypercore Protocol](https://hypercore-protocol.org/), but I haven't found any built with _embedding_ in mind. To be truly useful as a gaming substrate, the implementation can't require users to run daemons or faff about with SysOps.

And finally, this project is just a good learning exercise. :grin:

## Getting started

### Install Lua

First, install [Lua 5.2](http://www.lua.org/versions.html#5.2). As this is an older version of Lua (for compatibility reasons), you may need to build and install it [from source](http://www.lua.org/ftp/lua-5.2.4.tar.gz), if your chosen package manager doesn't have it already.

### Install LuaRocks

[LuaRocks](https://luarocks.org/) is used to manage dependencies and versioning. [Download and install it according to their instructions](https://github.com/luarocks/luarocks/wiki/Download).

The latest version of LuaRocks ([v3.7.0](https://github.com/luarocks/luarocks/releases/tag/v3.7.0) as of the time of writing) should work fine with Lua 5.2, but you may need to configure and build it from scratch to point it at your Lua 5.2 libraries and headers—or else provide the correct paths with each invocation at runtime.

### Build and install the library

To build and install _gamechain_ for your user, run the following from the repository's folder:

```sh
luarocks make --local gamechain-[^d]*.rockspec
```

If you want to install the library globally (note: you probably don't), just drop the `--local` flag.

### Run the demo

The demo can be built and installed the same way as the library:

```sh
luarocks make --local gamechain-demo-*.rockspec
```

… then run like so:

```sh
lua -l gamechain.demo
```

### Run the tests

Tests are written using [Busted](http://olivinelabs.com/busted/). Busted is not listed as an explicit dependency of the project (to avoid forcing end users to download it), so you must install it manually:

```sh
luarocks install --local busted
```

Then, you can run tests by simply invoking it from the repository root:

```sh
busted
```

## License

_gamechain_ is released under the [MIT license](LICENSE).