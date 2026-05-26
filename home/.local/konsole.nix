{
  config,
  pkgs,
  ...
}:
{
  home.file."./local/share/konsole/Profile 1.profile" = {
    source = config.lib.file.mkOutOfStoreSymlink "./share/konsole/Profile 1.profile";
  };
}
