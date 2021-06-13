local Wallet = {}
Wallet.__index = Wallet

setmetatable(Wallet, {
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:init(...)
		return self
	end,
})

function Wallet:init()
	self.pubkey = nil
	self.balance = 0
end

return Wallet