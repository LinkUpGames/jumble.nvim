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

---@return table M Save options to a seperate table
return M
