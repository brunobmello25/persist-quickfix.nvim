local M = {}

--- @param path string
--- @return boolean, table
function M.list_stored_lists(path)
	local items = {}
	local fd = vim.loop.fs_scandir(path)
	if not fd then
		vim.notify("Could not open directory: " .. path, vim.log.levels.ERROR)
		return false, {}
	end

	while true do
		local name, _ = vim.loop.fs_scandir_next(fd)
		if not name then
			break
		end
		table.insert(items, name)
	end

	return true, items
end

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
