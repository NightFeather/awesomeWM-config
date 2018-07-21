local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")

local BatteryWidget = {}
BatteryWidget.__index = BatteryWidget

function min2hm(mins)
  res = ""
  mins = math.floor(mins/5)*5
  if mins > 90 then
    res = res .. string.format("%2d h ", math.floor(mins / 60))
  end
  res = res .. string.format("%3d m", mins % 60)
  return res
end

function BatteryWidget:new( battery )
  local obj = {}
  setmetatable(obj, BatteryWidget)

  obj.battery_name = battery

  obj.widget = wibox.widget.textbox()
  obj.tooltip = awful.tooltip({ objects = {obj.widget},})

  obj.state = 0

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
    self.state = 2
    mark = "*"
  elseif bat_stat:find("Discharging") then
    self.state = 0
    mark = "-"
  else
    self.state = 1
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
  bat_charge = tonumber(self:read_info("charge_now")) / 1000

  table.insert(a, string.format("Name:    %6s", self.battery_name))
  table.insert(a, string.format("Voltage: %2.2fV", bat_voltage))

  if bat_current >= 500 then
    table.insert(a, string.format("Current: %2.2fA", bat_current/1000))
  else
    table.insert(a, string.format("Current: %4.0fmA", bat_current))
  end

  if self.state == 0 then
    table.insert(a, "Est.D.Time: " .. min2hm( (bat_charge / bat_current) * 60 ))
  elseif self.state == 1 then
    table.insert(a, "Est.C.Time: " .. min2hm( ( (bat_full/1000 - bat_charge) / bat_current) * 60 ))
  elseif self.state == 2 then
    table.insert(a, "Est.D.Time:  N/A")
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
