{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.kde-material-you-colors = {
    source = config.lib.file.mkOutOfStoreSymlink ./kde-material-you-colors;
  };
}
