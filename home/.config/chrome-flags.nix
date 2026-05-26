{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.chrome-flags = {
    source = config.lib.file.mkOutOfStoreSymlink ./chrome-flags;
  };
}
