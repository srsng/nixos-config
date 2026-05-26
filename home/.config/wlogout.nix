{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.wlogout = {
    source = config.lib.file.mkOutOfStoreSymlink ./wlogout;
  };
}
