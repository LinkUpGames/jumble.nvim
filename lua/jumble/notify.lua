local date = require("jumble.date")

local M = {}

---Get a better date to show when the theme will change
---@param timestamp string The date as a formatter tring
local time_left = function(timestamp)
	local granularity = "year"
	local duration = 0
	local milliseconds = date.time_left(timestamp)
	local timeleft = date.duration(milliseconds)

	-- Get the time left
	if timeleft.years > 0 then
		duration = timeleft.years
		granularity = "year"
	elseif timeleft.months > 0 then
		duration = timeleft.months
		granularity = "month"
	elseif timeleft.days > 0 then
		duration = timeleft.days
		granularity = "day"
	elseif timeleft.hours > 0 then
		duration = timeleft.hours
		granularity = "hour"
	elseif timeleft.minutes > 0 then
		duration = timeleft.minutes
		granularity = "minute"
	elseif timeleft.seconds > 0 then
		granularity = "second"
		duration = timeleft.seconds
	end

	local message = string.format("%d %s%s", duration, granularity, duration > 1 and "s" or "")

	return message
end

---Notify a theme change
---@param theme string The current theme that was applied
---@param timestamp string The date in string format to apply
function M.notify_theme_change(theme, timestamp)
	local message = time_left(timestamp)
	local value = string.format("Theme updated to %s. \nNext update will happen %s", theme, message)

	vim.notify(value, vim.log.levels.INFO)
end

---@return table notify The notification api
return M
