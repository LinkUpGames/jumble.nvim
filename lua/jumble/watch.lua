local theme = require("jumble.theme")
local schedule = require("jumble.schedule")
local date = require("jumble.date")
local constants = require("jumble.constants")
local file = require("jumble.file")
local lock = require("jumble.lock")

local M = {}

---Update the colorscheme when the colorscheme changes
---@param err string|nil
---@param filename string
---@param events uv.fs_event_start.callback.events
function M.on_theme_change(err, filename, events)
	if err or not filename or filename == "" then
		vim.notify("Error with recieved colorscheme change: " .. err)

		return
	end

	if filename == constants.colorscheme then
		local change = events.change
		local deleted = events.rename

		-- Check for deleted file
		if deleted then
			-- If the file is deleted than the person with the sceduler should trigger a manual change
		end

		-- Changes inside of the file
		if change then
			local milliseconds = date.get_random_milliseconds(0.3, 0.8)

			vim.defer_fn(function()
				local content = file.get_theme()

				if content == nil then
					vim.notify("Could not read file content")

					return
				end

				theme.change_theme(content.colorscheme)
			end, milliseconds)
		end
	end
end

---Check for the current lock file and update it
---@param err string|nil
---@param filename string
---@param events uv.fs_event_start.callback.events
---@param options {themes: string[], timeoptions: DateOpts}
function M.on_lock_change(err, filename, events, options)
	local themes, dateoptions = options.themes, options.timeoptions

	if err or not filename or filename == "" then
		vim.notify("Error checking lockfile for updates: " .. err)

		return
	end

	if filename == constants.lock then
		local deleted = events.rename

		if deleted then
			-- Acquire lock and be the new instance responsible
			lock.handle_lock_acquisition(function()
				schedule.schedule_colorscheme_change(themes, dateoptions)
			end)
		end
	end
end

--- Watch the colorscheme file for any changes
function M.watch_colorscheme()
	local fsevent = vim.uv.new_fs_event()

	if fsevent ~= nil then
		fsevent:start(constants.path, {
			change = true,
		}, vim.schedule_wrap(M.on_theme_change))
	end
end

--- Watch the lock file for any changes
--- Pass along the themes and time options for acquiring the lock again
--- @param themes string[] The themes
--- @param timeoptions DateOpts Date options to pass along
function M.watch_lock(themes, timeoptions)
	local fsevent = vim.uv.new_fs_event()

	if fsevent ~= nil then
		fsevent:start(
			constants.path,
			{
				change = true,
			},
			vim.schedule_wrap(function(err, filename, events)
				M.on_lock_change(err, filename, events, {
					themes = themes,
					timeoptions = timeoptions,
				})
			end)
		)
	end
end

---@return table M Functions for watching changes within file
return M
