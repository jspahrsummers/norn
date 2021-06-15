local Blockchain = require("gamechain.blockchain")
local message = require("gamechain.message")

local Node = {}
Node.__index = Node

setmetatable(Node, {
	__call = function (cls, obj, ...)
		local self = setmetatable(obj or {}, cls)
		self:init(...)
		return self
	end,
})

local function peer_list_to_set(peer_list)
	local set = {}
	for _, peer in pairs(peer_list) do
		set[peer] = true
	end

	return set
end

local function peer_set_to_list(peer_set)
	local list = {}
	for peer, _ in pairs(peer_set) do
		list[#list + 1] = peer
	end

	table.sort(list)
	return list
end

local function producer_keys(producers)
	local keys = {}
	for _, producer in pairs(producers) do
		keys[#keys + 1] = producer.wallet_pubkey
	end

	return keys
end

function Node:init()
	assert(self.networker, "Node must be created with a networker to use")

	if self.peer_list then
		self.peer_set = peer_list_to_set(self.peer_list)
		self.peer_list = nil
	else
		self.peer_set = {}
	end

	self.known_producers = {}
	self.chain = self.chain or Blockchain {}
end

--- Runs the node logic forever, or until an error is raised.
-- This function never returns normally.
function Node:run()
	while true do
		local sender, bytes = self.networker:recv()
		self.peer_set[sender] = true

		local msg = message.decode(bytes)
		self:handle_message(sender, msg)
	end
end

function Node:create_wallet()
	if self.wallet_privkey then
		io.stderr:write(string.format("Warning: creating new wallet for node to replace wallet %s", self.wallet_privkey:public_key()))
	end

	-- TODO
	assert(false)
end

function Node:handle_message(sender, msg)
	local handlers = {
		[message.APP_DEFINED] = self.handle_app_defined,
		[message.PING] = self.handle_ping,
		[message.PONG] = self.handle_pong,
		[message.REQUEST_PEER_LIST] = self.handle_request_peer_list,
		[message.PEER_LIST] = self.handle_peer_list,
		[message.REQUEST_BLOCKCHAIN] = self.handle_request_blockchain,
		[message.BLOCKCHAIN] = self.handle_blockchain,
		[message.BLOCK_FORGED] = self.handle_block_forged,
	}

	local name = msg[1]
	local handler = handlers[name]
	if handler then
		handler(self, sender, table.unpack(msg, 2))
	else
		io.stderr:write("Non-producer node cannot handle message ", name)
	end
end

function Node:handle_app_defined(sender, ...)
	-- Does nothing by default. A custom handler can be provided at init time.
	io.stderr:write("Node received app-defined message it doesn't know how to handle")
end

function Node:handle_ping(sender, token)
	local msg = message.pong(token)
	self.networker:send(sender, message.encode(msg))
end

function Node:handle_pong(sender, token)
	-- TODO
end

function Node:handle_request_peer_list(sender, token)
	local msg = message.peer_list(token, peer_set_to_list(self.peer_set))
	self.networker:send(sender, message.encode(msg))
end

function Node:handle_peer_list(sender, maybe_token, peers)
	for _, peer in pairs(peers) do
		self.peer_set[peer] = true
	end
end

function Node:handle_request_blockchain(sender, token)
	if not self.chain then
		return
	end

	local msg = message.blockchain(token, self.chain)
	self.networker:send(sender, message.encode(msg))
end

function Node:handle_blockchain(sender, token, chain)
	-- TODO: This should reconcile the multiple blockchains somehow (e.g., longest chain rule, or build consensus using N different chains). For now, we just trust the first one we receive.
	if #self.chain > 0 then
		io.stderr:write(string.format("Peer node %s tried to replace our blockchain with:\n%s", sender, chain))
		return
	end

	-- TODO: Find latest producer list in chain
	self.chain = chain
end

function Node:handle_block_forged(sender, block)
	if not block:verify_signers(producer_keys(self.known_producers)) then
		io.stderr.write(string.format("Missing consensus for block sent by peer node %s:\n%s", sender, block))
		return
	end

	if not self.chain:add_block(block) then
		io.stderr.write(string.format("Peer node %s tried to add an incompatible block to our chain:\n%s", sender, block))
		return
	end
end

return Node