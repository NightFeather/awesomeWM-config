local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")

local BatteryWidget = {}
BatteryWidget.__index = BatteryWidget

function BatteryWidget:new( battery )
  local obj = {}
  setmetatable(obj, BatteryWidget)

  obj.battery_name = battery

  obj.widget = wibox.widget.textbox()
  obj.tooltip = awful.tooltip({ objects = {obj.widget},})

  obj:update_widget()  

  gears.timer.start_new(1,
            function()
                obj:update_widget()
                obj:update_tooltip()
                return true
            end
         )

  return obj

end

function BatteryWidget:update_widget()
  a = {}

  bat_cap  = self:read_info("capacity")
  bat_stat = self:read_info("status")
  
  if bat_stat:find("Full") then
    mark = "*"
  elseif bat_stat:find("Discharging") then
    mark = "-"
  else
    mark = "+"
  end

  table.insert(a," [ ")
  table.insert(a, string.format("%3d%%", bat_cap))
  table.insert(a, mark)
  table.insert(a, " ] ")
  self.widget:set_text(table.concat(a))
end

function BatteryWidget:update_tooltip()
  a = {}

  bat_current = tonumber(self:read_info("current_now")) / 1000
  bat_voltage = tonumber(self:read_info("voltage_now")) / 1000000
  bat_design_full = tonumber(self:read_info("charge_full_design"))
  bat_full = tonumber(self:read_info("charge_full"))

  table.insert(a, string.format("Name:    %6s", self.battery_name))
  table.insert(a, string.format("Voltage: %2.2fV", bat_voltage))

  if bat_current >= 500 then
    table.insert(a, string.format("Current: %2.2fA", bat_current/1000))
  else
    table.insert(a, string.format("Current: %4.0fmA", bat_current))
  end

  table.insert(a, string.format("Health: %2.2f%%", (bat_full / bat_design_full) * 100))

  print({text = table.concat(a, "\n")})
  self.tooltip:set_text(table.concat(a,"\n"))

end

function BatteryWidget:read_info(name)
  handle = io.open('/sys/class/power_supply/' .. self.battery_name .. '/' .. name)
  result = handle:read()
  handle:close()
  return result
end

return BatteryWidget
