local basexx = require("basexx")

local M = {}
setmetatable(M, {
	__call = function (cls, ...)
		return cls.tohex(...)
	end,
})

function M.tohex(b)
	return string.lower(basexx.to_hex(b))
end

return M