local M = {}

---The colorscheme to change this neovim instance to
---@param colorscheme string
function M.change_theme(colorscheme)
	vim.cmd("colorscheme " .. colorscheme)
end

---@return table M Theme functions for color theme changes
return M
