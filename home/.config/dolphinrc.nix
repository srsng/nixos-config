{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.dolphinrc = {
    source = config.lib.file.mkOutOfStoreSymlink ./dolphinrc;
  };
}
