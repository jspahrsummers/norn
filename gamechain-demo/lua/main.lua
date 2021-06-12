Block = require("gamechain.block")
Blockchain = require("gamechain.blockchain")
hash = require("gamechain.hash")
PrivateKey = require("gamechain.privatekey")
PublicKey = require("gamechain.publickey")
tohex = require("gamechain.tohex")

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