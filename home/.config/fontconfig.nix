{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."fontconfig/fonts.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink ./fontconfig/fonts.conf;
  };
}
