{
  pkgs,
  config,
  lib,
  ...
}:
{
  # 避免HM自行生成 hypr/.luarc.json
  xdg.configFile."hypr/.luarc.json".enable = lib.mkForce false;

  wayland.windowManager.hyprland = {
    # Make sure home-manager not generate ~/.config/hypr/hyprland.conf
    systemd.enable = false;
    configType = "lua";
    plugins = [ ];
    settings = { };
    extraConfig = "";
    enable = true;
    package = pkgs.hyprland;
  };

  xdg.configFile.hypr = {
    source = config.lib.file.mkOutOfStoreSymlink ./hypr;
  };
}
