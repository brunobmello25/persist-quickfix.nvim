local M = {}
local Utils = require("persist-quickfix.utils")

M.config = {
	storage_dir = vim.fn.stdpath("data") .. "/persist-quickfix",
}

--- @param name string  The name of the quickfix to save
--- @return nil
function M.save(name)
	local filepath = M.config.storage_dir .. "/" .. name

	local qflist = vim.fn.getqflist()
	qflist = Utils.convert_bfnumbers_to_paths(qflist)
	local json = vim.fn.json_encode(qflist)
	local file, err = io.open(filepath, "w")
	if not file then
		vim.notify("Error opening file for writing quickfix: " .. err, vim.log.levels.ERROR)
		return
	end
	file:write(json)
	file:close()
	vim.notify("Quickfix list saved as " .. name, vim.log.levels.INFO)
end

--- @param name string  The name of the quickfix to load
--- @return nil
function M.load(name)
	local filepath = M.config.storage_dir .. "/" .. name

	local file, err = io.open(filepath, "r")
	if not file then
		vim.notify("Error opening quickfix file for reading: " .. err, vim.log.levels.ERROR)
		return
	end

	local json = file:read("*a")
	file:close()
	local qflist = vim.fn.json_decode(json)

	if qflist then
		qflist = Utils.convert_filepaths_to_bfnumbers(qflist)
		vim.fn.setqflist(qflist)
		vim.cmd("copen")
		vim.notify("Quickfix list loaded from " .. name, vim.log.levels.INFO)
	else
		vim.notify("Failed to decode quickfix list from JSON.", vim.log.levels.ERROR)
	end
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("keep", opts, M.config)

	vim.fn.mkdir(M.config.storage_dir, "p")
end

return M
