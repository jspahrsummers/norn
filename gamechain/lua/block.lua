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
	assert(self.hash == Block.compute_hash(self), "Block initialized hash does not match computed hash")
	assert(self.signatures, "Block must have signatures from forging producers")
	assert(#self.signatures > 0, "Block must have signatures from forging producers")
end

function Block:verify_signers(keys_orig)
	local keys_copy = { table.unpack(keys_orig) }
	local found = 0
	for _, signature in pairs(self.signatures) do
		local matching_idx = nil
		for i, key in ipairs(keys_copy) do
			if key:verify(signature, self.hash) then
				matching_idx = i
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

function Block.compute_hash(obj)
	assert(obj.timestamp, "Block is missing a timestamp")
	assert(obj.data, "Block must have data")
	return hash(obj.timestamp:fmt("${iso}"), obj.previous_hash or "", obj.data)
end

function Block:__tostring()
	return string.format("%s: %s", self.timestamp, tohex(self.hash))
end

return Block