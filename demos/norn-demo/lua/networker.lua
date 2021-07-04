local logging = require("norn.logging")

local Networker = {}
Networker.__index = Networker
Networker._addresses = {}

setmetatable(Networker, {
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:init(...)
		return self
	end
})

function Networker:init(address)
	self.address = address

	assert(not self._addresses[address], "Networker already exists for chosen address")
	self._addresses[address] = self

	self.queue = {}
end

function Networker:send(dest, bytes)
	logging.debug("%s sending to %s: %s", self.address, logging.explode(dest), bytes)

	local networker = self._addresses[dest]
	assert(networker, "Could not find destination address")

	table.insert(networker.queue, { self.address, bytes })
end

function Networker:recv()
	while #self.queue == 0 do
		coroutine.yield()
	end

	return table.unpack(table.remove(self.queue, 1))
end

return Networker