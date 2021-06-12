local Block = {}
Block.__index = Block

local date = require("date")
local hash = require("gamechain.hash")
local tohex = require("gamechain.tohex")

setmetatable(Block, {
	__call = function (cls, obj, ...)
		local self = setmetatable(obj or {}, cls)
		self:init(...)
		return self
	end,
})

function Block:init()
	assert(self.data, "Block must have data")
	assert(self.key, "Block must have a key to sign or verify with")

	if self.hash then
		assert(self.timestamp, "Block is missing a timestamp")
		assert(self.hash == hash(self:_hashables()), "Block initialized hash does not match computed hash")
		assert(self.key:verify(self.signature, self:_hashables()), "Block signature is invalid")
	else
		assert(not self.signature, "Block signature should not be present if hash is missing")

		if not self.timestamp then
			-- UTC time
			self.timestamp = date(true)
		end

		self.hash = hash(self:_hashables())
		self.signature = self.key:sign(self:_hashables())
	end

	assert(self.hash, "Block is missing a hash")
	assert(self.signature, "Block is missing a signature")
end

function Block:_hashables()
	return self.timestamp:fmt("${iso}"), self.previous_hash or "", self.data
end

function Block:__tostring()
	return string.format("%s: %s", self.timestamp, tohex(self.hash))
end

return Block