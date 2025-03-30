local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

-- Create the bluetooth widget
local bluetooth_widget = wibox.widget({
    id = "bluetooth",
    widget = wibox.widget.textbox,
    text = "󰂯", -- Default icon (bluetooth off)
})

-- Function to update bluetooth status
local function update_bluetooth_status(widget)
    awful.spawn.easy_async({ "bluetoothctl", "show" }, function(stdout)
        if stdout:match("Powered: yes") then
            widget.text = "󰂯" -- Bluetooth on icon
        else
            widget.text = "󰂲" -- Bluetooth off icon
        end
    end)
end

-- Function to toggle bluetooth
local function toggle_bluetooth()
    awful.spawn.easy_async({ "bluetoothctl", "show" }, function(stdout)
        if stdout:match("Powered: yes") then
            awful.spawn("bluetoothctl power off")
        else
            awful.spawn("bluetoothctl power on")
        end
        update_bluetooth_status(bluetooth_widget)
    end)
end

-- Function to show bluetooth devices menu
local function show_bluetooth_devices()
    awful.spawn.easy_async({ "bluetoothctl", "devices" }, function(stdout)
        local devices = {}
        for device in stdout:gmatch("Device ([%w:]+) ([^\n]+)") do
            table.insert(devices, { device[1], device[2] })
        end

        if #devices == 0 then
            naughty.notify({
                title = "Bluetooth",
                text = "No devices found",
                timeout = 3,
            })
            return
        end

        local menu_items = {}
        for _, device in ipairs(devices) do
            table.insert(menu_items, {
                device[2],
                function()
                    awful.spawn("bluetoothctl connect " .. device[1])
                    naughty.notify({
                        title = "Bluetooth",
                        text = "Connecting to " .. device[2],
                        timeout = 3,
                    })
                end,
            })
        end

        awful.menu({
            items = menu_items,
            theme = { width = 200 },
        }):show()
    end)
end

-- Add click events to the widget
bluetooth_widget:buttons(gears.table.join(
    awful.button({}, 1, function() -- Left click to toggle bluetooth
        toggle_bluetooth()
    end),
    awful.button({}, 3, function() -- Right click to show devices menu
        show_bluetooth_devices()
    end)
))

-- Update bluetooth status every 5 seconds
gears.timer({
    timeout = 5,
    autostart = true,
    callback = function()
        update_bluetooth_status(bluetooth_widget)
    end,
})

-- Initial update
update_bluetooth_status(bluetooth_widget)

return bluetooth_widget
