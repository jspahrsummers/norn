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
	create_node("A"),
	create_node("B"),
}

local addresses = {}
local coros = {}
for _, node in ipairs(nodes) do
	table.insert(addresses, node.address)
	table.insert(coros, coroutine.create(function ()
		node:add_peer_list(addresses)
		node:run()
	end))
end

for t = 1, 1000 do
	clock.current_time = t
	for _, coro in ipairs(coros) do
		local success, err = coroutine.resume(coro)
		if not success then
			logging.error("Demo exiting due to error: %s", debug.traceback(coro, err))
			return 1
		end
	end
end