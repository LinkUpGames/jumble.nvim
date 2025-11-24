local lock = require("jumble.lock")
local watch = require("jumble.watch")
local schedule = require("jumble.schedule")
local file = require("jumble.file")
local theme = require("jumble.theme")

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

	-- Try to get the lock and check based on that
	lock.handle_lock_acquisition(function()
		schedule.schedule_colorscheme_change(themes, timeoptions)
	end)

	-- Watch for changes
	watch.watch_lock()
	watch.watch_colorscheme()

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

--- @return table M
return M
