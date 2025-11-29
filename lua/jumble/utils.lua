local lock = require("jumble.lock")
local watch = require("jumble.watch")
local schedule = require("jumble.schedule")
local file = require("jumble.file")
local theme = require("jumble.theme")
local date = require("jumble.date")
local state = require("jumble.state")
local constants = require("jumble.constants")

local M = {
	opts = {},
}

---Initialize the plugin
---@param opts Opts
function M.init(opts)
	-- Options
	local themes = opts.themes

	---@type DateOpts
	local timeoptions = {
		days = opts.days,
		hours = opts.hours,
		minutes = opts.minutes,
		months = opts.months,
		years = opts.years,
	}

	-- Save options
	state.save_theme_state(themes)
	state.save_timeoptions_state(timeoptions)

	-- Try to get the lock and check based on that
	lock.handle_lock_acquisition(function()
		schedule.schedule_colorscheme_change(themes, timeoptions)
		watch.watch_colorscheme_delete()
	end)

	-- Watch for changes
	watch.watch_colorscheme()
	watch.watch_lock()

	-- Update theme to that on file
	local content = file.get_theme() or {}
	if content.colorscheme then
		theme.change_theme(content.colorscheme or "")
	end
end

---Get all themes from neovim
---@return string[] themes All themes available
function M.get_all_themes()
	return theme.get_all_themes()
end

---Randomize and select a new random colorscheme
---@param colorscheme string The current theme so that we can avoid it
function M.randomize(colorscheme)
	-- Delete the file so that we retrigger a new theme and also the rescheduler to recompute a new time
	-- before the theme changes again
	file.file_delete(constants.get_colorscheme_path())
end

--- @return table M
return M
