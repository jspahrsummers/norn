# Consensus algorithm

## Fixed constants

* _N_ is the number of producers (fixed constant)
* _p<sub>0</sub>, ..., p<sub>N</sub>_ are the **online** producers, ordered from greatest stake (_0_) to smallest stake (_N_)
* _t_ is the liveness interval
* _B_ is the rate limit on becoming a producer
* _z_ is the penalty (denominated in in-game currency) applied to any producer which is caught cheating
	* _z_ could be defined as the amount of in-game currency held by the richest producer, plus some constant amount to still discourage cheating when the game is in its infancy
	* Negative balances are permitted!

## Election

Any time there are _zero_ producers, any node can elect itself a producer without approval.

Otherwise, these are the steps for any node that wishes to be elected as a producer:
1. Submit a staking request, along with proof of ownership of a wallet containing the stake. The candidate must have a greater stake than at least one of the current producers (or, if the list is incomplete, any stake greater than zero).
1. The other producers vote in the election. As soon as at least 2/3 of the existing producers approve the candidate, the candidate is added to the producer list.
1. The new producer list is broadcast to the whole network via a new block on the chain.

Any node that was a producer within the last interval _B_ is ineligible to be elected as a producer until that time has past.

![](election.svg)

## Forging

1. Participants multicast their proposed transactions to all _p_.
1. Each _p<sub>i</sub>_ which approves the transaction broadcasts its approval to all the other producers _p_.
1. As soon as at least 2/3 of producers _p_ approve the transaction, it is finalized and committed ("forged"), and broadcast through the whole network.
	1. If any producer _p<sub>i</sub>_ fails to respond within interval _t_, the other producers can forge a block to remove _p<sub>i</sub>_ from the producer list; afterward, a new producer is elected (see above).

## Penalties

* Evidence of any producer _p<sub>i</sub>_ approving two mutually exclusive transactions can be submitted to the chain by anyone (but most likely another producer), which will deduct _z_ from _p<sub>i</sub>_'s balance.
	* Penalties can still be applied this way even if _p<sub>i</sub>_ is no longer actively producing.

## References

* https://academy.binance.com/en/articles/byzantine-fault-tolerance-explained
* https://medium.com/loom-network/understanding-blockchain-fundamentals-part-1-byzantine-fault-tolerance-245f46fe8419
* https://medium.com/coinmonks/implementing-proof-of-stake-part-3-c68b953a50be
* https://eth.wiki/en/concepts/proof-of-stake-faqs