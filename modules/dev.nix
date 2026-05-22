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
    vim
    nano
    neovim
    less
    bash-completion
    which
    file
    tree

    # Search, navigation and inspection
    ripgrep
    fd
    fzf
    bat
    eza
    jq
    yq-go
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
    curl
    wget
    aria2
    rsync
    unzip
    zip
    p7zip
    zstd
    xz

    # Network/debug tools
    dnsutils
    inetutils
    iproute2
    nmap
    netcat-openbsd
    tcpdump

    # Git/GitHub
    git
    git-lfs
    gh

    # Nix helpers
    nix-output-monitor
    nvd
    nix-tree
    nix-diff
    nix-index
    comma
    nh
    nil
    nixd
    nixfmt-rfc-style
    alejandra
    statix
    deadnix

    # Other language/toolchain basics
    shellcheck
    shfmt
    nodejs
    python312.out
    uv
    rustup

    # VS Code with Nix syntax highlighting/LSP support preinstalled.
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        jnoortheen.nix-ide
        mkhl.direnv
        mhutchie.git-graph
        ms-ceintl.vscode-language-pack-zh-hans
      ];
    })

    # temp
    thunar
    swaybg
    vis
  ];

  # Project-local devShell support: automatically load flake.nix/shell.nix envs.
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}
