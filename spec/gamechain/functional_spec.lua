require("busted.runner")()

local functional = require("gamechain.functional")

describe("find", function ()
	local tbl = { 3, "foo", ["fuzz"] = "buzz", -1.5, "bar" }

	it("should return nil for always-false predicate", function ()
		local k, v = functional.find(tbl, function (k, v) return false end)
		assert.is_nil(k)
		assert.is_nil(v)
	end)

	it("should return any element for always-true predicate", function ()
		local k, v = functional.find(tbl, function (k, v) return true end)
		assert.is_not_nil(k)
		assert.is_not_nil(v)
		assert.equals(tbl[k], v)
	end)

	it("should return matching element", function ()
		local k, v = functional.find(tbl, function (k, v) return k == "fuzz" and v == "buzz" end)
		assert.equals(k, "fuzz")
		assert.equals(v, "buzz")
	end)

	it("should return one of several matching elements", function ()
		local k, v = functional.find(tbl, function (k, v) return type(v) == "number" end)
		assert.is_not_nil(k)
		assert.is_not_nil(v)
		assert.equals(tbl[k], v)
		assert.is_true(v == 3 or v == -1.5)
	end)
end)

pending("find_all", function ()
end)

pending("count_keys", function ()
end)