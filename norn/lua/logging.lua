local M = {}

M.LOG_LEVEL_ERROR = 1
M.LOG_LEVEL_WARNING = 2
M.LOG_LEVEL_DEBUG = 3

M.level = M.LOG_LEVEL_WARNING

function M.error(fmt, ...)
	if M.level >= M.LOG_LEVEL_ERROR then
		io.stderr:write("[ERROR]", string.format(fmt, ...))
	end
end

function M.warning(fmt, ...)
	if M.level >= M.LOG_LEVEL_WARNING then
		io.stderr:write("[WARNING]", string.format(fmt, ...))
	end
end

function M.debug(fmt, ...)
	if M.level >= M.LOG_LEVEL_DEBUG then
		io.stderr:write("[DEBUG]", string.format(fmt, ...))
	end
end

return M