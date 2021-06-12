local M = {}

function M.approved(obj)
	assert(obj.agreed and obj.disagreed, "Expected agreement/disagreement counts")
	return obj.agreed >= obj.disagreed * 2
end

return M