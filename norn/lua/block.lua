local Block = {}
Block.__index = Block

local basexx = require("basexx")
local consensus = require("norn.consensus")
local date = require("date")
local hash = require("norn.hash")
local tohex = require("norn.tohex")

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
	assert(self.signatures, "Block must have signatures from forging validators")
	assert(#self.signatures > 0, "Block must have signatures from forging validators")
end

function Block.forge(proposed)
	if not proposed.timestamp then
		proposed.timestamp = date(true)
	end

	if not proposed.hash then
		proposed.hash = Block.compute_hash(proposed)
	end

	assert(proposed.keys, "Keys must be provided to sign block to be forged")
	assert(#proposed.keys > 0, "Keys must be provided to sign block to be forged")
	assert(not proposed.signatures, "Block to be forged should not be signed yet")

	proposed.signatures = {}
	for _, key in pairs(proposed.keys) do
		table.insert(proposed.signatures, key:sign(proposed.hash))
	end

	proposed.keys = nil
	return Block(proposed)
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

function Block.from_network_representation(tbl)
	local signatures = {}
	for _, sig in pairs(tbl.signatures) do
		table.insert(signatures, basexx.from_base64(sig))
	end

	return Block {
		timestamp = date(tbl.timestamp),
		data = tbl.data,
		hash = basexx.from_hex(tbl.hash),
		previous_hash = tbl.previous_hash and basexx.from_hex(tbl.previous_hash) or nil,
		signatures = signatures,
	}
end

function Block:network_representation()
	local encoded_signatures = {}
	for _, sig in pairs(self.signatures) do
		table.insert(encoded_signatures, basexx.to_base64(sig))
	end

	return {
		timestamp = self.timestamp:fmt("${iso}"),
		data = self.data, -- should be JSON-encoded already
		hash = string.lower(basexx.to_hex(self.hash)),
		previous_hash = self.previous_hash and string.lower(basexx.to_hex(self.hash)) or nil,
		signatures = encoded_signatures,
	}
end

function Block:__eq(other)
	if not (self.hash == other.hash and self.timestamp == other.timestamp and self.previous_hash == other.previous_hash and self.data == other.data) then
		return false
	end

	if #self.signatures ~= #other.signatures then
		return false
	end

	for i, sig in ipairs(self.signatures) do
		if self.signatures[i] ~= other.signatures[i] then
			return false
		end
	end

	return true
end

function Block:__tostring()
	return string.format("%s: %s", self.timestamp, tohex(self.hash))
end

return Block