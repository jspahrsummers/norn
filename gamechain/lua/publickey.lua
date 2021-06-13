local digest = require("openssl.digest")
local pkey = require("openssl.pkey")

local PublicKey = {}
PublicKey.__index = PublicKey
PublicKey.digest_type = "sha256"

setmetatable(PublicKey, {
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:init(...)
		return self
	end
})

function PublicKey:init(str, privkey)
	if str then
		self.pkey = pkey.new(tostring(str))
	elseif privkey then
		self.pkey = privkey
	end
end

function PublicKey:verify(signature, ...)
	local d = digest.new(self.digest_type)
	d:update(...)

	return self.pkey:verify(signature, d)
end

function PublicKey:public_key()
	return self
end

function PublicKey:__tostring()
	return self.pkey:toPEM("public")
end

return PublicKey