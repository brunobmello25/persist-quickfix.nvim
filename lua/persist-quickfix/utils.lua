local M = {}

function M.convert_bfnumbers_to_paths(qflist)
	for _, entry in ipairs(qflist) do
		local bufnr = entry.bufnr
		local path = vim.api.nvim_buf_get_name(bufnr)
		entry.filepath = path
		entry.bufnr = nil
	end

	return qflist
end

function M.convert_filepaths_to_bfnumbers(qflist)
	for _, entry in ipairs(qflist) do
		local path = entry.filepath
		local bufnr = vim.fn.bufadd(path)
		entry.bufnr = bufnr
		entry.filepath = nil
	end

	return qflist
end

return M
