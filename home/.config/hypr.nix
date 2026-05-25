{
  config,
  ...
}:
{
  xdg.configFile.hypr = {
    source = config.lib.file.mkOutOfStoreSymlink ./hypr;
  };
}
