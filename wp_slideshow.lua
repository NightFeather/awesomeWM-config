-- Origin Version Here: https://gist.github.com/anonymous/9072154f03247ab6e28c

-- scan directory and filter files if filter provided

function scandir(directory)
    local i, t, popen = 0, {}, io.popen
    for filename in popen("find " .. directory .. " -name \"*.jpg\" -or -name \"*.png\""):lines() do
      i = i + 1
      t[i] = filename
    end
    return t
end

function wp_slideshow(handle, target, path, ticker, n)
  local wp_index = 1
  local wp_list = scandir(path)
  local wp_handle = handle
  local wp_target = target
  local wp_notifier = n
  wp_ticker = ticker

  wp_notifier.notify({text = "Wallpaper Slide Started"})
  wp_notifier.notify({text = "Current Timeout is " .. wp_ticker.timeout .. " seconds."})
  wp_notifier.notify({text = #wp_list .. "wallpapers in queue."})

  wp_ticker:connect_signal("timeout", function()

    for s = 1, wp_target.count() do
      wp_handle(wp_list[wp_index], s)
    end

    wp_notifier.notify({text = wp_list[wp_index]})
    os.execute("gsettings set org.cinnamon.desktop.background picture-uri 'file://" .. wp_list[wp_index] .. "'")

 
    -- stop the timer (we don't need multiple instances running at the same time)
--    ticker:stop()
 
    -- get next random index
    wp_index = math.random( 1, #wp_list)
 
    --restart the timer
--    ticker.timeout = wp_timeout
--    ticker:start()
  end)

  wp_ticker:start()

end
