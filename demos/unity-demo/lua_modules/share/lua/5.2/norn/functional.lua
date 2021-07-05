local M = {}

function M.count_keys(tbl)
	local count = 0

	for k, v in pairs(tbl) do
		count = count + 1
	end

	return count
end

function M.find(tbl, predicate)
	for k, v in pairs(tbl) do
		if predicate(k, v) then
			return k, v
		end
	end

	return nil
end

function M.find_all(tbl, predicate)
	local results = {}
	for k, v in pairs(tbl) do
		if predicate(k, v) then
			results[k] = v
		end
	end

	return results
end

return M