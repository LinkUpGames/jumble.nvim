local M = {
	---@type string[] The themes that the user wants to keep
	themes = {},

	---@type DateOpts The date options
	timeoptions = {
		months = 0,
		years = 0,
		minutes = 0,
		hours = 0,
	},

	---@type function The callback function
	callback = function() end,
}

---The themes to save
---@param themes string[] The themes to save
function M.save_theme_state(themes)
	M.themes = themes
end

---The timeoptions to save
---@param timeoptions DateOpts The options to save
function M.save_timeoptions_state(timeoptions)
	M.timeoptions = timeoptions
end

---Save the callback theme to call when the theme changes
---@param callback function The callback function
function M.save_callback(callback)
	M.callback = callback
end

---@return table M Save options to a seperate table
return M
