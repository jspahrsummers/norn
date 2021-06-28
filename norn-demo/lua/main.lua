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
	create_node("a"),
	create_node("b"),
}

local addresses = {}
local fns = {}
for _, node in ipairs(nodes) do
	table.insert(addresses, node.address)
	table.insert(fns, coroutine.wrap(function ()
		node:add_peer_list(addresses)
		node:run()
	end))
end

for t = 1, 1000 do
	clock.current_time = t
	for _, fn in ipairs(fns) do
		fn()
	end
end