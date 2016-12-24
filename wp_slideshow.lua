WallpaperSlide = {}
WallpaperSlide.__index = WallpaperSlide

function WallpaperSlide:new( basedir, align ,interval )
  local obj = {}
  setmetatable(obj, WallpaperSlide)
  obj.basedir = basedir                    -- Set wallpaper scanning basedir
  obj.align = align                        -- Send to gears.wallpaper
  obj.timer = timer({timeout=interval})    -- Set timer
  obj.handle = require('gears').wallpaper  -- Wallpaper handle
  obj.target = screen                      -- 
  obj.notifier = require('naughty').notify -- notify handle
  obj:scandir()
  return obj
end

function WallpaperSlide:scandir()
  local i, t, popen = 0, {}, io.popen
  for filename in popen("find " .. self.basedir .. " -name \"*.jpg\" -or -name \"*.png\""):lines() do
    i = i + 1
    t[i] = filename
  end
  self.wp_list = t
end

function WallpaperSlide:nextWallpaper()

    if #self.wp_list <= 0 then
      return 0
    end

    -- get random index
    self.wp_index = math.random( 1, #self.wp_list)

    for s = 1, screen.count() do
      self.handle[self.align](self.wp_list[self.wp_index], s)
    end

    self.notifier({text = self.wp_list[self.wp_index]})
    os.execute(table.concat({
      "gsettings",
      "set",
      "org.cinnamon.desktop.background",
      "picture-uri",
      "'file://" ..
      self.wp_list[self.wp_index],
      }, " ").."'")

end

function WallpaperSlide:run()
  self.notifier({text = "Wallpaper Slide Started"})
  self.notifier({text = "Current Timeout is " .. self.timer.timeout .. " seconds."})
  self.notifier({text = #self.wp_list .. " wallpapers in queue."})

  self.timer:connect_signal("timeout", function()
    self:nextWallpaper()
  end)

  self.timer:start()
end
