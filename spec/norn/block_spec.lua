require("busted.runner")()

local Block = require("norn.block")
local date = require("date")
local hash = require("norn.hash")
local PrivateKey = require("norn.privatekey")
local tohex = require("norn.tohex")

describe("block", function ()
	local keys

	setup(function ()
		keys = {}
		for i = 1, 10 do
			keys[i] = PrivateKey()
		end
	end)

	it("should not instantiate without a timestamp", function ()
		local proposed = {
			data = "foobar",
		}

		assert.has_error(function () Block.compute_hash(proposed) end)
		assert.has_error(function () Block(proposed) end)
	end)

	it("should not instantiate without data", function ()
		local proposed = {
			timestamp = date(true),
		}

		assert.has_error(function () Block.compute_hash(proposed) end)
		assert.has_error(function () Block(proposed) end)
	end)

	it("should not instantiate without a hash", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
		}

		assert.has_no.errors(function () Block.compute_hash(proposed) end)
		assert.has_error(function () Block(proposed) end)
	end)

	it("should not instantiate with an invalid hash", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
			hash = hash("fuzzbuzz"),
		}

		assert.has_error(function () Block(proposed) end)
	end)

	it("should not instantiate without signatures", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
		}

		proposed.hash = Block.compute_hash(proposed)
		assert.has_error(function () Block(proposed) end)
	end)

	it("should instantiate when minimum is provided", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
		}

		proposed.hash = Block.compute_hash(proposed)
		proposed.signatures = { keys[1]:sign(proposed.hash) }
		assert.are.same(Block(proposed), proposed)
	end)

	it("should compare equal to itself", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
		}

		proposed.hash = Block.compute_hash(proposed)
		proposed.signatures = { keys[1]:sign(proposed.hash) }

		local block = Block(proposed)
		assert.are.equal(block, block)
	end)

	it("should not compare equal to different block", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
		}

		proposed.hash = Block.compute_hash(proposed)
		proposed.signatures = { keys[1]:sign(proposed.hash) }
		local a = Block(proposed)

		proposed = {
			timestamp = date(true),
			data = "fuzzbuzz",
		}

		proposed.hash = Block.compute_hash(proposed)
		proposed.signatures = { keys[1]:sign(proposed.hash) }
		local b = Block(proposed)

		assert.are_not.equal(a, b)
	end)

	it("should instantiate when additional signatures are provided", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
		}

		proposed.hash = Block.compute_hash(proposed)

		local signatures = {}
		for i, key in ipairs(keys) do
			signatures[i] = key:sign(proposed.hash)
		end

		proposed.signatures = signatures
		assert.are.same(Block(proposed), proposed)
	end)

	it("should instantiate when previous hash is provided", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
			previous_hash = hash("fuzzbuzz")
		}

		proposed.hash = Block.compute_hash(proposed)
		proposed.signatures = { keys[1]:sign(proposed.hash) }
		assert.are.same(Block(proposed), proposed)
	end)

	it("should hash idempotently", function ()
		local a = {
			timestamp = date("2020-01-01"),
			data = "foobar",
		}

		assert.are.equal(Block.compute_hash(a), Block.compute_hash(a))
	end)

	it("should include timestamp in hash", function ()
		local a = {
			timestamp = date("2020-01-01"),
			data = "foobar",
		}

		local b = {
			timestamp = date("2019-12-12"),
			data = "foobar",
		}

		assert.are_not.equal(Block.compute_hash(a), Block.compute_hash(b))
	end)

	it("should include data in hash", function ()
		local a = {
			timestamp = date("2020-01-01"),
			data = "foobar",
		}

		local b = {
			timestamp = date("2020-01-01"),
			data = "fuzzbuzz",
		}

		assert.are_not.equal(Block.compute_hash(a), Block.compute_hash(b))
	end)

	it("should include previous hash in hash", function ()
		local a = {
			timestamp = date("2020-01-01"),
			data = "foobar",
		}

		local b = {
			timestamp = date("2020-01-01"),
			data = "foobar",
			previous_hash = hash("fuzzbuzz")
		}

		assert.are_not.equal(Block.compute_hash(a), Block.compute_hash(b))
	end)

	it("should verify when all signers are found", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
		}

		proposed.hash = Block.compute_hash(proposed)

		local signatures = {}
		for i, key in ipairs(keys) do
			signatures[i] = key:sign(proposed.hash)
		end

		proposed.signatures = signatures
		local block = Block(proposed)
		assert.is_true(block:verify_signers(keys))
	end)

	it("should verify when many except one signers are found", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
		}

		proposed.hash = Block.compute_hash(proposed)

		local signatures = {}
		for i, key in ipairs(keys) do
			if i > 1 then
				signatures[i] = key:sign(proposed.hash)
			end
		end

		proposed.signatures = signatures
		local block = Block(proposed)
		assert.is_true(block:verify_signers(keys))
	end)

	it("should fail to verify when no signers are found", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
		}

		proposed.hash = Block.compute_hash(proposed)

		local unknown_key = PrivateKey()
		proposed.signatures = { unknown_key:sign(proposed.hash) }

		local block = Block(proposed)
		assert.is_false(block:verify_signers(keys))
		assert.is_false(block:verify_signers({ keys[1] }))
	end)

	it("should fail to verify when only one of many signers is found", function ()
		local proposed = {
			timestamp = date(true),
			data = "foobar",
		}

		proposed.hash = Block.compute_hash(proposed)
		proposed.signatures = { keys[1]:sign(proposed.hash) }

		local block = Block(proposed)
		assert.is_false(block:verify_signers(keys))
		assert.is_true(block:verify_signers({ keys[1] }))
	end)
end)