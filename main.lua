hash = require("hash")
PrivateKey = require("PrivateKey")
PublicKey = require("PublicKey")

function tohex(b)
	local s = string.gsub(b, "(.)", function (x) return string.format("%.1x", string.byte(x)) end)
	return s
end

print("hash", tohex(hash("foobar")))

local key = PrivateKey()
local signature = key:sign("foobar")
print("key", key)
print("signature", tohex(signature))
print("verifies?", key:verify(signature, "foobar"))

local pubkey = key:public_key()
print("pubkey", pubkey)
print("pubkey verifies?", pubkey:verify(signature, "foobar"))