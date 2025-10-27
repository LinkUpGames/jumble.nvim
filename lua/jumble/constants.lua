local path = vim.fn.stdpath("data") .. "/jumble/"

local M = {
	-- Temporary lock file
	lock = "lock",
	-- Colorscheme file
	colorscheme = "colorscheme",
	-- Plugin Path
	path = path,
	-- Date Formats
	dateformat = "%Y-%m-%d:%H:%M",
	datematch = "(%d+)-(%d+)-(%d+):(%d+):(%d+)",
	timestampformat = "%d-%02d-%02d:%02d:%02d",
}

function M.get_colorscheme_path()
	return M.path .. M.colorscheme
end

function M.get_lock_path()
	return M.path .. M.lock
end

---@return table M All file names, dates and formats to use
return M
