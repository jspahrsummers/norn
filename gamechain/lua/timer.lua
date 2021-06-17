local M = {}

local Clock = require("gamechain.clock")

function M.once(seconds, f, clock)
	if not clock then
		clock = Clock.os()
	end

	local start_time = clock:now()
	return coroutine.create(function ()
		while clock:diff_seconds(clock:now(), start_time) < seconds do
			coroutine.yield()
		end

		f()
	end)
end

function M.every(seconds, f, clock)
	if not clock then
		clock = Clock.os()
	end

	local start_time = clock:now()
	return coroutine.create(function ()
		local fired = 0

		while true do
			local current_time = clock:now()
			local should_have_fired = math.floor(clock:diff_seconds(current_time, start_time) / seconds)

			if fired >= should_have_fired then
				coroutine.yield()
			else
				repeat
					fired = fired + 1
					f()

					-- If the timer fires as fast as possible (i.e., zero seconds), we still want to yield between invocations
					coroutine.yield()
				until fired >= should_have_fired
			end
		end
	end)
end

return M