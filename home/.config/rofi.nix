{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [ rofi ];

  xdg.configFile.rofi = {
    source = config.lib.file.mkOutOfStoreSymlink ./rofi;
    recursive = true;
  };
}
