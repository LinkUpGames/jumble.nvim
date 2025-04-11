local utils = require("jumble.utils")

---@class opts
---@field days number The number of days before the new theme rolls over
---@field months number The number of months before the new theme rolls over
---@field years number The number of years before the new theme rolls over
---@field hours number The number of hours befoer the new theme rolls over
---@field themes table<string> The themes to include for randomizing (empty will default to all colorschemes)

-- Local Options for plugin
---@type opts
local options = {
	days = 1,
	months = 0,
	years = 0,
	hours = 0,
	themes = utils.get_colorschemes(), -- The themes to rotate for (empty means all)
}

-- Module Definition
local M = {}

---@param opts? opts options
function M.setup(opts)
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end

	utils.get_theme(options)
end

--- @return table
return M
