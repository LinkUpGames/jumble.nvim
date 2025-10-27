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
	local next = M.parse_date(date)

	-- Epoch
	local nowepoch = os.time()
	local nextepoch =
		os.time({ year = next.year, month = next.month, day = next.day, hour = next.hour, min = next.minute })

	local milliseconds = math.abs(nextepoch - nowepoch) * 1000

	return milliseconds
end

---@return table M Date functions and methods
return M
