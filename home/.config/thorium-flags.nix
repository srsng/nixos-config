{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.thorium-flags = {
    source = config.lib.file.mkOutOfStoreSymlink ./thorium-flags;
  };
}
