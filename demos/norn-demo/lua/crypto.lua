local digest = require("openssl.digest")
local pkey = require("openssl.pkey")

crypto = {}
crypto.DIGEST_TYPE = "sha256"

local PublicKey = {}
PublicKey.__index = PublicKey

setmetatable(PublicKey, {
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:init(...)
		return self
	end
})

local PrivateKey = {}
PrivateKey.__index = PrivateKey

setmetatable(PrivateKey, {
	__index = PublicKey,
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:init(...)
		return self
	end,
})



function crypto.hash(...)
	local d = digest.new(crypto.DIGEST_TYPE)
	return d:final(...)
end

function crypto.generate_private_key()
	return PrivateKey()
end

function crypto.public_key(public_or_private_key)
	return public_or_private_key:public_key()
end

function crypto.sign(private_key, ...)
	return private_key:sign(...)
end

function crypto.verify(public_or_private_key, signature, ...)
	return public_or_private_key:verify(signature, ...)
end

function crypto.serialize_public_key(public_key)
	return tostring(public_key)
end

function crypto.deserialize_public_key(public_key_string)
	return PublicKey(public_key_string)
end



function PublicKey:init(str, privkey)
	if str then
		self.pkey = pkey.new(tostring(str))
	elseif privkey then
		self.pkey = privkey
	end
end

function PublicKey:verify(signature, ...)
	local d = digest.new(crypto.DIGEST_TYPE)
	d:update(...)

	return self.pkey:verify(signature, d)
end

function PublicKey:public_key()
	return self
end

function PublicKey:__eq(other)
	return tostring(self) == tostring(other)
end

function PublicKey:__tostring()
	return self.pkey:toPEM("public")
end



function PrivateKey:init(str)
	if str then
		PublicKey.init(self, str)
	else
		self.pkey = pkey.new { type = "EC", curve = "prime192v1" }
	end
end

function PrivateKey:sign(...)
	local d = digest.new(crypto.DIGEST_TYPE)
	d:update(...)

	local sig = self.pkey:sign(d)
	return sig
end

function PrivateKey:public_key()
	return PublicKey(nil, self.pkey)
end

function PrivateKey:__eq(other)
	return tostring(self) == tostring(other)
end

function PrivateKey:__tostring()
	return self.pkey:toPEM("private")
end