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
    # Editors and shell basics
    neovim
    emacs

    # Search, navigation and inspection
    ripgrep
    fd # eazy, better find
    fzf
    # jq  # JSON 工具
    # yq-go # YAML 工具
    htop
    btop
    procs
    lsof
    strace

    # Disk and performance helpers
    duf
    dust
    ncdu
    hyperfine
    tealdeer

    # Archive/download/transfer
    aria2
    rsync
    p7zip
    zstd
    localsend

    # Network/debug tools
    dnsutils
    inetutils
    iproute2
    nmap
    netcat-openbsd
    tcpdump
  ];

  # Project-local devShell support: automatically load flake.nix/shell.nix envs.
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
