require("busted.runner")()

local hash = require("verdhandi.hash")

describe("hash", function ()
	it("should produce a 32-byte hash", function ()
		local h = hash("foobar")
		assert.are.equal(#h, 32)
	end)

	it("should be idempotent", function ()
		assert.are.equal(hash("foobar"), hash("foobar"))
	end)

	it("should hash different data differently", function ()
		assert.are_not.equal(hash("foobar"), hash("fuzzbuzz"))
	end)
end)