---@class Date
---@field year number The year
---@field month number The month
---@field day number The day

---@class Opts
---@field years number The number of years after the initial date
---@field months number The number of months after the initial date
---@field days number The number of days

local M = {
	opts = {},
}

-- File for colorscheme
local colordirectory = vim.fn.stdpath("data") .. "/jumble/"

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

---Parse the date as a string "yyyy-mm-dd", returns a table with the year, month and day
---@param date_string string
---@return {year: number, month: number, day:number} values Returns the year, month and day as a value
function M.parse_date(date_string)
	local year, month, day = date_string:match("(%d+)-(%d+)-(%d+)")

	year = tonumber(year)
	month = tonumber(month)
	day = tonumber(day)

	local values = {
		year = year,
		month = month,
		day = day,
	}

	return values
end

---Compare two different dates to verify that they are different
---@param current Date
---@param saved Date
---@return boolean verify The current date is larger than the previous date
function M.date_change(current, saved)
	local current_milliseconds = os.time({ year = current.year, month = current.month, day = current.day })
	local saved_milliseconds = os.time({ year = saved.year, month = saved.month, day = saved.day })

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
---@param opts Opts
---@return string date The date to save in "yyyy-mm-dd" format
function M.next_time(current, opts)
	-- Update the next time to change the color scheme
	local milliseconds = os.time({ year = current.year, month = current.month, day = current.day })
	local date = os.date("*t", milliseconds)

	date.day = date.day + opts.days
	date.month = date.month + opts.months
	date.year = date.year + opts.years

	local timestamp = string.format("%d-%02d-%02d", date.year, date.month, date.day)

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

	local opts = {
		days = M.opts.days,
		years = M.opts.years,
		months = M.opts.months,
	}

	local newtheme = M.get_truly_random(themes, colorscheme)
	local date = M.parse_date(tostring(os.date("%Y-%m-%d")))
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
	local date = M.parse_date(tostring(os.date("%Y-%m-%d")))
	local dateoptions = {
		days = opts.days,
		years = opts.years,
		months = opts.months,
	}
	local newdate = M.next_time(date, dateoptions)

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
end

--- @return table M
return M
