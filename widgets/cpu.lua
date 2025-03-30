local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local cpu_widget = wibox.widget({
  id = "cpu",
  widget = wibox.widget.textbox,
  text = "CPU: 0%",
})

local function update_cpu(widget)
  awful.spawn.easy_async({ "sh", "-c", "grep 'cpu ' /proc/stat" }, function(stdout)
    local user, nice, system, idle = stdout:match("cpu%s+(%d+)%s+(%d+)%s+(%d+)%s+(%d+)")
    user, nice, system, idle = tonumber(user), tonumber(nice), tonumber(system), tonumber(idle)
    local total = user + nice + system + idle

    if widget.last_total then
      local diff_idle = idle - widget.last_idle
      local diff_total = total - widget.last_total
      local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
      widget.text = string.format("CPU: %.1f%%", diff_usage)
    end

    widget.last_total = total
    widget.last_idle = idle
  end)
end

gears.timer({
  timeout = 1,
  autostart = true,
  callback = function()
    update_cpu(cpu_widget)
  end,
})

return cpu_widget
