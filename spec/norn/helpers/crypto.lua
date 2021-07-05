crypto = {}
crypto._private_key_num = -1

function crypto.hash(...)
	return table.concat({ ... }, "_")
end

function crypto.generate_private_key()
	local num = crypto._private_key_num
	crypto._private_key_num = num - 1
	return num
end

function crypto.public_key(public_or_private_key)
	if public_or_private_key < 0 then
		return -public_or_private_key
	else
		return public_or_private_key
	end
end

function crypto.sign(private_key, ...)
	assert(private_key < 0, "Expected negative number for a private key")
	return table.concat({ private_key, ... }, "*")
end

function crypto.verify(public_or_private_key, signature, ...)
	local private_key
	if public_or_private_key < 0 then
		private_key = public_or_private_key
	else
		private_key = -public_or_private_key
	end

	return crypto.sign(private_key, ...) == signature
end

function crypto.serialize_public_key(public_key)
	return tostring(public_key)
end

function crypto.deserialize_public_key(public_key_string)
	return tonumber(public_key_string)
end