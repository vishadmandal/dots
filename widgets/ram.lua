local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local ram_widget = wibox.widget({
	id = "ram",
	widget = wibox.widget.textbox,
	text = "RAM: 0%",
})

local function update_ram(widget)
	awful.spawn.easy_async({ "sh", "-c", "free -m | grep Mem" }, function(stdout)
		local total, used = stdout:match("Mem:%s+(%d+)%s+(%d+)")
		total, used = tonumber(total), tonumber(used)
		local percent_used = (used / total) * 100
		widget.text = string.format("RAM: %.1f%%", percent_used)
	end)
end

gears.timer({
	timeout = 1,
	autostart = true,
	callback = function()
		update_ram(ram_widget)
	end,
})

return ram_widget
