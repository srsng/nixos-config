{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.fuzzel = {
    source = config.lib.file.mkOutOfStoreSymlink ./fuzzel;
  };
}
