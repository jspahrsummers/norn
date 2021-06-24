# Consensus algorithm

## Fixed constants

* _N_ is the number of validators (fixed constant)
* _p<sub>0</sub>, ..., p<sub>N</sub>_ are the **online** validators, ordered from greatest stake (_0_) to smallest stake (_N_)
* _t_ is the liveness interval
* _B_ is the rate limit on becoming a validator after eviction
* _m_ is the minimum in-game currency required to stake
* _z_ is the penalty (denominated in in-game currency) applied to any validator which is caught cheating
	* _z_ could be defined as the amount of in-game currency held by the richest validator, plus _m_, so staking is no longer possible for the cheater
	* Negative balances are permitted!

## Election

Any time there are _zero_ validators, any node can elect itself a validator without approval.

Otherwise, these are the steps for any node that wishes to be elected as a validator:
1. Submit a staking request, along with proof of ownership of a wallet containing the stake. The candidate must have a greater stake than at least one of the current validators (unless the list is incomplete), and greater than constant value _m_ as well.
1. The other validators vote in the election. As soon as at least 2/3 of the existing validators approve the candidate, the candidate is added to the validator list.
1. The new validator list is broadcast to the whole network via a new block on the chain.

Any node that was evicted as a validator within the last interval _B_ is ineligible to be elected as a validator until that time has passed.

![](election.svg)

## Forging

1. Participants multicast their proposed transactions to all _p_.
1. Each _p<sub>i</sub>_ which approves the transaction multicasts its approval to all the other validators _p_.
1. As soon as at least 2/3 of validators _p_ approve the transaction, it is finalized and committed ("forged"), and broadcast through the whole network.
	1. If any validator _p<sub>i</sub>_ fails to respond within interval _t_, the other validators can evict _p<sub>i</sub>_ from the validator list.
1. Pending transactions expire after interval _t_ if not approved.

## Penalties

* Evidence of any validator _p<sub>i</sub>_ approving two mutually exclusive transactions (within interval _t_ of each other) can be submitted to the chain by anyone (but most likely another validator), which will deduct _z_ from _p<sub>i</sub>_'s balance.
	* Penalties can still be applied this way even if _p<sub>i</sub>_ is no longer actively producing.
* If, at any point, _p<sub>i</sub>_ falls below the minimum staking requirement _m_, the other validators can evict _p<sub>i</sub>_ from the validator list.

## Wallet creation

Any node can create a new wallet by submitting a transaction to do so. The wallet will be created with a zero balance, so that the node is not immediately eligible for staking.

## References

* https://academy.binance.com/en/articles/byzantine-fault-tolerance-explained
* https://medium.com/loom-network/understanding-blockchain-fundamentals-part-1-byzantine-fault-tolerance-245f46fe8419
* https://medium.com/coinmonks/implementing-proof-of-stake-part-3-c68b953a50be
* https://eth.wiki/en/concepts/proof-of-stake-faqs