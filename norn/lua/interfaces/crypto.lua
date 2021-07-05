local M = {}

function M.hash(...)
	assert(false, "crypto.hash is unimplemented")
	return nil
end

function M.generate_private_key()
	assert(false, "crypto.generate_private_key is unimplemented")
	return nil
end

function M.public_key(public_or_private_key)
	assert(false, "crypto.public_key is unimplemented")
	return nil
end

function M.sign(private_key, ...)
	assert(false, "crypto.sign is unimplemented")
	return nil
end

function M.verify(public_or_private_key, signature, ...)
	assert(false, "crypto.verify is unimplemented")
	return false
end

function M.serialize_public_key(public_key)
	assert(false, "crypto.serialize is unimplemented")
	return nil
end

function M.deserialize_public_key(public_key_string)
	assert(false, "crypto.deserialize is unimplemented")
	return nil
end

return M