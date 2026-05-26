{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."illogical-impulse/installed_true" = {
    source = config.lib.file.mkOutOfStoreSymlink ./illogical-impulse/installed_true;
  };
  xdg.configFile."illogical-impulse/installed_listfile" = {
    source = config.lib.file.mkOutOfStoreSymlink ./illogical-impulse/installed_listfile;
  };
}
