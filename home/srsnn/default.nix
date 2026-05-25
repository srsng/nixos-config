{
  config,
  pkgs,
  inputs,
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
    # ./xdg-mimes.nix

    # public
    ../.config/hypr.nix
    ../.config/rofi.nix
    # ../.config/fastfetch.nix

    # dank-material-shell
    # inputs.dms.homeModules.dank-material-shell
  ];

  home.sessionVariables = {
    EDITOR = myvars.user.editor;
    VISUAL = myvars.user.visual;
    SUDO_EDITOR = myvars.user.sudo_editor;
  };

  programs.home-manager.enable = true;
}
