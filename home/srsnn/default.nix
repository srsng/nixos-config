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
    ./direnv.nix
    # public
    ../.config/hypr.nix # hyprland
    ../.config/rofi.nix # rofi
  ];

  home.sessionVariables = {
    EDITOR = "code";
  };

  programs.home-manager.enable = true;
}
