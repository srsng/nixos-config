{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.foot = {
    source = config.lib.file.mkOutOfStoreSymlink ./foot;
  };
}
