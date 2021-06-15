require("busted.runner")()

local timer = require("gamechain.timer")

describe("timer", function ()
	local fired
	local f
	before_each(function ()
		fired = 0
		f = function ()
			fired = fired + 1
		end
	end)

	it("should fire once", function ()
		local t = timer.once(0, f)
		assert.is.equal(fired, 0)

		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 1)
		assert.is.equal(coroutine.resume(t), false)
		assert.is.equal(fired, 1)
	end)

	it("should fire repeatedly", function ()
		local t = timer.every(0, f)
		assert.is.equal(fired, 0)

		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 1)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 2)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 3)
	end)
end)