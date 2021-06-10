local M = {}
local digest = require("openssl.digest")

function M.hash(data)
	local d = digest.new("sha256")
	return d:final(data)
end

return M