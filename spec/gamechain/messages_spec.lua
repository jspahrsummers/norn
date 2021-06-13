require("busted.runner")()

local message = require("gamechain.message")
local opcode = require("gamechain.opcode")

--- Given a module, maps message/opcode keys to the functions used to build them.
local function messages_to_builders(tbl)
	local result = {}
	for key, value in pairs(tbl) do
		if key[1] ~= "_" and key == string.upper(key) then
			local builder = tbl[string.lower(key)]
			result[value] = builder
		end
	end

	return result
end

describe("messages", function ()
	local all_messages

	setup(function ()
		all_messages = messages_to_builders(message)
	end)

	it("should create tables", function ()
		for m, b in pairs(all_messages) do
			assert.is.table(b(), string.format("Message %s did not return a table", m))
		end
	end)

	it("should include the message as the first value", function ()
		for m, b in pairs(all_messages) do
			local value = b()
			assert.are.equal(value[1], m, string.format("Value {%s} does not include message key %s", table.concat(value, ", "), m))
		end
	end)

	it("should encode and decode", function ()
		for m, b in pairs(all_messages) do
			local original = b()
			assert.are.same(message.decode(message.encode(original)), original)
		end
	end)
end)

describe("opcodes", function ()
	local all_opcodes

	setup(function ()
		all_opcodes = messages_to_builders(opcode)
	end)

	it("should create tables", function ()
		for m, b in pairs(all_opcodes) do
			assert.is.table(b(), string.format("Opcode %s did not return a table", m))
		end
	end)

	it("should include the opcode as the first value", function ()
		for m, b in pairs(all_opcodes) do
			local value = b()
			assert.are.equal(value[1], m, string.format("Value {%s} does not include opcode %s", table.concat(value, ", "), m))
		end
	end)

	it("should encode and decode", function ()
		for m, b in pairs(all_opcodes) do
			local original = b()
			assert.are.same(opcode.decode(opcode.encode(original)), original)
		end
	end)
end)