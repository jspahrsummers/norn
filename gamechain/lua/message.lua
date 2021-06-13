local cjson = require("cjson.safe")

--- This module contains messages that are sent between nodes but _not_ encoded as-is into the blockchain.
local M = {}

--- Any message whose handling is defined in the embedding application.
M.APP_DEFINED = "app-defined"
function M.app_defined(...)
	return { M.APP_DEFINED, ... }
end

--- Ping one or more nodes to see if they're online, and how great the latency is.
M.PING = "ping"
function M.ping(token)
	return { M.PING, token }
end

--- Response to a previous ping.
M.PONG = "pong"
function M.pong(token)
	return { M.PONG, token }
end

--- Request the list of peers held by a given node.
M.REQUEST_PEER_LIST = "request-peer-list"
function M.request_peer_list(token)
	return { M.REQUEST_PEER_LIST, token }
end

--- Contains the list of peers for the sending node.
-- May be sent in response to REQUEST_PEER_LIST, in which case the originating token will be included, but nodes could also broadcast this without being prompted.
M.PEER_LIST = "peer-list"
function M.peer_list(peers, maybe_token)
	-- TODO
	return {}
end

--- A staking request from a node that would like to become a producer.
-- The indicated wallet will be used to determine eligibility for staking, and the node must demonstrate ownership of it by signing a message with the wallet's private key.
M.STAKE = "stake"
function M.stake(token, wallet_pubkey, signed_message)
	-- TODO
	return {}
end

--- One producer's vote to approve a staking request.
M.STAKE_VOTE_APPROVAL = "stake-vote-approval"
function M.stake_vote_approval(token)
	-- TODO
	return {}
end

--- One producer's vote to evict another producer, either for inactivity or because their stake fell below the minimum requirement.
M.EVICTION_VOTE = "eviction-vote"
function M.eviction_vote(token, wallet_pubkey)
	-- TODO
	return {}
end

--- A request to create a new wallet. Nothing happens if the wallet already exists.
M.CREATE_WALLET = "create-wallet"
function M.create_wallet(wallet_pubkey, signed_message)
	-- TODO
	return {}
end

--- Sent when a node discovers evidence that one or more producers signed two mutually exclusive blocks before either had expired.
-- The remaining producers should confirm a block to apply a penalty to the cheating wallet(s).
M.CAUGHT_CHEATING = "caught-cheating"
function M.caught_cheating(evidence_block_a, evidence_block_b)
	-- TODO
	return {}
end

--- Requests the latest balance for the named wallet.
-- This information is discoverable through the blockchain, but this allows nodes who do not have a full copy of the chain to quickly query it from those who do (i.e., producers).
M.REQUEST_WALLET_BALANCE = "request-wallet-balance"
function M.request_wallet_balance(token, wallet_pubkey)
	-- TODO
	return {}
end

--- Response to a wallet balance request.
M.WALLET_BALANCE = "wallet-balance"
function M.wallet_balance(token, wallet_pubkey, balance)
	-- TODO
	return {}
end

--- Sent from the owner of a wallet when they wish to spend some of their currency.
-- The remaining data in this block is defined by the embedding application, as transactions are an application-specific concept.
M.SPEND = "spend"
function M.spend(wallet_pubkey, spender_signature, amount, ...)
	-- TODO
	return {}
end

--- Sent when a node wants to request a copy of the blockchain.
-- Currently fetches all history. It may be possible to limit the fetch in the future.
M.REQUEST_BLOCKCHAIN = "request-blockchain"
function M.request_blockchain(token)
	-- TODO
	return {}
end

--- Response to a blockchain request.
M.BLOCKCHAIN = "blockchain"
function M.blockchain(token, chain)
	-- TODO
	return {}
end

--- Sent to all nodes when producers have forged a new block for the chain.
M.BLOCK_FORGED = "block-forged"
function M.block_forged(block)
	-- TODO
	return {}
end

M.encode = cjson.encode
M.decode = cjson.decode

return M