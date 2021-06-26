local M = {}

function M.approved(obj)
	assert(obj.agreed >= 0 and obj.disagreed >= 0, "Expected positive integers for agreement/disagreement")
	return obj.agreed > 0 and obj.agreed >= obj.disagreed * 2
end

return M