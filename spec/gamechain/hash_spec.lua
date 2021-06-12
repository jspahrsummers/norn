require("busted.runner")()

local hash = require("gamechain.hash")

describe("hash", function ()
	it("should produce a 32-byte hash", function ()
		local h = hash("foobar")
		assert.are.same(#h, 32)
	end)

	it("consistently hashes the same value", function ()
		assert.are.same(hash("foobar"), hash("foobar"))
	end)

	it("should hash different data differently", function ()
		assert.are_not.same(hash("foobar"), hash("fuzzbuzz"))
	end)
end)