local utils = require("jumble.utils")

describe("Unit Tests", function()
	it("Random Theme", function()
		local themes = {
			"a",
			"b",
			"c",
		}

		local colorscheme = utils.random_theme(themes)
		print(colorscheme)
		assert.truthy(colorscheme)
	end)

	it("Parse Date", function()
		local date = "2025-2-20"
		local expected = {
			day = 20,
			month = 2,
			year = 2025,
		}

		local result = utils.parse_date(date)

		assert.are.same(expected, result)
	end)

	it("Date Change", function()
		local current = {
			day = 04,
			year = 2025,
			month = 9,
		}

		local previous = {
			day = 02,
			year = 2025,
			month = 8,
		}

		local result = utils.date_change(current, previous)

		assert.is_true(result)
	end)

	it("Next Time", function()
		local options = {
			days = 2,
			years = 0,
			months = 0,
		}

		local current_time = utils.parse_date("2025-09-04")
		local timestamp = utils.next_time(current_time, options)

		assert.are.equals(timestamp, "2025-09-06")
	end)
end)
