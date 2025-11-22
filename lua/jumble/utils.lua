local lock = require("jumble.lock")
local watch = require("jumble.watch")
local schedule = require("jumble.schedule")

local M = {
	opts = {},
	next_date = "",
	lock = false,
	deferred = nil,
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
	lock.acquire_lock(function(acquired)
		if acquired then
			schedule.schedule_colorscheme_change(themes, timeoptions)
			-- Additionally, if this instance is closed, make sure that we then again, remove the lock file and also re run the acquire lock part
			-- TODO: Add the autocmd to release (delete file) lock when the instance closes
			vim.api.nvim_create_autocmd({ "QuitPre" }, {
				callback = function()
					lock.release_lock()
				end,
			})
		end

		-- Watch for changes
		watch.watch_colorscheme()
	end)
end

--- @return table M
return M
