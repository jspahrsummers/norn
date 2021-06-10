local M = {}
local digest = require("openssl.digest")

function M.hash(s)
	d = digest.new("sha256")
	return d:final(s)
end

return M