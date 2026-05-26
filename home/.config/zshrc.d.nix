{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."zshrc.d" = {
    source = config.lib.file.mkOutOfStoreSymlink ./zshrc.d;
  };
}
