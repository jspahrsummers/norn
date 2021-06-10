# Consensus algorithm

**Fixed constants:**

* _N_ is the number of producers (fixed constant)
* _p<sub>0</sub>, ..., p<sub>N</sub>_ are the specific producers, ordered from greatest stake (_0_) to smallest stake (_N_)
* _timeout_ is how long before any given peer in the distributed network is declared dead

**Steps:**

1. Participants multicast their proposed transactions to all _p_
1. ... something about producers talk to each other ...
1. As long as 2/3 of _p_ commit the transaction, it is finalized
1. If at any point, _timeout_ has elapsed since _p<sub>i</sub>_ was last seen on a transaction (as determined by the transaction's codified timestamp), _p<sub>i</sub>_ is rejected from the network just like any other peer, and the producer list is recalculated
	1. This isn't fair; a producer might just be slower :\

## Open questions

* How do we penalize producers that validate or attempt to submit invalid blocks?
	* Being a producer that didn't commit a transaction is not necessarily an error state (could just be network issues)

## Reading list

* https://academy.binance.com/en/articles/byzantine-fault-tolerance-explained
* https://medium.com/loom-network/understanding-blockchain-fundamentals-part-1-byzantine-fault-tolerance-245f46fe8419
* https://medium.com/coinmonks/implementing-proof-of-stake-part-3-c68b953a50be
* https://eth.wiki/en/concepts/proof-of-stake-faqs