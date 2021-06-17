local M = {}

function M.find(tbl, predicate)
	for k, v in pairs(tbl) do
		if predicate(k, v) then
			return k, v
		end
	end

	return nil
end

return M