local path = vim.fn.stdpath("data") .. "/jumble/"

local M = {
	-- Temporary lock file
	lock = path .. "lock",
	-- Colorscheme file
	colorscheme = path .. "colorscheme",
	-- Date Formats
	dateformat = "%Y-%m-%d:%H:%M",
	datematch = "(%d+)-(%d+)-(%d+):(%d+):(%d+)",
	timestampformat = "%d-%02d-%02d:%02d:%02d",
}

---@return table M All file names, dates and formats to use
return M
