{ config, pkgs, ... }:

{
  # Let VS Code Remote-SSH's downloaded server run on NixOS.
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
  ];

  # Development tools. Add things here as you learn/need them.
  environment.systemPackages = with pkgs; [
    # CLI fundamentals
    bash-completion
    file
    htop
    jq
    ripgrep
    tree
    unzip
    zip

    # Nix helpers
    nix-output-monitor
    nixpkgs-fmt

    # GUI/user apps
    vscode
  ];
}
