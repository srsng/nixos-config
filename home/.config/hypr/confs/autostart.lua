-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function()
  -- 壁纸
  hl.exec_cmd("swaybg -i ~/nixos-config/wallpapers/sg.png")

  -- bar
  hl.exec_cmd("waybar")
  --   hl.exec_cmd("hyprpaper")

  -- 通知
  hl.exec_cmd("mako")

  -- 权限弹窗
  hl.exec_cmd("/run/current-system/sw/libexec/polkit-gnome-authentication-agent-1")

  -- 托盘
  hl.exec_cmd("nm-applet")      -- 网络
  hl.exec_cmd("blueman-applet") -- 蓝牙

  -- -- 磁盘自动挂载
  hl.exec_cmd("udiskie --tray")

  -- 剪贴板历史
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")

  -- 自动息屏/锁屏
  hl.exec_cmd("hypridle")
end)
