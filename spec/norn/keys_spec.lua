require("busted.runner")()

local PublicKey = require("norn.publickey")
local PrivateKey = require("norn.privatekey")

describe("PrivateKey", function ()
	it("should equal itself", function ()
		local key = PrivateKey()
		assert.are.equal(key, key)
	end)

	it("should always create a unique key", function ()
		local a = PrivateKey()
		local b = PrivateKey()
		assert.are_not.equal(a, b)
	end)

	it("should be serializable to string", function ()
		local key = PrivateKey()
		assert.are.equal(PrivateKey(tostring(key)), key)
	end)

	it("should sign and verify data", function ()
		local key = PrivateKey()
		local sig = key:sign("foobar", "fuzzbuzz")
		assert.is.string(sig)
		assert.is_true(key:verify(sig, "foobar", "fuzzbuzz"))
	end)

	it("should still verify signatures after serialization", function ()
		local key = PrivateKey()
		local sig = key:sign("foobar", "fuzzbuzz")

		key = PrivateKey(tostring(key))
		assert.is_true(key:verify(sig, "foobar", "fuzzbuzz"))
	end)

	it("should fail to verify incorrect data", function ()
		local key = PrivateKey()
		local sig = key:sign("foobar", "fuzzbuzz")
		assert.is_false(key:verify(sig, "fuzzbuzz", "foobar"))
	end)

	it("should fail to verify another key's signature", function ()
		local a = PrivateKey()
		local b = PrivateKey()
		local sig = a:sign("foobar", "fuzzbuzz")
		assert.is_false(b:verify(sig, "foobar", "fuzzbuzz"))
	end)
end)

describe("PublicKey", function ()
	it("should be created from a private key", function ()
		local privkey = PrivateKey()
		local pubkey = privkey:public_key()
		assert.are_not.equal(pubkey, privkey)
	end)

	it("should equal itself", function ()
		local privkey = PrivateKey()
		local pubkey = privkey:public_key()
		assert.are.equal(pubkey, pubkey)
	end)

	it("should return self as a public key", function ()
		local privkey = PrivateKey()
		local pubkey = privkey:public_key()
		assert.are.equal(pubkey, pubkey:public_key())
	end)

	it("should serialize differently than a private key", function ()
		local privkey = PrivateKey()
		local pubkey = privkey:public_key()
		assert.are_not.equal(tostring(pubkey), tostring(privkey))
	end)

	it("should not deserialize into a private key", function ()
		local privkey = PrivateKey()
		local pubkey = privkey:public_key()
		local new_privkey = PrivateKey(pubkey)
		assert.has_error(function () return tostring(new_privkey) end)
		assert.has_error(function () return new_privkey == privkey end)
		assert.has_error(function () return new_privkey:sign("foobar") end)
	end)

	it("should verify private key signatures", function ()
		local privkey = PrivateKey()
		local sig = privkey:sign("foobar", "fuzzbuzz")

		local pubkey = privkey:public_key()
		assert.is_true(pubkey:verify(sig, "foobar", "fuzzbuzz"))
	end)

	it("should still verify private key signatures after serialization", function ()
		local privkey = PrivateKey()
		local sig = privkey:sign("foobar", "fuzzbuzz")

		local pubkey = PublicKey(tostring(privkey:public_key()))
		assert.is_true(pubkey:verify(sig, "foobar", "fuzzbuzz"))
	end)

	it("should fail to verify incorrect data", function ()
		local privkey = PrivateKey()
		local sig = privkey:sign("foobar", "fuzzbuzz")
		
		local pubkey = PublicKey(privkey)
		assert.is_false(pubkey:verify(sig, "fuzzbuzz", "foobar"))
	end)

	it("should fail to verify another key's signature", function ()
		local a = PrivateKey()
		local b = PrivateKey()
		local sig = a:sign("foobar", "fuzzbuzz")

		local pubkey = PublicKey(b)
		assert.is_false(pubkey:verify(sig, "foobar", "fuzzbuzz"))
	end)
end)