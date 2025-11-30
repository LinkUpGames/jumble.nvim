local M = {}

---Notify a theme change
---@param theme string The current theme that was applied
---@param date string The date in string format to apply
function M.notify_theme_change(theme, date)
	local value = string.format("Theme updated to %s. \nNext update will happen %s", theme, date)

	vim.notify_once(value, vim.log.levels.INFO)
end

---@return table notify The notification api
return M
