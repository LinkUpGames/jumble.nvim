local utils = require("jumble.utils")
local constants = require("jumble.constants")
local watch = require("jumble.watch")

local M = {}

---Setup the commands available to the user
function M.commands()
	vim.api.nvim_create_user_command("Jumble", function(cmd)
		if cmd.fargs[1] == "randomize" then
			local colorscheme = vim.g.colors_name

			utils.randomize(colorscheme)
		end
	end, {
		nargs = 1,
		complete = function()
			return { "randomize" }
		end,
		desc = "Randomize the colorscheme on demand",
	})
end

return M
