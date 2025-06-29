---@class Date
---@field year number The year
---@field month number The month
---@field day number The day
---@field hour number The hour
---@field minute number The minute

---@class Options
---@field years number The number of years after the initial date
---@field months number The number of months after the initial date
---@field days number The number of days
---@field hours number The number of hours
---@field minutes number The number of minutes

local M = {
	opts = {},
	next_date = "",
}

-- File for colorscheme
local colordirectory = vim.fn.stdpath("data") .. "/jumble/"

-- Date Format
local date_format = "%Y-%m-%d:%H:%M"
local date_match = "(%d+)-(%d+)-(%d+):(%d+):(%d+)"
local timestamp_format = "%d-%02d-%02d:%02d:%02d"

---Ensure that the directory is create
---@param directory string The directory to create
function M.ensure_directory(directory)
	local stat = (vim.uv or vim.loop).fs_stat(directory)

	if not stat then
		vim.uv.fs_mkdir(directory, 493)
	end
end

---Get a list of all colorschemes
---@return string[] colors All colorschemes in neovim
function M.get_colorschemes()
	local colors = vim.fn.getcompletion("", "color")

	return colors
end

---Save the colorscheme and date to a file
---@param colorscheme string
---@param date string
---@return boolean true if the file was successfully saved
function M.save_file(colorscheme, date)
	-- Check if the directory exists
	M.ensure_directory(colordirectory)

	-- Open file
	local file = io.open(colordirectory .. "colorscheme", "w+")

	if file then
		file:write(colorscheme, "\n")
		file:write(date, "\n")
		file:close()

		M.next_date = date

		return true
	end

	return false
end

---Load the colorscheme and the date to the file
---@return {colorscheme: string, date: string} data The data
function M.load_file()
	local table = {
		colorscheme = "",
		date = "",
	}

	local file = io.open(colordirectory .. "colorscheme", "r")

	if file then
		local colorscheme, date = file:read("*l"), file:read("*l")

		table.colorscheme = colorscheme
		table.date = date
	end

	return table
end

---Parse the date as a string "yyyy-mm-dd:HH:MM", returns a table with the year, month and day
---@param date_string string
---@return {year: number, month: number, day:number, hour:number, minute:number} values Returns the year, month and day as a value
function M.parse_date(date_string)
	local year, month, day, hour, minute = date_string:match(date_match)

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

---Compare two different dates to verify that they are different
---@param current Date
---@param saved Date
---@return boolean verify The current date is larger than the previous date
function M.date_change(current, saved)
	local current_milliseconds = os.time({
		year = current.year,
		month = current.month,
		day = current.day,
		hour = current.hour,
		min = current.minute,
	})
	local saved_milliseconds = os.time({
		year = saved.year,
		month = saved.month,
		day = saved.day,
		hour = saved.hour,
		min = saved.minute,
	}) or 0

	return current_milliseconds >= saved_milliseconds
end

---Returns a random colorscheme from the theme table
---@param themes table<string> themes to randomly pick from
---@return string theme The theme to use
function M.random_theme(themes)
	local i = math.random(os.time()) % #themes
	i = i == 0 and #themes or i

	return themes[i]
end

---Get a colorscheme from the table that does not match the one provided
---@param themes table<string>
---@param colorscheme string
---@return string new_theme The new theme
function M.get_truly_random(themes, colorscheme)
	local newcolorscheme

	repeat
		newcolorscheme = M.random_theme(themes)
	until colorscheme ~= newcolorscheme

	return newcolorscheme
end

---Create the date object for the next time that the function should fire
---@param current Date
---@param opts Options
---@return string date The date to save in "yyyy-mm-dd" format
function M.next_time(current, opts)
	-- Update the next time to change the color scheme
	local milliseconds = os.time({
		year = current.year + opts.years,
		month = current.month + opts.months,
		day = current.day + opts.days,
		hour = current.hour + opts.hours,
		min = current.minute + opts.minutes,
	})

	local date = os.date("*t", milliseconds)

	local timestamp = string.format(timestamp_format, date.year, date.month, date.day, date.hour, date.min)

	return timestamp
end

---Notify that the colorscheme has changed and will be updated the following date
---@param colorscheme string The colorscheme
---@param date string The date
function M.notify_change(colorscheme, date)
	local message = string.format("Colorscheme updated to %s.\nNext update will happen on %s", colorscheme, date)

	vim.notify(message, 0)
end

---Randomize the colorscheme
---@param colorscheme string The current colorscheme
function M.randomize(colorscheme)
	local themes = M.opts.themes

	---@type Options
	local opts = {
		days = M.opts.days,
		years = M.opts.years,
		months = M.opts.months,
		hours = M.opts.hours,
		minutes = M.opts.minutes,
	}

	local newtheme = M.get_truly_random(themes, colorscheme)
	local date = M.parse_date(tostring(os.date(date_format)))
	local newdate = M.next_time(date, opts)

	M.save_file(newtheme, newdate)

	vim.cmd("colorscheme " .. newtheme)

	M.notify_change(newtheme, newdate)
end

---Get a random theme from the list of themes we want
---@param opts opts The options passed down by the user
function M.get_theme(opts)
	-- Keep record of colorschemes
	M.opts = opts

	local colorscheme
	local date = M.parse_date(tostring(os.date(date_format)))

	---@type Options
	local dateoptions = {
		days = opts.days,
		years = opts.years,
		months = opts.months,
		hours = opts.hours,
		minutes = opts.minutes,
	}

	local newdate = M.next_time(date, dateoptions)
	M.next_date = newdate

	-- Check whether there is a timestamp file saved
	local data = M.load_file()

	if data.date ~= nil and data.date ~= "" then -- Save file exists
		local savedcolorscheme = data.colorscheme
		local saveddate = M.parse_date(data.date)

		if M.date_change(date, saveddate) then
			-- Use random colorscheme
			colorscheme = M.get_truly_random(opts.themes, savedcolorscheme)

			-- Update the new time
			M.save_file(colorscheme, newdate)
			M.notify_change(colorscheme, newdate)
		else
			colorscheme = savedcolorscheme
		end
	else
		colorscheme = M.random_theme(opts.themes)

		-- Update the new time
		M.save_file(colorscheme, newdate)

		M.notify_change(colorscheme, newdate)
	end

	-- Set the colorscheme
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			vim.cmd("colorscheme " .. colorscheme)
		end,
	})

	-- Ensure the callback
	if opts.live_change then
		M.update_colorscheme()
	end
end

---The amount of time left before the next color switch is due based on the date passed
---@return number milliseconds The time in milliseconds before the next update
function M.time_to_next()
	-- Setup the dates
	local next = M.parse_date(M.next_date)

	-- Epoch
	local nowepoch = os.time()
	local nextepoch =
		os.time({ year = next.year, month = next.month, day = next.day, hour = next.hour, min = next.minute })

	local milliseconds = math.abs(nextepoch - nowepoch) * 1000

	return milliseconds
end

---Update the colorscheme automatically by using a callback after the amount of time has passed
function M.update_colorscheme()
	local timeleft = M.time_to_next()
	local limit = 24 * 60 * 60 * 1000

	if timeleft > 0 and timeleft < limit then
		vim.defer_fn(function()
			M.randomize(vim.g.colors_name)

			M.update_colorscheme()
		end, timeleft)
	end
end

--- @return table M
return M
