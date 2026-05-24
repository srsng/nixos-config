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

  # home.packages = with pkgs; [
  #   localsend

  #   foot
  #   waybar
  #   wofi
  #   mako

  #   wl-clipboard
  #   grim
  #   slurp
  #   swappy

  #   hyprpaper
  #   hyprlock
  #   hypridle

  #   pavucontrol
  #   networkmanagerapplet
  # ];

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

  xdg.configFile.hypr = {
      source = config.lib.file.mkOutOfStoreSymlink ./.config/hypr;
      recursive = true;
    };

  home.sessionVariables = {
    EDITOR = "code";
  };

  # programs.git = {
  #   enable = true;
  #   userName = myvars.user.fullname;
  #   userEmail = myvars.user.email;
  # };

  # # programs.foot = {
  # #   enable = true;
  # #   font = {
  # #     name = "Sarasa Mono SC";
  # #     size = 12;
  # #   };
  # # };

  programs.bash = {
    enable = true;
    shellAliases = {
      "ll" = "ls -l";
      "la" = "ls -la";
      ".." = "cd ..";
    };
  };

  programs.home-manager.enable = true;
}