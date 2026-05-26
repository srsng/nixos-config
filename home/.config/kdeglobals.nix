{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.kdeglobals = {
    source = config.lib.file.mkOutOfStoreSymlink ./kdeglobals;
  };
}
