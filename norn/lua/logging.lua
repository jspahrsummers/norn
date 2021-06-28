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

local LoggableTable = {}
LoggableTable.__index = LoggableTable

function M.explode(tbl)
	if type(tbl) ~= "table" then
		return tbl
	end

	local meta = getmetatable(tbl)
	if meta and meta.__tostring then
		return tbl
	end

	local tbl_copy = setmetatable({}, LoggableTable)
	for k, v in pairs(tbl) do
		tbl_copy[M.explode(k)] = M.explode(v)
	end

	return tbl_copy
end

local function quoted_tostring(v)
	if type(v) == "string" then
		return string.format("%q", v)
	else
		return tostring(v)
	end
end

local function indent(s)
	return string.gsub(s, "\n", "\n\t")
end

function LoggableTable:__tostring()
	if not next(self) then
		return "{}"
	end

	local s = "{"
	for k, v in pairs(self) do
		s = s .. string.format("\n\t[%s] = %s", indent(quoted_tostring(k)), indent(quoted_tostring(v)))
	end

	return s .. "\n}"
end

return M