secure_hash = require("secure_hash")

function tohex(b)
	local s = string.gsub(b, "(.)", function (x) return string.format("%.1x", string.byte(x)) end)
	return s
end

print(tohex(secure_hash.hash("foobar")))