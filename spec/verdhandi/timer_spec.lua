require("busted.runner")()

local Clock = require("verdhandi.clock")
local timer = require("verdhandi.timer")

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

	it("should fire once after interval", function ()
		local c = Clock.virtual()
		local t = timer.once(2, f, c)
		assert.is.equal(fired, 0)

		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 0)

		c:advance(3)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 1)
		assert.is.equal(coroutine.resume(t), false)
		assert.is.equal(fired, 1)

		c:advance(3)
		assert.is.equal(coroutine.resume(t), false)
		assert.is.equal(fired, 1)
	end)

	it("should fire repeatedly after each interval", function ()
		local c = Clock.virtual()
		local t = timer.every(2, f, c)
		assert.is.equal(fired, 0)

		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 0)

		c:advance(3)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 1)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 1)

		c:advance(2)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 2)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 2)

		c:advance(4)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 3)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 4)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 4)

		c:advance(100)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 5)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 6)
		assert.is.equal(coroutine.resume(t), true)
		assert.is.equal(fired, 7)
	end)
end)