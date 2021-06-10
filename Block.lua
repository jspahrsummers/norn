local Block = {}
Block.__index = Block

local date = require("date")
local hash = require("hash")
local tohex = require("tohex")

setmetatable(Block, {
	__call = function (cls, obj, ...)
		local self = setmetatable(obj or {}, cls)
		self:init(...)
		return self
	end,
})

function Block:init()
	assert(self.data)
	assert(self.key)

	if self.hash then
		assert(self.hash == hash(self:_hashables()))
		assert(self.key:verify(self.signature, self:_hashables()))
	else
		assert(not self.signature)

		if not self.timestamp then
			-- UTC time
			self.timestamp = date(true)
		end

		self.hash = hash(self:_hashables())
		self.signature = self.key:sign(self:_hashables())
	end

	assert(self.timestamp)
	assert(self.hash)
	assert(self.signature)
end

function Block:_hashables()
	return self.timestamp:fmt("${iso}"), self.previous_hash or "", self.data
end

function Block:__tostring()
	return string.format("%s: %s", self.timestamp, tohex(self.hash))
end

return Block