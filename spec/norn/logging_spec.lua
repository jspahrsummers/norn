require("busted.runner")()

local logging = require("norn.logging")

describe("logging", function ()
	describe("explode", function ()
		it("should stringify empty table", function ()
			local tbl = {}
			local s = tostring(logging.explode(tbl))
			assert.equals(s, "{}")
		end)

		it("should stringify a sequence", function ()
			local tbl = { 2, 4, 6 }
			local s = tostring(logging.explode(tbl))
			assert.equals(s, [[{
	[1] = 2
	[2] = 4
	[3] = 6
}]])
		end)

		it("should sort and quote string keys", function ()
			local tbl = { foo = 5, bar = 10 }
			local s = tostring(logging.explode(tbl))
			assert.equals(s, [[{
	["bar"] = 10
	["foo"] = 5
}]])
		end)

		it("should quote string values", function ()
			local tbl = { "foo", "bar" }
			local s = tostring(logging.explode(tbl))
			assert.equals(s, [[{
	[1] = "foo"
	[2] = "bar"
}]])
		end)

		it("should escape strings", function ()
			local tbl = { ["foo'bar"] = 'fuzz"buzz' }
			local s = tostring(logging.explode(tbl))
			assert.equals(s, [[{
	["foo'bar"] = "fuzz\"buzz"
}]])
		end)

		it("should explode nested tables", function ()
			local tbl = {
				[{ fuzz = "buzz" }] = { "foo", "bar" }
			}
			local s = tostring(logging.explode(tbl))
			assert.equals(s, [[{
	[{
		["fuzz"] = "buzz"
	}] = {
		[1] = "foo"
		[2] = "bar"
	}
}]])
		end)

		it("should call custom __tostring", function ()
			local a = setmetatable({}, {
				__tostring = function (...)
					return "a"
				end
			})

			local b = setmetatable({}, {
				__tostring = function (...)
					return "b"
				end
			})

			local tbl = { [a] = b }
			local s = tostring(logging.explode(tbl))
			assert.equals(s, [[{
	[a] = b
}]])
		end)
	end)
end)