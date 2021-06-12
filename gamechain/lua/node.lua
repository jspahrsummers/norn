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

function Node:init(peer_list)
	assert(self.networker, "Node must be created with a networker to use")
	self.peer_set = peer_list_to_set(peer_list or {})
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
		[M.APP_DEFINED] = self.handle_app_defined,
		[M.PING] = self.handle_ping,
		[M.PONG] = self.handle_pong,
		[M.REQUEST_PEER_LIST] = self.handle_request_peer_list,
		[M.PEER_LIST] = self.handle_peer_list,
		[M.REQUEST_BLOCKCHAIN] = self.handle_request_blockchain,
		[M.BLOCKCHAIN] = self.handle_blockchain,
		[M.BLOCK_FORGED] = self.handle_block_forged,
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
	assert(false)
end

function Node:handle_request_peer_list(sender, token)
	local msg = message.peer_list(peer_set_to_list(self.peer_set), token)
	self.networker:send(sender, message.encode(msg))
end

function Node:handle_peer_list(sender, peers, maybe_token)
	for _, peer in ipairs(peers) do
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
	if self.chain then
		io.stderr:write("Another node tried to replace our blockchain with:\n", chain)
		return
	end

	self.chain = chain
end

function Node:block_forged(sender, block)
	-- TODO
	assert(false)
end

local function peer_list_to_set(peer_list)
	local set = []
	for _, peer in ipairs(peer_list) do
		set[peer] = true
	end

	return set
end

local function peer_set_to_list(peer_set)
	local list = []
	for peer, _ in pairs(peer_set) do
		list[] = peer
	end

	return list
end

return Node