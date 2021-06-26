require("busted.runner")()

local Clock = require("norn.clock")

describe("OS clock", function ()
	local c
	before_each(function ()
		c = Clock.os()
	end)

	it("should instantiate", function ()
		assert.not_nil(c)
	end)

	it("should return current time", function ()
		local t1 = c:now()
		assert.not_nil(t1)

		local t2 = os.time()
		assert.is_true(os.difftime(t2, t1) >= 0)
	end)

	it("should return time difference", function ()
		local t1 = c:now()
		assert.not_nil(t1)

		local t2 = c:now()
		assert.not_nil(t2)

		assert.is_true(c:diff_seconds(t2, t1) >= 0)
	end)
end)

describe("virtual clock", function ()
	local c
	before_each(function ()
		c = Clock.virtual()
	end)

	it("should instantiate", function ()
		assert.not_nil(c)
	end)

	it("should return current time", function ()
		local t1 = c:now()
		assert.equals(t1, 0)

		c.current_time = 5

		local t2 = c:now()
		assert.equals(t2, 5)
	end)

	it("should return time difference", function ()
		c.current_time = 2

		local t1 = c:now()
		assert.equals(t1, 2)

		c.current_time = 5

		local t2 = c:now()
		assert.equals(t2, 5)

		assert.equals(c:diff_seconds(t2, t1), 3)
	end)

	it("should advance current time", function ()
		c:advance(1)
		assert.equals(c:now(), 1)
		c:advance(3)
		assert.equals(c:now(), 4)
		c:advance(2)
		assert.equals(c:now(), 6)
	end)
end)