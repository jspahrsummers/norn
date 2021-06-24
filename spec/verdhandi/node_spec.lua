require("busted.runner")()

local Block = require("verdhandi.block")
local Blockchain = require("verdhandi.blockchain")
local Clock = require("verdhandi.clock")
local date = require("date")
local functional = require("verdhandi.functional")
local message = require("verdhandi.message")
local Node = require("verdhandi.node")
local opcode = require("verdhandi.opcode")
local PrivateKey = require("verdhandi.privatekey")

local TestNetworker = {}
TestNetworker.__index = TestNetworker

setmetatable(TestNetworker, {
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:init(...)
		return self
	end
})

local EXPECTED_PEER_PING_INTERVAL = Node.PEER_PING_MIN_INTERVAL + Node.PEER_PING_MAX_JITTER + 1

local function resume_until(coro, predicate, message)
	local t = os.time()
	local i = 1
	while not predicate(i) and os.difftime(os.time(), t) < 3 do
		coroutine.resume(coro)
		i = i + 1
	end

	local b = predicate(nil)
	assert.is_true(b, message)
	return b
end

describe("node", function ()
	local networker

	before_each(function ()
		networker = TestNetworker()
	end)

	it("should respond to ping with pong", function ()
		local node = Node { networker = networker }
		local token = "foobar"
		local sender = "test_sender"
		node:handle_message(sender, message.ping(token))

		local sent = networker.sent[1]
		assert.are.equal(sent.dest, sender)
		assert.are.same(message.decode(sent.bytes), message.pong(token, sender))
	end)

	it("should fulfill peer list request", function ()
		local peers = { "a", "b", "c" }
		local node = Node { networker = networker, peer_list = peers }
		local token = "foobar"
		local sender = "test_sender"
		node:handle_message(sender, message.request_peer_list(token))

		local sent = networker.sent[1]
		assert.are.equal(sent.dest, sender)
		assert.are.same(message.decode(sent.bytes), message.peer_list(token, peers))
	end)

	it("should deduplicate peer list", function ()
		local node = Node {
			networker = networker,
			peer_list = { "a", "a", "b", "c", "c", "c" }
		}

		local token = "foobar"
		local sender = "test_sender"
		node:handle_message(sender, message.request_peer_list(token))

		local sent = networker.sent[1]
		assert.are.equal(sent.dest, sender)
		assert.are.same(message.decode(sent.bytes), message.peer_list(token, {"a", "b", "c"}))
	end)

	it("should merge received peer list", function ()
		local original_peers = { "a", "d", "e" }
		local node = Node { networker = networker, peer_list = original_peers }

		local added_peers = { "f", "b", "c", }
		local sender = "test_sender"
		node:handle_message(sender, message.peer_list(nil, added_peers))

		-- Request this node's peer list now.
		local token = "foobar"
		node:handle_message(sender, message.request_peer_list(token))

		local all_peers = { "a", "b", "c", "d", "e", "f" }
		local k, v = functional.find(networker.sent, function (k, v)
			return v.bytes == message.encode(message.peer_list(token, all_peers))
		end)

		assert.is_not_nil(k)
		assert.is_not_nil(v)
	end)

	it("should ping peer list after interval", function ()
		local c = Clock.virtual()
		local peers = { "a", "b" }
		local node = Node { networker = networker, peer_list = peers, clock = c }

		local coro = coroutine.create(function ()
			node:run()
		end)

		coroutine.resume(coro)
		c:advance(EXPECTED_PEER_PING_INTERVAL)

		local function is_ping(k, v)
			return message.decode(v.bytes)[1] == message.PING
		end

		resume_until(coro, function ()
			return functional.count_keys(functional.find_all(networker.sent, is_ping)) == 2
		end, "Expected to find two ping messages")

		local a = functional.find(networker.sent, function (k, v)
			return v.dest == "a" and is_ping(k, v)
		end)

		assert.is_not_nil(a)

		local b = functional.find(networker.sent, function (k, v)
			return v.dest == "b" and is_ping(k, v)
		end)

		assert.is_not_nil(b)
	end)

	it("should drop peers that fail to communicate in time", function ()
		local c = Clock.virtual()
		local peers = { "a", "b" }
		local node = Node { networker = networker, peer_list = peers, clock = c }

		local coro = coroutine.create(function ()
			node:run()
		end)

		-- Set up timers, etc.
		coroutine.resume(coro)

		c:advance(EXPECTED_PEER_PING_INTERVAL)

		networker.recv_queue[#networker.recv_queue + 1] = { "b", message.encode(message.pong(nil)) }
		assert.is.not_nil(node.peer_set["a"])
		assert.is.not_nil(node.peer_set["b"])

		c:advance(Node.PEER_PING_TIMEOUT)

		local t = os.time()
		while node.peer_set["a"] and os.difftime(os.time(), t) < 3 do
			coroutine.resume(coro)
		end

		assert.is_nil(node.peer_set["a"])
		assert.is.not_nil(node.peer_set["b"])

		local peer, last_seen = next(node.peer_set)
		assert.equals(peer, "b")
	end)

	it("should support custom handling of app-defined messages", function ()
		local sender = "test_sender"
		local received_app_defined = nil
		local function app_defined_handler(node, _sender, ...)
			assert.are.equal(sender, _sender)
			received_app_defined = { ... }
		end

		local node = Node { networker = networker, handle_app_defined = app_defined_handler }
		local test_data = { "foobar", 5 }
		node:handle_message(sender, message.app_defined(table.unpack(test_data)))
		assert.are.same(received_app_defined, test_data)
	end)

	describe("blockchain", function ()
		local privkey
		setup(function ()
			privkey = PrivateKey()
		end)

		local function create_blockchain(...)
			local last = nil
			local blocks = {}
			for _, op in ipairs { ... } do
				local data = opcode.encode(op)
				local block = Block.forge { data = data, previous_hash = last, keys = { privkey }}
				blocks[#blocks + 1] = block
				last = block.hash
			end

			return Blockchain(blocks)
		end

		it("should start empty", function ()
			local node = Node { networker = networker }
			assert.is.equal(#node.chain, 0)
		end)

		it("should be initializable", function ()
			local chain = create_blockchain(opcode.app_defined("foobar"), opcode.app_defined("fuzzbuzz"))
			local node = Node { networker = networker, chain = chain }
			assert.is.equal(node.chain, chain)
		end)
		
		it("should be sent to any peer who requests it", function ()
			local chain = create_blockchain(opcode.app_defined("foobar"), opcode.app_defined("fuzzbuzz"))
			local node = Node { networker = networker, chain = chain }
			local token = "foobar"
			local sender = "test_sender"
			node:handle_message(sender, message.request_blockchain(token))

			local sent = networker.sent[1]
			assert.are.equal(sent.dest, sender)
			assert.are.same(message.decode(sent.bytes), message.blockchain(token, chain))
		end)
		
		it("should be loaded from network", function ()
			local node = Node { networker = networker }
			local chain = create_blockchain(opcode.app_defined("foobar"), opcode.app_defined("fuzzbuzz"))
			assert.are_not.equal(node.chain, chain)

			local sender = "test_sender"
			node:handle_message(sender, message.blockchain(nil, chain))
			assert.are.equal(node.chain, chain)
		end)

		it("should be parsed for validator list", function ()
			local validators_and_wallets = {
				["192.168.0.1"] = { key = PrivateKey(), balance = 0 },
				["192.168.0.2"] = { key = PrivateKey(), balance = 0 },
			}

			local chain = create_blockchain(opcode.validators_changed(validators_and_wallets))
			local node = Node { networker = networker, chain = chain }

			local expected_validators = {}
			for address, wallet in pairs(validators_and_wallets) do
				expected_validators[#expected_validators + 1] = {
					peer_address = address,
					wallet_pubkey = wallet.key:public_key(),
				}
			end

			assert.are.same(node.known_validators, expected_validators)
		end)
	end)
end)

function TestNetworker:init(...)
	self.sent = {}
	self.send_error = nil
	self.recv_queue = {}
	self.recv_error = nil
end

function TestNetworker:send(dest, bytes)
	if self.send_error then
		self.send_error = nil
		error(self.send_error)
	end

	self.sent[#self.sent + 1] = {
		dest = dest,
		bytes = bytes
	}
end

function TestNetworker:recv()
	if self.recv_error then
		self.recv_error = nil
		error(self.recv_error)
	end

	while #self.recv_queue == 0 do
		coroutine.yield()
	end

	return table.unpack(table.remove(self.recv_queue, 1))
end