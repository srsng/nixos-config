{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.konsolerc = {
    source = config.lib.file.mkOutOfStoreSymlink ./konsolerc;
  };
}
