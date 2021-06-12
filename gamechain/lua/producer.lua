local Producer = {}
Producer.__index = Producer

setmetatable(Producer, {
	__call = function (cls, obj, ...)
		local self = setmetatable(obj or {}, cls)
		self:init(...)
		return self
	end,
})

function Producer:init()
	assert(self.peer_address, "Producer must have a known peer address")
	assert(self.wallet_pubkey, "Producer must have a known wallet")
end

return Producer