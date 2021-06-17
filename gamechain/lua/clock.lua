local Clock = {}
Clock.__index = Clock

function Clock.os()
	local self = setmetatable({}, Clock)
	self.now = function (self)
		return os.time()
	end

	self.diff_seconds = function (self, t2, t1)
		return os.difftime(t2, t1)
	end

	return self
end

function Clock.virtual()
	local self = setmetatable({}, Clock)
	self.current_time = 0

	self.now = function (self)
		return self.current_time
	end

	self.diff_seconds = function (self, t2, t1)
		return t2 - t1
	end

	self.advance = function (self, delta)
		self.current_time = self.current_time + delta
		return self.current_time
	end

	return self
end

function Clock:now()
	assert(false, "Clock:now must be implemented by concrete clocks")
end

function Clock:diff_seconds(t2, t1)
	assert(false, "Clock:diff_seconds must be implemented by concrete clocks")
end

return Clock