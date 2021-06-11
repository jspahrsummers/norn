local Block = require("Block")

local Blockchain = {}
Blockchain.__index = Blockchain

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
		if i > 1 then
			assert(v.previous_hash == blocks[i - 1].hash, "Blockchain is invalid")
		end
	end

	self.blocks = blocks
end

function Blockchain:__tostring()
	s = "Blockchain:"
	for _, v in ipairs(self.blocks) do
		s = s .. "\n" .. tostring(v)
	end

	return s
end

return Blockchain