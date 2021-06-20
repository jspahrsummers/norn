require("busted.runner")()

local functional = require("gamechain.functional")

describe("count_keys", function ()
	it("should be zero for an empty table", function ()
		assert.equals(functional.count_keys({}), 0)
	end)

	it("should match length for a sequence", function ()
		local tbl = { "foo", "bar", "buzz" }
		assert.equals(#tbl, 3)
		assert.equals(functional.count_keys(tbl), #tbl)
	end)

	it("should count non-numeric keys", function ()
		local tbl = { "foo", "bar", ["fuzz"] = "buzz", -1.5 }
		assert.equals(#tbl, 3)
		assert.equals(functional.count_keys(tbl), 4)
	end)

	it("should count keys in table without any sequence", function ()
		local tbl = { ["foo"] = "bar", ["fuzz"] = "buzz" }
		assert.equals(#tbl, 0)
		assert.equals(functional.count_keys(tbl), 2)
	end)
end)

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

describe("find_all", function ()
	local tbl = { 3, "foo", ["fuzz"] = "buzz", -1.5, "bar" }

	it("should return empty table for always-false predicate", function ()
		local result = functional.find_all(tbl, function (k, v) return false end)
		assert.is.same(result, {})
	end)

	it("should return all elements for always-true predicate", function ()
		local result = functional.find_all(tbl, function (k, v) return true end)
		assert.is.same(result, tbl)
	end)

	it("should return a single matching element", function ()
		local result = functional.find_all(tbl, function (k, v) return k == "fuzz" and v == "buzz" end)
		assert.is.same(result, { ["fuzz"] = "buzz" })
	end)

	it("should return all of several matching elements", function ()
		local result = functional.find_all(tbl, function (k, v) return type(v) == "number" end)
		assert.is.same(result, { [1] = 3, [3] = -1.5 })
	end)
end)