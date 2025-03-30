local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local volume_widget = wibox.widget({
	id = "volume",
	widget = wibox.widget.textbox,
	text = "Vol: 0%",
})

local function update_volume(widget)
	awful.spawn.easy_async({ "amixer", "sget", "Master" }, function(stdout)
		local volume = stdout:match("(%d?%d?%d)%%")
		volume = tonumber(volume)
		widget.text = "Vol: " .. volume .. "%"
	end)
end

volume_widget:buttons(awful.util.table.join(
	awful.button({}, 1, function()
		awful.spawn("amixer -q sset Master toggle")
		update_volume(volume_widget)
	end),
	awful.button({}, 4, function()
		awful.spawn("amixer -q sset Master 5%+")
		update_volume(volume_widget)
	end),
	awful.button({}, 5, function()
		awful.spawn("amixer -q sset Master 5%-")
		update_volume(volume_widget)
	end),
	awful.button({ modkey }, 113, function()
		awful.spawn("amixer -q sset Master 5%-")
		update_volume(volume_widget)
	end),
	awful.button({ modkey }, 114, function()
		awful.spawn("amixer -q sset Master 5%+")
		update_volume(volume_widget)
	end)
))

gears.timer({
	timeout = 1,
	autostart = true,
	callback = function()
		update_volume(volume_widget)
	end,
})

return volume_widget
