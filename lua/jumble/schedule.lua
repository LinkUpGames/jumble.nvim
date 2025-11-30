local file = require("jumble.file")
local theme = require("jumble.theme")
local date = require("jumble.date")

local M = {
	-- Reference to the current timer
	theme_change_timer = nil, ---@type table
}

---The main instance is responsible for changing the colorscheme
---@param themes table<string> The themes circulating
---@param options DateOpts The options to pass down for scheduling a colorscheme change
function M.schedule_colorscheme_change(themes, options)
	-- Make sure that if this is called again from an outside function, we remove the previous instance of the timer object
	if M.theme_change_timer ~= nil then
		M.theme_change_timer:stop()
		M.theme_change_timer:close()
		M.theme_change_timer = nil
	end

	-- Get date and colorscheme from file
	local content = file.get_theme()

	-- Keep track of the current theme and the next date
	local currenttheme
	local currentnextdate

	if content then
		-- File exists, use saved values
		currenttheme = content.colorscheme
		currentnextdate = content.date
	else
		-- First time running, get initial theme and set next date
		currenttheme = theme.new_theme(themes, "")
		currentnextdate = date.update_time(date.time_now(), options)

		-- Apply the initial theme immediately on first run
		file.save_theme(currenttheme, currentnextdate)
	end

	-- Change Colorscheme and update the time left
	local newtheme = theme.new_theme(themes, currenttheme)
	local milliseconds = date.time_left(currentnextdate)

	-- Create the scheduler for the colorscheme change
	M.theme_change_timer = vim.defer_fn(function()
		-- Remove Timer reference once it fires
		M.theme_change_timer = nil

		-- Get the next date and save it now that we have a reference
		-- to the other one on file
		local nextdate = date.update_time(date.time_now(), options)

		vim.notify_once(
			string.format("Theme updated to %s.\nNext Update will happen %s.", newtheme, nextdate),
			vim.log.levels.INFO
		)

		file.save_theme(newtheme, nextdate)

		M.schedule_colorscheme_change(themes, options)
	end, milliseconds)
end

---@return table M Scheduling methods for this
return M
