{
  config,
  pkgs,
  inputs,
  myvars,
  ...
}:
{
  # Note: The following generate files under ~/.config/fontconfig/conf.d/
  # fontconfig may rely on this to properly find fonts installed via Nix.
  fonts.fontconfig.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
      kdePackages.xdg-desktop-portal-kde
    ];
    # The following seems to generate ~/.config/xdg-desktop-portal conflicting with the one under dots/
    #config.hyprland = {
    #  default = [ "hyprland" "gtk" ];
    #  "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
    #};
  };

  imports = [
    ./ii-quickshell.nix
    ./ii-python.nix

    ../../.config/quickshell.nix
    ../../.config/illogical-impulse.nix
    ../../.config/chrome-flags.nix
    ../../.config/code-flags.nix
    ../../.config/darklyrc.nix
    ../../.config/dolphinrc.nix
    ../../.config/fish.nix
    ../../.config/fontconfig.nix
    ../../.config/fuzzel.nix
    ../../.config/kde-material-you-colors.nix
    ../../.config/kdeglobals.nix
    ../../.config/kitty.nix
    ../../.config/konsolerc.nix
    ../../.config/Kvantum.nix
    ../../.config/matugen.nix
    ../../.config/mpv.nix
    ../../.config/starship.nix
    ../../.config/thorium-flags.nix
    ../../.config/wlogout.nix
    ../../.config/xdg-desktop-portal.nix
    ../../.config/zshrc.d.nix

    ../../.local/ii-icons.nix
    ../../.local/konsole.nix
  ];
}
