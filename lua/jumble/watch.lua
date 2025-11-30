local theme = require("jumble.theme")
local schedule = require("jumble.schedule")
local date = require("jumble.date")
local constants = require("jumble.constants")
local file = require("jumble.file")
local lock = require("jumble.lock")
local state = require("jumble.state")
local notify = require("jumble.notify")

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
		local change = events.change or events.rename

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
function M.on_lock_change(err, filename)
	local themes, dateoptions = state.themes, state.timeoptions

	if err or not filename or filename == "" then
		vim.notify("Error checking lockfile for updates: " .. err)

		return
	end

	if filename == constants.lock then
		local exists = file.file_exists(constants.get_lock_path())

		if not exists then
			-- Acquire lock and be the new instance responsible
			lock.handle_lock_acquisition(function()
				schedule.schedule_colorscheme_change(themes, dateoptions)
			end)
		end
	end
end

---Check for the colorscheme file being deleted
---@param err string|nil
---@param filename string
function M.on_theme_deleted(err, filename)
	if err or not filename or filename == "" then
		vim.notify("Error on on_theme_deleted: " .. err)
	end

	if filename == constants.colorscheme then
		local exists = file.file_exists(constants.get_colorscheme_path())
		local colorscheme, dateoptions = state.themes, state.timeoptions

		-- Only update if the file is deleted
		if exists == nil then
			local currenttheme = theme.get_current_theme()
			local newtheme = theme.new_theme(state.themes, currenttheme)
			local nextdate = date.update_time(date.time_now(), dateoptions)

			-- Save the new theme to the saved file for all instances to watch and update
			file.save_theme(newtheme, nextdate)
			notify.notify_theme_change(newtheme, nextdate)

			-- Schedule again
			schedule.schedule_colorscheme_change(colorscheme, dateoptions)
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
function M.watch_lock()
	local fsevent = vim.uv.new_fs_event()

	if fsevent ~= nil then
		fsevent:start(constants.path, {
			change = true,
		}, vim.schedule_wrap(M.on_lock_change))
	end
end

---Watch for any changes when the colorscheme file is deleted
function M.watch_colorscheme_delete()
	local fsevent = vim.uv.new_fs_event()

	if fsevent ~= nil then
		fsevent:start(constants.path, {
			change = false,
		}, vim.schedule_wrap(M.on_theme_deleted))
	end
end

---@return table M Functions for watching changes within file
return M
