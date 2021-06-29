local Clock = require("norn.clock")
local Node = require("norn.node")
local logging = require("norn.logging")
local Wallet = require("norn.wallet")

local DemoNetworker = require("norn.demo.networker")

logging.level = logging.LOG_LEVEL_DEBUG

local clock = Clock.virtual()

local function create_node(name)
	return Node {
		address = name,
		networker = DemoNetworker(name),
		wallet = Wallet.create(),
		clock = clock,
	}
end

local nodes = {
	[create_node("A")] = 1,
	[create_node("B")] = 100,
	[create_node("C")] = 100,
}

local addresses = {}
local coros = {}
for node, start_time in pairs(nodes) do
	addresses[node.address] = start_time

	local coro = coroutine.create(function ()
		logging.debug("Starting %s at time %s", node.address, clock.current_time)

		for address, t in pairs(addresses) do
			if start_time >= t then
				node:add_peer_list({ address })
			end
		end

		node:run()
	end)

	coros[coro] = start_time
end

for t = 1, 1000 do
	clock.current_time = t
	for coro, start_time in pairs(coros) do
		if t >= start_time then
			local success, err = coroutine.resume(coro)
			if not success then
				logging.error("Demo exiting due to error: %s", debug.traceback(coro, err))
				return 1
			end
		end
	end
end