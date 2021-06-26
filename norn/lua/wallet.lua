local Wallet = {}
Wallet.__index = Wallet

local PrivateKey = require("norn.privatekey")

setmetatable(Wallet, {
	__call = function (cls, obj, ...)
		local self = setmetatable(obj or {}, cls)
		self:init(...)
		return self
	end,
})

function Wallet:init()
	assert(self.key, "Wallet needs to be initialized with a key")
	assert(self.balance, "Wallet needs to be initialized with a balance")
end

function Wallet.create()
	return Wallet {
		key = PrivateKey(),
		balance = 0,
	}
end

function Wallet:public_key()
	return self.key:public_key()
end

function Wallet:__lt(other)
	return self.balance < other.balance
end

function Wallet:__eq(other)
	return self.key == other.key and self.balance == other.balance
end

function Wallet:__tostring()
	return string.format("Wallet %s (balance %s)", self:public_key(), self.balance)
end

return Wallet