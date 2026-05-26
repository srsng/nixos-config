{
  config,
  pkgs,
  ...
}:
{
  xdg.configFile."kitty.conf" = {
    source = config.lib.file.mkOutOfStoreSymlink ./kitty/kitty.conf;
  };
  xdg.configFile."scroll_mark.py" = {
    source = config.lib.file.mkOutOfStoreSymlink ./kitty/scroll_mark.py;
  };
  xdg.configFile."search.py" = {
    source = config.lib.file.mkOutOfStoreSymlink ./kitty/search.py;
  };
}
