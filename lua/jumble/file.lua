local constants = require("jumble.constants")

local M = {}

---Check the colorscheme file
---@return {colorscheme: string, date: string}|nil content The colorscheme and the date, nil if does not exist
function M.get_theme()
	local content = nil

	local path = constants.colorscheme
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
	local pid = nil

	local path = constants.lock
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
	-- TODO: Continue from here, add this method then finish schedule colorscheme
	local path = constants.colorscheme
end

---@return table M All file related methods
return M
