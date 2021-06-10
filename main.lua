Block = require("Block")
hash = require("hash")
PrivateKey = require("PrivateKey")
PublicKey = require("PublicKey")
tohex = require("tohex")

print("hash", tohex(hash("foobar")))

local key = PrivateKey()
local signature = key:sign("foobar")
print("key", key)
print("signature", tohex(signature))
print("verifies?", key:verify(signature, "foobar"))

local pubkey = key:public_key()
print("pubkey", pubkey)
print("pubkey verifies?", pubkey:verify(signature, "foobar"))

local block = Block { data = "foobar", key = key }
print(block)