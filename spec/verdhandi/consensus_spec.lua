require("busted.runner")()

local consensus = require("verdhandi.consensus")

describe("consensus", function ()
	it("should fail without any agreement", function ()
		assert.is_false(consensus.approved { agreed = 0, disagreed = 0})
		assert.is_false(consensus.approved { agreed = 0, disagreed = 99})
	end)

	it("should require at least as much agreement as disagreement", function ()
		assert.is_false(consensus.approved { agreed = 0, disagreed = 1})
		assert.is_false(consensus.approved { agreed = 99, disagreed = 100})
	end)

	it("should succeed with all agreement", function ()
		assert.is_true(consensus.approved { agreed = 1, disagreed = 0})
		assert.is_true(consensus.approved { agreed = 99, disagreed = 0})
	end)

	it("should tolerate at least 1% disagreement", function ()
		assert.is_true(consensus.approved { agreed = 99, disagreed = 1})
	end)
end)