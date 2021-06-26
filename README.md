# norn [![Lua 5.2.4](https://img.shields.io/badge/lua-5.2.4-blue)](http://www.lua.org/manual/5.2/)

_norn_ (named after the [Norns](https://en.wikipedia.org/wiki/Norns) in Norse mythology) provides [blockchain](https://en.wikipedia.org/wiki/Blockchain) infrastructure for peer-to-peer multiplayer games, allowing players to coordinate game state without any central authority.

This library implements _only the infrastructure_ and is designed to be embedded into a game—it is neither a client nor a server for an existing blockchain network! Customized, game-specific logic is meant to be added on top, making it actually come alive.

> :warning: This library is (not even) a proof of concept right now, and is not ready to be used in production games. :warning:

## Is this a cryptocurrency?

**Emphatically no. This library implements a blockchain in the "[distributed ledger](https://en.wikipedia.org/wiki/Distributed_ledger)" sense only, and is _not secure enough to transact real funds_.**

Some aspects of the blockchain implementation will seem related to cryptocurrency, like the reference to "wallets," "balances," and "spending," but _this refers to in-game currency only_, with no real-world monetary value.

The library's [design philosophy](#why-a-new-blockchain-implementation) emphasizes gaming capabilities over true security. Funds may be lost or altered at any time, network forks may be trivially possible, etc. Do not transact real money using this library!

## Why Lua?

[Lua](http://www.lua.org/) is one of the smallest, easiest-to-embed scripting languages—and very popular in gaming for exactly these reasons.

Although we miss out on the safety of static type-checking, and despite a [much smaller package ecosystem](https://luarocks.org/) than some other languages, Lua has bindings for basically every language & platform used to build games. The goal is for _norn_ to be trivially embeddable, and to give the game on top maximum latitude to use it as it sees fit.

_norn_ targets [Lua 5.2](http://www.lua.org/manual/5.2/), for compatibility with the [MoonSharp](https://www.moonsharp.org/) interpreter (which, if you're building a game in [Unity](https://unity.com/), you may find useful!).

## Why a new blockchain implementation?

Most existing blockchains are built to transact cryptocurrencies (i.e., money), and their designs work toward this goal by prioritizing security, consistency, and correctness over everything else. In many implementations, block confirmations (when something is confirmed by the blockchain to have actually happened) can take minutes, or even hours.

These features are important for games too, but real-time gaming requires _low latency_ above all else. Most multiplayer games are, by nature, slightly unpredictable (e.g., due to player ping differences) and have _some_ incidence of cheating. Although neither effect is desirable, players will tolerate these consequences if it means that actions are mostly "instant."

Security- and cryptocurrency-focused blockchains _have_ been occasionally combined with gaming, but these applications generally look like one of the following:
* _Paying to run the game itself_ using a distributed virtual machine (like [Ethereum](https://ethereum.org/))
* Games that use cryptocurrency for microtransactions
* Turn-based games that aren't latency-sensitive

These aren't good benchmarks for real-time multiplayer gaming. _norn_ is intended to implement peer-to-peer synchronization for real-time games that are mostly played client-side (e.g., on desktops, consoles, or phones).

Plus, this project is just a good learning exercise. :grin:

### Other alternatives

Flexible, low-latency blockchain implementations do exist, but I haven't found any that quite fit the niche that _norn_ is attempting to fill:

* [eosio](https://eos.io/) seems highly customizable and reasonably low-latency, but is not really built with embedding in mind. It appears to require users to run a daemon, and implements its own smart contract language (great for flexibility, but abstraction overkill for games). Games can't require users to be SysOps.
* [Hypercore Protocol](https://hypercore-protocol.org/) looks simple and very lightweight, and is available via Node.js libraries—while not _quite_ as suited to games as Lua is, JavaScript is still highly embeddable and could work. Unfortunately, it doesn't include any consensus mechanisms, which distributed gaming requires (for fairness and to mitigate cheating). Hypercore may nonetheless still be useful as a network topology or storage abstraction.

Know of any others? I'd love to hear about them! Please [open an issue](https://github.com/jspahrsummers/norn/issues/new), including a link, a little summary, and your thoughts on their applicability to multiplayer gaming.

## Getting started

### Install Lua

First, install [Lua 5.2](http://www.lua.org/versions.html#5.2). As this is an older version of Lua (for compatibility reasons), you may need to build and install it [from source](http://www.lua.org/ftp/lua-5.2.4.tar.gz), if your chosen package manager doesn't have it already.

### Install LuaRocks

[LuaRocks](https://luarocks.org/) is used to manage dependencies and versioning. [Download and install it according to their instructions](https://github.com/luarocks/luarocks/wiki/Download).

The latest version of LuaRocks ([v3.7.0](https://github.com/luarocks/luarocks/releases/tag/v3.7.0) as of the time of writing) should work fine with Lua 5.2, but you may need to configure and build it from scratch to point it at your Lua 5.2 libraries and headers—or else provide the correct paths with each invocation at runtime.

### Build and install the library

To build and install _norn_ for your user, run the following from the repository's folder:

```sh
luarocks make --local norn-[^d]*.rockspec
```

If you want to install the library globally (note: you probably don't), just drop the `--local` flag.

### Run the demo

The demo can be built and installed the same way as the library:

```sh
luarocks make --local norn-demo-*.rockspec
```

… then run like so:

```sh
lua -l norn.demo
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

_norn_ is released under the [MIT license](LICENSE).