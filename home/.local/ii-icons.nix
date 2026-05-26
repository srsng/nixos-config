{
  config,
  pkgs,
  ...
}:
{
  home.file."./local/share/icons/illogical-impulse.svg" = {
    source = config.lib.file.mkOutOfStoreSymlink ./share/icons/illogical-impulse.svg;
  };
}
