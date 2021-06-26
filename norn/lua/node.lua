local Blockchain = require("norn.blockchain")
local Clock = require("norn.clock")
local functional = require("norn.functional")
local message = require("norn.message")
local opcode = require("norn.opcode")
local PublicKey = require("norn.publickey")
local tohex = require("norn.tohex")
local timer = require("norn.timer")
local Wallet = require("norn.wallet")

local Node = {}
Node.__index = Node
Node.PEER_PING_MIN_INTERVAL = 50
Node.PEER_PING_MAX_JITTER = 20
Node.PEER_PING_TIMEOUT = 120

setmetatable(Node, {
	__call = function (cls, obj, ...)
		local self = setmetatable(obj or {}, cls)
		self:init(...)
		return self
	end,
})

local function peer_set_to_list(peer_set)
	local list = {}
	for peer, _ in pairs(peer_set) do
		list[#list + 1] = peer
	end

	table.sort(list)
	return list
end

local function validator_keys(validators)
	local keys = {}
	for address, wallet in pairs(validators) do
		keys[#keys + 1] = wallet.key
	end

	return keys
end

function Node:init()
	assert(self.networker, "Node must be created with a networker to use")
	assert(self.address, "Node must be created with an address")

	if not self.clock then
		self.clock = Clock.os()
	end

	if self.peer_list then
		self.peer_set = {}
		for _, peer in pairs(self.peer_list) do
			assert(self:_is_valid_peer(peer), "Invalid peer provided at initialization time")
			self.peer_set[peer] = 0
		end

		self.peer_list = nil
	else
		self.peer_set = {}
	end

	self.is_validator = false
	self.known_validators = {}
	if self.chain then
		-- Scrape the blockchain for validator list, etc.
		self:_set_blockchain(self.chain)
	else
		self.chain = Blockchain {}
	end
end

--- Runs the node logic forever, or until an error is raised.
-- This function never returns normally, but will regularly yield if wrapped into a coroutine.
function Node:run()
	math.randomseed(os.time())

	for peer, _ in pairs(self.peer_set) do
		self:_maybe_new_peer(peer, true)
	end

	if #self.chain.blocks == 0 then
		self:_obtain_blockchain()
	end

	local peer_ping_interval = self.PEER_PING_MIN_INTERVAL + math.random() * self.PEER_PING_MAX_JITTER
	local coros = {
		self:_recv_loop(),
		timer.every(peer_ping_interval, function () self:_ping_peers() end, self.clock),
	}

	while true do
		for _, coro in ipairs(coros) do
			coroutine.resume(coro)
		end

		coroutine.yield()
	end
end

function Node:_recv_loop()
	return coroutine.create(function ()
		while true do
			local sender, bytes = self.networker:recv()
			assert(self:_is_valid_peer(sender), "Received message from invalid peer")
			self:_maybe_new_peer(sender)
			self.peer_set[sender] = self.clock:now()

			local msg = message.decode(bytes)
			self:handle_message(sender, msg)

			coroutine.yield()
		end
	end)
end

function Node:_ping_peers()
	local current_time = self.clock:now()
	for peer, last_seen in pairs(self.peer_set) do
		assert(self:_is_valid_peer(peer), "Found invalid peer in peer list when pinging")

		if self.clock:diff_seconds(current_time, last_seen) >= self.PEER_PING_TIMEOUT then
			-- Drop unresponsive peer.
			self.peer_set[peer] = nil
		else
			local msg = message.ping(current_time)
			self.networker:send(peer, message.encode(msg))
		end

		coroutine.yield()
	end
end

function Node:_obtain_blockchain()
	if not next(self.peer_set) then
		io.stderr:write("No peers available to synchronize with, starting a new network")
		self:_seize_power()
		return
	end

	-- TODO: Authenticate request with our own signature?
	self:_broadcast(message.request_blockchain(nil))
end

function Node:create_wallet()
	if self.wallet then
		io.stderr:write(string.format("Warning: creating new wallet for node to replace wallet %s", self.wallet.key:public_key()))
	end

	self.wallet = {
		key = PrivateKey(),
		balance = 0
	}
end

function Node:handle_message(sender, msg)
	local handlers = {
		[message.APP_DEFINED] = self.handle_app_defined,
		[message.PING] = self._handle_ping,
		[message.PONG] = self._handle_pong,
		[message.REQUEST_PEER_LIST] = self._handle_request_peer_list,
		[message.PEER_LIST] = self._handle_peer_list,
		[message.REQUEST_BLOCKCHAIN] = self._handle_request_blockchain,
		[message.BLOCKCHAIN] = self._handle_blockchain,
		[message.BLOCK_FORGED] = self._handle_block_forged,
	}

	local name = msg[1]
	local handler = handlers[name]
	if handler then
		handler(self, sender, table.unpack(msg, 2))
	else
		io.stderr:write("Non-validator node cannot handle message ", name)
	end
end

function Node:handle_app_defined(sender, ...)
	-- Does nothing by default. A custom handler can be provided at init time to override this method.
	io.stderr:write("Node received app-defined message it doesn't know how to handle")
end

function Node:_handle_ping(sender, token)
	local msg = message.pong(token)
	self.networker:send(sender, message.encode(msg))
end

function Node:_handle_pong(sender, token)
	-- This sender was already marked as active in the receive loop.
end

function Node:_handle_request_peer_list(sender, token)
	local msg = message.peer_list(token, peer_set_to_list(self.peer_set))
	self.networker:send(sender, message.encode(msg))
end

function Node:_handle_peer_list(sender, maybe_token, peers)
	for _, peer in pairs(peers) do
		self:_maybe_new_peer(peer)
	end
end

function Node:_handle_request_blockchain(sender, token)
	if not self.chain then
		return
	end

	local msg = message.blockchain(token, self.chain)
	self.networker:send(sender, message.encode(msg))
end

function Node:_handle_blockchain(sender, token, blocks)
	if self.is_validator then
		io.stderr:write(string.format("As a validator, ignoring replacement blockchain from peer node %s:\n%s", sender, chain))
		return
	end
	
	-- TODO: This should reconcile the multiple blockchains somehow (e.g., longest chain rule, or build consensus using N different chains). For now, we just trust the first one we receive.
	if #self.chain > 0 then
		io.stderr:write(string.format("Peer node %s tried to replace our blockchain with:\n%s", sender, chain))
		return
	end

	self:_set_blockchain(Blockchain(blocks))
end

function Node:_set_blockchain(chain)
	self.chain = chain
	self.known_validators = {}

	for block in self.chain:traverse_latest() do
		local op = opcode.decode(block.data)
		if not op then
			io.stderr:write(string.format("Unable to parse block %s", tohex(block.hash)))
		elseif op[1] == opcode.VALIDATORS_CHANGED then
			for address, wallet in pairs(op[2]) do
				self.known_validators[address] = Wallet.from_network_representation(wallet)
			end
		end
	end

	if not next(self.known_validators) then
		io.stderr:write("Received existing blockchain, but no validators are elected")
		self:_seize_power()
	end
end

function Node:_seize_power()
	if not self.wallet then
		io.stderr:write("Node does not have a wallet, cannot elect self as a validator")
		return
	end

	-- TODO: Should this issue a staking request instead of just assuming it succeeded?
	local block = Block.forge {
		data = opcode.encode(opcode.validators_changed {
			[self.address] = self.wallet,
		}),
		keys = { self.wallet.key },
		previous_hash = self.chain:latest_block() and self.chain:latest_block().hash or nil,
	}

	if not self.chain:add_block(block) then
		io.stderr.write(string.format("Could not forge new block for self-election:\n%s", block))
		return
	end

	self.known_validators = {
		[self.address] = self.wallet,
	}

	local msg = message.block_forged(block)
	self:_broadcast(msg)
end

function Node:_handle_block_forged(sender, block)
	-- TODO: Handle the case where there are no validators
	if not block:verify_signers(validator_keys(self.known_validators)) then
		io.stderr.write(string.format("Missing consensus for block sent by peer node %s:\n%s", sender, block))
		return
	end

	if not self.chain:add_block(block) then
		io.stderr.write(string.format("Peer node %s tried to add an incompatible block to our chain:\n%s", sender, block))
		return
	end
end

function Node:_is_valid_peer(peer)
	return peer ~= self.address
end

function Node:_maybe_new_peer(peer, force)
	if (not self:_is_valid_peer(peer)) or (self.peer_set[peer] and not force) then
		return
	end

	local t = self.clock:now()
	self.peer_set[peer] = t

	local msg = message.request_peer_list(t)
	self.networker:send(peer, message.encode(msg))
end

function Node:_broadcast(msg)
	local bytes = message.encode(msg)
	for peer, _ in pairs(self.peer_set) do
		assert(self:_is_valid_peer(peer), "Found invalid peer in peer list when broadcasting")
		self.networker:send(peer, bytes)
	end
end

function Node:_multicast_to_validators(msg)
	local bytes = message.encode(msg)
	for address, wallet in pairs(self.known_validators) do
		-- It's legal for this node to appear in its own validator list, but obviously, we don't need to notify ourselves.
		if address ~= self.address then
			self.networker:send(address, bytes)
		end
	end
end

return Node