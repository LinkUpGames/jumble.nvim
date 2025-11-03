local file = require("jumble.file")
local theme = require("jumble.theme")
local date = require("jumble.date")

local M = {}

---The main instance is responsible for changing the colorscheme
---@param themes table<string> The themes circulating
function M.schedule_colorscheme_change(themes)
	-- Get date and colorscheme from file
	local currenttheme = ""
	local nextdate = "" -- Set this to the next date of change
	local content = file.get_theme()

	-- Make sure that the file exists
	if content then
		currenttheme = content.colorscheme
		nextdate = content.date
	end

	-- Change Colorscheme and update the time left
	local newtheme = theme.new_theme(themes, currenttheme)
	local milliseconds = date.time_left(nextdate)
	-- todo: get the next date update and also change the file for the state
	-- Make sure that if this is the first time than the milliseconds is set to the next time based
	-- on the options, if not then this is just from the file gotten

	-- Save new theme and optsion

	-- Create the scheduler for the colorscheme change
	vim.defer_fn(M.schedule_colorscheme_change(themes, nextdate), milliseconds)
end

---@return table M Scheduling methods for this
return M
