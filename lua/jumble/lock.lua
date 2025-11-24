local constants = require("jumble.constants")
local date = require("jumble.date")

local M = {}

---Try acquiring the lock and writing the pid to the file
---@return boolean success True if the lock was aquired by this neovim instance
function M.try_lock()
	local lock = constants.get_lock_path()
	local file = io.open(lock, "r")

	-- Check if the file exists
	if file then
		file:close()
		return false -- Did not get the lock
	end

	-- Acquired lock, write pid to file
	file = io.open(lock, "w")
	if not file then
		return false
	end

	local pid = vim.fn.getpid()

	file:write(pid)
	file:close()

	return true
end

---Get the lock ID (PID) in the file
---@return integer pid The pid of the process that has the lock
function M.lock_id()
	local lock = constants.get_lock_path()

	local file = io.open(lock, "r")

	if not file then
		return -1
	end

	local pid = file:read("*L")

	return pid
end

---Release the lock if this instance can do so
---@return boolean status Whether the file existed and the lock was removed
function M.release_lock()
	local lock = constants.get_lock_path()

	local status = os.remove(lock)

	return status
end

---Schedules a function that tries to make this process a leader by acquiring the lock
---@param try function(acquire: boolean)
function M.acquire_lock(try)
	local milliseconds = date.get_random_milliseconds(0.3, 1)

	vim.defer_fn(function()
		local success = M.try_lock()

		try(success)
	end, milliseconds)
end

---Handle lock acquisition with common setup logic
---@param on_acquired function() Function to call when lock is acquired
function M.handle_lock_acquisition(on_acquired)
	M.acquire_lock(function(acquired)
		if acquired then
			on_acquired()
			-- Set up autocmd to release lock when instance closes
			vim.api.nvim_create_autocmd({ "QuitPre" }, {
				callback = function()
					M.release_lock()
				end,
			})
		end
	end)
end

---@return table M Lock functions for getting the "mutex" lock we want
return M
