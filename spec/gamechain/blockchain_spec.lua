require("busted.runner")()

local Block = require("gamechain.block")
local Blockchain = require("gamechain.blockchain")
local date = require("date")
local hash = require("gamechain.hash")
local PrivateKey = require("gamechain.privatekey")

describe("blockchain", function ()
	local privkey
	setup(function ()
		privkey = PrivateKey()
	end)

	local function create_block(data, prev_hash)
		local proposed = {
			timestamp = date(true),
			data = data,
			previous_hash = prev_hash,
		}

		proposed.hash = Block.compute_hash(proposed)
		proposed.signatures = { privkey:sign(proposed.hash) }
		return Block(proposed)
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
		local second = create_block("fuzzbuzz", hash("foobar"))
		assert.has_error(function () Blockchain { second } end)
	end)

	it("should fail to initialize with invalid chain", function ()
		local first = create_block("foobar")
		local second = create_block("fuzzbuzz", first.hash)
		local third = create_block("blahblah", first.hash)
		assert.has_error(function () Blockchain { first, second, third } end)
	end)
end)