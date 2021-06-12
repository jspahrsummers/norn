local digest = require("openssl.digest")
local pkey = require("openssl.pkey")
local PublicKey = require("gamechain.publickey")

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

function PrivateKey:init(str)
	if str then
		PublicKey.init(self, str)
	else
		self.pkey = pkey.new { type = "EC", curve = "prime192v1" }
	end
end

function PrivateKey:sign(...)
	local d = digest.new(self.digest_type)
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

return PrivateKey