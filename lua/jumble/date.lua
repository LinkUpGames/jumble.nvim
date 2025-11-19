local constants = require("jumble.constants")

local M = {}

---Get a random millisecond time between both the low and high
---@param low number in seconds
---@param high number in seconds
function M.get_random_milliseconds(low, high)
	local pid = vim.fn.getpid()
	local range = { low, high }

	-- Random seed
	math.randomseed(os.time() + pid)

	local randomvalue = math.random()
	local milliseconds = (range[1] + (range[2] - range[1]) * randomvalue) * 1000

	return milliseconds
end

---Parse the date as a string "yyyy-mm-dd", returns a table with the year, month and day
---@param datestring string
---@return {year: number, month: number, day:number, hour:number, minute:number} values Returns the year, month and day as a value
function M.parse_date(datestring)
	local year, month, day, hour, minute = datestring:match(constants.datematch)

	-- Get the time options we want if they exist in the string
	year = tonumber(year or 1) --[[@as number]]
	month = tonumber(month or 1) --[[@as number]]
	day = tonumber(day or 1) --[[@as number]]
	hour = tonumber(hour or 1) --[[@as number]]
	minute = tonumber(minute or 0) --[[@as number]]

	---@type Date
	local values = {
		year = year,
		month = month,
		day = day,
		hour = hour,
		minute = minute,
	}

	return values
end

---Get the time left in milliseconds before the theme turns
---@param date string The next date to check
---@return number milliseconds The milliseconds between now and then
function M.time_left(date)
	if not date or date == "" then
		return 0
	end

	local next = M.parse_date(date)

	-- Epoch
	local nowepoch = os.time()
	local nextepoch =
		os.time({ year = next.year, month = next.month, day = next.day, hour = next.hour, min = next.minute })

	local diff = nextepoch - nowepoch
	local milliseconds = diff > 0 and diff * 1000 or 0

	return milliseconds
end

---Update the time by adding or subtracting from the options provided
---@param date string The date object to modify
---@param opts DateOpts? The date options
---@return string timestamp The new timestamp given the options
function M.update_time(date, opts)
	opts = opts or {}
	local current = M.parse_date(date or "")

	local seconds = os.time({
		year = current.year + (opts.years or 0),
		month = current.month + (opts.months or 0),
		day = current.day + (opts.days or 0),
		hour = current.hour + (opts.hours or 0),
		min = current.minute + (opts.minutes or 0),
	})

	local s = os.date("*t", seconds)
	local timestamp = string.format(constants.timestampformat, s.year, s.month, s.day, s.hour, s.min)

	return timestamp
end

---Get the time now in a formatted date string
---@return string date The current time as a date string formatted to the required parts
function M.time_now()
	local s = os.date("*t", os.time())

	-- Parse the string
	local timestamp = string.format(constants.timestampformat, s.year, s.month, s.day, s.hour, s.min)

	return timestamp
end

---@return table M Date functions and methods
return M
