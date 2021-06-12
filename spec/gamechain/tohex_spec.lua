require("busted.runner")()

local tohex = require("gamechain.tohex")

describe("tohex", function ()
	it("should do nothing for empty string", function ()
		assert.are.same(tohex(""), "")
	end)

	it("should return hex for one byte", function ()
		assert.are.same(tohex("a"), "61")
	end)

	it("should return hex for multiple bytes", function ()
		assert.are.same(tohex("Aa?"), "41613f")
	end)
end)