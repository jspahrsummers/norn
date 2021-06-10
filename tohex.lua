local M = {}
setmetatable(M, {
	__call = function (cls, ...)
		return cls.tohex(...)
	end,
})

function M.tohex(b)
	local s = string.gsub(b, "(.)", function (x) return string.format("%.1x", string.byte(x)) end)
	return s
end

return M