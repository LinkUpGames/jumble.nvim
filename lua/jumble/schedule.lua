local file = require("jumble.file")
local theme = require("jumble.theme")
local date = require("jumble.date")

local M = {}

---The main instance is responsible for changing the colorscheme
---@param themes table<string> The themes circulating
---@param options DateOpts The options to pass down for scheduling a colorscheme change
function M.schedule_colorscheme_change(themes, options)
	-- Keep track of the current theme and the next date
	local currenttheme = theme.new_theme(themes, "")
	local nextdate = date.update_time(date.time_now()) -- Set this to the next date of change

	-- Get date and colorscheme from file
	local content = file.get_theme()

	-- Make sure that the file exists
	if content then
		currenttheme = content.colorscheme
		nextdate = content.date
	end

	-- Change Colorscheme and update the time left
	local newtheme = theme.new_theme(themes, currenttheme)
	local milliseconds = date.time_left(nextdate)

	-- Get the next date and save it now that we have a reference
	-- to the other one on file
	nextdate = date.update_time(nextdate, options)

	-- Create the scheduler for the colorscheme change
	vim.defer_fn(function()
		file.save_theme(newtheme, nextdate)

		M.schedule_colorscheme_change(themes, options)
	end, milliseconds)
end

---@return table M Scheduling methods for this
return M
