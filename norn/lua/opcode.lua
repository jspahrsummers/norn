local dkjson = require("dkjson")

--- This module contains opcodes that are encoded in blocks on the blockchain.
local M = {}

--- Any block whose handling is defined in the embedding application.
M.APP_DEFINED = "app-defined"
function M.app_defined(...)
	return { M.APP_DEFINED, ... }
end

--- Contains a map of the new validators that all nodes should now follow, along with their wallets (so any node can attempt to stake if it has more).
-- Note that this block must be signed by the usual majority of the _old_ validators.
M.VALIDATORS_CHANGED = "validators-changed"
function M.validators_changed(new_validators_and_wallets)
	local map = {}
	for address, wallet in pairs(new_validators_and_wallets) do
		map[address] = wallet:network_representation()
	end

	return { M.VALIDATORS_CHANGED, map }
end

--- Written when a wallet has been caught cheating, and a penalty has been applied by the validator quorum.
-- The new balance cannot be higher than the previous balance.
M.WALLET_PENALTY = "wallet-penalty"
function M.wallet_penalty(wallet_with_new_balance, evidence_block_a, evidence_block_b)
	return { M.WALLET_PENALTY, wallet_with_new_balance:network_representation(), evidence_block_a:network_representation(), evidence_block_b:network_representation() }
end

--- Written when the owner of a wallet has spent some of their currency.
-- The remaining data in this block is defined by the embedding application, as transactions are an application-specific concept.
M.SPENT = "spent"
function M.spent(wallet_with_new_balance, spent_amount, spender_signed_amount, ...)
	return { M.SPENT, wallet_with_new_balance:network_representation(), spent_amount, spender_signed_amount, ... }
end

--- Written when the network validators have minted new currency and deposited into the specified wallet.
-- This can be used to implement application-specific logic. It is not written automatically by the blockchain infrastructure.
M.MINTED = "minted"
function M.minted(wallet_with_new_balance, ...)
	return { M.MINTED, wallet_with_new_balance:network_representation(), ... }
end

M.encode = dkjson.encode
M.decode = dkjson.decode

return M