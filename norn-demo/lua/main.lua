local Node = require("norn.node")
local logging = require("norn.logging")
local Wallet = require("norn.wallet")

local DemoNetworker = require("norn.demo.networker")
local EXIT_SUCCESS = "EXIT_SUCCESS"

local main_coro = coroutine.wrap(function ()
	logging.level = logging.LOG_LEVEL_DEBUG

	local a = DemoNetworker("a")
	local b = DemoNetworker("b")

	a:send(b.address, 5)
	local sender, bytes = b:recv()
	logging.debug("sender: %s", logging.explode(sender))
	logging.debug("bytes: %s", bytes)

	return EXIT_SUCCESS
end)

local result
repeat
	result = main_coro()
until result == EXIT_SUCCESS