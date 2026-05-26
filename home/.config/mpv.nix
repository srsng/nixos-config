{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile.mpv = {
    source = config.lib.file.mkOutOfStoreSymlink ./mpv;
  };
}
