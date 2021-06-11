--- This module contains messages that are sent between nodes but _not_ encoded as-is into the blockchain.

local M = {}

M.USER_DEFINED = "user-defined"
function M.user_defined(...)
	return { M.USER_DEFINED, ... }
end

M.PING = "ping"
function M.ping(token)
	return { M.PING, token }
end

M.PONG = "pong"
function M.pong(token)
	return { M.PONG, token }
end

M.REQUEST_NODE_LIST = "request-node-list"
function M.request_node_list(token)
	return { M.REQUEST_NODE_LIST, token }
end

M.NODE_LIST = "node-list"
function M.node_list(token)
	-- TODO
end

M.STAKE = "stake"
function M.stake()
	-- TODO
end

M.APPROVE_STAKING = "approve-staking"
function M.approve_staking()
	-- TODO
end

M.PROPOSE = "propose"
function M.propose()
	-- TODO
end

M.APPROVE_PROPOSAL = "approve-proposal"
function M.approve_proposal()
	-- TODO
end

M.EVICT = "evict"
function M.evict()
	-- TODO
end

M.APPROVE_EVICTION = "approve-eviction"
function M.approve_eviction()
	-- TODO
end

return M