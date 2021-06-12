local Block = {}
Block.__index = Block

local consensus = require("gamechain.consensus")
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
	assert(self.timestamp, "Block is missing a timestamp")
	assert(self.data, "Block must have data")
	assert(self.hash == hash(self:_hashables()), "Block initialized hash does not match computed hash")
	assert(#self.signatures > 0, "Block must have signatures from forging producers")
end

function Block:verify_signers(keys_orig)
	local keys_copy = { table.unpack(keys_orig) }
	local found = 0
	for _, signature in self.signatures do
		local matching_idx = nil
		for i, key in keys_copy do
			if key:verify(signature) then
				found = found + 1
				break
			end
		end

		if matching_idx then
			found = found + 1
			table.remove(keys_copy, matching_idx)
		end
	end

	local missing = #keys_copy
	return consensus.approved { agreed = found, disagreed = missing }
end

function Block:_hashables()
	return self.timestamp:fmt("${iso}"), self.previous_hash or "", self.data
end

function Block:__tostring()
	return string.format("%s: %s", self.timestamp, tohex(self.hash))
end

return Block