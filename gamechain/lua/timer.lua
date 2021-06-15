local M = {}

function M.once(seconds, f)
	local start_time = os.time()
	return coroutine.create(function ()
		while os.difftime(os.time(), start_time) < seconds do
			coroutine.yield()
		end

		f()
	end)
end

function M.every(seconds, f)
	local last_fired = os.time() 
	return coroutine.create(function ()
		while true do
			local current_time = os.time()
			while os.difftime(current_time, last_fired) < seconds do
				coroutine.yield()
				current_time = os.time()
			end

			last_fired = current_time
			f()

			-- If the timer fires as fast as possible (i.e., zero seconds), we still want to yield between invocations
			coroutine.yield()
		end
	end)
end

return M