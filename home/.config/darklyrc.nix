{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.darklyrc = {
    source = config.lib.file.mkOutOfStoreSymlink ./darklyrc;
  };
}
