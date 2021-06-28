local Node = require("norn.node")
local logging = require("norn.logging")
local Wallet = require("norn.wallet")

local DemoNetworker = require("norn.demo.networker")

local main = coroutine.create(function ()
	logging.level = logging.LOG_LEVEL_DEBUG

	local a = DemoNetworker("a")
	local b = DemoNetworker("b")

	a:send(b.address, 5)
	local sender, bytes = b:recv()
	logging.debug("sender: %s", logging.explode(sender))
	logging.debug("bytes: %s", bytes)
	return 0
end)

local success, result
while coroutine.status(main) ~= "dead" do
	success, result = coroutine.resume(main)
	if not success then
		logging.error(debug.traceback(main, result))
		return 1
	end
end

return result