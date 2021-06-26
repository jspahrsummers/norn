Block = require("norn.block")
Blockchain = require("norn.blockchain")
hash = require("norn.hash")
PrivateKey = require("norn.privatekey")
PublicKey = require("norn.publickey")
tohex = require("norn.tohex")

print("hash", tohex(hash("foobar")))

key = PrivateKey()
signature = key:sign("foobar")
print("key", key)
print("signature", tohex(signature))
print("verifies?", key:verify(signature, "foobar"))

pubkey = key:public_key()
print("pubkey", pubkey)
print("pubkey verifies?", pubkey:verify(signature, "foobar"))

-- block = Block { data = "foobar", key = key }
-- block2 = Block { data = "fuzzbuzz", key = key, previous_hash = block.hash }
-- 
-- blockchain = Blockchain { block, block2 }
-- print(blockchain)