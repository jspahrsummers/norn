require("busted.runner")()

local tohex = require("norn.tohex")

describe("tohex", function ()
	it("should do nothing for empty string", function ()
		assert.are.equal(tohex(""), "")
	end)

	it("should return hex for one byte", function ()
		assert.are.equal(tohex("a"), "61")
	end)

	it("should return hex for multiple bytes", function ()
		assert.are.equal(tohex("Aa?"), "41613f")
	end)
end)