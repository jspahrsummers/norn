local M = {}
local digest = require("openssl.digest")
local pkey = require("openssl.pkey")

M.digest_type = "sha256"

-- TODO: Create key type(s) that these can become methods upon

function M.sign(data, key)
	local d = digest.new(M.digest_type)
	d:update(data)

	local sig = key:sign(d)
	return sig
end

function M.verify(signature, data, key)
	local d = digest.new(M.digest_type)
	d:update(data)

	return key:verify(signature, d)
end

function M.serialize_public_key(key)
	return key:toPEM("public")
end

function M.deserialize_public_key(str)
	return pkey.new(str)
end

function M.new_key()
	return pkey.new { type = "EC", curve = "prime192v1" }
end
	
return M