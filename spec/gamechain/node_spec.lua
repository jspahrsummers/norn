require("busted.runner")()

local message = require("gamechain.message")
local Node = require("gamechain.node")

local TestNetworker = {}
TestNetworker.__index = TestNetworker

setmetatable(TestNetworker, {
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:init(...)
		return self
	end
})

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
		assert.are.same(message.decode(sent.bytes), message.pong(token))
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

		local sent = networker.sent[1]
		local all_peers = { "a", "b", "c", "d", "e", "f" }
		assert.are.same(message.decode(sent.bytes), message.peer_list(token, all_peers))
	end)
end)