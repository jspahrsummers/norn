require("spec/norn/helpers/crypto")
require("busted.runner")()

local Wallet = require("norn.wallet")

describe("wallet", function ()
	it("should be created empty", function ()
		local wallet = Wallet.create()
		assert.equals(wallet.balance, 0)
		assert.is_not_nil(wallet.key)
	end)

	it("should be created with private key", function ()
		local key = crypto.generate_private_key()
		local wallet = Wallet { key = key, balance = 5 }
		assert.equals(wallet.balance, 5)
		assert.equals(wallet.key, key)
		assert.equals(wallet:public_key(), crypto.public_key(key))
	end)

	it("should be created with public key", function ()
		local key = crypto.public_key(crypto.generate_private_key())
		local wallet = Wallet { key = key, balance = 5 }
		assert.equals(wallet.balance, 5)
		assert.equals(wallet.key, key)
		assert.equals(wallet:public_key(), key)
	end)

	it("should compare equal to itself", function ()
		local wallet = Wallet.create()
		assert.equals(wallet, wallet)
	end)

	it("should compare equal to itself when re-created", function ()
		local a = Wallet.create()
		local b = Wallet { key = a.key, balance = a.balance }
		assert.equals(a, b)
	end)

	it("should not compare equal to different wallet", function ()
		assert.are_not.equal(Wallet.create(), Wallet.create())
	end)

	it("should sort by balance", function ()
		local a = Wallet {
			key = crypto.generate_private_key(),
			balance = 0,
		}

		local b = Wallet {
			key = crypto.generate_private_key(),
			balance = 15,
		}

		local c = Wallet {
			key = crypto.generate_private_key(),
			balance = -1,
		}

		local wallets = { a, b, c }
		table.sort(wallets)
		assert.are.same(wallets, { c, a, b })
	end)
end)