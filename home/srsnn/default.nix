{
  config,
  pkgs,
  myvars,
  ...
}:

{
  home.username = myvars.user.name;
  home.homeDirectory = "/home/${myvars.user.name}";

  home.stateVersion = "25.11";

  imports = [
    # personal
    ./pkgs
    ./shell.nix
    ./terminal.nix
    ./direnv.nix
    ./bat.nix
    ./browser.nix
    # public
    ../.config/hypr.nix # hyprland
    ../.config/rofi.nix # rofi
  ];

  home.sessionVariables = {
    EDITOR = myvars.user.editor;
    VISUAL = myvars.user.visual;
    SUDO_EDITOR = myvars.user.sudo_editor;
  };

  programs.home-manager.enable = true;
}
