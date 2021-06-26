local Block = require("norn.block")

local Blockchain = {}
Blockchain.__index = function (self, key)
	local idx = tonumber(key)
	if idx then
		return self.blocks[idx]
	else
		return Blockchain[key]
	end
end

setmetatable(Blockchain, {
	__call = function (cls, ...)
		local self = setmetatable({}, cls)
		self:init(...)
		return self
	end,
})

function Blockchain:init(blocks)
	assert(blocks, "Blockchain must be initialized with a list of blocks")

	for i, v in ipairs(blocks) do
		if i == 1 then
			-- TODO: Lift this restriction in future
			assert(not v.previous_hash, "Missing blockchain history")
		else
			assert(v.previous_hash == blocks[i - 1].hash, "Blockchain is invalid")
		end
	end

	self.blocks = blocks
end

function Blockchain:latest_block()
	return self.blocks[#self.blocks]
end

function Blockchain:add_block(block)
	local latest = self:latest_block()
	if latest and block.previous_hash ~= latest.hash then
		return false
	end

	assert(block.timestamp and block.hash and #block.signatures > 0, "Invalid block added to blockchain")
	self.blocks[#self.blocks + 1] = block
	return true
end

--- Iterates over the blockchain, starting with the latest block first.
function Blockchain:traverse_latest()
	local idx = #self.blocks
	return function ()
		local block = self.blocks[idx]
		idx = idx - 1
		return block
	end
end

function Blockchain:__len()
	return #self.blocks
end

function Blockchain:__eq(other)
	if #self.blocks ~= #other.blocks then
		return false
	end

	-- Check for deviations starting with the most recent blocks, because older history is more likely to be shared in common.
	for i = #self.blocks, 1, -1 do
		if self.blocks[i] ~= other.blocks[i] then
			return false
		end
	end

	return true
end

function Blockchain:__tostring()
	s = "Blockchain:"
	for _, v in ipairs(self.blocks) do
		s = s .. "\n" .. tostring(v)
	end

	return s
end

return Blockchain