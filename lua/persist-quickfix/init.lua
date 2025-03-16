--- @class PersistQuickfix
local M = {}
local Utils = require("persist-quickfix.utils")

local function default_selector(items, callback)
	vim.ui.select(items, {}, function(item)
		if not item then
			return
		end
		callback(item)
	end)
end

--- @class PersistQuickfix.Config
--- @field storage_dir string|nil The directory where quickfix files are stored.
M.config = {
	storage_dir = vim.fn.stdpath("data") .. "/persist-quickfix",
	selector = default_selector,
}

--- Save the current quickfix list.
--- @param name string  The name of the quickfix list to save.
--- @return nil
function M.save(name)
	local filepath = M.config.storage_dir .. "/" .. name

	local qflist = vim.fn.getqflist()
	qflist = Utils.convert_bfnumbers_to_paths(qflist)
	local json = vim.fn.json_encode(qflist)
	local file, err = io.open(filepath, "w")
	if not file then
		vim.notify(
			"Error opening file for writing quickfix: " .. err,
			vim.log.levels.ERROR
		)
		return
	end
	file:write(json)
	file:close()
	vim.notify("Quickfix list saved as " .. name, vim.log.levels.INFO)
end

--- Load a quickfix list.
--- @param name string  The name of the quickfix list to load.
--- @return nil
function M.load(name)
	local filepath = M.config.storage_dir .. "/" .. name

	local file, err = io.open(filepath, "r")
	if not file then
		vim.notify(
			"Error opening quickfix file for reading: " .. err,
			vim.log.levels.ERROR
		)
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
		vim.notify(
			"Failed to decode quickfix list from JSON.",
			vim.log.levels.ERROR
		)
	end
end

function M.choose()
	local ok, stored_lists = Utils.list_stored_lists(M.config.storage_dir)

	if not ok then
		return
	end

	M.config.selector(stored_lists, M.load)
end

--- Setup persist-quickfix with user options.
--- @param opts PersistQuickfix.Config|nil A table containing user configuration.
--- @return nil
function M.setup(opts)
	M.config = vim.tbl_deep_extend("keep", opts or {}, M.config)
	vim.fn.mkdir(M.config.storage_dir, "p")
end

return M
