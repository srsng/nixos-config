{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.quickshell = {
    source = config.lib.file.mkOutOfStoreSymlink ./quickshell;
  };
}
