local utils = require("jumble.utils")
local theme = require("jumble.theme")

---@class DateOpts
---@field days number | nil The number of days before the new theme rolls over
---@field months number The number of months before the new theme rolls over
---@field years number The number of years before the new theme rolls over
---@field hours number The number of hours before the new theme rolls over
---@field minutes number The number of minutes before the new theme rolls over

---@class Opts: DateOpts
---@field themes table<string> The themes to include for randomizing (empty will default to all colorschemes)
---@field live_change boolean Whether the theme should change live after the given time period is fulfilled

---@class Date
---@field day number
---@field month number
---@field year number
---@field minute number
---@field hour number

-- Local Options for plugin
---@type Opts
local options = {
	days = 1,
	months = 0,
	years = 0,
	hours = 0,
	minutes = 0,
	live_change = false,
	themes = theme.get_all_themes(), -- The themes to rotate for (empty means all)
}

-- Module Definition
local M = {}

---@param opts? Opts options
function M.setup(opts)
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end

	utils.init(options)
end

--- @return table
return M
