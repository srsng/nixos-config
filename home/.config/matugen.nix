{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.matugen = {
    source = config.lib.file.mkOutOfStoreSymlink ./matugen;
  };
}
