{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.xdg-desktop-portal = {
    source = config.lib.file.mkOutOfStoreSymlink ./xdg-desktop-portal;
  };
}
