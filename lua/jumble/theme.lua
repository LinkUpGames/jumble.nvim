local M = {}

---The colorscheme to change this neovim instance to
---@param colorscheme string
function M.change_theme(colorscheme)
	vim.cmd("colorscheme " .. colorscheme)
end

---Get a randome theme given a table of themes to go through
---@param themes table<string>
---@return string theme The theme to use
function M.get_random_theme(themes)
	local i = math.random(os.time()) % #themes

	i = i == 0 and #themes or i

	return themes[i]
end

---Get a colorscheme from the table that does not match the one provided
---@param themes table<string>
---@param currenttheme string
---@return string new_theme The new theme
function M.new_theme(themes, currenttheme)
	local newtheme

	repeat
		newtheme = M.get_random_theme(themes)
	until currenttheme ~= newtheme

	return newtheme
end

---Get all themes from neovim
--@return themes string[] The builtin and custom themes
function M.get_all_themes()
	local themes = vim.fn.getcompletion("", "color")

	return themes
end

---Get the name of the current theme in the editor
---@return string theme The name of the theme
function M.get_current_theme()
	return vim.g.colors_name
end

---@return table M Theme functions for color theme changes
return M
