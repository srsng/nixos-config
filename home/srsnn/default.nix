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
  ];

  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    # ".config/hypr" = {
    #   source = config.lib.file.mkOutOfStoreSymlink ./.config/hypr;
    #   # source = ./.config/hypr;
    #   recursive = true;
    # };

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  home.sessionVariables = {
    EDITOR = "code";
  };

  # # programs.foot = {
  # #   enable = true;
  # #   font = {
  # #     name = "Sarasa Mono SC";
  # #     size = 12;
  # #   };
  # # };

  programs.home-manager.enable = true;
}
