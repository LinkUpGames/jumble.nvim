local constants = require("jumble.constants")

local M = {}

---Ensure that the directory is created
---@param directory string The directory to create
function M.ensure_directory(directory)
	local stat = (vim.uv or vim.loop).fs_stat(directory)

	if not stat then
		vim.uv.fs_mkdir(directory, 493)
	end
end

---Check the colorscheme file
---@return {colorscheme: string, date: string}|nil content The colorscheme and the date, nil if does not exist
function M.get_theme()
	M.ensure_directory(constants.path)

	local content = nil

	local path = constants.get_colorscheme_path()
	local file = io.open(path, "r")

	if file then
		local colorscheme, date = file:read("*l"), file:read("*l")

		content = {
			colorscheme = colorscheme,
			date = date,
		}

		file:close()
	end

	return content
end

---Check the lock
---@return number|nil pid The pid that is in the lock file
function M.get_lock()
	M.ensure_directory(constants.path)

	local pid = nil

	local path = constants.get_lock_path()
	local file = io.open(path, "r")

	if file then
		pid = file:read("*l")
	end

	return pid
end

---Save the file
---@param theme string The new theme
---@param date string The new data
function M.save_theme(theme, date)
	M.ensure_directory(constants.path)

	local status = false

	local path = constants.get_colorscheme_path()
	local file = io.open(path, "w")

	if file then
		-- Update the file
		file:write(theme, "\n")
		file:write(date, "\n")
		file:close()

		status = true
	end

	return status
end

---Check if the file exists
---@param path string The file path
---@return uv.fs_stat.result | nil exists True if the file exists
function M.file_exists(path)
	local exists = vim.uv.fs_stat(path)

	return exists
end

---@return table M All file related methods
return M
