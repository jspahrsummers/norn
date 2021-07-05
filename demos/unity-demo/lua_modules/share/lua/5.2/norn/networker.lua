--- Abstract interface, uninstantiable and meant to be implemented by the embedding application.
local Networker = {}
Networker.__index = Networker

--- Sends the given byte string to the destination address (which is treated as opaque to the library).
-- Networking errors should raise a Lua error.
function Networker:send(dest, bytes)
	assert(false, "Networker:send must be implemented in a concrete class")
	return
end

--- Blocks until data is available, then returns the sender's address and the data to the caller.
-- Networking errors should raise a Lua error.
function Networker:recv()
	assert(false, "Networker:recv must be implemented in a concrete class")
	return nil, nil
end

return Networker