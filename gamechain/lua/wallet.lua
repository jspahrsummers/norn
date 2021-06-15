local Wallet = {}
Wallet.__index = Wallet

setmetatable(Wallet, {
	__call = function (cls, obj, ...)
		local self = setmetatable(obj or {}, cls)
		self:init(...)
		return self
	end,
})

function Wallet:init()
end

function Wallet:public_key()
	return self.key:public_key()
end

return Wallet