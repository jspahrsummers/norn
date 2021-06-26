local digest = require("openssl.digest")

local M = {}
setmetatable(M, {
	__call = function (cls, ...)
		return M.hash(...)
	end
})

function M.hash(...)
	local d = digest.new("sha256")
	return d:final(...)
end

return M