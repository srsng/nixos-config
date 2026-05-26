{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.code-flags = {
    source = config.lib.file.mkOutOfStoreSymlink ./code-flags;
  };
}
