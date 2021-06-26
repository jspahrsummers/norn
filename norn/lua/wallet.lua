local Wallet = {}
Wallet.__index = Wallet

local PrivateKey = require("norn.privatekey")
local PublicKey = require("norn.publickey")

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

function Wallet.from_network_representation(tbl)
	return Wallet { key = PublicKey(tbl.key), balance = tbl.balance }
end

function Wallet:public_key()
	return self.key:public_key()
end

function Wallet:network_representation()
	return {
		key = tostring(self:public_key()),
		balance = self.balance,
	}
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