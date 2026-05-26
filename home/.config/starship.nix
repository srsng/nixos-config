{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.starship = {
    source = config.lib.file.mkOutOfStoreSymlink ./starship;
  };
}
