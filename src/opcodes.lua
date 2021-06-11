--- This module contains opcodes that are encoded in blocks on the blockchain.

local M = {}

M.USER_DEFINED = "user-defined"
function M.user_defined(...)
	return { M.USER_DEFINED, ... }
end

M.PRODUCERS_CHANGED = "producers-changed"
function M.producers_changed(...)
	-- TODO
end

M.PENALTY = "penalty"
function M.penalty(...)
	-- TODO
end

return M