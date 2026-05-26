{
  ...
}:
{
  dconf.enable = true;

  # gsettings set org.gnome.desktop.interface color-scheme prefer-dark
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
