require("spec/norn/helpers/crypto")
require("busted.runner")()

local Block = require("norn.block")
local Blockchain = require("norn.blockchain")
local date = require("date")

describe("blockchain", function ()
	local privkey
	setup(function ()
		privkey = crypto.generate_private_key()
	end)

	local function create_block(data, prev_hash)
		return Block.forge { data = data, previous_hash = prev_hash, keys = { privkey }}
	end

	it("should initialize with no blocks", function ()
		local chain = Blockchain {}
		assert.not_nil(chain)
		assert.is_nil(chain:latest_block())
		assert.equals(#chain, 0)
	end)

	it("should initialize with a single block", function ()
		local first = create_block("foobar")
		local chain = Blockchain { first }
		assert.not_nil(chain)
		assert.equals(chain:latest_block(), first)
		assert.equals(chain[1], first)
		assert.equals(#chain, 1)
	end)

	it("should initialize with multiple blocks", function ()
		local first = create_block("foobar")
		local second = create_block("fuzzbuzz", first.hash)
		local third = create_block("blahblah", second.hash)

		local chain = Blockchain { first, second, third }
		assert.not_nil(chain)
		assert.equals(chain:latest_block(), third)
		assert.equals(chain[1], first)
		assert.equals(chain[2], second)
		assert.equals(chain[3], third)
		assert.equals(#chain, 3)
	end)

	it("should fail to initialize with missing history", function ()
		local second = create_block("fuzzbuzz", crypto.hash("foobar"))
		assert.has_error(function () Blockchain { second } end)
	end)

	it("should fail to initialize with invalid chain", function ()
		local first = create_block("foobar")
		local second = create_block("fuzzbuzz", first.hash)
		local third = create_block("blahblah", first.hash)
		assert.has_error(function () Blockchain { first, second, third } end)
	end)

	it("should compare equal to itself", function ()
		local chain = Blockchain { create_block("foobar") }
		assert.are.equal(chain, chain)
	end)

	it("should not be equal to different chain", function ()
		local a = Blockchain { create_block("foobar") }
		local b = Blockchain { create_block("fuzzbuzz") }
		assert.are_not.equal(a, b)
	end)

	it("should not be equal to different chain with common history", function ()
		local first = create_block("first shared block")
		local a = Blockchain { first, create_block("foobar", first.hash) }
		local b = Blockchain { first, create_block("fuzzbuzz", first.hash) }
		assert.are_not.equal(a, b)
	end)

	it("should traverse latest to oldest", function ()
		local first = create_block("foobar")
		local second = create_block("fuzzbuzz", first.hash)
		local third = create_block("blahblah", second.hash)

		local chain = Blockchain { first, second, third }
		local traversed = {}
		for block in chain:traverse_latest() do
			table.insert(traversed, block)
		end

		assert.not_nil(chain)
		assert.are.same(traversed, { third, second, first })
	end)
end)