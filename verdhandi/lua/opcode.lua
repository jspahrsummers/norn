local cjson = require("cjson.safe")

--- This module contains opcodes that are encoded in blocks on the blockchain.
local M = {}

--- Any block whose handling is defined in the embedding application.
M.APP_DEFINED = "app-defined"
function M.app_defined(...)
	return { M.APP_DEFINED, ... }
end

--- Contains the new list of producers that all nodes should now follow, along with their wallets (so any node can attempt to stake if it has more).
-- Note that this block must be signed by the usual majority of the _old_ producers.
M.PRODUCERS_CHANGED = "producers-changed"
function M.producers_changed(new_producers_and_wallets)
	local list = {}
	for address, wallet in pairs(new_producers_and_wallets) do
		list[#list + 1] = { address, tostring(wallet.key:public_key()), wallet.balance }
	end

	return { M.PRODUCERS_CHANGED, list }
end

--- Written when a new wallet is created.
M.WALLET_CREATED = "wallet-created"
function M.wallet_created(wallet_pubkey)
	return { M.WALLET_CREATED, tostring(wallet_pubkey:public_key()) }
end

--- Written when a wallet has been caught cheating, and a penalty has been applied by the producer quorum.
-- The new balance cannot be higher than the previous balance.
M.WALLET_PENALTY = "wallet-penalty"
function M.wallet_penalty(wallet_pubkey, new_balance, evidence_block_a, evidence_block_b)
	return { M.WALLET_PENALTY, tostring(wallet_pubkey:public_key()), new_balance, evidence_block_a, evidence_block_b }
end

--- Written when the owner of a wallet has spent some of their currency.
-- The remaining data in this block is defined by the embedding application, as transactions are an application-specific concept.
M.SPENT = "spent"
function M.spent(wallet_pubkey, new_balance, amount, spender_signed_amount, ...)
	return { M.SPENT, tostring(wallet_pubkey:public_key()), new_balance, amount, spender_signed_amount, ... }
end

--- Written when the network producers have minted new currency and deposited into the specified wallet.
-- This can be used to implement application-specific logic. It is not written automatically by the blockchain infrastructure.
M.MINTED = "minted"
function M.minted(wallet_pubkey, new_balance, ...)
	return { M.MINTED, tostring(wallet_pubkey:public_key()), new_balance, ... }
end

M.encode = cjson.encode
M.decode = cjson.decode

return M