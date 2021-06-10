secure_hash = require("secure_hash")
signing = require("signing")

function tohex(b)
	local s = string.gsub(b, "(.)", function (x) return string.format("%.1x", string.byte(x)) end)
	return s
end

print("hash", tohex(secure_hash.hash("foobar")))

local key = signing.new_key()
local signature = signing.sign("foobar", key)
print("signature", tohex(signature))
print("verifies?", signing.verify(signature, "foobar", key))

local pubkey = signing.serialize_public_key(key)
print("pubkey", pubkey)
print("pubkey verifies?", signing.verify(signature, "foobar", signing.deserialize_public_key(pubkey)))