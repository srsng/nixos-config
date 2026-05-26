{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.Kvantum = {
    source = config.lib.file.mkOutOfStoreSymlink ./Kvantum;
  };
}
