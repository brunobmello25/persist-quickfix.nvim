--- @class PersistQuickfix
local M = {}
local Utils = require("persist-quickfix.utils")

--- @alias SelectorFunction fun(items: any[], on_choice: fun(item: any|nil): nil): nil

--- @type SelectorFunction
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
--- @field selector SelectorFunction|nil The method use to select items when calling `choose` function. Defaults to `vim.ui.select`
M.config = {
	storage_dir = vim.fn.stdpath("data") .. "/persist-quickfix",
	selector = default_selector,
}

--- Save the current quickfix list.
--- @param name string  The name of the quickfix list to save.
--- @return nil
function M.save(name)
	if not name or name == "" then
		vim.notify(
			"No name provided for quickfix list. Aborting.",
			vim.log.levels.INFO
		)
		return
	end

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

--- Save the quickfix list with the given name.
--- @param name string
--- @return nil
function M.delete(name)
	if not name or name == "" then
		vim.notify(
			"No name provided for quickfix list. Aborting deletion.",
			vim.log.levels.INFO
		)
		return
	end

	local filepath = M.config.storage_dir .. "/" .. name
	local ok, err = os.remove(filepath)
	if not ok then
		vim.notify(
			"Error deleting quickfix file: " .. err,
			vim.log.levels.ERROR
		)
		return
	end
	vim.notify("Quickfix list '" .. name .. "' deleted.", vim.log.levels.INFO)
end

--- Prompt the user to pick a saved quickfix list to delete.
--- @return nil
function M.choose_delete()
	local ok, stored_lists = Utils.list_stored_lists(M.config.storage_dir)

	if not ok then
		vim.notify(
			"failed to list quickfix lists to delete",
			vim.log.levels.WARN
		)
		return
	end

	if #stored_lists == 0 then
		vim.notify("There are no stored lists to delete", vim.log.levels.INFO)
		return
	end

	M.config.selector(stored_lists, M.delete)
end

--- Prompt the user to pick a saved quickfix list to open.
--- @return nil
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

--- Merge two quickfix lists into a new one.
--- @param source1 string The name of the first quickfix list.
--- @param source2 string The name of the second quickfix list.
--- @param target string The name of the resulting merged quickfix list.
--- @return nil
function M.merge(source1, source2, target)
	if not source1 or not source2 or not target then
		vim.notify(
			"Source and target names are required for merging quickfix lists.",
			vim.log.levels.INFO
		)
		return
	end

	local filepath1 = M.config.storage_dir .. "/" .. source1
	local filepath2 = M.config.storage_dir .. "/" .. source2
	local target_filepath = M.config.storage_dir .. "/" .. target

	-- Read first quickfix list
	local file1, err1 = io.open(filepath1, "r")
	if not file1 then
		vim.notify(
			"Error opening first quickfix file: " .. err1,
			vim.log.levels.ERROR
		)
		return
	end
	local json1 = file1:read("*a")
	file1:close()
	local qflist1 = vim.fn.json_decode(json1)

	-- Read second quickfix list
	local file2, err2 = io.open(filepath2, "r")
	if not file2 then
		vim.notify(
			"Error opening second quickfix file: " .. err2,
			vim.log.levels.ERROR
		)
		return
	end
	local json2 = file2:read("*a")
	file2:close()
	local qflist2 = vim.fn.json_decode(json2)

	-- Merge the lists
	local merged_list = {}
	for _, item in ipairs(qflist1) do
		table.insert(merged_list, item)
	end
	for _, item in ipairs(qflist2) do
		table.insert(merged_list, item)
	end

	-- Save the merged list
	local json = vim.fn.json_encode(merged_list)
	local target_file, err = io.open(target_filepath, "w")
	if not target_file then
		vim.notify(
			"Error saving merged quickfix list: " .. err,
			vim.log.levels.ERROR
		)
		return
	end
	target_file:write(json)
	target_file:close()
	vim.notify(
		string.format(
			"Successfully merged '%s' and '%s' into '%s'",
			source1,
			source2,
			target
		),
		vim.log.levels.INFO
	)
end

--- Rename a quickfix list.
--- @param old_name string The current name of the quickfix list.
--- @param new_name string The new name for the quickfix list.
--- @return nil
function M.rename(old_name, new_name)
	if not old_name or not new_name then
		vim.notify(
			"Both old and new names are required for renaming a quickfix list.",
			vim.log.levels.INFO
		)
		return
	end

	if old_name == new_name then
		vim.notify(
			"The new name is the same as the old name. No changes made.",
			vim.log.levels.INFO
		)
		return
	end

	local old_filepath = M.config.storage_dir .. "/" .. old_name
	local new_filepath = M.config.storage_dir .. "/" .. new_name

	-- Check if the old file exists
	local file, err = io.open(old_filepath, "r")
	if not file then
		vim.notify(
			"Error: Quickfix list '" .. old_name .. "' does not exist: " .. err,
			vim.log.levels.ERROR
		)
		return
	end
	file:close()

	-- Check if the new name already exists
	file, err = io.open(new_filepath, "r")
	if file then
		file:close()
		vim.notify(
			"Error: A quickfix list with the name '" .. new_name .. "' already exists.",
			vim.log.levels.ERROR
		)
		return
	end

	-- Rename the file
	local ok, err = os.rename(old_filepath, new_filepath)
	if not ok then
		vim.notify(
			"Error renaming quickfix list: " .. err,
			vim.log.levels.ERROR
		)
		return
	end

	vim.notify(
		string.format(
			"Successfully renamed quickfix list from '%s' to '%s'",
			old_name,
			new_name
		),
		vim.log.levels.INFO
	)
end

return M
