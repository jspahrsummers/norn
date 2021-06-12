local message = require("message")

local Node = {}
Node.__index = Node

setmetatable(Node, {
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:init(...)
		return self
	end,
})

function Node:init(wallet_privkey)
	self.wallet_privkey = wallet_privkey
end

function Node:create_wallet()
	if self.wallet_privkey then
		io.stderr:write(str.format("Warning: creating new wallet for node to replace wallet %s", self.wallet_privkey:public_key()))
	end

	-- TODO
end

function Node:handle_message(msg)
	local handlers = {
		[M.APP_DEFINED] = self.app_defined,
		[M.PING] = self.ping,
		[M.PONG] = self.pong,
		[M.REQUEST_PEER_LIST] = self.request_peer_list,
		[M.PEER_LIST] = self.peer_list,
		[M.WALLET_BALANCE] = self.wallet_balance,
	}

	local name = msg[1]
	local handler = handlers[name]
	if handler then
		handler(self, table.unpack(msg, 2))
	else
		io.stderr:write("Non-producer node cannot handle message ", name)
	end
end

function Node:app_defined(...)
	-- TODO
end

function Node:ping(token)
	-- TODO
end

function Node:pong(token)
	-- TODO
end

function Node:request_peer_list(token)
	-- TODO
end

function Node:peer_list(peers, maybe_token)
	-- TODO
end

function Node:wallet_balance(token, wallet_pubkey, balance)
	-- TODO
end

return Node