{
  config,
  pkgs,
  inputs,
  myvars,
  ...
}:

{
  programs.home-manager.enable = true;
  home.username = myvars.user.name;
  home.homeDirectory = "/home/${myvars.user.name}";
  home.stateVersion = "25.11";

  imports = [
    # personal
    ./pkgs
    ./dconf.nix
    ./shell.nix
    ./terminal.nix
    ./direnv.nix
    ./bat.nix
    ./browser.nix
    # ./xdg-mimes.nix

    # desktop-shell
    ./desktop-shell/ii-dotfiles.nix

    # public
    ../.config/hypr.nix
    ../.config/rofi.nix
    # ../.config/fastfetch.nix
  ];

  home.sessionVariables = {
    EDITOR = myvars.user.editor;
    VISUAL = myvars.user.visual;
    SUDO_EDITOR = myvars.user.sudo_editor;
  };  
}
